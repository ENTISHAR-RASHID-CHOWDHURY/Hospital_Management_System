import express from 'express';
import cors from 'cors';
import helmet from 'helmet';
import morgan from 'morgan';
import rateLimit from 'express-rate-limit';
import { PrismaClient } from '@prisma/client';
import * as dotenv from 'dotenv';

// Import working routes
import authRoutes from './routes/auth';
import userRoutes from './routes/users';
import pharmacyRoutes from './routes/pharmacy_minimal';
import patientRoutes from './routes/patients_fixed';
import doctorRoutes from './routes/doctors';
import appointmentRoutes from './routes/appointments';
import labRoutes from './routes/laboratory';
import staffRoutes from './routes/staff';
import billingRoutes from './routes/billing';
import facilityRoutes from './routes/facility';
import reportsRoutes from './routes/reports';
import notificationRoutes from './routes/notifications';
import developerRoutes from './routes/developer';
import { env } from './config/env';
import { authenticate } from './middleware/auth.middleware';

// Import middleware

import { errorHandler } from './middleware/error.middleware';

dotenv.config();

export function createApp() {
  const app = express();
  const prisma = new PrismaClient();

  // Only trust X-Forwarded-For when running behind a known number of proxies;
  // trusting it blindly lets clients fake their IP and bypass rate limiting.
  app.set('trust proxy', parseInt(process.env.TRUST_PROXY_HOPS ?? '0', 10));

  // Security middleware
  app.use(helmet());

  // CORS: in production only FRONTEND_URL (comma-separated) is allowed.
  // Outside production, any localhost/127.0.0.1 port is also allowed so the
  // Flutter dev server's random ports work.
  const configuredOrigins = (process.env.FRONTEND_URL ?? '')
    .split(',')
    .map((origin) => origin.trim())
    .filter(Boolean);
  const isProduction = process.env.NODE_ENV === 'production';
  const localOriginPattern = /^https?:\/\/(localhost|127\.0\.0\.1)(:\d+)?$/;

  app.use(cors({
    origin: (origin, callback) => {
      // Requests without an Origin header (mobile apps, curl) aren't subject to CORS.
      if (!origin) return callback(null, true);
      if (configuredOrigins.includes(origin)) return callback(null, true);
      if (!isProduction && localOriginPattern.test(origin)) return callback(null, true);
      return callback(null, false);
    },
    credentials: true,
    methods: ['GET', 'POST', 'PUT', 'DELETE', 'PATCH', 'OPTIONS'],
    allowedHeaders: ['Content-Type', 'Authorization', 'X-Requested-With', 'Accept', 'Origin']
  }));

  // Rate limiting
  const limiter = rateLimit({
    windowMs: parseInt(process.env.RATE_LIMIT_WINDOW_MS || '900000'), // 15 minutes
    max: parseInt(process.env.RATE_LIMIT_MAX_REQUESTS || '100'),
    message: {
      error: 'Too many requests from this IP, please try again later.'
    },
    standardHeaders: true,
    legacyHeaders: false,
  });

  app.use(limiter);

  // Body parsing middleware
  app.use(express.json({ limit: '10mb' }));
  app.use(express.urlencoded({ extended: true, limit: '10mb' }));

  // Logging middleware
  if (process.env.NODE_ENV !== 'test') {
    app.use(morgan('combined'));
  }

  // Health check endpoint
  app.get('/health', async (req, res) => {
    try {
      // Check database connection
      await prisma.$queryRaw`SELECT 1`;
      res.status(200).json({
        status: 'healthy',
        timestamp: new Date().toISOString(),
        version: process.env.npm_package_version || '1.0.0',
        environment: process.env.NODE_ENV || 'development'
      });
    } catch (error) {
      res.status(503).json({
        status: 'unhealthy',
        timestamp: new Date().toISOString(),
        error: 'Database connection failed'
      });
    }
  });

  // API routes
  app.use('/api/auth', authRoutes);
  app.use('/api/users', userRoutes);
  app.use('/api/pharmacy', pharmacyRoutes);
  app.use('/api/patients', patientRoutes);

  // Protected routes
  app.use('/api/doctors', authenticate, doctorRoutes);
  app.use('/api/appointments', authenticate, appointmentRoutes);
  app.use('/api/laboratory', authenticate, labRoutes);
  app.use('/api/staff', authenticate, staffRoutes);
  app.use('/api/billing', authenticate, billingRoutes);
  app.use('/api/facility', authenticate, facilityRoutes);
  app.use('/api/reports', authenticate, reportsRoutes);
  app.use('/api/notifications', authenticate, notificationRoutes);

  // Developer tools: only exist when DEVELOPER_MODE=true (never in production).
  if (env.developerMode) {
    app.use('/api/developer', developerRoutes);
  }

  // Error handling middleware (must be last)
  app.use(errorHandler);

  // Graceful shutdown handlers
  const gracefulShutdown = async () => {
    console.log('Shutting down gracefully...');
    await prisma.$disconnect();
    process.exit(0);
  };

  process.on('SIGINT', gracefulShutdown);
  process.on('SIGTERM', gracefulShutdown);

  return app;
}

export type App = ReturnType<typeof createApp>;
