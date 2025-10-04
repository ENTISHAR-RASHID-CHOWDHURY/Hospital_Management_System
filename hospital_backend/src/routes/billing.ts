import express from 'express';
import { PrismaClient } from '@prisma/client';
import { authenticate } from '../middleware/auth.middleware';
import { z } from 'zod';

const router = express.Router();
const prisma = new PrismaClient();

// Input validation schemas
const createBillSchema = z.object({
  patientId: z.string(),
  dueDate: z.string().datetime(),
  items: z.array(z.object({
    description: z.string(),
    itemType: z.enum(['CONSULTATION', 'PROCEDURE', 'MEDICATION', 'LAB_TEST', 'RADIOLOGY', 'ROOM_CHARGE', 'SURGERY', 'OTHER']),
    referenceId: z.string().optional(),
    quantity: z.number().min(1).default(1),
    unitPrice: z.number().min(0)
  })).min(1),
  tax: z.number().min(0).default(0),
  discount: z.number().min(0).default(0),
  insuranceClaim: z.string().optional(),
  notes: z.string().optional()
});

const updateBillSchema = z.object({
  dueDate: z.string().datetime().optional(),
  tax: z.number().min(0).optional(),
  discount: z.number().min(0).optional(),
  insuranceClaim: z.string().optional(),
  notes: z.string().optional()
});

const paymentSchema = z.object({
  amount: z.number().min(0.01),
  paymentMethod: z.enum(['CASH', 'CREDIT_CARD', 'DEBIT_CARD', 'BANK_TRANSFER', 'CHECK', 'INSURANCE', 'OTHER']),
  referenceNumber: z.string().optional(),
  notes: z.string().optional()
});

// GET /api/billing/bills - Get bills with filters
router.get('/bills', authenticate, async (req, res) => {
  try {
    const {
      patientId,
      status,
      startDate,
      endDate,
      overdue,
      page = 1,
      limit = 10,
      search
    } = req.query;

    const where: any = {};
    
    if (patientId) where.patientId = patientId;
    if (status) where.status = status;
    
    // Date filtering
    if (startDate && endDate) {
      where.billDate = {
        gte: new Date(startDate as string),
        lte: new Date(endDate as string)
      };
    }
    
    // Overdue bills
    if (overdue === 'true') {
      where.dueDate = { lt: new Date() };
      where.status = { in: ['PENDING', 'SENT', 'PARTIAL'] };
    }

    // Search functionality
    if (search) {
      where.OR = [
        { billNumber: { contains: search as string, mode: 'insensitive' } },
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
    
    const [bills, total] = await Promise.all([
      prisma.bill.findMany({
        where,
        include: {
          patient: {
            select: {
              id: true,
              firstName: true,
              lastName: true,
              patientNumber: true,
              phone: true,
              email: true
            }
          },
          items: {
            select: {
              id: true,
              description: true,
              itemType: true,
              quantity: true,
              unitPrice: true,
              totalPrice: true
            }
          },
          payments: {
            select: {
              id: true,
              amount: true,
              paymentDate: true,
              paymentMethod: true
            },
            orderBy: { paymentDate: 'desc' }
          }
        },
        skip,
        take: Number(limit),
        orderBy: { billDate: 'desc' }
      }),
      prisma.bill.count({ where })
    ]);

    res.json({
      bills,
      pagination: {
        total,
        page: Number(page),
        limit: Number(limit),
        pages: Math.ceil(total / Number(limit))
      }
    });
  } catch (error) {
    console.error('Error fetching bills:', error);
    res.status(500).json({ error: 'Internal server error' });
  }
});

// GET /api/billing/bills/:id - Get bill by ID
router.get('/bills/:id', authenticate, async (req, res) => {
  try {
    const { id } = req.params;

    const bill = await prisma.bill.findUnique({
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
            address: true,
            insuranceInfo: true
          }
        },
        items: {
          orderBy: { createdAt: 'asc' }
        },
        payments: {
          orderBy: { paymentDate: 'desc' }
        }
      }
    });

    if (!bill) {
      return res.status(404).json({ error: 'Bill not found' });
    }

    res.json(bill);
  } catch (error) {
    console.error('Error fetching bill:', error);
    res.status(500).json({ error: 'Internal server error' });
  }
});

