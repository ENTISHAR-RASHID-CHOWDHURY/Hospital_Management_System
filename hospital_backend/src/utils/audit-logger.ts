import { PrismaClient } from '@prisma/client';
import * as winston from 'winston';

const prisma = new PrismaClient();

// Configure Winston logger
const logger = winston.createLogger({
  level: process.env.LOG_LEVEL || 'info',
  format: winston.format.combine(
    winston.format.timestamp(),
    winston.format.errors({ stack: true }),
    winston.format.json()
  ),
  defaultMeta: { service: 'hospital-management' },
  transports: [
    new winston.transports.File({ filename: 'logs/error.log', level: 'error' }),
    new winston.transports.File({ filename: 'logs/combined.log' }),
  ],
});

if (process.env.NODE_ENV !== 'production') {
  logger.add(new winston.transports.Console({
    format: winston.format.simple()
  }));
}

export interface AuditLogData {
  userId: number;
  action: string;
  module: string;
  resourceId?: string;
  resourceType?: string;
  details?: any;
  ipAddress?: string;
  userAgent?: string;
}

export class AuditLogger {
  async log(data: AuditLogData): Promise<void> {
    try {
      // Log to database if audit logging is enabled
      if (process.env.ENABLE_AUDIT_LOGS === 'true') {
        await prisma.auditLog.create({
          data: {
            userId: data.userId,
            action: data.action,
            module: data.module,
            resourceId: data.resourceId,
            resourceType: data.resourceType,
            details: data.details,
            ipAddress: data.ipAddress,
            userAgent: data.userAgent,
          }
        });
      }

      // Also log to Winston for file-based logging
      logger.info('Audit Log', data);
    } catch (error) {
      logger.error('Failed to create audit log', { error, data });
    }
  }

  async getAuditLogs(filters: {
    userId?: number;
    module?: string;
    action?: string;
    startDate?: Date;
    endDate?: Date;
    limit?: number;
    offset?: number;
  }) {
    try {
      const where: any = {};

      if (filters.userId) where.userId = filters.userId;
      if (filters.module) where.module = filters.module;
      if (filters.action) where.action = filters.action;
      
      if (filters.startDate || filters.endDate) {
        where.timestamp = {};
        if (filters.startDate) where.timestamp.gte = filters.startDate;
        if (filters.endDate) where.timestamp.lte = filters.endDate;
      }

      const logs = await prisma.auditLog.findMany({
        where,
        include: {
          user: {
            select: {
              id: true,
              email: true,
              displayName: true,
              role: {
                select: {
                  name: true,
                  displayName: true
                }
              }
            }
          }
        },
        orderBy: { timestamp: 'desc' },
        take: filters.limit || 100,
        skip: filters.offset || 0
      });

      return logs;
    } catch (error) {
      logger.error('Failed to retrieve audit logs', { error, filters });
      throw error;
    }
  }

  async getUserActivity(userId: number, days: number = 30) {
    try {
      const startDate = new Date();
      startDate.setDate(startDate.getDate() - days);

      const activity = await prisma.auditLog.findMany({
        where: {
          userId,
          timestamp: {
            gte: startDate
          }
        },
        orderBy: { timestamp: 'desc' },
        take: 100
      });

      return activity;
    } catch (error) {
      logger.error('Failed to retrieve user activity', { error, userId });
      throw error;
    }
  }

  async getModuleActivity(module: string, days: number = 7) {
    try {
      const startDate = new Date();
      startDate.setDate(startDate.getDate() - days);

      const activity = await prisma.auditLog.groupBy({
        by: ['action'],
        where: {
          module,
          timestamp: {
            gte: startDate
          }
        },
        _count: {
          action: true
        }
      });

      return activity;
    } catch (error) {
      logger.error('Failed to retrieve module activity', { error, module });
      throw error;
    }
  }
}

export default new AuditLogger();