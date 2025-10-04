import express from 'express';
import { PrismaClient } from '@prisma/client';
import { authenticate } from '../middleware/auth.middleware';
import { z } from 'zod';

const router = express.Router();
const prisma = new PrismaClient();

// Input validation schemas
const createNotificationSchema = z.object({
  userId: z.number(),
  title: z.string().min(1),
  message: z.string().min(1),
  type: z.enum(['APPOINTMENT_REMINDER', 'LAB_RESULT', 'PRESCRIPTION_READY', 'BILL_DUE', 'SYSTEM_ALERT', 'GENERAL']),
  priority: z.enum(['LOW', 'NORMAL', 'HIGH', 'CRITICAL']).default('NORMAL'),
  data: z.record(z.string(), z.any()).optional()
});

const bulkNotificationSchema = z.object({
  userIds: z.array(z.number()).min(1),
  title: z.string().min(1),
  message: z.string().min(1),
  type: z.enum(['APPOINTMENT_REMINDER', 'LAB_RESULT', 'PRESCRIPTION_READY', 'BILL_DUE', 'SYSTEM_ALERT', 'GENERAL']),
  priority: z.enum(['LOW', 'NORMAL', 'HIGH', 'CRITICAL']).default('NORMAL'),
  data: z.record(z.string(), z.any()).optional()
});

// GET /api/notifications - Get notifications for authenticated user
router.get('/', authenticate, async (req, res) => {
  try {
    const {
      unread,
      type,
      priority,
      page = 1,
      limit = 20
    } = req.query;

    const userId = (req as any).user.id;
    
    const where: any = { userId };
    
    if (unread === 'true') where.isRead = false;
    if (type) where.type = type;
    if (priority) where.priority = priority;

    const skip = (Number(page) - 1) * Number(limit);
    
    const [notifications, total, unreadCount] = await Promise.all([
      prisma.notification.findMany({
        where,
        skip,
        take: Number(limit),
        orderBy: { createdAt: 'desc' }
      }),
      prisma.notification.count({ where }),
      prisma.notification.count({
        where: {
          userId,
          isRead: false
        }
      })
    ]);

    res.json({
      notifications,
      pagination: {
        total,
        page: Number(page),
        limit: Number(limit),
        pages: Math.ceil(total / Number(limit))
      },
      unreadCount
    });
  } catch (error) {
    console.error('Error fetching notifications:', error);
    res.status(500).json({ error: 'Internal server error' });
  }
});

// GET /api/notifications/unread-count - Get unread notification count
router.get('/unread-count', authenticate, async (req, res) => {
  try {
    const userId = (req as any).user.id;
    
    const unreadCount = await prisma.notification.count({
      where: {
        userId,
        isRead: false
      }
    });

    res.json({ unreadCount });
  } catch (error) {
    console.error('Error fetching unread count:', error);
    res.status(500).json({ error: 'Internal server error' });
  }
});

// GET /api/notifications/:id - Get notification by ID
router.get('/:id', authenticate, async (req, res) => {
  try {
    const { id } = req.params;
    const userId = (req as any).user.id;

    const notification = await prisma.notification.findFirst({
      where: {
        id,
        userId // Ensure user can only access their own notifications
      }
    });

    if (!notification) {
      return res.status(404).json({ error: 'Notification not found' });
    }

    res.json(notification);
  } catch (error) {
    console.error('Error fetching notification:', error);
    res.status(500).json({ error: 'Internal server error' });
  }
});

// POST /api/notifications - Create new notification (admin only)
router.post('/', authenticate, async (req, res) => {
  try {
    // Check if user has permission to create notifications
    const currentUser = (req as any).user;
    if (currentUser.role.name !== 'SUPER_ADMIN') {
      return res.status(403).json({ error: 'Insufficient permissions' });
    }

    const validatedData = createNotificationSchema.parse(req.body);
    
    // Check if target user exists
    const targetUser = await prisma.user.findUnique({
      where: { id: validatedData.userId }
    });

    if (!targetUser) {
      return res.status(400).json({ error: 'Target user not found' });
    }

    const notification = await prisma.notification.create({
      data: {
        ...validatedData,
        data: validatedData.data as any
      }
    });

    res.status(201).json(notification);
  } catch (error) {
    if (error instanceof z.ZodError) {
      return res.status(400).json({ error: 'Validation error', details: error.issues });
    }
    console.error('Error creating notification:', error);
    res.status(500).json({ error: 'Internal server error' });
  }
});