// POST /api/billing/bills - Create new bill
router.post('/bills', authenticate, async (req, res) => {
  try {
    const validatedData = createBillSchema.parse(req.body);
    
    // Check if patient exists
    const patient = await prisma.patient.findUnique({
      where: { id: validatedData.patientId }
    });

    if (!patient) {
      return res.status(400).json({ error: 'Patient not found' });
    }

    // Generate unique bill number
    const billCount = await prisma.bill.count();
    const billNumber = `BILL${String(billCount + 1).padStart(6, '0')}`;

    // Calculate totals
    const subtotal = validatedData.items.reduce((sum, item) => 
      sum + (item.quantity * item.unitPrice), 0
    );
    
    const totalAmount = subtotal + validatedData.tax - validatedData.discount;

    const bill = await prisma.bill.create({
      data: {
        patientId: validatedData.patientId,
        billNumber,
        dueDate: new Date(validatedData.dueDate),
        subtotal,
        tax: validatedData.tax,
        discount: validatedData.discount,
        totalAmount,
        insuranceClaim: validatedData.insuranceClaim,
        notes: validatedData.notes,
        items: {
          create: validatedData.items.map(item => ({
            ...item,
            totalPrice: item.quantity * item.unitPrice
          }))
        }
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
        },
        items: true
      }
    });

    res.status(201).json(bill);
  } catch (error) {
    if (error instanceof z.ZodError) {
      return res.status(400).json({ error: 'Validation error', details: error.issues });
    }
    console.error('Error creating bill:', error);
    res.status(500).json({ error: 'Internal server error' });
  }
});

// PUT /api/billing/bills/:id - Update bill
router.put('/bills/:id', authenticate, async (req, res) => {
  try {
    const { id } = req.params;
    const validatedData = updateBillSchema.parse(req.body);

    // Check if bill exists
    const existingBill = await prisma.bill.findUnique({
      where: { id }
    });

    if (!existingBill) {
      return res.status(404).json({ error: 'Bill not found' });
    }

    // Don't allow updates if bill is fully paid
    if (existingBill.status === 'PAID') {
      return res.status(400).json({ error: 'Cannot update paid bill' });
    }

    const updateData: any = {};
    if (validatedData.dueDate) updateData.dueDate = new Date(validatedData.dueDate);
    if (validatedData.tax !== undefined) updateData.tax = validatedData.tax;
    if (validatedData.discount !== undefined) updateData.discount = validatedData.discount;
    if (validatedData.insuranceClaim !== undefined) updateData.insuranceClaim = validatedData.insuranceClaim;
    if (validatedData.notes !== undefined) updateData.notes = validatedData.notes;

    // Recalculate total if tax or discount changed
    if (validatedData.tax !== undefined || validatedData.discount !== undefined) {
      const tax = validatedData.tax !== undefined ? validatedData.tax : existingBill.tax.toNumber();
      const discount = validatedData.discount !== undefined ? validatedData.discount : existingBill.discount.toNumber();
      updateData.totalAmount = existingBill.subtotal.toNumber() + tax - discount;
    }

    const bill = await prisma.bill.update({
      where: { id },
      data: updateData,
      include: {
        patient: {
          select: {
            id: true,
            firstName: true,
            lastName: true,
            patientNumber: true
          }
        },
        items: true,
        payments: true
      }
    });

    res.json(bill);
  } catch (error) {
    if (error instanceof z.ZodError) {
      return res.status(400).json({ error: 'Validation error', details: error.issues });
    }
    console.error('Error updating bill:', error);
    res.status(500).json({ error: 'Internal server error' });
  }
});

