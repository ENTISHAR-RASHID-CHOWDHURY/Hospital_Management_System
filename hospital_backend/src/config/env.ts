import * as dotenv from 'dotenv';

dotenv.config();

function requireEnv(key: string): string {
  const value = process.env[key];
  if (!value) {
    throw new Error(`Environment variable ${key} is required`);
  }
  return value;
}

// Placeholder values that must never be used to sign tokens.
const KNOWN_WEAK_SECRETS = new Set(['change-me', 'changeme', 'secret', 'your-secret-key', 'jwt-secret']);
const MIN_PRODUCTION_SECRET_LENGTH = 32;

function requireSecret(key: string, value: string, nodeEnv: string): string {
  if (KNOWN_WEAK_SECRETS.has(value.toLowerCase())) {
    throw new Error(`${key} is set to a placeholder value; set a long random secret`);
  }
  if (nodeEnv === 'production' && value.length < MIN_PRODUCTION_SECRET_LENGTH) {
    throw new Error(`${key} must be at least ${MIN_PRODUCTION_SECRET_LENGTH} characters in production`);
  }
  return value;
}

const nodeEnv = process.env.NODE_ENV ?? 'development';
const jwtSecret = requireSecret('JWT_SECRET', requireEnv('JWT_SECRET'), nodeEnv);
const refreshSecret = process.env.JWT_REFRESH_SECRET
  ? requireSecret('JWT_REFRESH_SECRET', process.env.JWT_REFRESH_SECRET, nodeEnv)
  : jwtSecret;

export const env = {
  nodeEnv,
  port: parseInt(process.env.PORT ?? '3000', 10),
  jwtSecret,
  jwtExpiresIn: process.env.JWT_EXPIRES_IN ?? '15m',
  refreshSecret,
  refreshExpiresIn: process.env.JWT_REFRESH_EXPIRES_IN ?? '7d',
  databaseUrl: requireEnv('DATABASE_URL'),
  frontendUrl: process.env.FRONTEND_URL,
};