// POST /api/notifications/bulk - Create bulk notifications (admin only)
router.post('/bulk', authenticate, async (req, res) => {
  try {
    // Check if user has permission to create notifications
    const currentUser = (req as any).user;
    if (currentUser.role.name !== 'SUPER_ADMIN') {
      return res.status(403).json({ error: 'Insufficient permissions' });
    }

    const validatedData = bulkNotificationSchema.parse(req.body);
    
    // Check if all target users exist
    const targetUsers = await prisma.user.findMany({
      where: {
        id: { in: validatedData.userIds }
      }
    });

    if (targetUsers.length !== validatedData.userIds.length) {
      return res.status(400).json({ error: 'One or more target users not found' });
    }

    // Create notifications for all users
    const notifications = await prisma.notification.createMany({
      data: validatedData.userIds.map(userId => ({
        userId,
        title: validatedData.title,
        message: validatedData.message,
        type: validatedData.type,
        priority: validatedData.priority,
        data: validatedData.data as any
      }))
    });

    res.status(201).json({
      message: `${notifications.count} notifications created successfully`,
      count: notifications.count
    });
  } catch (error) {
    if (error instanceof z.ZodError) {
      return res.status(400).json({ error: 'Validation error', details: error.issues });
    }
    console.error('Error creating bulk notifications:', error);
    res.status(500).json({ error: 'Internal server error' });
  }
});

// PATCH /api/notifications/:id/read - Mark notification as read
router.patch('/:id/read', authenticate, async (req, res) => {
  try {
    const { id } = req.params;
    const userId = (req as any).user.id;

    // Check if notification belongs to the user
    const notification = await prisma.notification.findFirst({
      where: {
        id,
        userId
      }
    });

    if (!notification) {
      return res.status(404).json({ error: 'Notification not found' });
    }

    const updatedNotification = await prisma.notification.update({
      where: { id },
      data: {
        isRead: true,
        readAt: new Date()
      }
    });

    res.json(updatedNotification);
  } catch (error) {
    console.error('Error marking notification as read:', error);
    res.status(500).json({ error: 'Internal server error' });
  }
});

// PATCH /api/notifications/mark-all-read - Mark all notifications as read
router.patch('/mark-all-read', authenticate, async (req, res) => {
  try {
    const userId = (req as any).user.id;

    const result = await prisma.notification.updateMany({
      where: {
        userId,
        isRead: false
      },
      data: {
        isRead: true,
        readAt: new Date()
      }
    });

    res.json({
      message: `${result.count} notifications marked as read`,
      count: result.count
    });
  } catch (error) {
    console.error('Error marking all notifications as read:', error);
    res.status(500).json({ error: 'Internal server error' });
  }
});

