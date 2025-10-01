import { Router, Request, Response } from 'express';
import { PrismaClient } from '@prisma/client';
import { authenticate, requireRoles, DataFilters } from '../middleware/auth.middleware';
import { z } from 'zod';

const router = Router();
const prisma = new PrismaClient();

// Validation schemas
const patientCreateSchema = z.object({
  firstName: z.string().min(1, 'First name is required'),
  lastName: z.string().min(1, 'Last name is required'),
  dateOfBirth: z.string().transform((str) => new Date(str)),
  gender: z.enum(['MALE', 'FEMALE', 'OTHER']),
  phone: z.string().min(10, 'Valid phone number is required'),
  email: z.string().email('Valid email is required').optional(),
  address: z.object({
    street: z.string().min(1, 'Street is required'),
    city: z.string().min(1, 'City is required'),
    state: z.string().min(1, 'State is required'),
    zip: z.string().min(1, 'ZIP code is required'),
    country: z.string().default('USA'),
  }),
  emergencyContact: z.object({
    name: z.string().min(1, 'Emergency contact name is required'),
    relationship: z.string().min(1, 'Relationship is required'),
    phone: z.string().min(10, 'Valid phone number is required'),
  }),
  bloodType: z.enum(['A_POSITIVE', 'A_NEGATIVE', 'B_POSITIVE', 'B_NEGATIVE', 'AB_POSITIVE', 'AB_NEGATIVE', 'O_POSITIVE', 'O_NEGATIVE']).optional(),
  allergies: z.array(z.string()).default([]),
  chronicConditions: z.array(z.string()).default([]),
  insuranceInfo: z.object({
    provider: z.string().optional(),
    policyNumber: z.string().optional(),
    groupNumber: z.string().optional(),
  }).optional(),
});

// Get all patients with role-based filtering
router.get('/', 
  authenticate, 
  requireRoles('SUPER_ADMIN', 'DOCTOR', 'NURSE', 'RECEPTIONIST'),
  async (req: Request, res: Response) => {
    try {
      const { 
        page = 1, 
        limit = 10, 
        search, 
        bloodType, 
        status 
      } = req.query;

      const pageNum = parseInt(page as string);
      const limitNum = parseInt(limit as string);
      const skip = (pageNum - 1) * limitNum;

      let where: any = {};

      // Role-based data access restrictions
      const userRole = (req as any).user?.role;
      const userId = (req as any).user?.id;
      const doctorId = (req as any).user?.doctorId;

      switch (userRole) {
        case 'DOCTOR':
          // Doctors can only see their assigned patients
          where.appointments = {
            some: {
              doctorId: doctorId || userId.toString()
            }
          };
          break;
        
        case 'NURSE':
          // Nurses can see patients in active care
          where.admissions = {
            some: {
              status: 'ACTIVE'
            }
          };
          break;

        case 'RECEPTIONIST':
          // Receptionists can see basic patient info for scheduling
          break;

        case 'SUPER_ADMIN':
          // Super admin can see all patients
          break;
      }

      // Apply search filters
      if (search) {
        where.OR = [
          { firstName: { contains: search, mode: 'insensitive' } },
          { lastName: { contains: search, mode: 'insensitive' } },
          { email: { contains: search, mode: 'insensitive' } },
          { phone: { contains: search } }
        ];
      }

      if (bloodType) {
        where.bloodType = bloodType;
      }

      if (status) {
        where.status = status;
      }

      const [patients, total] = await Promise.all([
        prisma.patient.findMany({
          where,
          skip,
          take: limitNum,
          orderBy: { createdAt: 'desc' },
          select: {
            id: true,
            firstName: true,
            lastName: true,
            dateOfBirth: true,
            gender: true,
            phone: true,
            email: true,
            patientNumber: true,
            status: true,
            bloodType: true,
            createdAt: true,
            _count: {
              select: {
                appointments: true,
                prescriptions: true,
                labOrders: true,
              },
            },
          },
        }),
        prisma.patient.count({ where }),
      ]);

      // Apply role-based data filtering
      const filteredPatients = patients
        .map((patient: any) => DataFilters.filterPatientData(patient, userRole, String(userId)))
        .filter((patient: any) => patient !== null);

      res.json({
        patients: filteredPatients,
        pagination: {
          currentPage: pageNum,
          totalPages: Math.ceil(total / limitNum),
          totalItems: total,
          itemsPerPage: limitNum,
        },
      });
    } catch (error) {
      console.error('Error fetching patients:', error);
      res.status(500).json({ error: 'Failed to fetch patients' });
    }
  }
);

