import express from 'express';
import { PrismaClient } from '@prisma/client';
import { authenticate } from '../middleware/auth.middleware';
import { z } from 'zod';

const router = express.Router();
const prisma = new PrismaClient();

// Input validation schemas
const createAppointmentSchema = z.object({
  patientId: z.string(),
  doctorId: z.string(),
  appointmentDate: z.string().datetime(),
  duration: z.number().min(15).max(480), // 15 minutes to 8 hours
  type: z.enum(['CONSULTATION', 'FOLLOW_UP', 'PROCEDURE', 'SURGERY', 'EMERGENCY', 'TELEMEDICINE']),
  reason: z.string().min(1),
  notes: z.string().optional(),
  roomNumber: z.string().optional(),
  isUrgent: z.boolean().default(false)
});

const updateAppointmentSchema = createAppointmentSchema.partial();

const rescheduleSchema = z.object({
  appointmentDate: z.string().datetime(),
  reason: z.string().optional()
});

// GET /api/appointments - Get appointments with filters
router.get('/', authenticate, async (req, res) => {
  try {
    const { 
      patientId,
      doctorId,
      status,
      type,
      date,
      startDate,
      endDate,
      page = 1,
      limit = 10,
      isUrgent
    } = req.query;

    const where: any = {};
    
    if (patientId) where.patientId = patientId;
    if (doctorId) where.doctorId = doctorId;
    if (status) where.status = status;
    if (type) where.type = type;
    if (isUrgent !== undefined) where.isUrgent = isUrgent === 'true';
    
    // Date filtering
    if (date) {
      const selectedDate = new Date(date as string);
      where.appointmentDate = {
        gte: new Date(selectedDate.setHours(0, 0, 0, 0)),
        lt: new Date(selectedDate.setHours(23, 59, 59, 999))
      };
    } else if (startDate && endDate) {
      where.appointmentDate = {
        gte: new Date(startDate as string),
        lte: new Date(endDate as string)
      };
    }

    const skip = (Number(page) - 1) * Number(limit);
    
    const [appointments, total] = await Promise.all([
      prisma.appointment.findMany({
        where,
        include: {
          patient: {
            select: {
              id: true,
              firstName: true,
              lastName: true,
              patientNumber: true,
              phone: true,
              email: true,
              dateOfBirth: true
            }
          },
          doctor: {
            select: {
              id: true,
              specialty: true,
              user: {
                select: {
                  firstName: true,
                  lastName: true,
                  phone: true
                }
              },
              department: {
                select: {
                  name: true,
                  location: true
                }
              }
            }
          }
        },
        skip,
        take: Number(limit),
        orderBy: { appointmentDate: 'asc' }
      }),
      prisma.appointment.count({ where })
    ]);

    res.json({
      appointments,
      pagination: {
        total,
        page: Number(page),
        limit: Number(limit),
        pages: Math.ceil(total / Number(limit))
      }
    });
  } catch (error) {
    console.error('Error fetching appointments:', error);
    res.status(500).json({ error: 'Internal server error' });
  }
});

// GET /api/appointments/:id - Get appointment by ID
router.get('/:id', authenticate, async (req, res) => {
  try {
    const { id } = req.params;

    const appointment = await prisma.appointment.findUnique({
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
            chronicConditions: true,
            emergencyContact: true
          }
        },
        doctor: {
          select: {
            id: true,
            licenseNumber: true,
            specialty: true,
            subSpecialty: true,
            consultationFee: true,
            user: {
              select: {
                firstName: true,
                lastName: true,
                phone: true,
                email: true
              }
            },
            department: {
              select: {
                name: true,
                location: true
              }
            }
          }
        }
      }
    });

    if (!appointment) {
      return res.status(404).json({ error: 'Appointment not found' });
    }

    res.json(appointment);
  } catch (error) {
    console.error('Error fetching appointment:', error);
    res.status(500).json({ error: 'Internal server error' });
  }
});

