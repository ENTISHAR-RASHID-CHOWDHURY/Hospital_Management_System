import express from 'express';
import { PrismaClient } from '@prisma/client';
import { authenticate } from '../middleware/auth.middleware';
import { z } from 'zod';

const router = express.Router();
const prisma = new PrismaClient();

// Input validation schemas
const createBedSchema = z.object({
  bedNumber: z.string(),
  departmentId: z.string(),
  bedType: z.enum(['GENERAL', 'ICU', 'EMERGENCY', 'MATERNITY', 'PEDIATRIC', 'ISOLATION', 'SURGERY']),
  location: z.string().optional()
});

const updateBedSchema = createBedSchema.partial();

const admissionSchema = z.object({
  patientId: z.string(),
  bedId: z.string(),
  admissionType: z.enum(['EMERGENCY', 'SCHEDULED', 'TRANSFER', 'OBSERVATION']),
  admittingDiagnosis: z.string()
});

const dischargeSchema = z.object({
  dischargeDiagnosis: z.string(),
  treatmentSummary: z.string().optional()
});

// GET /api/facility/beds - Get beds with filters
router.get('/beds', authenticate, async (req, res) => {
  try {
    const {
      departmentId,
      bedType,
      status,
      available,
      page = 1,
      limit = 10,
      search
    } = req.query;

    const where: any = { isActive: true };
    
    if (departmentId) where.departmentId = departmentId;
    if (bedType) where.bedType = bedType;
    if (status) where.status = status;
    
    // Filter for available beds
    if (available === 'true') {
      where.status = 'AVAILABLE';
    }

    // Search functionality
    if (search) {
      where.OR = [
        { bedNumber: { contains: search as string, mode: 'insensitive' } },
        { location: { contains: search as string, mode: 'insensitive' } },
        { department: { name: { contains: search as string, mode: 'insensitive' } } }
      ];
    }

    const skip = (Number(page) - 1) * Number(limit);
    
    const [beds, total] = await Promise.all([
      prisma.bed.findMany({
        where,
        include: {
          department: {
            select: {
              id: true,
              name: true,
              location: true
            }
          },
          admissions: {
            where: {
              dischargeDate: null // Current admission
            },
            include: {
              patient: {
                select: {
                  id: true,
                  firstName: true,
                  lastName: true,
                  patientNumber: true,
                  dateOfBirth: true
                }
              }
            },
            take: 1
          }
        },
        skip,
        take: Number(limit),
        orderBy: { bedNumber: 'asc' }
      }),
      prisma.bed.count({ where })
    ]);

    res.json({
      beds,
      pagination: {
        total,
        page: Number(page),
        limit: Number(limit),
        pages: Math.ceil(total / Number(limit))
      }
    });
  } catch (error) {
    console.error('Error fetching beds:', error);
    res.status(500).json({ error: 'Internal server error' });
  }
});

// GET /api/facility/beds/:id - Get bed by ID
router.get('/beds/:id', authenticate, async (req, res) => {
  try {
    const { id } = req.params;

    const bed = await prisma.bed.findUnique({
      where: { id },
      include: {
        department: {
          select: {
            id: true,
            name: true,
            description: true,
            location: true
          }
        },
        admissions: {
          include: {
            patient: {
              select: {
                id: true,
                firstName: true,
                lastName: true,
                patientNumber: true,
                phone: true,
                dateOfBirth: true,
                gender: true,
                bloodType: true
              }
            }
          },
          orderBy: { admissionDate: 'desc' },
          take: 10
        }
      }
    });

    if (!bed) {
      return res.status(404).json({ error: 'Bed not found' });
    }

    res.json(bed);
  } catch (error) {
    console.error('Error fetching bed:', error);
    res.status(500).json({ error: 'Internal server error' });
  }
});

// POST /api/facility/beds - Create new bed
router.post('/beds', authenticate, async (req, res) => {
  try {
    const validatedData = createBedSchema.parse(req.body);
    
    // Check if department exists
    const department = await prisma.department.findUnique({
      where: { id: validatedData.departmentId }
    });

    if (!department) {
      return res.status(400).json({ error: 'Department not found' });
    }

    // Check if bed number is unique
    const existingBed = await prisma.bed.findUnique({
      where: { bedNumber: validatedData.bedNumber }
    });

    if (existingBed) {
      return res.status(400).json({ error: 'Bed number already exists' });
    }

    const bed = await prisma.bed.create({
      data: validatedData,
      include: {
        department: {
          select: {
            id: true,
            name: true,
            location: true
          }
        }
      }
    });

    res.status(201).json(bed);
  } catch (error) {
    if (error instanceof z.ZodError) {
      return res.status(400).json({ error: 'Validation error', details: error.issues });
    }
    console.error('Error creating bed:', error);
    res.status(500).json({ error: 'Internal server error' });
  }
});

