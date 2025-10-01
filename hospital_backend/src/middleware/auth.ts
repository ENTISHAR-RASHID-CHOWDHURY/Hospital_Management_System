import { Request, Response, NextFunction } from 'express';
import * as jwt from 'jsonwebtoken';
import { PrismaClient } from '@prisma/client';
import { AuditLogger } from '../utils/audit-logger';
import { JwtPayloadData } from '../utils/token';

const prisma = new PrismaClient();
const auditLogger = new AuditLogger();

export interface AuthenticatedRequest extends Request {
  user?: JwtPayloadData & {
    email: string;
    roleDetails: {
      name: string;
      permissions: Array<{
        name: string;
        module: string;
        action: string;
      }>;
    };
  };
}

export const authenticate = async (
  req: AuthenticatedRequest,
  res: Response,
  next: NextFunction
) => {
  try {
    const token = req.header('Authorization')?.replace('Bearer ', '');

    if (!token) {
      return res.status(401).json({ error: 'Access denied. No token provided.' });
    }

    const decoded = jwt.verify(token, process.env.JWT_SECRET!) as any;
    
    // Verify token is not blacklisted and session is active
    const session = await prisma.userSession.findFirst({
      where: {
        token,
        userId: decoded.userId,
        isActive: true,
        expiresAt: {
          gt: new Date()
        }
      }
    });

    if (!session) {
      return res.status(401).json({ error: 'Invalid or expired token.' });
    }

    // Get user with role and permissions
    const user = await prisma.user.findUnique({
      where: { id: decoded.userId },
      include: {
        role: {
          include: {
            permissions: true
          }
        }
      }
    });

    if (!user || !user.isActive) {
      return res.status(401).json({ error: 'User not found or inactive.' });
    }

    // Update session last used
    await prisma.userSession.update({
      where: { id: session.id },
      data: { lastUsed: new Date() }
    });

    req.user = {
      userId: user.id,
      id: user.id,
      role: user.role.name,
      email: user.email,
      roleDetails: {
        name: user.role.name,
        permissions: user.role.permissions.map(p => ({
          name: p.name,
          module: p.module,
          action: p.action
        }))
      }
    };
    next();
  } catch (error) {
    res.status(401).json({ error: 'Invalid token.' });
  }
};

export const authorize = (requiredPermissions: string[]) => {
  return (req: AuthenticatedRequest, res: Response, next: NextFunction) => {
    if (!req.user) {
      return res.status(401).json({ error: 'Authentication required.' });
    }

    const userPermissions = req.user.roleDetails.permissions.map(p => p.name);
    const hasPermission = requiredPermissions.every(permission => 
      userPermissions.includes(permission)
    );

    if (!hasPermission) {
      // Log unauthorized access attempt
      auditLogger.log({
        userId: req.user.id,
        action: 'UNAUTHORIZED_ACCESS',
        module: 'auth',
        details: {
          requiredPermissions,
          userPermissions,
          endpoint: req.path
        },
        ipAddress: req.ip,
        userAgent: req.get('User-Agent')
      });

      return res.status(403).json({ 
        error: 'Insufficient permissions.',
        required: requiredPermissions,
        userRole: req.user.roleDetails.name
      });
    }

    next();
  };
};

export const roleBasedAccess = (allowedRoles: string[]) => {
  return (req: AuthenticatedRequest, res: Response, next: NextFunction) => {
    if (!req.user) {
      return res.status(401).json({ error: 'Authentication required.' });
    }

    if (!allowedRoles.includes(req.user.roleDetails.name)) {
      return res.status(403).json({ 
        error: 'Access denied for your role.',
        userRole: req.user.roleDetails.name,
        allowedRoles
      });
    }

    next();
  };
};

export const auditTrail = (action: string, module: string) => {
  return (req: AuthenticatedRequest, res: Response, next: NextFunction) => {
    // Store original send function
    const originalSend = res.send;
    
    res.send = function(data) {
      // Log the action after successful response
      if (req.user && res.statusCode < 400) {
        auditLogger.log({
          userId: req.user.id,
          action,
          module,
          resourceId: req.params.id,
          resourceType: module,
          details: {
            method: req.method,
            path: req.path,
            body: req.method !== 'GET' ? req.body : undefined,
            query: req.query
          },
          ipAddress: req.ip,
          userAgent: req.get('User-Agent')
        });
      }
      
      return originalSend.call(this, data);
    };
    
    next();
  };
};