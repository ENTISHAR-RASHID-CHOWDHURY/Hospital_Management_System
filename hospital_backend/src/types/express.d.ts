import type { JwtPayloadData } from '../utils/token';

declare global {
  namespace Express {
    interface Request {
      user?: JwtPayloadData;
      /** Set by resolveOwnPatient for PATIENT users: their own patient id. */
      ownPatientId?: string;
    }
  }
}

export {};
