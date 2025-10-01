import * as jwt from 'jsonwebtoken';
import { Secret, SignOptions } from 'jsonwebtoken';

import { env } from '../config/env';

export interface JwtPayloadData {
  userId: number;
  id: number; // Alias for userId for compatibility
  role: string;
  patientId?: string; // For patient users
  doctorId?: string; // For doctor users
  staffId?: string; // For staff users
}

type ExpiresIn = Exclude<SignOptions['expiresIn'], undefined>;

const accessOptions: SignOptions = {};
if (env.jwtExpiresIn) {
  accessOptions.expiresIn = env.jwtExpiresIn as ExpiresIn;
}

const refreshOptions: SignOptions = {};
if (env.refreshExpiresIn) {
  refreshOptions.expiresIn = env.refreshExpiresIn as ExpiresIn;
}

export function signAccessToken(payload: JwtPayloadData): string {
  return jwt.sign(payload, env.jwtSecret as Secret, accessOptions);
}

export function signRefreshToken(payload: JwtPayloadData): string {
  return jwt.sign(payload, env.refreshSecret as Secret, refreshOptions);
}

export function verifyAccessToken(token: string): JwtPayloadData {
  return jwt.verify(token, env.jwtSecret as Secret) as JwtPayloadData;
}

export function verifyRefreshToken(token: string): JwtPayloadData {
  return jwt.verify(token, env.refreshSecret as Secret) as JwtPayloadData;
}
