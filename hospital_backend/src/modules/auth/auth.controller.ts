import { NextFunction, Request, Response } from 'express';

import { badRequest } from '../../utils/error';
import { loginSchema, refreshSchema, registerSchema } from './auth.schema';
import { getUserProfile, listRoles, loginUser, refreshSession, registerUser } from './auth.service';

export async function registerHandler(req: Request, res: Response, next: NextFunction) {
  try {
    const payload = await registerSchema.parseAsync(req.body);
    const result = await registerUser(payload);
    return res.status(201).json(result);
  } catch (error) {
    return next(error);
  }
}

export async function loginHandler(req: Request, res: Response, next: NextFunction) {
  try {
    const payload = await loginSchema.parseAsync(req.body);
    const result = await loginUser(payload);
    return res.json(result);
  } catch (error) {
    return next(error);
  }
}

export async function refreshHandler(req: Request, res: Response, next: NextFunction) {
  try {
    const payload = await refreshSchema.parseAsync(req.body);
    const result = await refreshSession(payload.refreshToken);
    return res.json(result);
  } catch (error) {
    return next(error);
  }
}

export async function meHandler(req: Request, res: Response, next: NextFunction) {
  try {
    const userId = req.user?.userId;
    if (!userId) {
      badRequest('Missing authenticated user');
    }

    const user = await getUserProfile(userId);
    return res.json({ user });
  } catch (error) {
    return next(error);
  }
}

export async function rolesHandler(_req: Request, res: Response, next: NextFunction) {
  try {
    const roles = await listRoles();
    return res.json({ roles });
  } catch (error) {
    return next(error);
  }
}
