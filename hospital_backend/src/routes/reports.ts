import express from 'express';
import { PrismaClient } from '@prisma/client';
import { authenticate } from '../middleware/auth.middleware';
import { z } from 'zod';

const router = express.Router();
const prisma = new PrismaClient();

// Input validation schemas
const reportQuerySchema = z.object({
  startDate: z.string().datetime().optional(),
  endDate: z.string().datetime().optional(),
  departmentId: z.string().optional(),
  doctorId: z.string().optional(),
  patientId: z.string().optional(),
  limit: z.number().min(1).max(1000).default(100).optional(),
  format: z.enum(['json', 'csv']).default('json').optional()
});

// GET /api/reports/dashboard - Get dashboard overview data
router.get('/dashboard', authenticate, async (req, res) => {
  try {
    const today = new Date();
    const startOfDay = new Date(today.setHours(0, 0, 0, 0));
    const endOfDay = new Date(today.setHours(23, 59, 59, 999));
    const startOfMonth = new Date(today.getFullYear(), today.getMonth(), 1);
    const startOfWeek = new Date();
    startOfWeek.setDate(today.getDate() - 7);

    const [
      // Patient statistics
      totalPatients,
      newPatientsToday,
      newPatientsThisWeek,
      
      // Appointment statistics
      totalAppointments,
      todayAppointments,
      pendingAppointments,
      
      // Staff statistics
      totalDoctors,
      availableDoctors,
      totalStaff,
      activeStaff,
      
      // Facility statistics
      totalBeds,
      occupiedBeds,
      availableBeds,
      
      // Financial statistics
      todayRevenue,
      monthRevenue,
      pendingBills,
      
      // Laboratory statistics
      pendingLabOrders,
      completedLabResults,
      
      // Recent activities
      recentAppointments,
      recentAdmissions
    ] = await Promise.all([
      // Patient queries
      prisma.patient.count({ where: { status: 'ACTIVE' } }),
      prisma.patient.count({
        where: {
          registrationDate: { gte: startOfDay, lte: endOfDay }
        }
      }),
      prisma.patient.count({
        where: {
          registrationDate: { gte: startOfWeek }
        }
      }),
      
      // Appointment queries
      prisma.appointment.count(),
      prisma.appointment.count({
        where: {
          appointmentDate: { gte: startOfDay, lte: endOfDay }
        }
      }),
      prisma.appointment.count({
        where: {
          status: { in: ['SCHEDULED', 'CONFIRMED'] },
          appointmentDate: { gte: new Date() }
        }
      }),
      
      // Staff queries
      prisma.doctor.count(),
      prisma.doctor.count({ where: { isAvailable: true } }),
      prisma.staff.count(),
      prisma.staff.count({ where: { isActive: true } }),
      
      // Facility queries
      prisma.bed.count({ where: { isActive: true } }),
      prisma.bed.count({ where: { status: 'OCCUPIED' } }),
      prisma.bed.count({ where: { status: 'AVAILABLE' } }),
      
      // Financial queries
      prisma.payment.aggregate({
        where: {
          paymentDate: { gte: startOfDay, lte: endOfDay }
        },
        _sum: { amount: true }
      }),
      prisma.payment.aggregate({
        where: {
          paymentDate: { gte: startOfMonth }
        },
        _sum: { amount: true }
      }),
      prisma.bill.count({
        where: { status: { in: ['PENDING', 'SENT'] } }
      }),
      
      // Laboratory queries
      prisma.labOrder.count({
        where: { status: { in: ['PENDING', 'IN_PROGRESS'] } }
      }),
      prisma.labResult.count({
        where: {
          reportedAt: { gte: startOfDay, lte: endOfDay }
        }
      }),
      
      // Recent activities
      prisma.appointment.findMany({
        take: 5,
        orderBy: { createdAt: 'desc' },
        include: {
          patient: {
            select: { firstName: true, lastName: true, patientNumber: true }
          },
          doctor: {
            select: {
              user: { select: { firstName: true, lastName: true } }
            }
          }
        }
      }),
      prisma.admission.findMany({
        take: 5,
        orderBy: { admissionDate: 'desc' },
        include: {
          patient: {
            select: { firstName: true, lastName: true, patientNumber: true }
          },
          bed: {
            select: { bedNumber: true, department: { select: { name: true } } }
          }
        }
      })
    ]);

    // Calculate occupancy rate
    const occupancyRate = totalBeds > 0 ? Math.round((occupiedBeds / totalBeds) * 100) : 0;

    res.json({
      patients: {
        total: totalPatients,
        newToday: newPatientsToday,
        newThisWeek: newPatientsThisWeek
      },
      appointments: {
        total: totalAppointments,
        today: todayAppointments,
        pending: pendingAppointments
      },
      staff: {
        doctors: {
          total: totalDoctors,
          available: availableDoctors
        },
        staff: {
          total: totalStaff,
          active: activeStaff
        }
      },
      facility: {
        beds: {
          total: totalBeds,
          occupied: occupiedBeds,
          available: availableBeds,
          occupancyRate
        }
      },
      finance: {
        todayRevenue: todayRevenue._sum.amount || 0,
        monthRevenue: monthRevenue._sum.amount || 0,
        pendingBills
      },
      laboratory: {
        pendingOrders: pendingLabOrders,
        completedResults: completedLabResults
      },
      recentActivities: {
        appointments: recentAppointments,
        admissions: recentAdmissions
      }
    });
  } catch (error) {
    console.error('Error fetching dashboard data:', error);
    res.status(500).json({ error: 'Internal server error' });
  }
});

