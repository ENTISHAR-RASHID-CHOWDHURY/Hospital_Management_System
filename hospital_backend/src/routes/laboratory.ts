import express from 'express';
import { PrismaClient } from '@prisma/client';
import { authenticate } from '../middleware/auth.middleware';
import { z } from 'zod';

const router = express.Router();
const prisma = new PrismaClient();

// Input validation schemas
const createLabOrderSchema = z.object({
  patientId: z.string(),
  doctorId: z.string().optional(),
  testTypes: z.array(z.string()).min(1),
  urgency: z.enum(['ROUTINE', 'URGENT', 'STAT']).default('ROUTINE'),
  instructions: z.string().optional(),
  clinicalInfo: z.string().optional()
});

const updateLabOrderSchema = createLabOrderSchema.partial();

const labResultSchema = z.object({
  testName: z.string(),
  value: z.string(),
  unit: z.string().optional(),
  referenceRange: z.string().optional(),
  status: z.enum(['NORMAL', 'ABNORMAL', 'CRITICAL', 'PENDING']).default('NORMAL'),
  notes: z.string().optional(),
  performedBy: z.string().optional(),
  verifiedBy: z.string().optional()
});

// GET /api/laboratory/orders - Get lab orders with filters
router.get('/orders', authenticate, async (req, res) => {
  try {
    const {
      patientId,
      doctorId,
      status,
      urgency,
      startDate,
      endDate,
      page = 1,
      limit = 10,
      search
    } = req.query;

    const where: any = {};
    
    if (patientId) where.patientId = patientId;
    if (doctorId) where.doctorId = doctorId;
    if (status) where.status = status;
    if (urgency) where.urgency = urgency;
    
    // Date filtering
    if (startDate && endDate) {
      where.orderDate = {
        gte: new Date(startDate as string),
        lte: new Date(endDate as string)
      };
    }

    // Search functionality
    if (search) {
      where.OR = [
        { orderNumber: { contains: search as string, mode: 'insensitive' } },
        { testTypes: { hasSome: [search as string] } },
        { patient: { 
          OR: [
            { firstName: { contains: search as string, mode: 'insensitive' } },
            { lastName: { contains: search as string, mode: 'insensitive' } },
            { patientNumber: { contains: search as string, mode: 'insensitive' } }
          ]
        }}
      ];
    }

    const skip = (Number(page) - 1) * Number(limit);
    
    const [orders, total] = await Promise.all([
      prisma.labOrder.findMany({
        where,
        include: {
          patient: {
            select: {
              id: true,
              firstName: true,
              lastName: true,
              patientNumber: true,
              phone: true,
              dateOfBirth: true
            }
          },
          results: {
            select: {
              id: true,
              testName: true,
              value: true,
              unit: true,
              status: true,
              reportedAt: true
            }
          }
        },
        skip,
        take: Number(limit),
        orderBy: { orderDate: 'desc' }
      }),
      prisma.labOrder.count({ where })
    ]);

    res.json({
      orders,
      pagination: {
        total,
        page: Number(page),
        limit: Number(limit),
        pages: Math.ceil(total / Number(limit))
      }
    });
  } catch (error) {
    console.error('Error fetching lab orders:', error);
    res.status(500).json({ error: 'Internal server error' });
  }
});

// GET /api/laboratory/orders/:id - Get lab order by ID
router.get('/orders/:id', authenticate, async (req, res) => {
  try {
    const { id } = req.params;

    const order = await prisma.labOrder.findUnique({
      where: { id },
      include: {
        patient: {
          select: {
            id: true,
            firstName: true,
            lastName: true,
            patientNumber: true,
            phone: true,
            email: true,
            dateOfBirth: true,
            gender: true,
            bloodType: true,
            allergies: true,
            chronicConditions: true
          }
        },
        results: {
          orderBy: { createdAt: 'asc' }
        }
      }
    });

    if (!order) {
      return res.status(404).json({ error: 'Lab order not found' });
    }

    res.json(order);
  } catch (error) {
    console.error('Error fetching lab order:', error);
    res.status(500).json({ error: 'Internal server error' });
  }
});

// POST /api/laboratory/orders - Create new lab order
router.post('/orders', authenticate, async (req, res) => {
  try {
    const validatedData = createLabOrderSchema.parse(req.body);
    
    // Check if patient exists
    const patient = await prisma.patient.findUnique({
      where: { id: validatedData.patientId }
    });

    if (!patient) {
      return res.status(400).json({ error: 'Patient not found' });
    }

    // If doctorId is provided, check if doctor exists
    if (validatedData.doctorId) {
      const doctor = await prisma.doctor.findUnique({
        where: { id: validatedData.doctorId }
      });

      if (!doctor) {
        return res.status(400).json({ error: 'Doctor not found' });
      }
    }

    // Generate unique order number
    const orderCount = await prisma.labOrder.count();
    const orderNumber = `LAB${String(orderCount + 1).padStart(6, '0')}`;

    const order = await prisma.labOrder.create({
      data: {
        ...validatedData,
        orderNumber
      },
      include: {
        patient: {
          select: {
            id: true,
            firstName: true,
            lastName: true,
            patientNumber: true,
            phone: true
          }
        }
      }
    });

    res.status(201).json(order);
  } catch (error) {
    if (error instanceof z.ZodError) {
      return res.status(400).json({ error: 'Validation error', details: error.issues });
    }
    console.error('Error creating lab order:', error);
    res.status(500).json({ error: 'Internal server error' });
  }
});

