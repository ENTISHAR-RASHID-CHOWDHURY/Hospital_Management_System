/**
 * Developer tools: lets a developer sign in and act as one of the seeded demo
 * users, to try the app in each role.
 *
 * Only mounted when DEVELOPER_MODE=true (see app.ts); env.ts refuses to start
 * with it on in production. Every request must carry the DEVELOPER_PHRASE in
 * the x-developer-phrase header, and only users marked isDemo can be
 * impersonated, never real accounts.
 */
import { timingSafeEqual } from 'crypto';
import { NextFunction, Request, Response, Router } from 'express';
import { z } from 'zod';

import { env } from '../config/env';
import { HOSPITAL_ROLES, HospitalRole } from '../constants/roles';
import { prisma } from '../prisma';
import { AuditLogger } from '../utils/audit-logger';
import { comparePassword, hashPassword } from '../utils/password';
import { signAccessToken, signDeveloperToken, signRefreshToken, verifyDeveloperToken } from '../utils/token';

const router = Router();
const auditLogger = new AuditLogger();

type DevRequest = Request & { developerId?: number };

interface DeveloperSession {
  selectedRole: HospitalRole;
  selectedDemoUserId: number;
  selectedAt: string;
}

// Which demo user each developer is currently acting as. In memory on purpose:
// this is a local development aid, and it resets when the server restarts.
const sessions = new Map<number, DeveloperSession>();

const credentialsSchema = z.object({
  email: z.string().email(),
  password: z.string().min(8),
});
const createAccountSchema = credentialsSchema.extend({
  displayName: z.string().min(1).max(100),
});
const selectRoleSchema = z.object({
  role: z.string().min(1),
  demoUserId: z.union([z.number().int(), z.string()]).nullish(),
});

function fail(res: Response, status: number, error: string) {
  return res.status(status).json({ success: false, error });
}

// The app uses its own role names ('admin', 'laboratory', ...); map them to ours.
const ROLE_ALIASES: Record<string, HospitalRole> = {
  ADMIN: 'SUPER_ADMIN',
  LABORATORY: 'LAB_TECHNICIAN',
  LAB: 'LAB_TECHNICIAN',
};

export function toHospitalRole(role: string): HospitalRole | null {
  const upper = role.trim().toUpperCase();
  if (ROLE_ALIASES[upper]) return ROLE_ALIASES[upper];
  return (HOSPITAL_ROLES as readonly string[]).includes(upper) ? (upper as HospitalRole) : null;
}

function phraseMatches(given: string | undefined): boolean {
  const expected = env.developerPhrase;
  if (!expected || !given) return false;
  const a = Buffer.from(given);
  const b = Buffer.from(expected);
  return a.length === b.length && timingSafeEqual(a, b);
}

function requirePhrase(req: Request, res: Response, next: NextFunction) {
  if (!phraseMatches(req.get('x-developer-phrase'))) {
    return fail(res, 401, 'Missing or invalid developer phrase');
  }
  return next();
}

async function requireDeveloper(req: DevRequest, res: Response, next: NextFunction) {
  const header = req.get('authorization');
  if (!header?.startsWith('Bearer ')) {
    return fail(res, 401, 'Developer login required');
  }
  try {
    const { developerId } = verifyDeveloperToken(header.substring(7));
    const account = await prisma.developerAccount.findUnique({ where: { id: developerId } });
    if (!account) {
      return fail(res, 401, 'Developer account no longer exists');
    }
    req.developerId = developerId;
    return next();
  } catch {
    return fail(res, 401, 'Invalid or expired developer token');
  }
}

router.use(requirePhrase);

// POST /api/developer/accounts/create
router.post('/accounts/create', async (req, res, next) => {
  try {
    const parsed = createAccountSchema.safeParse(req.body);
    if (!parsed.success) return fail(res, 400, 'Email, a password of 8+ characters and a display name are required');
    const { email, password, displayName } = parsed.data;

    if (await prisma.developerAccount.findUnique({ where: { email } })) {
      return fail(res, 409, 'A developer account with this email already exists');
    }
    const account = await prisma.developerAccount.create({
      data: { email, displayName, passwordHash: await hashPassword(password) },
    });
    return res.status(201).json({
      success: true,
      developer: { id: account.id, email: account.email, displayName: account.displayName },
    });
  } catch (error) {
    return next(error);
  }
});

// POST /api/developer/auth/login
router.post('/auth/login', async (req, res, next) => {
  try {
    const parsed = credentialsSchema.safeParse(req.body);
    if (!parsed.success) return fail(res, 400, 'Email and password are required');
    const { email, password } = parsed.data;

    const account = await prisma.developerAccount.findUnique({ where: { email } });
    if (!account || !(await comparePassword(password, account.passwordHash))) {
      return fail(res, 401, 'Invalid email or password');
    }
    await prisma.developerAccount.update({ where: { id: account.id }, data: { lastLogin: new Date() } });

    return res.json({
      success: true,
      token: signDeveloperToken(account.id),
      developer: { id: account.id, email: account.email, displayName: account.displayName },
    });
  } catch (error) {
    return next(error);
  }
});

