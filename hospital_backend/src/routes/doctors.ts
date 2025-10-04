import express from 'express';
import { PrismaClient } from '@prisma/client';
import { authenticate } from '../middleware/auth.middleware';
import { z } from 'zod';

const router = express.Router();
const prisma = new PrismaClient();

// Input validation schemas
const createDoctorSchema = z.object({
  userId: z.number(),
  licenseNumber: z.string().min(1),
  specialty: z.enum([
    'CARDIOLOGY', 'NEUROLOGY', 'ORTHOPEDICS', 'PEDIATRICS', 'DERMATOLOGY',
    'PSYCHIATRY', 'RADIOLOGY', 'SURGERY', 'EMERGENCY_MEDICINE', 'ONCOLOGY',
    'GYNECOLOGY', 'UROLOGY', 'OPHTHALMOLOGY', 'ANESTHESIOLOGY', 'PATHOLOGY',
    'GENERAL_MEDICINE'
  ]),
  subSpecialty: z.string().optional(),
  yearsOfExperience: z.number().min(0),
  education: z.array(z.object({
    degree: z.string(),
    institution: z.string(),
    year: z.number()
  })),
  certifications: z.array(z.string()),
  departmentId: z.string(),
  consultationFee: z.number().optional(),
  workingHours: z.object({
    days: z.array(z.string()),
    startTime: z.string(),
    endTime: z.string()
  })
});

const updateDoctorSchema = createDoctorSchema.partial();

// GET /api/doctors - Get all doctors with filters
router.get('/', authenticate, async (req, res) => {
  try {
    const { 
      specialty, 
      departmentId, 
      isAvailable, 
      page = 1, 
      limit = 10,
      search 
    } = req.query;

    const where: any = {};
    
    if (specialty) where.specialty = specialty;
    if (departmentId) where.departmentId = departmentId;
    if (isAvailable !== undefined) where.isAvailable = isAvailable === 'true';
    
    if (search) {
      where.OR = [
        { user: { firstName: { contains: search as string, mode: 'insensitive' } } },
        { user: { lastName: { contains: search as string, mode: 'insensitive' } } },
        { licenseNumber: { contains: search as string, mode: 'insensitive' } }
      ];
    }

    const skip = (Number(page) - 1) * Number(limit);
    
    const [doctors, total] = await Promise.all([
      prisma.doctor.findMany({
        where,
        include: {
          user: {
            select: {
              id: true,
              firstName: true,
              lastName: true,
              email: true,
              phone: true,
              avatar: true
            }
          },
          department: {
            select: {
              id: true,
              name: true,
              location: true
            }
          }
        },
        skip,
        take: Number(limit),
        orderBy: { user: { firstName: 'asc' } }
      }),
      prisma.doctor.count({ where })
    ]);

    res.json({
      doctors,
      pagination: {
        total,
        page: Number(page),
        limit: Number(limit),
        pages: Math.ceil(total / Number(limit))
      }
    });
  } catch (error) {
    console.error('Error fetching doctors:', error);
    res.status(500).json({ error: 'Internal server error' });
  }
});

