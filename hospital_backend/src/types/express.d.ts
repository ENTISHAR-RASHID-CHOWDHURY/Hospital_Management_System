import type { JwtPayloadData } from '../utils/token';

declare global {
  namespace Express {
    interface Request {
      user?: JwtPayloadData;
    }
  }
}

export {};
