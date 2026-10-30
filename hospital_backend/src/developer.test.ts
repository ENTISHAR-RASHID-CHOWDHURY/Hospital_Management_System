import type { AddressInfo } from 'net';
import type { Server } from 'http';

// Every `new PrismaClient()` in the app gets this same fake, so no database is needed.
const fakeDb = {
  $queryRaw: jest.fn(),
  $disconnect: jest.fn(),
  developerAccount: {
    findUnique: jest.fn(),
    findMany: jest.fn(),
    create: jest.fn(),
    update: jest.fn(),
    delete: jest.fn(),
  },
  user: { findMany: jest.fn(), findFirst: jest.fn() },
  userSession: { create: jest.fn() },
  auditLog: { create: jest.fn() },
};

jest.mock('@prisma/client', () => ({
  PrismaClient: jest.fn(() => fakeDb),
}));

const JWT_SECRET = 'test-secret-that-is-long-enough-for-these-tests';
const PHRASE = 'test-developer-phrase';

function loadEnv(vars: Record<string, string | undefined>) {
  const saved = { ...process.env };
  Object.assign(process.env, { DATABASE_URL: 'postgres://test', JWT_SECRET, NODE_ENV: 'test' }, vars);
  for (const [key, value] of Object.entries(vars)) {
    if (value === undefined) delete process.env[key];
  }
  try {
    let env: unknown;
    jest.isolateModules(() => {
      env = require('./config/env').env;
    });
    return env;
  } finally {
    process.env = saved;
  }
}

describe('developer mode configuration', () => {
  it('is off unless DEVELOPER_MODE=true', () => {
    expect(loadEnv({ DEVELOPER_MODE: undefined })).toMatchObject({ developerMode: false });
  });

  it('refuses to start in production', () => {
    expect(() =>
      loadEnv({ DEVELOPER_MODE: 'true', DEVELOPER_PHRASE: PHRASE, NODE_ENV: 'production', JWT_SECRET: JWT_SECRET }),
    ).toThrow('DEVELOPER_MODE must not be enabled in production');
  });

  it('requires DEVELOPER_PHRASE when enabled', () => {
    expect(() => loadEnv({ DEVELOPER_MODE: 'true', DEVELOPER_PHRASE: undefined })).toThrow(
      'DEVELOPER_PHRASE is required',
    );
  });

  it('rejects the old hardcoded-style placeholder phrases', () => {
    expect(() => loadEnv({ DEVELOPER_MODE: 'true', DEVELOPER_PHRASE: 'change-me' })).toThrow('placeholder');
  });
});

