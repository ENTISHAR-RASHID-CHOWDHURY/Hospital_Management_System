import { prisma } from '../../prisma';
import { comparePassword, hashPassword } from '../../utils/password';
import { signAccessToken, signRefreshToken, verifyRefreshToken } from '../../utils/token';
import type { HospitalRole } from '../../constants/roles';
import { AppError } from '../../utils/error';
import { listRoles, loginUser, refreshSession, registerUser } from './auth.service';

jest.mock('../../prisma', () => ({
  prisma: {
    user: {
      findUnique: jest.fn(),
      create: jest.fn(),
    },
    role: {
      findUnique: jest.fn(),
      findMany: jest.fn(),
    },
  },
}));

jest.mock('../../utils/password', () => ({
  hashPassword: jest.fn(),
  comparePassword: jest.fn(),
}));

jest.mock('../../utils/token', () => ({
  signAccessToken: jest.fn(),
  signRefreshToken: jest.fn(),
  verifyRefreshToken: jest.fn(),
}));

type MockedPrisma = {
  user: {
    findUnique: jest.Mock;
    create: jest.Mock;
  };
  role: {
    findUnique: jest.Mock;
    findMany: jest.Mock;
  };
};

const mockedPrisma = prisma as unknown as MockedPrisma;
const mockedHashPassword = hashPassword as jest.MockedFunction<typeof hashPassword>;
const mockedComparePassword = comparePassword as jest.MockedFunction<typeof comparePassword>;
const mockedSignAccessToken = signAccessToken as jest.MockedFunction<typeof signAccessToken>;
const mockedSignRefreshToken = signRefreshToken as jest.MockedFunction<typeof signRefreshToken>;
const mockedVerifyRefreshToken = verifyRefreshToken as jest.MockedFunction<typeof verifyRefreshToken>;

describe('AuthService', () => {
  const baseRoleName: HospitalRole = 'doctor';

  const baseRole = {
    id: 1,
    name: baseRoleName,
    description: 'Doctor role',
    createdAt: new Date(),
    updatedAt: new Date(),
  };

  const baseUser = {
    id: 10,
    email: 'doc@example.com',
    passwordHash: 'hashed-password',
    displayName: 'Dr. Who',
    roleId: baseRole.id,
    createdAt: new Date(),
    updatedAt: new Date(),
    role: baseRole,
  };

  beforeEach(() => {
    jest.clearAllMocks();
    mockedSignAccessToken.mockReturnValue('access-token');
    mockedSignRefreshToken.mockReturnValue('refresh-token');
    mockedPrisma.role.findMany.mockResolvedValue([baseRole]);
  });

  it('registers a new user and returns tokens', async () => {
    mockedPrisma.user.findUnique.mockResolvedValueOnce(null);
    mockedPrisma.role.findUnique.mockResolvedValueOnce(baseRole);
    mockedHashPassword.mockResolvedValueOnce('hashed');
    mockedPrisma.user.create.mockResolvedValueOnce({ ...baseUser, passwordHash: 'hashed' });

    const result = await registerUser({
      email: baseUser.email,
      password: 'Password123',
      displayName: baseUser.displayName,
      role: baseRole.name,
    });

    expect(mockedPrisma.user.findUnique).toHaveBeenCalledWith({ where: { email: baseUser.email } });
    expect(mockedHashPassword).toHaveBeenCalledWith('Password123');
    expect(result).toMatchObject({
      user: {
        id: baseUser.id.toString(),
        email: baseUser.email,
        displayName: baseUser.displayName,
        role: baseRole.name,
      },
      accessToken: 'access-token',
      refreshToken: 'refresh-token',
    });
  });

  it('logs in an existing user', async () => {
    mockedPrisma.user.findUnique.mockResolvedValueOnce(baseUser);
    mockedComparePassword.mockResolvedValueOnce(true);

    const result = await loginUser({
      email: baseUser.email,
      password: 'Password123',
    });

    expect(mockedPrisma.user.findUnique).toHaveBeenCalledWith({
      where: { email: baseUser.email },
      include: { role: true },
    });
    expect(mockedComparePassword).toHaveBeenCalledWith('Password123', baseUser.passwordHash);
    expect(result.accessToken).toBe('access-token');
    expect(result.refreshToken).toBe('refresh-token');
  });

  it('refreshes a session using refresh token', async () => {
    mockedVerifyRefreshToken.mockReturnValue({ userId: baseUser.id, role: baseRole.name });
    mockedPrisma.user.findUnique.mockResolvedValueOnce(baseUser);
    const result = await refreshSession('refresh-token');

    expect(mockedVerifyRefreshToken).toHaveBeenCalledWith('refresh-token');
    expect(mockedPrisma.user.findUnique).toHaveBeenCalledWith({
      where: { id: baseUser.id },
      include: { role: true },
    });
    expect(result.accessToken).toBe('access-token');
    expect(result.refreshToken).toBe('refresh-token');
  });

  it('throws when registering with an unsupported role', async () => {
    await expect(
      registerUser({
        email: 'new@example.com',
        password: 'Password123',
        displayName: 'New User',
        role: 'visitor' as unknown as HospitalRole,
      }),
    ).rejects.toBeInstanceOf(AppError);
  });

  it('lists roles with metadata', async () => {
    mockedPrisma.role.findMany.mockResolvedValueOnce([baseRole]);

    const roles = await listRoles();

    expect(mockedPrisma.role.findMany).toHaveBeenCalled();
    expect(roles).toEqual([
      {
        name: baseRole.name,
        displayName: 'Doctor',
        description: baseRole.description,
      },
    ]);
  });
});