// GET /api/reports/patients - Get patient reports
router.get('/patients', authenticate, async (req, res) => {
  try {
    const query = reportQuerySchema.parse(req.query);
    
    const where: any = {};
    
    if (query.startDate && query.endDate) {
      where.registrationDate = {
        gte: new Date(query.startDate),
        lte: new Date(query.endDate)
      };
    }

    const patients = await prisma.patient.findMany({
      where,
      include: {
        appointments: {
          select: {
            id: true,
            appointmentDate: true,
            status: true,
            type: true
          }
        },
        medicalRecords: {
          select: {
            id: true,
            visitDate: true,
            visitType: true,
            diagnosis: true
          }
        },
        bills: {
          select: {
            id: true,
            billNumber: true,
            totalAmount: true,
            status: true
          }
        }
      },
      take: query.limit,
      orderBy: { registrationDate: 'desc' }
    });

    // Calculate statistics
    const stats = {
      totalPatients: patients.length,
      genderDistribution: patients.reduce((acc: any, patient) => {
        acc[patient.gender] = (acc[patient.gender] || 0) + 1;
        return acc;
      }, {}),
      bloodTypeDistribution: patients.reduce((acc: any, patient) => {
        if (patient.bloodType) {
          acc[patient.bloodType] = (acc[patient.bloodType] || 0) + 1;
        }
        return acc;
      }, {}),
      averageAge: Math.round(
        patients.reduce((sum, patient) => {
          const age = new Date().getFullYear() - patient.dateOfBirth.getFullYear();
          return sum + age;
        }, 0) / patients.length
      )
    };

    res.json({
      patients,
      statistics: stats,
      generatedAt: new Date()
    });
  } catch (error) {
    if (error instanceof z.ZodError) {
      return res.status(400).json({ error: 'Validation error', details: error.issues });
    }
    console.error('Error generating patient report:', error);
    res.status(500).json({ error: 'Internal server error' });
  }
});

