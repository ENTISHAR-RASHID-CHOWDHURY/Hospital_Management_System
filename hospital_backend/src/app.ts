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
// import doctorRoutes from './routes/doctors';
// import appointmentRoutes from './routes/appointments';
// import labRoutes from './routes/laboratory';
// import staffRoutes from './routes/staff';
// import billingRoutes from './routes/billing';
// import facilityRoutes from './routes/facility';
// import reportsRoutes from './routes/reports';
// import notificationRoutes from './routes/notifications';
import { authenticate } from './middleware/auth.middleware';

// Import middleware

import { errorHandler } from './middleware/error.middleware';

dotenv.config();

export function createApp() {
  const app = express();
  const prisma = new PrismaClient();

  app.set('trust proxy', true);

  // Security middleware
  app.use(helmet());

  // CORS configuration - Allow all localhost and 127.0.0.1 ports for development
  app.use(cors({
    origin: (origin, callback) => {
      // Allow requests with no origin (like mobile apps or curl requests)
      if (!origin) return callback(null, true);
      
      // Allow any localhost or 127.0.0.1 origin in development
      if (process.env.NODE_ENV === 'development' || process.env.NODE_ENV !== 'production') {
        if (origin.startsWith('http://localhost:') || origin.startsWith('http://127.0.0.1:')) {
          return callback(null, true);
        }
      }
      
      // Allow specific origins in production
      const allowedOrigins = [
        'http://localhost:8080',
        'http://127.0.0.1:8080',
        process.env.FRONTEND_URL
      ].filter(Boolean);
      
      if (allowedOrigins.includes(origin)) {
        return callback(null, true);
      }
      
      callback(new Error('Not allowed by CORS'));
    },
    credentials: true,
    methods: ['GET', 'POST', 'PUT', 'DELETE', 'PATCH'],
    allowedHeaders: ['Content-Type', 'Authorization']
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

  // Protected routes (commented out temporarily due to compilation issues)
  // app.use('/api/doctors', authenticate, doctorRoutes);
  // app.use('/api/appointments', authenticate, appointmentRoutes);
  // app.use('/api/laboratory', authenticate, labRoutes);
  // app.use('/api/staff', authenticate, staffRoutes);
  // app.use('/api/billing', authenticate, billingRoutes);
  // app.use('/api/facility', authenticate, facilityRoutes);
  // app.use('/api/reports', authenticate, reportsRoutes);
  // app.use('/api/notifications', authenticate, notificationRoutes);
  // app.use('/api/audit', authenticate, auditRoutes);

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
