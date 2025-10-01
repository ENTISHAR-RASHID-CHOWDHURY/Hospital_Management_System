import type { Role, User } from '@prisma/client';

import { HOSPITAL_ROLES, type HospitalRole, ROLE_DISPLAY_NAMES } from '../../constants/roles';
import { prisma } from '../../prisma';
import { AppError } from '../../utils/error';
import { comparePassword, hashPassword } from '../../utils/password';
import {
  JwtPayloadData,
  signAccessToken,
  signRefreshToken,
  verifyRefreshToken,
} from '../../utils/token';
import type { LoginInput, RegisterInput } from './auth.schema';

type UserWithRole = User & { role: Role };

export interface AuthenticatedUser {
  id: string;
  email: string;
  displayName: string;
  role: HospitalRole;
}

export interface AuthResult {
  user: AuthenticatedUser;
  accessToken: string;
  refreshToken: string;
}

export interface RoleDto {
  name: HospitalRole;
  displayName: string;
  description: string | null;
}

export async function getUserProfile(userId: number): Promise<AuthenticatedUser> {
  const user = await prisma.user.findUnique({
    where: { id: userId },
    include: { role: true },
  });

  if (!user) {
    throw new AppError(404, 'User not found');
  }

  return mapUser(user);
}

function mapUser(user: UserWithRole): AuthenticatedUser {
  const roleName = user.role.name as HospitalRole;
  if (!HOSPITAL_ROLES.includes(roleName)) {
    throw new AppError(500, `Role ${user.role.name} is not supported by the application`);
  }

  return {
    id: user.id.toString(),
    email: user.email,
    displayName: user.displayName,
    role: roleName,
  };
}

function buildTokens(payload: JwtPayloadData) {
  const accessToken = signAccessToken(payload);
  const refreshToken = signRefreshToken(payload);
  return { accessToken, refreshToken };
}

function toPayload(user: UserWithRole): JwtPayloadData {
  const roleName = user.role.name as HospitalRole;
  if (!HOSPITAL_ROLES.includes(roleName)) {
    throw new AppError(500, `Role ${user.role.name} is not supported by the application`);
  }

  return {
    userId: user.id,
    id: user.id,
    role: roleName,
  };
}

export async function registerUser(input: RegisterInput): Promise<AuthResult> {
  if (!HOSPITAL_ROLES.includes(input.role as HospitalRole)) {
    throw new AppError(400, 'Invalid role specified');
  }

  const existingUser = await prisma.user.findUnique({ where: { email: input.email } });
  if (existingUser) {
    throw new AppError(409, 'User with this email already exists');
  }

  const role = await prisma.role.findUnique({ where: { name: input.role } });
  if (!role) {
    throw new AppError(404, 'Role not found');
  }

  const passwordHash = await hashPassword(input.password);

  const user = await prisma.user.create({
    data: {
      email: input.email,
      passwordHash,
      displayName: input.displayName,
      firstName: input.displayName.split(' ')[0] || input.displayName,
      lastName: input.displayName.split(' ').slice(1).join(' ') || '',
      roleId: role.id,
    },
    include: { role: true },
  });

  const payload = toPayload(user);
  const tokens = buildTokens(payload);

  return {
    user: mapUser(user),
    ...tokens,
  };
}

export async function loginUser(input: LoginInput): Promise<AuthResult> {
  const user = await prisma.user.findUnique({
    where: { email: input.email },
    include: { role: true },
  });

  if (!user) {
    throw new AppError(401, 'Invalid email or password');
  }

  const passwordValid = await comparePassword(input.password, user.passwordHash);
  if (!passwordValid) {
    throw new AppError(401, 'Invalid email or password');
  }

  const payload = toPayload(user);
  const tokens = buildTokens(payload);

  return {
    user: mapUser(user),
    ...tokens,
  };
}

export async function refreshSession(refreshToken: string): Promise<AuthResult> {
  let payload: JwtPayloadData;
  try {
    payload = verifyRefreshToken(refreshToken);
  } catch (error) {
    throw new AppError(401, 'Invalid refresh token');
  }

  const user = await prisma.user.findUnique({
    where: { id: payload.userId },
    include: { role: true },
  });

  if (!user) {
    throw new AppError(401, 'User associated with this token no longer exists');
  }

  const tokens = buildTokens(toPayload(user));

  return {
    user: mapUser(user),
    ...tokens,
  };
}

export async function listRoles(): Promise<RoleDto[]> {
  const roles = await prisma.role.findMany({ orderBy: { name: 'asc' } });

  return roles
    .map((role) => {
      const name = role.name as HospitalRole;
      if (!HOSPITAL_ROLES.includes(name)) {
        return null;
      }

      return {
        name,
        displayName: ROLE_DISPLAY_NAMES[name],
        description: role.description ?? null,
      } satisfies RoleDto;
    })
    .filter((role: RoleDto | null): role is RoleDto => role !== null);
}