// PUT /api/laboratory/orders/:id - Update lab order
router.put('/orders/:id', authenticate, async (req, res) => {
  try {
    const { id } = req.params;
    const validatedData = updateLabOrderSchema.parse(req.body);

    // Check if order exists
    const existingOrder = await prisma.labOrder.findUnique({
      where: { id }
    });

    if (!existingOrder) {
      return res.status(404).json({ error: 'Lab order not found' });
    }

    // Don't allow updates if order is completed
    if (existingOrder.status === 'COMPLETED') {
      return res.status(400).json({ error: 'Cannot update completed lab order' });
    }

    const order = await prisma.labOrder.update({
      where: { id },
      data: validatedData,
      include: {
        patient: {
          select: {
            id: true,
            firstName: true,
            lastName: true,
            patientNumber: true
          }
        },
        results: true
      }
    });

    res.json(order);
  } catch (error) {
    if (error instanceof z.ZodError) {
      return res.status(400).json({ error: 'Validation error', details: error.issues });
    }
    console.error('Error updating lab order:', error);
    res.status(500).json({ error: 'Internal server error' });
  }
});

// PATCH /api/laboratory/orders/:id/status - Update lab order status
router.patch('/orders/:id/status', authenticate, async (req, res) => {
  try {
    const { id } = req.params;
    const { status } = req.body;

    const validStatuses = ['PENDING', 'IN_PROGRESS', 'COMPLETED', 'CANCELLED', 'REJECTED'];
    
    if (!validStatuses.includes(status)) {
      return res.status(400).json({ error: 'Invalid status' });
    }

    const order = await prisma.labOrder.update({
      where: { id },
      data: { status },
      include: {
        patient: {
          select: {
            firstName: true,
            lastName: true,
            patientNumber: true
          }
        }
      }
    });

    res.json(order);
  } catch (error) {
    console.error('Error updating lab order status:', error);
    res.status(500).json({ error: 'Internal server error' });
  }
});

// POST /api/laboratory/orders/:id/results - Add result to lab order
router.post('/orders/:id/results', authenticate, async (req, res) => {
  try {
    const { id } = req.params;
    const validatedData = labResultSchema.parse(req.body);

    // Check if order exists
    const order = await prisma.labOrder.findUnique({
      where: { id }
    });

    if (!order) {
      return res.status(404).json({ error: 'Lab order not found' });
    }

    // Check if test is part of the order
    if (!order.testTypes.includes(validatedData.testName)) {
      return res.status(400).json({ error: 'Test not included in this order' });
    }

    const result = await prisma.labResult.create({
      data: {
        ...validatedData,
        labOrderId: id,
        reportedAt: new Date()
      }
    });

    // Check if all tests have results, then mark order as completed
    const allResults = await prisma.labResult.findMany({
      where: { labOrderId: id }
    });

    const completedTests = allResults.map(r => r.testName);
    const allTestsCompleted = order.testTypes.every(test => completedTests.includes(test));

    if (allTestsCompleted && order.status !== 'COMPLETED') {
      await prisma.labOrder.update({
        where: { id },
        data: { status: 'COMPLETED' }
      });
    }

    res.status(201).json(result);
  } catch (error) {
    if (error instanceof z.ZodError) {
      return res.status(400).json({ error: 'Validation error', details: error.issues });
    }
    console.error('Error adding lab result:', error);
    res.status(500).json({ error: 'Internal server error' });
  }
});

// PUT /api/laboratory/results/:id - Update lab result
router.put('/results/:id', authenticate, async (req, res) => {
  try {
    const { id } = req.params;
    const validatedData = labResultSchema.partial().parse(req.body);

    const result = await prisma.labResult.update({
      where: { id },
      data: {
        ...validatedData,
        reportedAt: new Date()
      },
      include: {
        labOrder: {
          select: {
            orderNumber: true,
            patient: {
              select: {
                firstName: true,
                lastName: true,
                patientNumber: true
              }
            }
          }
        }
      }
    });

    res.json(result);
  } catch (error) {
    if (error instanceof z.ZodError) {
      return res.status(400).json({ error: 'Validation error', details: error.issues });
    }
    console.error('Error updating lab result:', error);
    res.status(500).json({ error: 'Internal server error' });
  }
});