// POST /api/notifications/appointment-reminders - Send appointment reminders (system)
router.post('/appointment-reminders', authenticate, async (req, res) => {
  try {
    // Check if user has admin permissions
    const currentUser = (req as any).user;
    if (currentUser.role.name !== 'SUPER_ADMIN') {
      return res.status(403).json({ error: 'Insufficient permissions' });
    }

    // Get appointments for tomorrow
    const tomorrow = new Date();
    tomorrow.setDate(tomorrow.getDate() + 1);
    const startOfTomorrow = new Date(tomorrow.setHours(0, 0, 0, 0));
    const endOfTomorrow = new Date(tomorrow.setHours(23, 59, 59, 999));

    const appointments = await prisma.appointment.findMany({
      where: {
        appointmentDate: {
          gte: startOfTomorrow,
          lte: endOfTomorrow
        },
        status: { in: ['SCHEDULED', 'CONFIRMED'] }
      },
      include: {
        patient: {
          include: {
            user: {
              select: {
                id: true,
                firstName: true,
                lastName: true
              }
            }
          }
        },
        doctor: {
          include: {
            user: {
              select: {
                firstName: true,
                lastName: true
              }
            },
            department: {
              select: {
                name: true
              }
            }
          }
        }
      }
    });

    // Create notifications for patients with appointments
    const notifications: any[] = [];
    for (const appointment of appointments) {
      if (appointment.patient.user) {
        const appointmentTime = appointment.appointmentDate.toLocaleTimeString('en-US', {
          hour: '2-digit',
          minute: '2-digit'
        });

        notifications.push({
          userId: appointment.patient.user.id,
          title: 'Appointment Reminder',
          message: `You have an appointment tomorrow at ${appointmentTime} with Dr. ${appointment.doctor.user.firstName} ${appointment.doctor.user.lastName} in ${appointment.doctor.department.name}`,
          type: 'APPOINTMENT_REMINDER' as const,
          priority: 'NORMAL' as const,
          data: {
            appointmentId: appointment.id,
            appointmentDate: appointment.appointmentDate,
            doctorName: `${appointment.doctor.user.firstName} ${appointment.doctor.user.lastName}`,
            department: appointment.doctor.department.name
          }
        });
      }
    }

    if (notifications.length > 0) {
      await prisma.notification.createMany({
        data: notifications
      });
    }

    res.json({
      message: `${notifications.length} appointment reminders sent`,
      count: notifications.length
    });
  } catch (error) {
    console.error('Error sending appointment reminders:', error);
    res.status(500).json({ error: 'Internal server error' });
  }
});

// POST /api/notifications/lab-results - Notify about lab results (system)
router.post('/lab-results', authenticate, async (req, res) => {
  try {
    // Check if user has admin permissions
    const currentUser = (req as any).user;
    if (currentUser.role.name !== 'SUPER_ADMIN') {
      return res.status(403).json({ error: 'Insufficient permissions' });
    }

    const { labOrderId } = req.body;

    if (!labOrderId) {
      return res.status(400).json({ error: 'Lab order ID is required' });
    }

    // Get lab order with results
    const labOrder = await prisma.labOrder.findUnique({
      where: { id: labOrderId },
      include: {
        patient: {
          include: {
            user: {
              select: {
                id: true,
                firstName: true,
                lastName: true
              }
            }
          }
        },
        results: true
      }
    });

    if (!labOrder) {
      return res.status(404).json({ error: 'Lab order not found' });
    }

    if (!labOrder.patient.user) {
      return res.status(400).json({ error: 'Patient does not have a user account' });
    }

    // Check if there are critical results
    const criticalResults = labOrder.results.filter(result => result.status === 'CRITICAL');
    const priority = criticalResults.length > 0 ? 'CRITICAL' : 'NORMAL';

    const notification = await prisma.notification.create({
      data: {
        userId: labOrder.patient.user.id,
        title: 'Lab Results Available',
        message: criticalResults.length > 0 
          ? `Your lab results are available with ${criticalResults.length} critical finding(s). Please contact your doctor immediately.`
          : 'Your lab results are available. Please check with your healthcare provider.',
        type: 'LAB_RESULT',
        priority,
        data: {
          labOrderId: labOrder.id,
          orderNumber: labOrder.orderNumber,
          criticalCount: criticalResults.length,
          totalResults: labOrder.results.length
        }
      }
    });

    res.json(notification);
  } catch (error) {
    console.error('Error sending lab result notification:', error);
    res.status(500).json({ error: 'Internal server error' });
  }
});