// GET /api/reports/appointments - Get appointment reports
router.get('/appointments', authenticate, async (req, res) => {
  try {
    const query = reportQuerySchema.parse(req.query);
    
    const where: any = {};
    
    if (query.startDate && query.endDate) {
      where.appointmentDate = {
        gte: new Date(query.startDate),
        lte: new Date(query.endDate)
      };
    }
    
    if (query.doctorId) where.doctorId = query.doctorId;
    if (query.patientId) where.patientId = query.patientId;

    const appointments = await prisma.appointment.findMany({
      where,
      include: {
        patient: {
          select: {
            firstName: true,
            lastName: true,
            patientNumber: true,
            phone: true
          }
        },
        doctor: {
          select: {
            specialty: true,
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
      },
      take: query.limit,
      orderBy: { appointmentDate: 'desc' }
    });

    // Calculate statistics
    const stats = {
      totalAppointments: appointments.length,
      statusDistribution: appointments.reduce((acc: any, apt) => {
        acc[apt.status] = (acc[apt.status] || 0) + 1;
        return acc;
      }, {}),
      typeDistribution: appointments.reduce((acc: any, apt) => {
        acc[apt.type] = (acc[apt.type] || 0) + 1;
        return acc;
      }, {}),
      specialtyDistribution: appointments.reduce((acc: any, apt) => {
        acc[apt.doctor.specialty] = (acc[apt.doctor.specialty] || 0) + 1;
        return acc;
      }, {}),
      averageDuration: Math.round(
        appointments.reduce((sum, apt) => sum + apt.duration, 0) / appointments.length
      )
    };

    res.json({
      appointments,
      statistics: stats,
      generatedAt: new Date()
    });
  } catch (error) {
    if (error instanceof z.ZodError) {
      return res.status(400).json({ error: 'Validation error', details: error.issues });
    }
    console.error('Error generating appointment report:', error);
    res.status(500).json({ error: 'Internal server error' });
  }
});

// GET /api/reports/revenue - Get revenue reports
router.get('/revenue', authenticate, async (req, res) => {
  try {
    const query = reportQuerySchema.parse(req.query);
    
    const where: any = {};
    
    if (query.startDate && query.endDate) {
      where.paymentDate = {
        gte: new Date(query.startDate),
        lte: new Date(query.endDate)
      };
    }

    const [payments, bills] = await Promise.all([
      prisma.payment.findMany({
        where,
        include: {
          bill: {
            select: {
              billNumber: true,
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
        take: query.limit,
        orderBy: { paymentDate: 'desc' }
      }),
      prisma.bill.findMany({
        where: query.startDate && query.endDate ? {
          billDate: {
            gte: new Date(query.startDate),
            lte: new Date(query.endDate)
          }
        } : {},
        include: {
          items: {
            select: {
              itemType: true,
              totalPrice: true
            }
          }
        }
      })
    ]);

    // Calculate statistics
    const totalRevenue = payments.reduce((sum, payment) => sum + payment.amount.toNumber(), 0);
    const totalBilled = bills.reduce((sum, bill) => sum + bill.totalAmount.toNumber(), 0);
    const totalPaid = bills.reduce((sum, bill) => sum + bill.paidAmount.toNumber(), 0);
    const outstanding = totalBilled - totalPaid;

    const paymentMethodDistribution = payments.reduce((acc: any, payment) => {
      acc[payment.paymentMethod] = (acc[payment.paymentMethod] || 0) + payment.amount.toNumber();
      return acc;
    }, {});

    const revenueByCategory = bills.reduce((acc: any, bill) => {
      bill.items.forEach(item => {
        acc[item.itemType] = (acc[item.itemType] || 0) + item.totalPrice.toNumber();
      });
      return acc;
    }, {});

    res.json({
      payments,
      statistics: {
        totalRevenue,
        totalBilled,
        totalPaid,
        outstanding,
        collectionRate: totalBilled > 0 ? Math.round((totalPaid / totalBilled) * 100) : 0,
        paymentMethodDistribution,
        revenueByCategory
      },
      generatedAt: new Date()
    });
  } catch (error) {
    if (error instanceof z.ZodError) {
      return res.status(400).json({ error: 'Validation error', details: error.issues });
    }
    console.error('Error generating revenue report:', error);
    res.status(500).json({ error: 'Internal server error' });
  }
});

// GET /api/reports/laboratory - Get laboratory reports
router.get('/laboratory', authenticate, async (req, res) => {
  try {
    const query = reportQuerySchema.parse(req.query);
    
    const where: any = {};
    
    if (query.startDate && query.endDate) {
      where.orderDate = {
        gte: new Date(query.startDate),
        lte: new Date(query.endDate)
      };
    }
    
    if (query.patientId) where.patientId = query.patientId;

    const labOrders = await prisma.labOrder.findMany({
      where,
      include: {
        patient: {
          select: {
            firstName: true,
            lastName: true,
            patientNumber: true
          }
        },
        results: {
          select: {
            testName: true,
            value: true,
            status: true,
            reportedAt: true
          }
        }
      },
      take: query.limit,
      orderBy: { orderDate: 'desc' }
    });

    // Calculate statistics
    const stats = {
      totalOrders: labOrders.length,
      statusDistribution: labOrders.reduce((acc: any, order) => {
        acc[order.status] = (acc[order.status] || 0) + 1;
        return acc;
      }, {}),
      urgencyDistribution: labOrders.reduce((acc: any, order) => {
        acc[order.urgency] = (acc[order.urgency] || 0) + 1;
        return acc;
      }, {}),
      testTypeDistribution: labOrders.reduce((acc: any, order) => {
        order.testTypes.forEach(test => {
          acc[test] = (acc[test] || 0) + 1;
        });
        return acc;
      }, {}),
      averageResults: Math.round(
        labOrders.reduce((sum, order) => sum + order.results.length, 0) / labOrders.length
      )
    };

    res.json({
      labOrders,
      statistics: stats,
      generatedAt: new Date()
    });
  } catch (error) {
    if (error instanceof z.ZodError) {
      return res.status(400).json({ error: 'Validation error', details: error.issues });
    }
    console.error('Error generating laboratory report:', error);
    res.status(500).json({ error: 'Internal server error' });
  }
});

// GET /api/reports/occupancy - Get facility occupancy reports
router.get('/occupancy', authenticate, async (req, res) => {
  try {
    const query = reportQuerySchema.parse(req.query);
    
    const where: any = {};
    
    if (query.startDate && query.endDate) {
      where.admissionDate = {
        gte: new Date(query.startDate),
        lte: new Date(query.endDate)
      };
    }
    
    if (query.departmentId) {
      where.bed = { departmentId: query.departmentId };
    }

    const [admissions, beds, departments] = await Promise.all([
      prisma.admission.findMany({
        where,
        include: {
          patient: {
            select: {
              firstName: true,
              lastName: true,
              patientNumber: true
            }
          },
          bed: {
            select: {
              bedNumber: true,
              bedType: true,
              department: {
                select: {
                  name: true
                }
              }
            }
          }
        },
        take: query.limit,
        orderBy: { admissionDate: 'desc' }
      }),
      prisma.bed.findMany({
        where: query.departmentId ? { departmentId: query.departmentId } : {},
        include: {
          department: {
            select: {
              name: true
            }
          }
        }
      }),
      prisma.department.findMany({
        include: {
          _count: {
            select: {
              beds: true
            }
          }
        }
      })
    ]);

    // Calculate occupancy statistics
    const totalBeds = beds.length;
    const occupiedBeds = beds.filter(bed => bed.status === 'OCCUPIED').length;
    const occupancyRate = totalBeds > 0 ? Math.round((occupiedBeds / totalBeds) * 100) : 0;

    const bedStatusDistribution = beds.reduce((acc: any, bed) => {
      acc[bed.status] = (acc[bed.status] || 0) + 1;
      return acc;
    }, {});

    const bedTypeDistribution = beds.reduce((acc: any, bed) => {
      acc[bed.bedType] = (acc[bed.bedType] || 0) + 1;
      return acc;
    }, {});

    const departmentOccupancy = departments.map(dept => {
      const deptBeds = beds.filter(bed => bed.departmentId === dept.id);
      const deptOccupied = deptBeds.filter(bed => bed.status === 'OCCUPIED').length;
      const deptTotal = deptBeds.length;
      
      return {
        departmentName: dept.name,
        totalBeds: deptTotal,
        occupiedBeds: deptOccupied,
        availableBeds: deptTotal - deptOccupied,
        occupancyRate: deptTotal > 0 ? Math.round((deptOccupied / deptTotal) * 100) : 0
      };
    });

    res.json({
      admissions,
      statistics: {
        totalBeds,
        occupiedBeds,
        availableBeds: totalBeds - occupiedBeds,
        occupancyRate,
        bedStatusDistribution,
        bedTypeDistribution,
        departmentOccupancy
      },
      generatedAt: new Date()
    });
  } catch (error) {
    if (error instanceof z.ZodError) {
      return res.status(400).json({ error: 'Validation error', details: error.issues });
    }
    console.error('Error generating occupancy report:', error);
    res.status(500).json({ error: 'Internal server error' });
  }
});

// GET /api/reports/doctors - Get doctor performance reports
router.get('/doctors', authenticate, async (req, res) => {
  try {
    const query = reportQuerySchema.parse(req.query);
    
    const where: any = {};
    
    if (query.startDate && query.endDate) {
      where.appointmentDate = {
        gte: new Date(query.startDate),
        lte: new Date(query.endDate)
      };
    }
    
    if (query.doctorId) where.doctorId = query.doctorId;
    if (query.departmentId) {
      where.doctor = { departmentId: query.departmentId };
    }

    const [doctors, appointments] = await Promise.all([
      prisma.doctor.findMany({
        where: query.departmentId ? { departmentId: query.departmentId } : {},
        include: {
          user: {
            select: {
              firstName: true,
              lastName: true,
              email: true
            }
          },
          department: {
            select: {
              name: true
            }
          },
          _count: {
            select: {
              appointments: true,
              medicalRecords: true,
              prescriptions: true
            }
          }
        }
      }),
      prisma.appointment.findMany({
        where,
        include: {
          doctor: {
            select: {
              id: true,
              user: {
                select: {
                  firstName: true,
                  lastName: true
                }
              }
            }
          },
          patient: {
            select: {
              firstName: true,
              lastName: true,
              patientNumber: true
            }
          }
        }
      })
    ]);

    // Calculate doctor performance metrics
    const doctorStats = doctors.map(doctor => {
      const doctorAppointments = appointments.filter(apt => apt.doctorId === doctor.id);
      const completedAppointments = doctorAppointments.filter(apt => apt.status === 'COMPLETED');
      const cancelledAppointments = doctorAppointments.filter(apt => apt.status === 'CANCELLED');
      
      return {
        doctor: {
          id: doctor.id,
          name: `${doctor.user.firstName} ${doctor.user.lastName}`,
          specialty: doctor.specialty,
          department: doctor.department.name
        },
        metrics: {
          totalAppointments: doctorAppointments.length,
          completedAppointments: completedAppointments.length,
          cancelledAppointments: cancelledAppointments.length,
          completionRate: doctorAppointments.length > 0 ? 
            Math.round((completedAppointments.length / doctorAppointments.length) * 100) : 0,
          totalPatients: doctor._count.appointments,
          totalPrescriptions: doctor._count.prescriptions,
          totalMedicalRecords: doctor._count.medicalRecords
        }
      };
    });

    res.json({
      doctorPerformance: doctorStats,
      summary: {
        totalDoctors: doctors.length,
        totalAppointments: appointments.length,
        averageAppointmentsPerDoctor: doctors.length > 0 ? 
          Math.round(appointments.length / doctors.length) : 0
      },
      generatedAt: new Date()
    });
  } catch (error) {
    if (error instanceof z.ZodError) {
      return res.status(400).json({ error: 'Validation error', details: error.issues });
    }
    console.error('Error generating doctor report:', error);
    res.status(500).json({ error: 'Internal server error' });
  }
});

// GET /api/reports/export/:type - Export reports in different formats
router.get('/export/:type', authenticate, async (req, res) => {
  try {
    const { type } = req.params;
    const { format = 'json' } = req.query;
    
    const validTypes = ['patients', 'appointments', 'revenue', 'laboratory', 'occupancy', 'doctors'];
    
    if (!validTypes.includes(type)) {
      return res.status(400).json({ error: 'Invalid report type' });
    }

    // For CSV format, set appropriate headers
    if (format === 'csv') {
      res.setHeader('Content-Type', 'text/csv');
      res.setHeader('Content-Disposition', `attachment; filename=${type}-report.csv`);
      // In a real implementation, you'd convert the data to CSV format
      return res.status(501).json({ error: 'CSV export not yet implemented' });
    }

    // For now, just return a message indicating the export capability
    res.json({
      message: `Export for ${type} report`,
      supportedFormats: ['json', 'csv'],
      note: 'Use the specific report endpoints for data retrieval'
    });
  } catch (error) {
    console.error('Error exporting report:', error);
    res.status(500).json({ error: 'Internal server error' });
  }
});

export default router;