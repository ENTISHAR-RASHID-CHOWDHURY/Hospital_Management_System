import { Router, RequestHandler } from 'express';
import * as bcrypt from 'bcrypt';
import { PrismaClient } from '@prisma/client';
import { z } from 'zod';
import { signAccessToken, signRefreshToken, verifyRefreshToken, JwtPayloadData } from '../utils/token';
import { authenticate, AuthenticatedRequest } from '../middleware/auth';
import { AuditLogger } from '../utils/audit-logger';

// Type alias for authenticated route handlers  
type AuthenticatedHandler = (req: AuthenticatedRequest, res: any, next?: any) => any;

// Helper function to cast authenticated handlers
const authHandler = (handler: AuthenticatedHandler): any => handler;

const router = Router();
const prisma = new PrismaClient();
const auditLogger = new AuditLogger();

// Validation schemas
const loginSchema = z.object({
  email: z.string().email(),
  password: z.string().min(6),
  deviceInfo: z.string().optional()
});

const registerSchema = z.object({
  email: z.string().email(),
  password: z.string().min(6),
  firstName: z.string().min(1),
  lastName: z.string().min(1),
  phone: z.string().optional(),
  roleId: z.number().int().positive()
});

const changePasswordSchema = z.object({
  currentPassword: z.string(),
  newPassword: z.string().min(6)
});

// Helper function to generate tokens
const generateTokens = (userId: number, role: string) => {
  const payload: JwtPayloadData = {
    userId,
    id: userId,
    role
  };
  
  const accessToken = signAccessToken(payload);
  const refreshToken = signRefreshToken(payload);

  return { accessToken, refreshToken };
};

// POST /api/auth/login
router.post('/login', async (req, res) => {
  try {
    const { email, password, deviceInfo } = loginSchema.parse(req.body);

    // Find user with role and permissions
    const user = await prisma.user.findUnique({
      where: { email },
      include: {
        role: true
      }
    });

    if (!user || !user.isActive) {
      return res.status(401).json({ error: 'Invalid credentials' });
    }

    // Check password
    const validPassword = await bcrypt.compare(password, user.passwordHash);
    if (!validPassword) {
      // Log failed login attempt
      await auditLogger.log({
        userId: user.id,
        action: 'LOGIN_FAILED',
        module: 'auth',
        details: { reason: 'invalid_password' },
        ipAddress: req.ip || 'unknown',
        userAgent: req.get('User-Agent') || 'unknown'
      });
      
      return res.status(401).json({ error: 'Invalid credentials' });
    }

    // Generate tokens
    const { accessToken, refreshToken } = generateTokens(user.id, user.role.name);

    // Create session
    const session = await prisma.userSession.create({
      data: {
        userId: user.id,
        token: accessToken,
        deviceInfo: deviceInfo || req.get('User-Agent') || 'unknown',
        ipAddress: req.ip || 'unknown',
        expiresAt: new Date(Date.now() + 7 * 24 * 60 * 60 * 1000) // 7 days
      }
    });

    // Update last login
    await prisma.user.update({
      where: { id: user.id },
      data: { lastLogin: new Date() }
    });

    // Log successful login
    await auditLogger.log({
      userId: user.id,
      action: 'LOGIN_SUCCESS',
      module: 'auth',
      details: { sessionId: session.id },
      ipAddress: req.ip || 'unknown',
      userAgent: req.get('User-Agent') || 'unknown'
    });

    // Get user permissions
    const permissions = await prisma.permission.findMany({
      where: {
        roles: {
          some: {
            id: user.roleId
          }
        }
      }
    });

    // Return user data (excluding sensitive info)
    const { passwordHash: _, ...userWithoutPassword } = user;
    
    res.json({
      user: userWithoutPassword,
      tokens: {
        accessToken,
        refreshToken
      },
      permissions: permissions.map(p => p.name)
    });
  } catch (error) {
    if (error instanceof z.ZodError) {
      return res.status(400).json({ error: 'Invalid input', details: error.issues });
    }
    console.error('Login error:', error);
    res.status(500).json({ error: 'Internal server error' });
  }
});