// Get patient by ID with role-based filtering
router.get('/:id', 
  authenticate, 
  requireRoles('SUPER_ADMIN', 'DOCTOR', 'NURSE', 'RECEPTIONIST', 'PATIENT'),
  async (req: Request, res: Response) => {
    try {
      const { id } = req.params;
      const userRole = (req as any).user?.role;
      const userId = (req as any).user?.id;
      const patientId = (req as any).user?.patientId;

      // Check if patient is requesting their own data
      if (userRole === 'PATIENT' && patientId !== id) {
        return res.status(403).json({ error: 'Access denied' });
      }

      const patient = await prisma.patient.findUnique({
        where: { id },
        select: {
          id: true,
          firstName: true,
          lastName: true,
          dateOfBirth: true,
          gender: true,
          phone: true,
          email: true,
          address: true,
          emergencyContact: true,
          patientNumber: true,
          status: true,
          bloodType: true,
          allergies: true,
          chronicConditions: true,
          insuranceInfo: true,
          createdAt: true,
          updatedAt: true,
        },
      });

      if (!patient) {
        return res.status(404).json({ error: 'Patient not found' });
      }

      // Apply role-based data filtering
      const filteredPatient = DataFilters.filterPatientData(
        patient, 
        userRole, 
        String(userId)
      );

      if (!filteredPatient) {
        return res.status(403).json({ error: 'Access denied' });
      }

      res.json(filteredPatient);
    } catch (error) {
      console.error('Error fetching patient:', error);
      res.status(500).json({ error: 'Failed to fetch patient' });
    }
  }
);

// Create new patient (restricted roles)
router.post('/', 
  authenticate, 
  requireRoles('SUPER_ADMIN', 'RECEPTIONIST', 'DOCTOR'),
  async (req: Request, res: Response) => {
    try {
      const validatedData = patientCreateSchema.parse(req.body);
      const userRole = (req as any).user?.role;
      const userId = (req as any).user?.id;

      // Check if patient already exists
      const existingPatient = await prisma.patient.findFirst({
        where: {
          OR: [
            { email: validatedData.email },
            { 
              AND: [
                { firstName: validatedData.firstName },
                { lastName: validatedData.lastName },
                { dateOfBirth: validatedData.dateOfBirth }
              ]
            }
          ]
        }
      });

      if (existingPatient) {
        return res.status(400).json({ error: 'Patient already exists' });
      }

      // Generate patient number
      const patientCount = await prisma.patient.count();
      const patientNumber = `PAT${new Date().getFullYear()}${String(patientCount + 1).padStart(6, '0')}`;

      const patient = await prisma.patient.create({
        data: {
          firstName: validatedData.firstName,
          lastName: validatedData.lastName,
          dateOfBirth: validatedData.dateOfBirth,
          gender: validatedData.gender,
          phone: validatedData.phone,
          email: validatedData.email,
          address: validatedData.address,
          emergencyContact: validatedData.emergencyContact,
          bloodType: validatedData.bloodType,
          allergies: validatedData.allergies,
          chronicConditions: validatedData.chronicConditions,
          insuranceInfo: validatedData.insuranceInfo,
          patientNumber,
          status: 'ACTIVE',
        },
      });

      // Apply role-based filtering to response
      const filteredPatient = DataFilters.filterPatientData(
        patient,
        userRole,
        String(userId)
      );

      res.status(201).json(filteredPatient);
    } catch (error) {
      if (error instanceof z.ZodError) {
        return res.status(400).json({ 
          error: 'Validation failed', 
          details: error.issues 
        });
      }
      console.error('Error creating patient:', error);
      res.status(500).json({ error: 'Failed to create patient' });
    }
  }
);

// Update patient (restricted access)
router.put('/:id', 
  authenticate, 
  requireRoles('SUPER_ADMIN', 'RECEPTIONIST', 'DOCTOR'),
  async (req: Request, res: Response) => {
    try {
      const { id } = req.params;
      const validatedData = patientCreateSchema.partial().parse(req.body);
      const userRole = (req as any).user?.role;
      const userId = (req as any).user?.id;

      const existingPatient = await prisma.patient.findUnique({
        where: { id },
      });

      if (!existingPatient) {
        return res.status(404).json({ error: 'Patient not found' });
      }

      // Role-based update restrictions
      if (userRole === 'DOCTOR') {
        // Doctors can only update medical information for their patients
        const allowedUpdates = ['allergies', 'chronicConditions'];
        const updateKeys = Object.keys(validatedData);
        const hasUnauthorizedUpdates = updateKeys.some(key => !allowedUpdates.includes(key));
        
        if (hasUnauthorizedUpdates) {
          return res.status(403).json({ 
            error: 'Doctors can only update medical information' 
          });
        }
      }

      const patient = await prisma.patient.update({
        where: { id },
        data: {
          ...validatedData,
          updatedAt: new Date(),
        },
      });

      // Apply role-based filtering to response
      const filteredPatient = DataFilters.filterPatientData(
        patient,
        userRole,
        String(userId)
      );

      res.json(filteredPatient);
    } catch (error) {
      if (error instanceof z.ZodError) {
        return res.status(400).json({ 
          error: 'Validation failed', 
          details: error.issues 
        });
      }
      console.error('Error updating patient:', error);
      res.status(500).json({ error: 'Failed to update patient' });
    }
  }
);

export default router;