// POST /api/appointments - Create new appointment
router.post('/', authenticate, async (req, res) => {
  try {
    const validatedData = createAppointmentSchema.parse(req.body);
    
    // Check if patient exists
    const patient = await prisma.patient.findUnique({
      where: { id: validatedData.patientId }
    });

    if (!patient) {
      return res.status(400).json({ error: 'Patient not found' });
    }

    // Check if doctor exists and is available
    const doctor = await prisma.doctor.findUnique({
      where: { id: validatedData.doctorId }
    });

    if (!doctor) {
      return res.status(400).json({ error: 'Doctor not found' });
    }

    if (!doctor.isAvailable) {
      return res.status(400).json({ error: 'Doctor is not available' });
    }

    const appointmentDate = new Date(validatedData.appointmentDate);
    
    // Check if appointment is in the future (unless it's an emergency)
    if (appointmentDate < new Date() && validatedData.type !== 'EMERGENCY') {
      return res.status(400).json({ error: 'Appointment date must be in the future' });
    }

    // Check for conflicting appointments for the doctor
    const endTime = new Date(appointmentDate.getTime() + validatedData.duration * 60000);
    const conflictingAppointments = await prisma.appointment.findMany({
      where: {
        doctorId: validatedData.doctorId,
        status: { in: ['SCHEDULED', 'CONFIRMED', 'IN_PROGRESS'] },
        OR: [
          {
            appointmentDate: {
              lt: endTime,
              gte: appointmentDate
            }
          },
          {
            AND: [
              { appointmentDate: { lte: appointmentDate } },
              { appointmentDate: { gte: new Date(appointmentDate.getTime() - 30 * 60000) } } // 30 min buffer
            ]
          }
        ]
      }
    });

    if (conflictingAppointments.length > 0) {
      return res.status(400).json({ 
        error: 'Doctor has conflicting appointments at this time',
        conflictingAppointments: conflictingAppointments.map(apt => ({
          id: apt.id,
          appointmentDate: apt.appointmentDate,
          duration: apt.duration
        }))
      });
    }

    const appointment = await prisma.appointment.create({
      data: validatedData,
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
        doctor: {
          select: {
            id: true,
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
      }
    });

    res.status(201).json(appointment);
  } catch (error) {
    if (error instanceof z.ZodError) {
      return res.status(400).json({ error: 'Validation error', details: error.issues });
    }
    console.error('Error creating appointment:', error);
    res.status(500).json({ error: 'Internal server error' });
  }
});

// PUT /api/appointments/:id - Update appointment
router.put('/:id', authenticate, async (req, res) => {
  try {
    const { id } = req.params;
    const validatedData = updateAppointmentSchema.parse(req.body);

    // Check if appointment exists
    const existingAppointment = await prisma.appointment.findUnique({
      where: { id }
    });

    if (!existingAppointment) {
      return res.status(404).json({ error: 'Appointment not found' });
    }

    // If appointment is completed or cancelled, don't allow updates
    if (['COMPLETED', 'CANCELLED'].includes(existingAppointment.status)) {
      return res.status(400).json({ error: 'Cannot update completed or cancelled appointment' });
    }

    // If doctor is being changed, check availability
    if (validatedData.doctorId && validatedData.doctorId !== existingAppointment.doctorId) {
      const doctor = await prisma.doctor.findUnique({
        where: { id: validatedData.doctorId }
      });

      if (!doctor?.isAvailable) {
        return res.status(400).json({ error: 'Doctor is not available' });
      }
    }

    // If appointment date is being changed, check for conflicts
    if (validatedData.appointmentDate) {
      const appointmentDate = new Date(validatedData.appointmentDate);
      const duration = validatedData.duration || existingAppointment.duration;
      const doctorId = validatedData.doctorId || existingAppointment.doctorId;
      
      const endTime = new Date(appointmentDate.getTime() + duration * 60000);
      const conflictingAppointments = await prisma.appointment.findMany({
        where: {
          doctorId,
          id: { not: id },
          status: { in: ['SCHEDULED', 'CONFIRMED', 'IN_PROGRESS'] },
          appointmentDate: {
            lt: endTime,
            gte: appointmentDate
          }
        }
      });

      if (conflictingAppointments.length > 0) {
        return res.status(400).json({ error: 'Doctor has conflicting appointments at this time' });
      }
    }

    const appointment = await prisma.appointment.update({
      where: { id },
      data: validatedData,
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
        doctor: {
          select: {
            id: true,
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
      }
    });

    res.json(appointment);
  } catch (error) {
    if (error instanceof z.ZodError) {
      return res.status(400).json({ error: 'Validation error', details: error.issues });
    }
    console.error('Error updating appointment:', error);
    res.status(500).json({ error: 'Internal server error' });
  }
});

// PATCH /api/appointments/:id/status - Update appointment status
router.patch('/:id/status', authenticate, async (req, res) => {
  try {
    const { id } = req.params;
    const { status, notes } = req.body;

    const validStatuses = ['SCHEDULED', 'CONFIRMED', 'IN_PROGRESS', 'COMPLETED', 'CANCELLED', 'NO_SHOW', 'RESCHEDULED'];
    
    if (!validStatuses.includes(status)) {
      return res.status(400).json({ error: 'Invalid status' });
    }

    const updateData: any = { status };
    if (notes) updateData.notes = notes;

    const appointment = await prisma.appointment.update({
      where: { id },
      data: updateData,
      include: {
        patient: {
          select: {
            firstName: true,
            lastName: true,
            patientNumber: true
          }
        },
        doctor: {
          select: {
            user: {
              select: {
                firstName: true,
                lastName: true
              }
            }
          }
        }
      }
    });

    res.json(appointment);
  } catch (error) {
    console.error('Error updating appointment status:', error);
    res.status(500).json({ error: 'Internal server error' });
  }
});

// POST /api/appointments/:id/reschedule - Reschedule appointment
router.post('/:id/reschedule', authenticate, async (req, res) => {
  try {
    const { id } = req.params;
    const validatedData = rescheduleSchema.parse(req.body);

    const existingAppointment = await prisma.appointment.findUnique({
      where: { id },
      include: { doctor: true }
    });

    if (!existingAppointment) {
      return res.status(404).json({ error: 'Appointment not found' });
    }

    if (['COMPLETED', 'CANCELLED'].includes(existingAppointment.status)) {
      return res.status(400).json({ error: 'Cannot reschedule completed or cancelled appointment' });
    }

    const appointmentDate = new Date(validatedData.appointmentDate);
    const endTime = new Date(appointmentDate.getTime() + existingAppointment.duration * 60000);

    // Check for conflicts with the new time
    const conflictingAppointments = await prisma.appointment.findMany({
      where: {
        doctorId: existingAppointment.doctorId,
        id: { not: id },
        status: { in: ['SCHEDULED', 'CONFIRMED', 'IN_PROGRESS'] },
        appointmentDate: {
          lt: endTime,
          gte: appointmentDate
        }
      }
    });

    if (conflictingAppointments.length > 0) {
      return res.status(400).json({ error: 'Doctor has conflicting appointments at this time' });
    }

    const appointment = await prisma.appointment.update({
      where: { id },
      data: {
        appointmentDate: appointmentDate,
        status: 'RESCHEDULED',
        notes: validatedData.reason ? 
          `${existingAppointment.notes || ''}\nRescheduled: ${validatedData.reason}`.trim() :
          existingAppointment.notes
      }
    });

    res.json(appointment);
  } catch (error) {
    if (error instanceof z.ZodError) {
      return res.status(400).json({ error: 'Validation error', details: error.issues });
    }
    console.error('Error rescheduling appointment:', error);
    res.status(500).json({ error: 'Internal server error' });
  }
});

// GET /api/appointments/available-slots - Get available time slots for a doctor
router.get('/available-slots/:doctorId', authenticate, async (req, res) => {
  try {
    const { doctorId } = req.params;
    const { date, duration = 30 } = req.query;

    if (!date) {
      return res.status(400).json({ error: 'Date is required' });
    }

    const doctor = await prisma.doctor.findUnique({
      where: { id: doctorId }
    });

    if (!doctor || !doctor.isAvailable) {
      return res.status(400).json({ error: 'Doctor not found or not available' });
    }

    const selectedDate = new Date(date as string);
    const startOfDay = new Date(selectedDate.setHours(0, 0, 0, 0));
    const endOfDay = new Date(selectedDate.setHours(23, 59, 59, 999));

    // Get existing appointments for the day
    const existingAppointments = await prisma.appointment.findMany({
      where: {
        doctorId,
        appointmentDate: {
          gte: startOfDay,
          lte: endOfDay
        },
        status: { in: ['SCHEDULED', 'CONFIRMED', 'IN_PROGRESS'] }
      },
      orderBy: { appointmentDate: 'asc' }
    });

    // Generate available slots based on doctor's working hours
    const workingHours = doctor.workingHours as any;
    const slots: Array<{
      startTime: Date;
      endTime: Date;
      available: boolean;
    }> = [];
    
    if (workingHours && workingHours.startTime && workingHours.endTime) {
      const startHour = parseInt(workingHours.startTime.split(':')[0]);
      const startMinute = parseInt(workingHours.startTime.split(':')[1]);
      const endHour = parseInt(workingHours.endTime.split(':')[0]);
      const endMinute = parseInt(workingHours.endTime.split(':')[1]);

      const slotDuration = Number(duration);
      let currentTime = new Date(selectedDate);
      currentTime.setHours(startHour, startMinute, 0, 0);

      const endTime = new Date(selectedDate);
      endTime.setHours(endHour, endMinute, 0, 0);

      while (currentTime < endTime) {
        const slotEndTime = new Date(currentTime.getTime() + slotDuration * 60000);
        
        // Check if this slot conflicts with existing appointments
        const hasConflict = existingAppointments.some(apt => {
          const aptEndTime = new Date(apt.appointmentDate.getTime() + apt.duration * 60000);
          return (currentTime < aptEndTime && slotEndTime > apt.appointmentDate);
        });

        if (!hasConflict && currentTime > new Date()) {
          slots.push({
            startTime: new Date(currentTime),
            endTime: new Date(slotEndTime),
            available: true
          });
        }

        currentTime.setMinutes(currentTime.getMinutes() + slotDuration);
      }
    }

    res.json({ date, slots });
  } catch (error) {
    console.error('Error fetching available slots:', error);
    res.status(500).json({ error: 'Internal server error' });
  }
});

// DELETE /api/appointments/:id - Cancel appointment
router.delete('/:id', authenticate, async (req, res) => {
  try {
    const { id } = req.params;
    const { reason } = req.body;

    const appointment = await prisma.appointment.findUnique({
      where: { id }
    });

    if (!appointment) {
      return res.status(404).json({ error: 'Appointment not found' });
    }

    if (['COMPLETED', 'CANCELLED'].includes(appointment.status)) {
      return res.status(400).json({ error: 'Appointment is already completed or cancelled' });
    }

    const updatedAppointment = await prisma.appointment.update({
      where: { id },
      data: {
        status: 'CANCELLED',
        notes: reason ? 
          `${appointment.notes || ''}\nCancelled: ${reason}`.trim() :
          appointment.notes
      }
    });

    res.json({ message: 'Appointment cancelled successfully', appointment: updatedAppointment });
  } catch (error) {
    console.error('Error cancelling appointment:', error);
    res.status(500).json({ error: 'Internal server error' });
  }
});

export default router;