// POST /api/auth/register
router.post('/register', async (req, res) => {
  try {
    const { email, password, firstName, lastName, phone, roleId } = registerSchema.parse(req.body);

    // Check if user already exists
    const existingUser = await prisma.user.findUnique({
      where: { email }
    });

    if (existingUser) {
      return res.status(400).json({ error: 'User already exists' });
    }

    // Verify role exists
    const role = await prisma.role.findUnique({
      where: { id: roleId }
    });

    if (!role) {
      return res.status(400).json({ error: 'Invalid role' });
    }

    // Hash password
    const saltRounds = parseInt(process.env.BCRYPT_ROUNDS || '12');
    const hashedPassword = await bcrypt.hash(password, saltRounds);

    // Create user
    const user = await prisma.user.create({
      data: {
        email,
        passwordHash: hashedPassword,
        displayName: `${firstName} ${lastName}`,
        firstName,
        lastName,
        phone,
        roleId
      },
      include: {
        role: true
      }
    });

    // Log user registration
    await auditLogger.log({
      userId: user.id,
      action: 'USER_REGISTERED',
      module: 'auth',
      details: { roleId },
      ipAddress: req.ip || 'unknown',
      userAgent: req.get('User-Agent') || 'unknown'
    });

    // Generate tokens
    const { accessToken, refreshToken } = generateTokens(user.id, user.role.name);

    // Create session
    await prisma.userSession.create({
      data: {
        userId: user.id,
        token: accessToken,
        deviceInfo: req.get('User-Agent') || 'unknown',
        ipAddress: req.ip || 'unknown',
        expiresAt: new Date(Date.now() + 7 * 24 * 60 * 60 * 1000)
      }
    });

    // Get user permissions
    const permissions = await prisma.permission.findMany({
      where: {
        roles: {
          some: {
            id: user.roleId
          }
        }
      }
    });

    // Return user data (excluding sensitive info)
    const { passwordHash: _, ...userWithoutPassword } = user;

    res.status(201).json({
      user: userWithoutPassword,
      tokens: {
        accessToken,
        refreshToken
      },
      permissions: permissions.map(p => p.name)
    });
  } catch (error) {
    if (error instanceof z.ZodError) {
      return res.status(400).json({ error: 'Invalid input', details: error.issues });
    }
    console.error('Registration error:', error);
    res.status(500).json({ error: 'Internal server error' });
  }
});

// POST /api/auth/logout  
(router.post as any)('/logout', authenticate, async (req: AuthenticatedRequest, res: any) => {
  try {
    const token = req.header('Authorization')?.replace('Bearer ', '');
    
    if (token) {
      // Deactivate session
      await prisma.userSession.updateMany({
        where: {
          token,
          userId: req.user!.id
        },
        data: {
          isActive: false
        }
      });

      // Log logout
      await auditLogger.log({
        userId: req.user!.id,
        action: 'LOGOUT',
        module: 'auth',
        ipAddress: req.ip || 'unknown',
        userAgent: req.get('User-Agent') || 'unknown'
      });
    }

    res.json({ message: 'Logged out successfully' });
  } catch (error) {
    console.error('Logout error:', error);
    res.status(500).json({ error: 'Internal server error' });
  }
});

// POST /api/auth/refresh
router.post('/refresh', async (req, res) => {
  try {
    const { refreshToken } = req.body;

    if (!refreshToken) {
      return res.status(401).json({ error: 'Refresh token required' });
    }

    const decoded = verifyRefreshToken(refreshToken);
      
      // Get user
      const user = await prisma.user.findUnique({
      where: { id: decoded.userId },
      include: {
        role: true
      }
    });

    if (!user || !user.isActive) {
      return res.status(401).json({ error: 'User not found or inactive' });
    }

    // Generate new tokens
    const tokens = generateTokens(user.id, user.role.name);

    // Get user permissions
    const permissions = await prisma.permission.findMany({
      where: {
        roles: {
          some: {
            id: user.roleId
          }
        }
      }
    });

    res.json({
      tokens,
      permissions: permissions.map(p => p.name)
    });
  } catch (error) {
    res.status(401).json({ error: 'Invalid refresh token' });
  }
});

