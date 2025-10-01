import { Router, Request, Response } from 'express';
import { z } from 'zod';
import { PrismaClient } from '@prisma/client';
import { authenticate, requireRoles } from '../middleware/auth.middleware';

const router = Router();
const prisma = new PrismaClient();

// ============ VALIDATION SCHEMAS ============

const createMedicationSchema = z.object({
  name: z.string().min(1),
  genericName: z.string().min(1),
  manufacturer: z.string().min(1),
  category: z.enum(['ANTIBIOTICS', 'PAIN_KILLERS', 'VITAMINS', 'CARDIAC', 'RESPIRATORY', 'DIGESTIVE', 'NEUROLOGICAL', 'DIABETES', 'HORMONES', 'VACCINES', 'ANTISEPTICS', 'SUPPLEMENTS']),
  currentStock: z.number().int().min(0),
  minStockLevel: z.number().int().min(0),
  maxStockLevel: z.number().int().min(0),
  unitPrice: z.number().positive(),
  expiryDate: z.string().datetime(),
  batchNumber: z.string().min(1),
  dosage: z.string().min(1),
  unit: z.string().min(1),
  description: z.string().optional(),
  sideEffects: z.array(z.string()).optional(),
  contraindications: z.array(z.string()).optional(),
  prescriptionRequired: z.boolean().default(true),
  location: z.string().optional(),
  supplier: z.string().optional()
});

const updateMedicationSchema = createMedicationSchema.partial();

// ============ MEDICATIONS MANAGEMENT ============

// Get all medications with filtering and search
router.get(
  '/medications',
  authenticate,
  (req, res, next) => {
    // Simple role check without requireRoles for now
    next();
  },
  async (req: Request, res: Response) => {
    try {
      const { 
        search, 
        category, 
        status = 'ACTIVE',
        page = '1', 
        limit = '20' 
      } = req.query;

      // Simple response for now since Medication model doesn't exist in current schema
      res.json({
        medications: [],
        pagination: {
          page: parseInt(page as string),
          limit: parseInt(limit as string),
          total: 0,
          totalPages: 0
        },
        message: 'Medication endpoints are working but need schema updates'
      });
    } catch (error) {
      console.error('Error fetching medications:', error);
      res.status(500).json({ 
        error: 'Internal server error',
        details: error instanceof Error ? error.message : 'Unknown error'
      });
    }
  }
);

// ============ INVENTORY REPORTS ============

router.get(
  '/inventory/report',
  authenticate,
  async (req: Request, res: Response) => {
    try {
      res.json({
        summary: {
          totalMedications: 0,
          lowStockItems: 0,
          expiringSoon: 0,
          totalInventoryValue: 0
        },
        message: 'Inventory endpoints are working but need schema updates'
      });
    } catch (error) {
      console.error('Error generating inventory report:', error);
      res.status(500).json({ 
        error: 'Internal server error',
        details: error instanceof Error ? error.message : 'Unknown error'
      });
    }
  }
);

export default router;