// PUT /api/facility/beds/:id - Update bed
router.put('/beds/:id', authenticate, async (req, res) => {
  try {
    const { id } = req.params;
    const validatedData = updateBedSchema.parse(req.body);

    // Check if bed exists
    const existingBed = await prisma.bed.findUnique({
      where: { id }
    });

    if (!existingBed) {
      return res.status(404).json({ error: 'Bed not found' });
    }

    // If bed number is being updated, check uniqueness
    if (validatedData.bedNumber && validatedData.bedNumber !== existingBed.bedNumber) {
      const conflictingBed = await prisma.bed.findUnique({
        where: { bedNumber: validatedData.bedNumber }
      });

      if (conflictingBed) {
        return res.status(400).json({ error: 'Bed number already exists' });
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

    const bed = await prisma.bed.update({
      where: { id },
      data: validatedData,
      include: {
        department: {
          select: {
            id: true,
            name: true,
            location: true
          }
        }
      }
    });

    res.json(bed);
  } catch (error) {
    if (error instanceof z.ZodError) {
      return res.status(400).json({ error: 'Validation error', details: error.issues });
    }
    console.error('Error updating bed:', error);
    res.status(500).json({ error: 'Internal server error' });
  }
});

// PATCH /api/facility/beds/:id/status - Update bed status
router.patch('/beds/:id/status', authenticate, async (req, res) => {
  try {
    const { id } = req.params;
    const { status } = req.body;

    const validStatuses = ['AVAILABLE', 'OCCUPIED', 'MAINTENANCE', 'BLOCKED', 'CLEANING'];
    
    if (!validStatuses.includes(status)) {
      return res.status(400).json({ error: 'Invalid status' });
    }

    // Check if bed has active admission when trying to mark as available
    if (status === 'AVAILABLE') {
      const activeAdmission = await prisma.admission.findFirst({
        where: {
          bedId: id,
          dischargeDate: null
        }
      });

      if (activeAdmission) {
        return res.status(400).json({ error: 'Cannot mark bed as available with active admission' });
      }
    }

    const bed = await prisma.bed.update({
      where: { id },
      data: { status },
      include: {
        department: {
          select: {
            name: true
          }
        }
      }
    });

    res.json(bed);
  } catch (error) {
    console.error('Error updating bed status:', error);
    res.status(500).json({ error: 'Internal server error' });
  }
});

// GET /api/facility/admissions - Get admissions with filters
router.get('/admissions', authenticate, async (req, res) => {
  try {
    const {
      patientId,
      bedId,
      departmentId,
      status,
      admissionType,
      active,
      page = 1,
      limit = 10,
      search
    } = req.query;

    const where: any = {};
    
    if (patientId) where.patientId = patientId;
    if (bedId) where.bedId = bedId;
    if (admissionType) where.admissionType = admissionType;
    if (status) where.status = status;
    
    // Filter for active admissions only
    if (active === 'true') {
      where.dischargeDate = null;
    }

    // Filter by department
    if (departmentId) {
      where.bed = { departmentId };
    }

    // Search functionality
    if (search) {
      where.OR = [
        { admittingDiagnosis: { contains: search as string, mode: 'insensitive' } },
        { dischargeDiagnosis: { contains: search as string, mode: 'insensitive' } },
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
    
    const [admissions, total] = await Promise.all([
      prisma.admission.findMany({
        where,
        include: {
          patient: {
            select: {
              id: true,
              firstName: true,
              lastName: true,
              patientNumber: true,
              phone: true,
              dateOfBirth: true,
              gender: true
            }
          },
          bed: {
            select: {
              id: true,
              bedNumber: true,
              bedType: true,
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
        orderBy: { admissionDate: 'desc' }
      }),
      prisma.admission.count({ where })
    ]);

    res.json({
      admissions,
      pagination: {
        total,
        page: Number(page),
        limit: Number(limit),
        pages: Math.ceil(total / Number(limit))
      }
    });
  } catch (error) {
    console.error('Error fetching admissions:', error);
    res.status(500).json({ error: 'Internal server error' });
  }
});

// GET /api/facility/admissions/:id - Get admission by ID
router.get('/admissions/:id', authenticate, async (req, res) => {
  try {
    const { id } = req.params;

    const admission = await prisma.admission.findUnique({
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
        bed: {
          select: {
            id: true,
            bedNumber: true,
            bedType: true,
            location: true,
            department: {
              select: {
                id: true,
                name: true,
                location: true
              }
            }
          }
        }
      }
    });

    if (!admission) {
      return res.status(404).json({ error: 'Admission not found' });
    }

    res.json(admission);
  } catch (error) {
    console.error('Error fetching admission:', error);
    res.status(500).json({ error: 'Internal server error' });
  }
});

// POST /api/facility/admissions - Create new admission (admit patient)
router.post('/admissions', authenticate, async (req, res) => {
  try {
    const validatedData = admissionSchema.parse(req.body);
    
    // Check if patient exists
    const patient = await prisma.patient.findUnique({
      where: { id: validatedData.patientId }
    });

    if (!patient) {
      return res.status(400).json({ error: 'Patient not found' });
    }

    // Check if bed exists and is available
    const bed = await prisma.bed.findUnique({
      where: { id: validatedData.bedId }
    });

    if (!bed) {
      return res.status(400).json({ error: 'Bed not found' });
    }

    if (bed.status !== 'AVAILABLE') {
      return res.status(400).json({ error: 'Bed is not available' });
    }

    // Check if patient has any active admissions
    const activeAdmission = await prisma.admission.findFirst({
      where: {
        patientId: validatedData.patientId,
        dischargeDate: null
      }
    });

    if (activeAdmission) {
      return res.status(400).json({ error: 'Patient already has an active admission' });
    }

    // Create admission and update bed status
    const admission = await prisma.$transaction(async (tx) => {
      const newAdmission = await tx.admission.create({
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
          bed: {
            select: {
              id: true,
              bedNumber: true,
              bedType: true,
              department: {
                select: {
                  name: true
                }
              }
            }
          }
        }
      });

      await tx.bed.update({
        where: { id: validatedData.bedId },
        data: { status: 'OCCUPIED' }
      });

      return newAdmission;
    });

    res.status(201).json(admission);
  } catch (error) {
    if (error instanceof z.ZodError) {
      return res.status(400).json({ error: 'Validation error', details: error.issues });
    }
    console.error('Error creating admission:', error);
    res.status(500).json({ error: 'Internal server error' });
  }
});

// POST /api/facility/admissions/:id/discharge - Discharge patient
router.post('/admissions/:id/discharge', authenticate, async (req, res) => {
  try {
    const { id } = req.params;
    const validatedData = dischargeSchema.parse(req.body);

    // Check if admission exists and is active
    const admission = await prisma.admission.findUnique({
      where: { id },
      include: { bed: true }
    });

    if (!admission) {
      return res.status(404).json({ error: 'Admission not found' });
    }

    if (admission.dischargeDate) {
      return res.status(400).json({ error: 'Patient is already discharged' });
    }

    // Discharge patient and update bed status
    const dischargedAdmission = await prisma.$transaction(async (tx) => {
      const updated = await tx.admission.update({
        where: { id },
        data: {
          dischargeDate: new Date(),
          status: 'DISCHARGED',
          dischargeDiagnosis: validatedData.dischargeDiagnosis,
          treatmentSummary: validatedData.treatmentSummary
        },
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
              department: {
                select: {
                  name: true
                }
              }
            }
          }
        }
      });

      await tx.bed.update({
        where: { id: admission.bedId },
        data: { status: 'CLEANING' } // Bed needs cleaning before being available
      });

      return updated;
    });

    res.json(dischargedAdmission);
  } catch (error) {
    if (error instanceof z.ZodError) {
      return res.status(400).json({ error: 'Validation error', details: error.issues });
    }
    console.error('Error discharging patient:', error);
    res.status(500).json({ error: 'Internal server error' });
  }
});

// POST /api/facility/admissions/:id/transfer - Transfer patient to another bed
router.post('/admissions/:id/transfer', authenticate, async (req, res) => {
  try {
    const { id } = req.params;
    const { newBedId, reason } = req.body;

    if (!newBedId) {
      return res.status(400).json({ error: 'New bed ID is required' });
    }

    // Check if admission exists and is active
    const admission = await prisma.admission.findUnique({
      where: { id },
      include: { bed: true }
    });

    if (!admission) {
      return res.status(404).json({ error: 'Admission not found' });
    }

    if (admission.dischargeDate) {
      return res.status(400).json({ error: 'Cannot transfer discharged patient' });
    }

    // Check if new bed exists and is available
    const newBed = await prisma.bed.findUnique({
      where: { id: newBedId }
    });

    if (!newBed) {
      return res.status(400).json({ error: 'New bed not found' });
    }

    if (newBed.status !== 'AVAILABLE') {
      return res.status(400).json({ error: 'New bed is not available' });
    }

    if (newBedId === admission.bedId) {
      return res.status(400).json({ error: 'Patient is already in this bed' });
    }

    // Transfer patient
    const transferredAdmission = await prisma.$transaction(async (tx) => {
      // Update admission with new bed
      const updated = await tx.admission.update({
        where: { id },
        data: {
          bedId: newBedId,
          status: 'TRANSFERRED',
          treatmentSummary: reason ? 
            `${admission.treatmentSummary || ''}\nTransferred: ${reason}`.trim() :
            admission.treatmentSummary
        }
      });

      // Update old bed status
      await tx.bed.update({
        where: { id: admission.bedId },
        data: { status: 'CLEANING' }
      });

      // Update new bed status
      await tx.bed.update({
        where: { id: newBedId },
        data: { status: 'OCCUPIED' }
      });

      return updated;
    });

    res.json(transferredAdmission);
  } catch (error) {
    console.error('Error transferring patient:', error);
    res.status(500).json({ error: 'Internal server error' });
  }
});

// GET /api/facility/stats - Get facility statistics
router.get('/stats', authenticate, async (req, res) => {
  try {
    const [
      totalBeds,
      availableBeds,
      occupiedBeds,
      maintenanceBeds,
      totalAdmissions,
      activeAdmissions,
      todayAdmissions,
      todayDischarges,
      bedsByType,
      bedsByDepartment
    ] = await Promise.all([
      prisma.bed.count({ where: { isActive: true } }),
      prisma.bed.count({ where: { status: 'AVAILABLE', isActive: true } }),
      prisma.bed.count({ where: { status: 'OCCUPIED', isActive: true } }),
      prisma.bed.count({ where: { status: 'MAINTENANCE', isActive: true } }),
      prisma.admission.count(),
      prisma.admission.count({ where: { dischargeDate: null } }),
      prisma.admission.count({
        where: {
          admissionDate: {
            gte: new Date(new Date().setHours(0, 0, 0, 0))
          }
        }
      }),
      prisma.admission.count({
        where: {
          dischargeDate: {
            gte: new Date(new Date().setHours(0, 0, 0, 0))
          }
        }
      }),
      prisma.bed.groupBy({
        by: ['bedType'],
        _count: { id: true },
        where: { isActive: true }
      }),
      prisma.bed.groupBy({
        by: ['departmentId'],
        _count: { id: true },
        where: { isActive: true }
      })
    ]);

    // Calculate occupancy rate
    const occupancyRate = totalBeds > 0 ? Math.round((occupiedBeds / totalBeds) * 100) : 0;

    res.json({
      totalBeds,
      availableBeds,
      occupiedBeds,
      maintenanceBeds,
      occupancyRate,
      totalAdmissions,
      activeAdmissions,
      todayAdmissions,
      todayDischarges,
      bedsByType,
      bedsByDepartment
    });
  } catch (error) {
    console.error('Error fetching facility stats:', error);
    res.status(500).json({ error: 'Internal server error' });
  }
});

// DELETE /api/facility/beds/:id - Deactivate bed
router.delete('/beds/:id', authenticate, async (req, res) => {
  try {
    const { id } = req.params;
    const { reason } = req.body;

    // Check if bed has active admission
    const activeAdmission = await prisma.admission.findFirst({
      where: {
        bedId: id,
        dischargeDate: null
      }
    });

    if (activeAdmission) {
      return res.status(400).json({ error: 'Cannot deactivate bed with active admission' });
    }

    const bed = await prisma.bed.update({
      where: { id },
      data: { 
        isActive: false,
        status: 'BLOCKED'
      }
    });

    res.json({ 
      message: 'Bed deactivated successfully', 
      bed,
      reason: reason || 'No reason provided'
    });
  } catch (error) {
    console.error('Error deactivating bed:', error);
    res.status(500).json({ error: 'Internal server error' });
  }
});

export default router;