// PATCH /api/billing/bills/:id/status - Update bill status
router.patch('/bills/:id/status', authenticate, async (req, res) => {
  try {
    const { id } = req.params;
    const { status } = req.body;

    const validStatuses = ['PENDING', 'SENT', 'PAID', 'OVERDUE', 'CANCELLED', 'PARTIAL'];
    
    if (!validStatuses.includes(status)) {
      return res.status(400).json({ error: 'Invalid status' });
    }

    const bill = await prisma.bill.update({
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

    res.json(bill);
  } catch (error) {
    console.error('Error updating bill status:', error);
    res.status(500).json({ error: 'Internal server error' });
  }
});

// POST /api/billing/bills/:id/payments - Add payment to bill
router.post('/bills/:id/payments', authenticate, async (req, res) => {
  try {
    const { id } = req.params;
    const validatedData = paymentSchema.parse(req.body);

    // Check if bill exists
    const bill = await prisma.bill.findUnique({
      where: { id },
      include: { payments: true }
    });

    if (!bill) {
      return res.status(404).json({ error: 'Bill not found' });
    }

    if (bill.status === 'CANCELLED') {
      return res.status(400).json({ error: 'Cannot add payment to cancelled bill' });
    }

    // Check if payment amount doesn't exceed remaining balance
    const totalPaid = bill.paidAmount.toNumber();
    const totalAmount = bill.totalAmount.toNumber();
    const remainingBalance = totalAmount - totalPaid;

    if (validatedData.amount > remainingBalance) {
      return res.status(400).json({ 
        error: 'Payment amount exceeds remaining balance',
        remainingBalance,
        requestedAmount: validatedData.amount
      });
    }

    const payment = await prisma.payment.create({
      data: {
        ...validatedData,
        billId: id
      }
    });

    // Update bill's paid amount and status
    const newPaidAmount = totalPaid + validatedData.amount;
    let newStatus = bill.status;
    
    if (newPaidAmount >= totalAmount) {
      newStatus = 'PAID';
    } else if (newPaidAmount > 0) {
      newStatus = 'PARTIAL';
    }

    await prisma.bill.update({
      where: { id },
      data: {
        paidAmount: newPaidAmount,
        status: newStatus
      }
    });

    res.status(201).json(payment);
  } catch (error) {
    if (error instanceof z.ZodError) {
      return res.status(400).json({ error: 'Validation error', details: error.issues });
    }
    console.error('Error adding payment:', error);
    res.status(500).json({ error: 'Internal server error' });
  }
});

// GET /api/billing/payments - Get payments with filters
router.get('/payments', authenticate, async (req, res) => {
  try {
    const {
      billId,
      paymentMethod,
      startDate,
      endDate,
      page = 1,
      limit = 10
    } = req.query;

    const where: any = {};
    
    if (billId) where.billId = billId;
    if (paymentMethod) where.paymentMethod = paymentMethod;
    
    // Date filtering
    if (startDate && endDate) {
      where.paymentDate = {
        gte: new Date(startDate as string),
        lte: new Date(endDate as string)
      };
    }

    const skip = (Number(page) - 1) * Number(limit);
    
    const [payments, total] = await Promise.all([
      prisma.payment.findMany({
        where,
        include: {
          bill: {
            select: {
              billNumber: true,
              totalAmount: true,
              patient: {
                select: {
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
        orderBy: { paymentDate: 'desc' }
      }),
      prisma.payment.count({ where })
    ]);

    res.json({
      payments,
      pagination: {
        total,
        page: Number(page),
        limit: Number(limit),
        pages: Math.ceil(total / Number(limit))
      }
    });
  } catch (error) {
    console.error('Error fetching payments:', error);
    res.status(500).json({ error: 'Internal server error' });
  }
});

// POST /api/billing/bills/:id/items - Add item to bill
router.post('/bills/:id/items', authenticate, async (req, res) => {
  try {
    const { id } = req.params;
    const { description, itemType, referenceId, quantity = 1, unitPrice } = req.body;

    // Check if bill exists and is not paid
    const bill = await prisma.bill.findUnique({
      where: { id }
    });

    if (!bill) {
      return res.status(404).json({ error: 'Bill not found' });
    }

    if (bill.status === 'PAID') {
      return res.status(400).json({ error: 'Cannot add items to paid bill' });
    }

    const totalPrice = quantity * unitPrice;

    const item = await prisma.billItem.create({
      data: {
        billId: id,
        description,
        itemType,
        referenceId,
        quantity,
        unitPrice,
        totalPrice
      }
    });

    // Update bill totals
    const newSubtotal = bill.subtotal.toNumber() + totalPrice;
    const newTotalAmount = newSubtotal + bill.tax.toNumber() - bill.discount.toNumber();

    await prisma.bill.update({
      where: { id },
      data: {
        subtotal: newSubtotal,
        totalAmount: newTotalAmount
      }
    });

    res.status(201).json(item);
  } catch (error) {
    console.error('Error adding bill item:', error);
    res.status(500).json({ error: 'Internal server error' });
  }
});

// GET /api/billing/stats - Get billing statistics
router.get('/stats', authenticate, async (req, res) => {
  try {
    const today = new Date();
    const startOfDay = new Date(today.setHours(0, 0, 0, 0));
    const endOfDay = new Date(today.setHours(23, 59, 59, 999));
    const startOfMonth = new Date(today.getFullYear(), today.getMonth(), 1);
    const startOfWeek = new Date();
    startOfWeek.setDate(today.getDate() - 7);

    const [
      todayRevenue,
      monthRevenue,
      pendingBills,
      overdueBills,
      totalOutstanding,
      paidBillsCount,
      recentPayments
    ] = await Promise.all([
      prisma.payment.aggregate({
        where: {
          paymentDate: {
            gte: startOfDay,
            lte: endOfDay
          }
        },
        _sum: { amount: true }
      }),
      prisma.payment.aggregate({
        where: {
          paymentDate: {
            gte: startOfMonth
          }
        },
        _sum: { amount: true }
      }),
      prisma.bill.count({
        where: {
          status: { in: ['PENDING', 'SENT'] }
        }
      }),
      prisma.bill.count({
        where: {
          dueDate: { lt: new Date() },
          status: { in: ['PENDING', 'SENT', 'PARTIAL'] }
        }
      }),
      prisma.bill.aggregate({
        where: {
          status: { in: ['PENDING', 'SENT', 'PARTIAL'] }
        },
        _sum: { totalAmount: true }
      }),
      prisma.bill.count({
        where: { status: 'PAID' }
      }),
      prisma.payment.count({
        where: {
          paymentDate: {
            gte: startOfWeek
          }
        }
      })
    ]);

    res.json({
      todayRevenue: todayRevenue._sum.amount || 0,
      monthRevenue: monthRevenue._sum.amount || 0,
      pendingBills,
      overdueBills,
      totalOutstanding: totalOutstanding._sum.totalAmount || 0,
      paidBillsCount,
      recentPayments
    });
  } catch (error) {
    console.error('Error fetching billing stats:', error);
    res.status(500).json({ error: 'Internal server error' });
  }
});

// GET /api/billing/reports/revenue - Get revenue report
router.get('/reports/revenue', authenticate, async (req, res) => {
  try {
    const { startDate, endDate, groupBy = 'day' } = req.query;

    if (!startDate || !endDate) {
      return res.status(400).json({ error: 'Start date and end date are required' });
    }

    const payments = await prisma.payment.findMany({
      where: {
        paymentDate: {
          gte: new Date(startDate as string),
          lte: new Date(endDate as string)
        }
      },
      include: {
        bill: {
          select: {
            patient: {
              select: {
                firstName: true,
                lastName: true
              }
            }
          }
        }
      },
      orderBy: { paymentDate: 'asc' }
    });

    // Group payments by the specified period
    const grouped: { [key: string]: number } = {};
    
    payments.forEach(payment => {
      let key: string;
      const date = payment.paymentDate;
      
      switch (groupBy) {
        case 'month':
          key = `${date.getFullYear()}-${String(date.getMonth() + 1).padStart(2, '0')}`;
          break;
        case 'week':
          const startOfWeek = new Date(date);
          startOfWeek.setDate(date.getDate() - date.getDay());
          key = startOfWeek.toISOString().split('T')[0];
          break;
        default: // day
          key = date.toISOString().split('T')[0];
      }
      
      grouped[key] = (grouped[key] || 0) + payment.amount.toNumber();
    });

    const report = Object.entries(grouped).map(([period, amount]) => ({
      period,
      amount
    }));

    res.json({
      report,
      totalRevenue: payments.reduce((sum, p) => sum + p.amount.toNumber(), 0),
      totalPayments: payments.length
    });
  } catch (error) {
    console.error('Error generating revenue report:', error);
    res.status(500).json({ error: 'Internal server error' });
  }
});

// DELETE /api/billing/bills/:id - Cancel bill
router.delete('/bills/:id', authenticate, async (req, res) => {
  try {
    const { id } = req.params;
    const { reason } = req.body;

    const bill = await prisma.bill.findUnique({
      where: { id },
      include: { payments: true }
    });

    if (!bill) {
      return res.status(404).json({ error: 'Bill not found' });
    }

    if (bill.status === 'PAID') {
      return res.status(400).json({ error: 'Cannot cancel paid bill' });
    }

    if (bill.payments.length > 0) {
      return res.status(400).json({ error: 'Cannot cancel bill with payments. Please refund payments first.' });
    }

    const updatedBill = await prisma.bill.update({
      where: { id },
      data: {
        status: 'CANCELLED',
        notes: reason ? 
          `${bill.notes || ''}\nCancelled: ${reason}`.trim() :
          bill.notes
      }
    });

    res.json({ message: 'Bill cancelled successfully', bill: updatedBill });
  } catch (error) {
    console.error('Error cancelling bill:', error);
    res.status(500).json({ error: 'Internal server error' });
  }
});

export default router;