// GET /api/doctors/:id - Get doctor by ID
router.get('/:id', authenticate, async (req, res) => {
  try {
    const { id } = req.params;

    const doctor = await prisma.doctor.findUnique({
      where: { id },
      include: {
        user: {
          select: {
            id: true,
            firstName: true,
            lastName: true,
            email: true,
            phone: true,
            avatar: true,
            isActive: true
          }
        },
        department: {
          select: {
            id: true,
            name: true,
            description: true,
            location: true
          }
        },
        appointments: {
          where: {
            appointmentDate: {
              gte: new Date()
            }
          },
          take: 5,
          orderBy: { appointmentDate: 'asc' },
          include: {
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
      }
    });

    if (!doctor) {
      return res.status(404).json({ error: 'Doctor not found' });
    }

    res.json(doctor);
  } catch (error) {
    console.error('Error fetching doctor:', error);
    res.status(500).json({ error: 'Internal server error' });
  }
});

// POST /api/doctors - Create new doctor
router.post('/', authenticate, async (req, res) => {
  try {
    const validatedData = createDoctorSchema.parse(req.body);
    
    // Check if user exists and doesn't already have a doctor profile
    const user = await prisma.user.findUnique({
      where: { id: validatedData.userId },
      include: { doctorProfile: true }
    });

    if (!user) {
      return res.status(400).json({ error: 'User not found' });
    }

    if (user.doctorProfile) {
      return res.status(400).json({ error: 'User already has a doctor profile' });
    }

    // Check if department exists
    const department = await prisma.department.findUnique({
      where: { id: validatedData.departmentId }
    });

    if (!department) {
      return res.status(400).json({ error: 'Department not found' });
    }

    // Check if license number is unique
    const existingDoctor = await prisma.doctor.findUnique({
      where: { licenseNumber: validatedData.licenseNumber }
    });

    if (existingDoctor) {
      return res.status(400).json({ error: 'License number already exists' });
    }

    const doctor = await prisma.doctor.create({
      data: {
        ...validatedData,
        consultationFee: validatedData.consultationFee || 0
      },
      include: {
        user: {
          select: {
            id: true,
            firstName: true,
            lastName: true,
            email: true,
            phone: true,
            avatar: true
          }
        },
        department: {
          select: {
            id: true,
            name: true,
            location: true
          }
        }
      }
    });

    res.status(201).json(doctor);
  } catch (error) {
    if (error instanceof z.ZodError) {
      return res.status(400).json({ error: 'Validation error', details: error.issues });
    }
    console.error('Error creating doctor:', error);
    res.status(500).json({ error: 'Internal server error' });
  }
});

// PUT /api/doctors/:id - Update doctor
router.put('/:id', authenticate, async (req, res) => {
  try {
    const { id } = req.params;
    const validatedData = updateDoctorSchema.parse(req.body);

    // Check if doctor exists
    const existingDoctor = await prisma.doctor.findUnique({
      where: { id }
    });

    if (!existingDoctor) {
      return res.status(404).json({ error: 'Doctor not found' });
    }

    // If license number is being updated, check uniqueness
    if (validatedData.licenseNumber) {
      const conflictingDoctor = await prisma.doctor.findFirst({
        where: {
          licenseNumber: validatedData.licenseNumber,
          id: { not: id }
        }
      });

      if (conflictingDoctor) {
        return res.status(400).json({ error: 'License number already exists' });
      }
    }

    // If department is being updated, check if it exists
    if (validatedData.departmentId) {
      const department = await prisma.department.findUnique({
        where: { id: validatedData.departmentId }
      });

      if (!department) {
        return res.status(400).json({ error: 'Department not found' });
      }
    }

    const doctor = await prisma.doctor.update({
      where: { id },
      data: validatedData,
      include: {
        user: {
          select: {
            id: true,
            firstName: true,
            lastName: true,
            email: true,
            phone: true,
            avatar: true
          }
        },
        department: {
          select: {
            id: true,
            name: true,
            location: true
          }
        }
      }
    });

    res.json(doctor);
  } catch (error) {
    if (error instanceof z.ZodError) {
      return res.status(400).json({ error: 'Validation error', details: error.issues });
    }
    console.error('Error updating doctor:', error);
    res.status(500).json({ error: 'Internal server error' });
  }
});

// PATCH /api/doctors/:id/status - Update doctor availability status
router.patch('/:id/status', authenticate, async (req, res) => {
  try {
    const { id } = req.params;
    const { isAvailable, currentStatus } = req.body;

    const validStatuses = ['AVAILABLE', 'BUSY', 'IN_SURGERY', 'ON_CALL', 'OFF_DUTY', 'ON_VACATION', 'EMERGENCY'];
    
    if (currentStatus && !validStatuses.includes(currentStatus)) {
      return res.status(400).json({ error: 'Invalid status' });
    }

    const updateData: any = {};
    if (isAvailable !== undefined) updateData.isAvailable = isAvailable;
    if (currentStatus) updateData.currentStatus = currentStatus;

    const doctor = await prisma.doctor.update({
      where: { id },
      data: updateData,
      include: {
        user: {
          select: {
            id: true,
            firstName: true,
            lastName: true
          }
        }
      }
    });

    res.json(doctor);
  } catch (error) {
    console.error('Error updating doctor status:', error);
    res.status(500).json({ error: 'Internal server error' });
  }
});

// GET /api/doctors/:id/schedule - Get doctor's schedule
router.get('/:id/schedule', authenticate, async (req, res) => {
  try {
    const { id } = req.params;
    const { date, startDate, endDate } = req.query;

    let dateFilter: any = {};
    
    if (date) {
      const selectedDate = new Date(date as string);
      dateFilter = {
        appointmentDate: {
          gte: new Date(selectedDate.setHours(0, 0, 0, 0)),
          lt: new Date(selectedDate.setHours(23, 59, 59, 999))
        }
      };
    } else if (startDate && endDate) {
      dateFilter = {
        appointmentDate: {
          gte: new Date(startDate as string),
          lte: new Date(endDate as string)
        }
      };
    } else {
      // Default to next 7 days
      const today = new Date();
      const nextWeek = new Date();
      nextWeek.setDate(today.getDate() + 7);
      dateFilter = {
        appointmentDate: {
          gte: today,
          lte: nextWeek
        }
      };
    }

    const appointments = await prisma.appointment.findMany({
      where: {
        doctorId: id,
        ...dateFilter
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
      },
      orderBy: { appointmentDate: 'asc' }
    });

    res.json(appointments);
  } catch (error) {
    console.error('Error fetching doctor schedule:', error);
    res.status(500).json({ error: 'Internal server error' });
  }
});

// DELETE /api/doctors/:id - Soft delete doctor (deactivate)
router.delete('/:id', authenticate, async (req, res) => {
  try {
    const { id } = req.params;

    // Check if doctor has active appointments
    const activeAppointments = await prisma.appointment.findMany({
      where: {
        doctorId: id,
        appointmentDate: { gte: new Date() },
        status: { in: ['SCHEDULED', 'CONFIRMED'] }
      }
    });

    if (activeAppointments.length > 0) {
      return res.status(400).json({ 
        error: 'Cannot deactivate doctor with active appointments',
        activeAppointments: activeAppointments.length
      });
    }

    // Deactivate the doctor by setting isAvailable to false
    const doctor = await prisma.doctor.update({
      where: { id },
      data: { 
        isAvailable: false,
        currentStatus: 'OFF_DUTY'
      }
    });

    res.json({ message: 'Doctor deactivated successfully', doctor });
  } catch (error) {
    console.error('Error deactivating doctor:', error);
    res.status(500).json({ error: 'Internal server error' });
  }
});

export default router;