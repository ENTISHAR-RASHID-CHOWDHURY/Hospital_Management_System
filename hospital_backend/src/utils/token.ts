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

// Marks which kind of token this is, so a refresh token can't be used as an
// access token (or the reverse), even when both share a signing secret.
type TokenType = 'access' | 'refresh';
type SignedPayload = JwtPayloadData & { tokenType: TokenType };

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
  return jwt.sign({ ...stripTokenType(payload), tokenType: 'access' }, env.jwtSecret as Secret, accessOptions);
}

export function signRefreshToken(payload: JwtPayloadData): string {
  return jwt.sign({ ...stripTokenType(payload), tokenType: 'refresh' }, env.refreshSecret as Secret, refreshOptions);
}

export function verifyAccessToken(token: string): JwtPayloadData {
  return verifyTyped(token, env.jwtSecret, 'access');
}

export function verifyRefreshToken(token: string): JwtPayloadData {
  return verifyTyped(token, env.refreshSecret, 'refresh');
}

function verifyTyped(token: string, secret: string, expected: TokenType): JwtPayloadData {
  const decoded = jwt.verify(token, secret as Secret, { algorithms: ['HS256'] });
  if (typeof decoded === 'string' || (decoded as SignedPayload).tokenType !== expected) {
    throw new jwt.JsonWebTokenError(`Expected a ${expected} token`);
  }
  return decoded as SignedPayload;
}

// Drop claims carried over from a decoded token so they aren't re-signed.
function stripTokenType(payload: JwtPayloadData): JwtPayloadData {
  const { tokenType: _t, iat: _i, exp: _e, ...rest } = payload as SignedPayload & { iat?: number; exp?: number };
  return rest;
}