describe('developer routes', () => {
  let server: Server;
  let baseUrl: string;
  let token: typeof import('./utils/token');
  let hashPassword: typeof import('./utils/password').hashPassword;
  let auditLog: jest.SpyInstance;

  beforeAll(async () => {
    Object.assign(process.env, {
      JWT_SECRET,
      DATABASE_URL: 'postgres://test',
      NODE_ENV: 'test',
      DEVELOPER_MODE: 'true',
      DEVELOPER_PHRASE: PHRASE,
    });
    token = require('./utils/token');
    hashPassword = require('./utils/password').hashPassword;
    // The audit logger only writes to the database when ENABLE_AUDIT_LOGS is set.
    auditLog = jest.spyOn(require('./utils/audit-logger').AuditLogger.prototype, 'log');
    const { createApp } = require('./app');
    server = createApp().listen(0);
    await new Promise((resolve) => server.once('listening', resolve));
    baseUrl = `http://127.0.0.1:${(server.address() as AddressInfo).port}`;
  });

  afterAll(async () => {
    await new Promise((resolve) => server.close(resolve));
  });

  beforeEach(() => {
    jest.clearAllMocks();
    fakeDb.developerAccount.findUnique.mockImplementation(async ({ where }) =>
      where.id === 1 || where.email === 'dev@example.com'
        ? { id: 1, email: 'dev@example.com', displayName: 'Dev', passwordHash: devPasswordHash }
        : null,
    );
  });

  let devPasswordHash = '';
  beforeAll(async () => {
    devPasswordHash = await hashPassword('correct-password');
  });

  const call = (method: string, path: string, opts: { body?: unknown; headers?: Record<string, string> } = {}) =>
    fetch(`${baseUrl}/api/developer${path}`, {
      method,
      headers: { 'Content-Type': 'application/json', 'x-developer-phrase': PHRASE, ...opts.headers },
      body: opts.body === undefined ? undefined : JSON.stringify(opts.body),
    });
  const asDeveloper = () => ({ Authorization: `Bearer ${token.signDeveloperToken(1)}` });

  describe('phrase', () => {
    it('rejects requests without the phrase', async () => {
      const res = await fetch(`${baseUrl}/api/developer/session`, { headers: asDeveloper() });
      expect(res.status).toBe(401);
    });

    it('rejects a wrong phrase', async () => {
      const res = await call('GET', '/session', { headers: { ...asDeveloper(), 'x-developer-phrase': 'nope' } });
      expect(res.status).toBe(401);
    });
  });

  describe('accounts and login', () => {
    it('creates an account with a hashed password', async () => {
      fakeDb.developerAccount.create.mockImplementation(async ({ data }) => ({ id: 2, ...data }));

      const res = await call('POST', '/accounts/create', {
        body: { email: 'new@example.com', password: 'a-long-password', displayName: 'New' },
      });

      expect(res.status).toBe(201);
      const { data } = fakeDb.developerAccount.create.mock.calls[0][0];
      expect(data.passwordHash).not.toBe('a-long-password');
      expect(await res.json()).toEqual({
        success: true,
        developer: { id: 2, email: 'new@example.com', displayName: 'New' },
      });
    });

    it('logs in with the right password and returns a developer token', async () => {
      const res = await call('POST', '/auth/login', { body: { email: 'dev@example.com', password: 'correct-password' } });
      const body = await res.json();

      expect(res.status).toBe(200);
      expect(body.developer).toEqual({ id: 1, email: 'dev@example.com', displayName: 'Dev' });
      expect(token.verifyDeveloperToken(body.token)).toEqual({ developerId: 1 });
    });

    it('rejects a wrong password', async () => {
      const res = await call('POST', '/auth/login', { body: { email: 'dev@example.com', password: 'wrong-password' } });
      expect(res.status).toBe(401);
    });

    it('requires a developer login to list accounts', async () => {
      expect((await call('GET', '/accounts')).status).toBe(401);
    });
  });

  describe('token separation', () => {
    it('a developer token is not accepted by the hospital API', async () => {
      const res = await fetch(`${baseUrl}/api/staff`, { headers: asDeveloper() });
      expect(res.status).toBe(401);
    });

    it('a normal access token is not accepted by the developer tools', async () => {
      const access = token.signAccessToken({ userId: 1, id: 1, role: 'SUPER_ADMIN' });
      const res = await call('GET', '/session', { headers: { Authorization: `Bearer ${access}` } });
      expect(res.status).toBe(401);
    });
  });

  describe('demo users and role selection', () => {
    it('maps the app\'s role names and only lists demo users', async () => {
      fakeDb.user.findMany.mockResolvedValue([
        { id: 5, email: 'admin@hospital.com', displayName: 'Admin User', patientProfile: null, doctorProfile: null, staffProfile: null },
      ]);

      const res = await call('GET', '/demo-users/admin', { headers: asDeveloper() });

      expect(res.status).toBe(200);
      expect(fakeDb.user.findMany.mock.calls[0][0].where).toEqual({
        isDemo: true,
        isActive: true,
        role: { name: 'SUPER_ADMIN' },
      });
      expect((await res.json()).demoUsers[0]).toMatchObject({ id: 5, email: 'admin@hospital.com', role: 'SUPER_ADMIN' });
    });

    it('rejects an unknown role', async () => {
      expect((await call('GET', '/demo-users/janitor', { headers: asDeveloper() })).status).toBe(400);
    });

    it('signs in as a demo user and returns working tokens for that role', async () => {
      fakeDb.user.findFirst.mockResolvedValue({
        id: 9,
        email: 'lab@hospital.com',
        displayName: 'Lab User',
        role: { name: 'LAB_TECHNICIAN' },
      });

      const res = await call('POST', '/role/select', { body: { role: 'laboratory', demoUserId: 9 }, headers: asDeveloper() });
      const body = await res.json();

      expect(res.status).toBe(200);
      expect(fakeDb.user.findFirst.mock.calls[0][0].where).toEqual({
        isDemo: true,
        isActive: true,
        role: { name: 'LAB_TECHNICIAN' },
        id: 9,
      });
      expect(token.verifyAccessToken(body.tokens.accessToken)).toMatchObject({ userId: 9, role: 'LAB_TECHNICIAN' });
      expect(fakeDb.userSession.create).toHaveBeenCalled();
      expect(auditLog).toHaveBeenCalledWith(
        expect.objectContaining({ userId: 9, action: 'DEVELOPER_IMPERSONATION', details: { developerId: 1, role: 'LAB_TECHNICIAN' } }),
      );

      const session = await (await call('GET', '/session', { headers: asDeveloper() })).json();
      expect(session.session).toMatchObject({ selectedRole: 'LAB_TECHNICIAN', selectedDemoUserId: 9 });
    });

    it('will not impersonate a user who is not a demo account', async () => {
      // The query requires isDemo: true, so a real account is never found.
      fakeDb.user.findFirst.mockResolvedValue(null);

      const res = await call('POST', '/role/select', { body: { role: 'admin', demoUserId: 1 }, headers: asDeveloper() });

      expect(res.status).toBe(404);
      expect(fakeDb.userSession.create).not.toHaveBeenCalled();
    });
  });
});
