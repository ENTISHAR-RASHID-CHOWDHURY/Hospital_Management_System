import { Router, Request, Response } from 'express';
import { authenticate, requireRoles } from '../middleware/auth.middleware';
import { prisma } from '../prisma';
import { z } from 'zod';

const router = Router();

// Simple validation schema matching current database structure
const createUserSchema = z.object({
  email: z.string().email(),
  passwordHash: z.string(),
  firstName: z.string().min(1),
  lastName: z.string().min(1),
  displayName: z.string(),
  roleId: z.number()
});

// Get all users (admin only)
router.get('/', 
  authenticate, 
  requireRoles('SUPER_ADMIN'), 
  async (req: Request, res: Response) => {
    try {
      const users = await prisma.user.findMany({
        select: {
          id: true,
          email: true,
          firstName: true,
          lastName: true,
          displayName: true,
          roleId: true,
          createdAt: true,
          updatedAt: true
        }
      });

      res.json({
        success: true,
        users,
        total: users.length
      });
    } catch (error) {
      console.error('Error fetching users:', error);
      res.status(500).json({
        success: false,
        error: 'Failed to fetch users'
      });
    }
  }
);

// Get user by ID
router.get('/:id', 
  authenticate, 
  requireRoles('SUPER_ADMIN'), 
  async (req: Request, res: Response) => {
    try {
      const { id } = req.params;
      
      const user = await prisma.user.findUnique({
        where: { id: parseInt(id) },
        select: {
          id: true,
          email: true,
          displayName: true,
          roleId: true,
          createdAt: true,
          updatedAt: true
        }
      });

      if (!user) {
        return res.status(404).json({
          success: false,
          error: 'User not found'
        });
      }

      res.json({
        success: true,
        user
      });
    } catch (error) {
      console.error('Error fetching user:', error);
      res.status(500).json({
        success: false,
        error: 'Failed to fetch user'
      });
    }
  }
);

// Create user (admin only)
router.post('/', 
  authenticate, 
  requireRoles('SUPER_ADMIN'), 
  async (req: Request, res: Response) => {
    try {
      const validatedData = createUserSchema.parse(req.body);
      
      const existingUser = await prisma.user.findUnique({
        where: { email: validatedData.email }
      });

      if (existingUser) {
        return res.status(400).json({
          success: false,
          error: 'User with this email already exists'
        });
      }

      const user = await prisma.user.create({
        data: validatedData,
        select: {
          id: true,
          email: true,
          firstName: true,
          lastName: true,
          displayName: true,
          roleId: true,
          createdAt: true,
          updatedAt: true
        }
      });

      res.status(201).json({
        success: true,
        user
      });
    } catch (error) {
      console.error('Error creating user:', error);
      if (error instanceof z.ZodError) {
        return res.status(400).json({
          success: false,
          error: 'Invalid input data',
          details: error.issues
        });
      }
      res.status(500).json({
        success: false,
        error: 'Failed to create user'
      });
    }
  }
);

// Update user
router.put('/:id', 
  authenticate, 
  requireRoles('SUPER_ADMIN'), 
  async (req: Request, res: Response) => {
    try {
      const { id } = req.params;
      const updates = createUserSchema.partial().parse(req.body);

      const existingUser = await prisma.user.findUnique({
        where: { id: parseInt(id) }
      });

      if (!existingUser) {
        return res.status(404).json({
          success: false,
          error: 'User not found'
        });
      }

      const user = await prisma.user.update({
        where: { id: parseInt(id) },
        data: {
          ...updates,
          updatedAt: new Date()
        },
        select: {
          id: true,
          email: true,
          displayName: true,
          roleId: true,
          createdAt: true,
          updatedAt: true
        }
      });

      res.json({
        success: true,
        user
      });
    } catch (error) {
      console.error('Error updating user:', error);
      if (error instanceof z.ZodError) {
        return res.status(400).json({
          success: false,
          error: 'Invalid input data',
          details: error.issues
        });
      }
      res.status(500).json({
        success: false,
        error: 'Failed to update user'
      });
    }
  }
);

// Delete user
router.delete('/:id', 
  authenticate, 
  requireRoles('SUPER_ADMIN'), 
  async (req: Request, res: Response) => {
    try {
      const { id } = req.params;

      const existingUser = await prisma.user.findUnique({
        where: { id: parseInt(id) }
      });

      if (!existingUser) {
        return res.status(404).json({
          success: false,
          error: 'User not found'
        });
      }

      await prisma.user.delete({
        where: { id: parseInt(id) }
      });

      res.json({
        success: true,
        message: 'User deleted successfully'
      });
    } catch (error) {
      console.error('Error deleting user:', error);
      res.status(500).json({
        success: false,
        error: 'Failed to delete user'
      });
    }
  }
);

export default router;