// GET /api/auth/me
(router.get as any)('/me', authenticate, async (req: AuthenticatedRequest, res: any) => {
  try {
    const user = await prisma.user.findUnique({
      where: { id: req.user!.id },
      include: {
        role: true
      }
    });

    if (!user) {
      return res.status(404).json({ error: 'User not found' });
    }

    // Get user permissions
    const permissions = await prisma.permission.findMany({
      where: {
        roles: {
          some: {
            id: user.roleId
          }
        }
      }
    });

    // Get dashboard options
    const dashboardOptions = await prisma.dashboardOption.findMany({
      where: { roleId: user.roleId }
    });

    const { passwordHash: _, ...userWithoutPassword } = user;

    res.json({
      user: userWithoutPassword,
      permissions: permissions.map(p => p.name),
      dashboardOptions
    });
  } catch (error) {
    console.error('Get user error:', error);
    res.status(500).json({ error: 'Internal server error' });
  }
});

// PUT /api/auth/change-password
(router.put as any)('/change-password', authenticate, async (req: AuthenticatedRequest, res: any) => {
  try {
    const { currentPassword, newPassword } = changePasswordSchema.parse(req.body);

    const user = await prisma.user.findUnique({
      where: { id: req.user!.id }
    });

    if (!user) {
      return res.status(404).json({ error: 'User not found' });
    }

    // Verify current password
    const validPassword = await bcrypt.compare(currentPassword, user.passwordHash);
    if (!validPassword) {
      return res.status(400).json({ error: 'Current password is incorrect' });
    }

    // Hash new password
    const saltRounds = parseInt(process.env.BCRYPT_ROUNDS || '12');
    const newPasswordHash = await bcrypt.hash(newPassword, saltRounds);

    // Update password
    await prisma.user.update({
      where: { id: user.id },
      data: { passwordHash: newPasswordHash }
    });

    // Invalidate all sessions except current
    const currentToken = req.header('Authorization')?.replace('Bearer ', '');
    await prisma.userSession.updateMany({
      where: {
        userId: user.id,
        token: { not: currentToken }
      },
      data: { isActive: false }
    });

    // Log password change
    await auditLogger.log({
      userId: user.id,
      action: 'PASSWORD_CHANGED',
      module: 'auth',
      ipAddress: req.ip || 'unknown',
      userAgent: req.get('User-Agent') || 'unknown'
    });

    res.json({ message: 'Password changed successfully' });
  } catch (error) {
    if (error instanceof z.ZodError) {
      return res.status(400).json({ error: 'Invalid input', details: error.issues });
    }
    console.error('Change password error:', error);
    res.status(500).json({ error: 'Internal server error' });
  }
});

// GET /api/auth/sessions
(router.get as any)('/sessions', authenticate, async (req: AuthenticatedRequest, res: any) => {
  try {
    const sessions = await prisma.userSession.findMany({
      where: {
        userId: req.user!.id,
        isActive: true
      },
      select: {
        id: true,
        deviceInfo: true,
        ipAddress: true,
        createdAt: true,
        lastUsed: true
      },
      orderBy: { lastUsed: 'desc' }
    });

    res.json(sessions);
  } catch (error) {
    console.error('Get sessions error:', error);
    res.status(500).json({ error: 'Internal server error' });
  }
});

// DELETE /api/auth/sessions/:sessionId
(router.delete as any)('/sessions/:sessionId', authenticate, async (req: AuthenticatedRequest, res: any) => {
  try {
    await prisma.userSession.update({
      where: {
        id: req.params.sessionId,
        userId: req.user!.id
      },
      data: { isActive: false }
    });

    res.json({ message: 'Session terminated successfully' });
  } catch (error) {
    console.error('Terminate session error:', error);
    res.status(500).json({ error: 'Internal server error' });
  }
});

export default router;