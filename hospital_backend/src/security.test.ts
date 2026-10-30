import type { AddressInfo } from 'net';
import type { Server } from 'http';
import type { NextFunction, Request, Response } from 'express';

// Every `new PrismaClient()` in the app gets this same fake, so no database is needed.
const fakeDb = {
  $queryRaw: jest.fn(),
  $disconnect: jest.fn(),
  user: { findUnique: jest.fn(), create: jest.fn() },
  role: { findUnique: jest.fn() },
  patient: { findUnique: jest.fn() },
  appointment: { findMany: jest.fn(), findUnique: jest.fn(), count: jest.fn() },
  bill: { findMany: jest.fn(), findUnique: jest.fn(), count: jest.fn() },
  labOrder: { findMany: jest.fn(), findUnique: jest.fn(), count: jest.fn() },
  labResult: { findMany: jest.fn(), findUnique: jest.fn(), count: jest.fn() },
  userSession: { create: jest.fn() },
  permission: { findMany: jest.fn() },
  auditLog: { create: jest.fn() },
};

jest.mock('@prisma/client', () => ({
  PrismaClient: jest.fn(() => fakeDb),
}));

const TEST_SECRET = 'test-secret-that-is-long-enough-for-these-tests';

function loadEnv(vars: Record<string, string | undefined>) {
  const saved = { ...process.env };
  Object.assign(process.env, { DATABASE_URL: 'postgres://test', NODE_ENV: 'test' }, vars);
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

describe('JWT secret configuration', () => {
  it('refuses to start without JWT_SECRET', () => {
    expect(() => loadEnv({ JWT_SECRET: undefined })).toThrow('JWT_SECRET is required');
  });

  it('refuses the old change-me placeholder', () => {
    expect(() => loadEnv({ JWT_SECRET: 'change-me' })).toThrow('placeholder');
  });

  it('requires a long secret in production', () => {
    expect(() => loadEnv({ JWT_SECRET: 'short-but-not-a-placeholder', NODE_ENV: 'production' })).toThrow(
      'at least 32 characters',
    );
  });

  it('accepts a real secret', () => {
    expect(loadEnv({ JWT_SECRET: TEST_SECRET })).toMatchObject({ jwtSecret: TEST_SECRET });
  });
});

describe('with the app running', () => {
  let server: Server;
  let baseUrl: string;
  let token: typeof import('./utils/token');

  beforeAll(async () => {
    process.env.JWT_SECRET = TEST_SECRET;
    process.env.DATABASE_URL = 'postgres://test';
    process.env.NODE_ENV = 'test';
    token = require('./utils/token');
    const { createApp } = require('./app');
    server = createApp().listen(0);
    await new Promise((resolve) => server.once('listening', resolve));
    baseUrl = `http://127.0.0.1:${(server.address() as AddressInfo).port}`;
  });

  afterAll(async () => {
    await new Promise((resolve) => server.close(resolve));
  });

  beforeEach(() => jest.clearAllMocks());

  const accessTokenFor = (role: string) => token.signAccessToken({ userId: 7, id: 7, role });

  const get = (path: string, headers: Record<string, string> = {}) =>
    fetch(`${baseUrl}${path}`, { headers });

  describe('tokens', () => {
    it('does not accept a refresh token as an access token', () => {
      const refresh = token.signRefreshToken({ userId: 1, id: 1, role: 'PATIENT' });
      expect(() => token.verifyAccessToken(refresh)).toThrow();
    });

    it('does not accept an access token as a refresh token', () => {
      expect(() => token.verifyRefreshToken(accessTokenFor('PATIENT'))).toThrow();
    });

    it('round-trips an access token', () => {
      expect(token.verifyAccessToken(accessTokenFor('DOCTOR'))).toMatchObject({ userId: 7, role: 'DOCTOR' });
    });
  });

  describe('role guards', () => {
    const blockedForPatients = [
      '/api/billing/bills',
      '/api/billing/stats',
      '/api/reports/revenue',
      '/api/reports/export/patients',
      '/api/billing/payments',
      '/api/staff',
      '/api/laboratory/stats',
      '/api/facility/admissions',
      '/api/doctors/some-doctor-id',
      '/api/notifications/admin/stats',
      '/api/pharmacy/medications',
    ];

    it.each(blockedForPatients)('returns 403 for a patient on %s', async (path) => {
      const res = await get(path, { Authorization: `Bearer ${accessTokenFor('PATIENT')}` });
      expect(res.status).toBe(403);
    });

    it('returns 401 without a token', async () => {
      expect((await get('/api/billing/bills')).status).toBe(401);
    });

    it('returns 401 when a refresh token is sent as the bearer token', async () => {
      const refresh = token.signRefreshToken({ userId: 7, id: 7, role: 'SUPER_ADMIN' });
      expect((await get('/api/staff', { Authorization: `Bearer ${refresh}` })).status).toBe(401);
    });

    it('keeps staff records (which include salary) admin-only', async () => {
      const res = await get('/api/staff', { Authorization: `Bearer ${accessTokenFor('DOCTOR')}` });
      expect(res.status).toBe(403);
    });

    it.each([
      ['BILLING_MANAGER', '/api/billing/bills'],
      ['SUPER_ADMIN', '/api/staff'],
      ['LAB_TECHNICIAN', '/api/laboratory/orders'],
    ])('lets %s past the guard on %s', async (role, path) => {
      // The fake database has no data for these, so the handler errors; what
      // matters is that the request got past authentication and the role check.
      const res = await get(path, { Authorization: `Bearer ${accessTokenFor(role)}` });
      expect([401, 403]).not.toContain(res.status);
    });

    it('keeps revenue reports away from clinical staff', async () => {
      const res = await get('/api/reports/revenue', { Authorization: `Bearer ${accessTokenFor('NURSE')}` });
      expect(res.status).toBe(403);
    });
  });

  describe('patients see only their own records', () => {
    const OWN = 'patient-own';
    const OTHER = 'patient-other';
    const patientHeaders = () => ({ Authorization: `Bearer ${accessTokenFor('PATIENT')}` });

    beforeEach(() => {
      fakeDb.patient.findUnique.mockResolvedValue({ id: OWN });
      for (const model of [fakeDb.appointment, fakeDb.bill, fakeDb.labOrder, fakeDb.labResult]) {
        model.findMany.mockResolvedValue([]);
        model.count.mockResolvedValue(0);
      }
    });

    it.each([
      ['/api/appointments', fakeDb.appointment],
      ['/api/billing/bills', fakeDb.bill],
      ['/api/laboratory/orders', fakeDb.labOrder],
    ])('%s is limited to the patient, even when another patientId is requested', async (path, model) => {
      const res = await get(`${path}?patientId=${OTHER}`, patientHeaders());

      expect(res.status).toBe(200);
      expect(fakeDb.patient.findUnique).toHaveBeenCalledWith({ where: { userId: 7 }, select: { id: true } });
      expect(model.findMany.mock.calls[0][0].where.patientId).toBe(OWN);
      expect(model.count.mock.calls[0][0].where.patientId).toBe(OWN);
    });

    it('lab results are limited to the patient\'s own lab orders', async () => {
      const res = await get(`/api/laboratory/results?patientId=${OTHER}`, patientHeaders());

      expect(res.status).toBe(200);
      expect(fakeDb.labResult.findMany.mock.calls[0][0].where.labOrder).toEqual({ patientId: OWN });
    });

    it.each([
      ['/api/appointments/a1', fakeDb.appointment, 'Appointment not found'],
      ['/api/billing/bills/b1', fakeDb.bill, 'Bill not found'],
      ['/api/laboratory/orders/o1', fakeDb.labOrder, 'Lab order not found'],
    ])('%s returns 404 for another patient\'s record', async (path, model, message) => {
      model.findUnique.mockResolvedValue({ id: 'x', patientId: OTHER });

      const res = await get(path, patientHeaders());

      expect(res.status).toBe(404);
      expect(await res.json()).toEqual({ error: message });
    });

    it.each([
      ['/api/appointments/a1', fakeDb.appointment],
      ['/api/billing/bills/b1', fakeDb.bill],
      ['/api/laboratory/orders/o1', fakeDb.labOrder],
    ])('%s returns the patient\'s own record', async (path, model) => {
      model.findUnique.mockResolvedValue({ id: 'x', patientId: OWN });

      const res = await get(path, patientHeaders());

      expect(res.status).toBe(200);
    });

    it('a lab result from another patient\'s order returns 404', async () => {
      fakeDb.labResult.findUnique.mockResolvedValue({ id: 'r1', labOrder: { patientId: OTHER } });
      expect((await get('/api/laboratory/results/r1', patientHeaders())).status).toBe(404);

      fakeDb.labResult.findUnique.mockResolvedValue({ id: 'r1', labOrder: { patientId: OWN } });
      expect((await get('/api/laboratory/results/r1', patientHeaders())).status).toBe(200);
    });

    it('returns 403 when the account has no linked patient record', async () => {
      fakeDb.patient.findUnique.mockResolvedValue(null);

      const res = await get('/api/appointments', patientHeaders());

      expect(res.status).toBe(403);
      expect(fakeDb.appointment.findMany).not.toHaveBeenCalled();
    });

    it('does not limit staff', async () => {
      const res = await get(`/api/appointments?patientId=${OTHER}`, {
        Authorization: `Bearer ${accessTokenFor('RECEPTIONIST')}`,
      });

      expect(res.status).toBe(200);
      expect(fakeDb.patient.findUnique).not.toHaveBeenCalled();
      expect(fakeDb.appointment.findMany.mock.calls[0][0].where.patientId).toBe(OTHER);
    });

    it('still keeps patients out of write endpoints', async () => {
      const res = await fetch(`${baseUrl}/api/appointments`, {
        method: 'POST',
        headers: { ...patientHeaders(), 'Content-Type': 'application/json' },
        body: '{}',
      });
      expect(res.status).toBe(403);
    });
  });

  describe('requireRoles', () => {
    const run = (role: string | undefined, allowed: string[]) => {
      const { requireRoles } = require('./middleware/auth.middleware');
      const res = { status: jest.fn().mockReturnThis(), json: jest.fn() } as unknown as Response;
      const next = jest.fn() as NextFunction;
      requireRoles(...allowed)({ user: role ? { role } : undefined } as Request, res, next);
      return { res, next };
    };

    it('lets an allowed role through', () => {
      expect(run('BILLING_MANAGER', ['SUPER_ADMIN', 'BILLING_MANAGER']).next).toHaveBeenCalled();
    });

    it('blocks other roles with 403', () => {
      const { res, next } = run('PATIENT', ['SUPER_ADMIN']);
      expect(next).not.toHaveBeenCalled();
      expect(res.status).toHaveBeenCalledWith(403);
    });
  });

  describe('public registration', () => {
    it('always creates a patient, ignoring any role sent by the client', async () => {
      fakeDb.user.findUnique.mockResolvedValue(null);
      fakeDb.role.findUnique.mockResolvedValue({ id: 10, name: 'PATIENT' });
      fakeDb.user.create.mockImplementation(async ({ data }) => ({
        id: 99,
        ...data,
        role: { id: data.roleId, name: 'PATIENT' },
      }));
      fakeDb.userSession.create.mockResolvedValue({});
      fakeDb.permission.findMany.mockResolvedValue([]);

      const res = await fetch(`${baseUrl}/api/auth/register`, {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({
          email: 'attacker@example.com',
          password: 'password123',
          firstName: 'A',
          lastName: 'B',
          roleId: 1,
          role: 'SUPER_ADMIN',
        }),
      });

      expect(res.status).toBe(201);
      expect(fakeDb.role.findUnique).toHaveBeenCalledWith({ where: { name: 'PATIENT' } });
      expect(fakeDb.user.create.mock.calls[0][0].data.roleId).toBe(10);
    });
  });

  describe('developer tools', () => {
    it('do not exist unless DEVELOPER_MODE=true', async () => {
      const res = await fetch(`${baseUrl}/api/developer/session`, {
        headers: { 'x-developer-phrase': 'anything' },
      });
      expect(res.status).toBe(404);
    });
  });

  describe('CORS', () => {
    it('does not allow an unknown origin', async () => {
      const res = await get('/api/billing/bills', { Origin: 'https://evil.example' });
      expect(res.headers.get('access-control-allow-origin')).toBeNull();
    });

    it('allows a localhost origin outside production', async () => {
      const res = await get('/api/billing/bills', { Origin: 'http://localhost:61228' });
      expect(res.headers.get('access-control-allow-origin')).toBe('http://localhost:61228');
    });
  });
});
