import { NextFunction, Request, Response } from 'express';

import { getDashboardOptionsForUser } from './dashboard.service';

export async function getDashboardOptionsHandler(req: Request, res: Response, next: NextFunction) {
  try {
    const userId = req.user?.userId;
    if (!userId) {
      return res.status(401).json({ message: 'Unauthorized' });
    }

    const options = await getDashboardOptionsForUser(userId);
    return res.json(options);
  } catch (error) {
    return next(error);
  }
}