// POST /api/developer/auth/logout
router.post('/auth/logout', requireDeveloper, (req: DevRequest, res) => {
  sessions.delete(req.developerId!);
  return res.json({ success: true });
});

// GET /api/developer/accounts
router.get('/accounts', requireDeveloper, async (_req, res, next) => {
  try {
    const accounts = await prisma.developerAccount.findMany({
      select: { id: true, email: true, displayName: true, lastLogin: true, createdAt: true },
      orderBy: { createdAt: 'asc' },
    });
    return res.json({ success: true, accounts });
  } catch (error) {
    return next(error);
  }
});

// DELETE /api/developer/accounts/:id
router.delete('/accounts/:id', requireDeveloper, async (req, res, next) => {
  try {
    const id = Number(req.params.id);
    if (!Number.isInteger(id)) return fail(res, 400, 'Invalid account id');
    if (!(await prisma.developerAccount.findUnique({ where: { id } }))) {
      return fail(res, 404, 'Developer account not found');
    }
    await prisma.developerAccount.delete({ where: { id } });
    sessions.delete(id);
    return res.json({ success: true });
  } catch (error) {
    return next(error);
  }
});

// GET /api/developer/demo-users/:role
router.get('/demo-users/:role', requireDeveloper, async (req, res, next) => {
  try {
    const role = toHospitalRole(req.params.role);
    if (!role) return fail(res, 400, `Unknown role: ${req.params.role}`);

    const users = await prisma.user.findMany({
      where: { isDemo: true, isActive: true, role: { name: role } },
      include: {
        patientProfile: { select: { patientNumber: true } },
        doctorProfile: { select: { specialty: true } },
        staffProfile: { select: { employeeId: true } },
      },
      orderBy: { id: 'asc' },
    });

    return res.json({
      success: true,
      demoUsers: users.map((user) => ({
        id: user.id,
        email: user.email,
        displayName: user.displayName,
        name: user.displayName,
        role,
        patientNumber: user.patientProfile?.patientNumber ?? null,
        specialty: user.doctorProfile?.specialty ?? null,
        employeeId: user.staffProfile?.employeeId ?? null,
      })),
    });
  } catch (error) {
    return next(error);
  }
});

// POST /api/developer/role/select
// Signs the developer in as a demo user with that role: returns normal access
// and refresh tokens for the demo user, so the app sees exactly what that role sees.
router.post('/role/select', requireDeveloper, async (req: DevRequest, res, next) => {
  try {
    const parsed = selectRoleSchema.safeParse(req.body);
    if (!parsed.success) return fail(res, 400, 'A role is required');
    const role = toHospitalRole(parsed.data.role);
    if (!role) return fail(res, 400, `Unknown role: ${parsed.data.role}`);

    const demoUserId = parsed.data.demoUserId == null ? undefined : Number(parsed.data.demoUserId);
    if (demoUserId !== undefined && !Number.isInteger(demoUserId)) {
      return fail(res, 400, 'Invalid demo user id');
    }

    // Only seeded demo users with the requested role, never real accounts.
    const user = await prisma.user.findFirst({
      where: {
        isDemo: true,
        isActive: true,
        role: { name: role },
        ...(demoUserId !== undefined ? { id: demoUserId } : {}),
      },
      include: { role: true },
      orderBy: { id: 'asc' },
    });
    if (!user) return fail(res, 404, `No demo user found for role ${role}`);

    const payload = { userId: user.id, id: user.id, role: user.role.name };
    const accessToken = signAccessToken(payload);
    const refreshToken = signRefreshToken(payload);

    // Same session record a normal login creates, so /api/auth/me and logout work.
    await prisma.userSession.create({
      data: {
        userId: user.id,
        token: accessToken,
        deviceInfo: `developer-tools:${req.developerId}`,
        ipAddress: req.ip || 'unknown',
        expiresAt: new Date(Date.now() + 7 * 24 * 60 * 60 * 1000),
      },
    });
    await auditLogger.log({
      userId: user.id,
      action: 'DEVELOPER_IMPERSONATION',
      module: 'developer',
      details: { developerId: req.developerId, role },
      ipAddress: req.ip || 'unknown',
      userAgent: req.get('User-Agent') || 'unknown',
    });

    const session: DeveloperSession = {
      selectedRole: role,
      selectedDemoUserId: user.id,
      selectedAt: new Date().toISOString(),
    };
    sessions.set(req.developerId!, session);

    return res.json({
      success: true,
      session,
      user: { id: user.id, email: user.email, displayName: user.displayName, role: user.role.name },
      tokens: { accessToken, refreshToken },
    });
  } catch (error) {
    return next(error);
  }
});

// GET /api/developer/session
router.get('/session', requireDeveloper, (req: DevRequest, res) => {
  return res.json({ success: true, session: sessions.get(req.developerId!) ?? null });
});

export default router;
