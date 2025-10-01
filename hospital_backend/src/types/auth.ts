import { Request } from 'express';
import { JwtPayloadData } from '../utils/token';

export interface AuthenticatedRequest extends Request {
  user: JwtPayloadData;
}

export interface RequestWithUser extends Request {
  user?: JwtPayloadData;
}