// POST /api/notifications/bill-due - Send bill due notifications (system)
router.post('/bill-due', authenticate, async (req, res) => {
  try {
    // Check if user has admin permissions
    const currentUser = (req as any).user;
    if (currentUser.role.name !== 'SUPER_ADMIN') {
      return res.status(403).json({ error: 'Insufficient permissions' });
    }

    // Get bills due in next 3 days
    const threeDaysFromNow = new Date();
    threeDaysFromNow.setDate(threeDaysFromNow.getDate() + 3);

    const dueBills = await prisma.bill.findMany({
      where: {
        dueDate: {
          lte: threeDaysFromNow
        },
        status: { in: ['PENDING', 'SENT', 'PARTIAL'] }
      },
      include: {
        patient: {
          include: {
            user: {
              select: {
                id: true,
                firstName: true,
                lastName: true
              }
            }
          }
        }
      }
    });

    // Create notifications for patients with due bills
    const notifications: any[] = [];
    for (const bill of dueBills) {
      if (bill.patient.user) {
        const remainingAmount = bill.totalAmount.toNumber() - bill.paidAmount.toNumber();
        const isOverdue = bill.dueDate < new Date();

        notifications.push({
          userId: bill.patient.user.id,
          title: isOverdue ? 'Overdue Bill' : 'Bill Due Soon',
          message: isOverdue 
            ? `Your bill #${bill.billNumber} of $${remainingAmount.toFixed(2)} is overdue. Please make payment as soon as possible.`
            : `Your bill #${bill.billNumber} of $${remainingAmount.toFixed(2)} is due on ${bill.dueDate.toLocaleDateString()}.`,
          type: 'BILL_DUE' as const,
          priority: isOverdue ? 'HIGH' as const : 'NORMAL' as const,
          data: {
            billId: bill.id,
            billNumber: bill.billNumber,
            amount: remainingAmount,
            dueDate: bill.dueDate,
            isOverdue
          }
        });
      }
    }

    if (notifications.length > 0) {
      await prisma.notification.createMany({
        data: notifications
      });
    }

    res.json({
      message: `${notifications.length} bill due notifications sent`,
      count: notifications.length
    });
  } catch (error) {
    console.error('Error sending bill due notifications:', error);
    res.status(500).json({ error: 'Internal server error' });
  }
});

// GET /api/notifications/stats - Get notification statistics (admin only)
router.get('/admin/stats', authenticate, async (req, res) => {
  try {
    // Check if user has admin permissions
    const currentUser = (req as any).user;
    if (currentUser.role.name !== 'SUPER_ADMIN') {
      return res.status(403).json({ error: 'Insufficient permissions' });
    }

    const today = new Date();
    const startOfDay = new Date(today.setHours(0, 0, 0, 0));
    const endOfDay = new Date(today.setHours(23, 59, 59, 999));
    const startOfWeek = new Date();
    startOfWeek.setDate(today.getDate() - 7);

    const [
      totalNotifications,
      todayNotifications,
      weekNotifications,
      unreadNotifications,
      notificationsByType,
      notificationsByPriority
    ] = await Promise.all([
      prisma.notification.count(),
      prisma.notification.count({
        where: {
          createdAt: {
            gte: startOfDay,
            lte: endOfDay
          }
        }
      }),
      prisma.notification.count({
        where: {
          createdAt: { gte: startOfWeek }
        }
      }),
      prisma.notification.count({
        where: { isRead: false }
      }),
      prisma.notification.groupBy({
        by: ['type'],
        _count: { id: true }
      }),
      prisma.notification.groupBy({
        by: ['priority'],
        _count: { id: true }
      })
    ]);

    res.json({
      totalNotifications,
      todayNotifications,
      weekNotifications,
      unreadNotifications,
      notificationsByType,
      notificationsByPriority
    });
  } catch (error) {
    console.error('Error fetching notification stats:', error);
    res.status(500).json({ error: 'Internal server error' });
  }
});

// DELETE /api/notifications/:id - Delete notification
router.delete('/:id', authenticate, async (req, res) => {
  try {
    const { id } = req.params;
    const userId = (req as any).user.id;
    const userRole = (req as any).user.role.name;

    // Users can only delete their own notifications, admins can delete any
    const where: any = { id };
    if (userRole !== 'SUPER_ADMIN') {
      where.userId = userId;
    }

    const notification = await prisma.notification.findFirst({ where });

    if (!notification) {
      return res.status(404).json({ error: 'Notification not found' });
    }

    await prisma.notification.delete({ where: { id } });

    res.json({ message: 'Notification deleted successfully' });
  } catch (error) {
    console.error('Error deleting notification:', error);
    res.status(500).json({ error: 'Internal server error' });
  }
});

export default router;