// GET /api/laboratory/results - Get lab results with filters
router.get('/results', authenticate, async (req, res) => {
  try {
    const {
      patientId,
      testName,
      status,
      startDate,
      endDate,
      page = 1,
      limit = 10
    } = req.query;

    const where: any = {};
    
    if (patientId) {
      where.labOrder = { patientId };
    }
    
    if (testName) where.testName = { contains: testName as string, mode: 'insensitive' };
    if (status) where.status = status;
    
    // Date filtering
    if (startDate && endDate) {
      where.reportedAt = {
        gte: new Date(startDate as string),
        lte: new Date(endDate as string)
      };
    }

    const skip = (Number(page) - 1) * Number(limit);
    
    const [results, total] = await Promise.all([
      prisma.labResult.findMany({
        where,
        include: {
          labOrder: {
            select: {
              orderNumber: true,
              orderDate: true,
              urgency: true,
              patient: {
                select: {
                  id: true,
                  firstName: true,
                  lastName: true,
                  patientNumber: true
                }
              }
            }
          }
        },
        skip,
        take: Number(limit),
        orderBy: { reportedAt: 'desc' }
      }),
      prisma.labResult.count({ where })
    ]);

    res.json({
      results,
      pagination: {
        total,
        page: Number(page),
        limit: Number(limit),
        pages: Math.ceil(total / Number(limit))
      }
    });
  } catch (error) {
    console.error('Error fetching lab results:', error);
    res.status(500).json({ error: 'Internal server error' });
  }
});

// GET /api/laboratory/results/:id - Get lab result by ID
router.get('/results/:id', authenticate, async (req, res) => {
  try {
    const { id } = req.params;

    const result = await prisma.labResult.findUnique({
      where: { id },
      include: {
        labOrder: {
          include: {
            patient: {
              select: {
                id: true,
                firstName: true,
                lastName: true,
                patientNumber: true,
                phone: true,
                email: true,
                dateOfBirth: true,
                gender: true
              }
            }
          }
        }
      }
    });

    if (!result) {
      return res.status(404).json({ error: 'Lab result not found' });
    }

    res.json(result);
  } catch (error) {
    console.error('Error fetching lab result:', error);
    res.status(500).json({ error: 'Internal server error' });
  }
});

// GET /api/laboratory/stats - Get laboratory statistics
router.get('/stats', authenticate, async (req, res) => {
  try {
    const today = new Date();
    const startOfDay = new Date(today.setHours(0, 0, 0, 0));
    const endOfDay = new Date(today.setHours(23, 59, 59, 999));
    const startOfWeek = new Date();
    startOfWeek.setDate(today.getDate() - 7);

    const [
      todayOrders,
      weekOrders,
      pendingOrders,
      urgentOrders,
      completedResults,
      criticalResults
    ] = await Promise.all([
      prisma.labOrder.count({
        where: {
          orderDate: {
            gte: startOfDay,
            lte: endOfDay
          }
        }
      }),
      prisma.labOrder.count({
        where: {
          orderDate: {
            gte: startOfWeek
          }
        }
      }),
      prisma.labOrder.count({
        where: {
          status: { in: ['PENDING', 'IN_PROGRESS'] }
        }
      }),
      prisma.labOrder.count({
        where: {
          urgency: { in: ['URGENT', 'STAT'] },
          status: { in: ['PENDING', 'IN_PROGRESS'] }
        }
      }),
      prisma.labResult.count({
        where: {
          reportedAt: {
            gte: startOfDay,
            lte: endOfDay
          }
        }
      }),
      prisma.labResult.count({
        where: {
          status: 'CRITICAL',
          reportedAt: {
            gte: startOfWeek
          }
        }
      })
    ]);

    res.json({
      todayOrders,
      weekOrders,
      pendingOrders,
      urgentOrders,
      completedResults,
      criticalResults
    });
  } catch (error) {
    console.error('Error fetching lab stats:', error);
    res.status(500).json({ error: 'Internal server error' });
  }
});

// DELETE /api/laboratory/orders/:id - Cancel lab order
router.delete('/orders/:id', authenticate, async (req, res) => {
  try {
    const { id } = req.params;
    const { reason } = req.body;

    const order = await prisma.labOrder.findUnique({
      where: { id }
    });

    if (!order) {
      return res.status(404).json({ error: 'Lab order not found' });
    }

    if (order.status === 'COMPLETED') {
      return res.status(400).json({ error: 'Cannot cancel completed lab order' });
    }

    const updatedOrder = await prisma.labOrder.update({
      where: { id },
      data: {
        status: 'CANCELLED',
        instructions: reason ? 
          `${order.instructions || ''}\nCancelled: ${reason}`.trim() :
          order.instructions
      }
    });

    res.json({ message: 'Lab order cancelled successfully', order: updatedOrder });
  } catch (error) {
    console.error('Error cancelling lab order:', error);
    res.status(500).json({ error: 'Internal server error' });
  }
});

export default router;