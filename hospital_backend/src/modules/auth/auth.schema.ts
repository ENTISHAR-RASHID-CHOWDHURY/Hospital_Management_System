import { z } from 'zod';

import { HOSPITAL_ROLES } from '../../constants/roles';

export const registerSchema = z.object({
  email: z.string().email('Email must be a valid email address'),
  password: z.string().min(8, 'Password must be at least 8 characters long'),
  displayName: z.string().min(1, 'Display name is required').max(120, 'Display name is too long'),
  role: z.enum(HOSPITAL_ROLES),
});

export const loginSchema = z.object({
  email: z.string().email('Email must be a valid email address'),
  password: z.string().min(1, 'Password is required'),
});

export const refreshSchema = z.object({
  refreshToken: z.string().min(1, 'Refresh token is required'),
});

export type RegisterInput = z.infer<typeof registerSchema>;
export type LoginInput = z.infer<typeof loginSchema>;
export type RefreshInput = z.infer<typeof refreshSchema>;
