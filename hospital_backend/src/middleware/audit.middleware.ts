import { Request, Response, NextFunction } from 'express';

export interface AuditLogData {
  userId: string;
  action: string;
  resource: string;
  resourceId?: string;
  oldValues?: any;
  newValues?: any;
  ipAddress?: string;
  userAgent?: string;
}

export const createAuditLog = async (data: AuditLogData) => {
  try {
    // For now, just log to console - can be enhanced later with database logging
    console.log('Audit Log:', {
      timestamp: new Date().toISOString(),
      ...data
    });
  } catch (error) {
    console.error('Failed to create audit log:', error);
  }
};

export const auditLog = (action: string, resource: string) => {
  return (req: Request, res: Response, next: NextFunction) => {
    const originalSend = res.send;
    const user = (req as any).user;

    res.send = function(body) {
      // Only log successful operations
      if (res.statusCode >= 200 && res.statusCode < 300) {
        const auditData: AuditLogData = {
          userId: user?.id || 'anonymous',
          action,
          resource,
          resourceId: req.params.id,
          newValues: req.method === 'POST' || req.method === 'PUT' ? req.body : undefined,
          ipAddress: req.ip,
          userAgent: req.get('User-Agent'),
        };

        createAuditLog(auditData).catch(err => 
          console.error('Audit log creation failed:', err)
        );
      }

      return originalSend.call(this, body);
    };

    next();
  };
};

export default auditLog;