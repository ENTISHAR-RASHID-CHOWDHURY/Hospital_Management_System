import express from 'express';
import { PrismaClient } from '@prisma/client';
import { authenticate } from '../middleware/auth.middleware';
import { z } from 'zod';

const router = express.Router();
const prisma = new PrismaClient();

// Input validation schemas
const createStaffSchema = z.object({
  userId: z.number(),
  employeeId: z.string(),
  departmentId: z.string(),
  position: z.string(),
  shiftType: z.enum(['DAY', 'NIGHT', 'SWING', 'ROTATING', 'ON_CALL']).default('DAY'),
  salary: z.number().optional(),
  hireDate: z.string().datetime(),
  emergencyContact: z.object({
    name: z.string(),
    relationship: z.string(),
    phone: z.string()
  }),
  skills: z.array(z.string()),
  certifications: z.array(z.string())
});

const updateStaffSchema = createStaffSchema.partial();

// GET /api/staff - Get all staff with filters
router.get('/', authenticate, async (req, res) => {
  try {
    const {
      departmentId,
      position,
      shiftType,
      isActive,
      page = 1,
      limit = 10,
      search
    } = req.query;

    const where: any = {};
    
    if (departmentId) where.departmentId = departmentId;
    if (position) where.position = { contains: position as string, mode: 'insensitive' };
    if (shiftType) where.shiftType = shiftType;
    if (isActive !== undefined) where.isActive = isActive === 'true';
    
    if (search) {
      where.OR = [
        { employeeId: { contains: search as string, mode: 'insensitive' } },
        { position: { contains: search as string, mode: 'insensitive' } },
        { user: { 
          OR: [
            { firstName: { contains: search as string, mode: 'insensitive' } },
            { lastName: { contains: search as string, mode: 'insensitive' } },
            { email: { contains: search as string, mode: 'insensitive' } }
          ]
        }}
      ];
    }

    const skip = (Number(page) - 1) * Number(limit);
    
    const [staff, total] = await Promise.all([
      prisma.staff.findMany({
        where,
        include: {
          user: {
            select: {
              id: true,
              firstName: true,
              lastName: true,
              email: true,
              phone: true,
              avatar: true,
              isActive: true,
              role: {
                select: {
                  name: true,
                  displayName: true
                }
              }
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
      prisma.staff.count({ where })
    ]);

    res.json({
      staff,
      pagination: {
        total,
        page: Number(page),
        limit: Number(limit),
        pages: Math.ceil(total / Number(limit))
      }
    });
  } catch (error) {
    console.error('Error fetching staff:', error);
    res.status(500).json({ error: 'Internal server error' });
  }
});

// GET /api/staff/:id - Get staff member by ID
router.get('/:id', authenticate, async (req, res) => {
  try {
    const { id } = req.params;

    const staff = await prisma.staff.findUnique({
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
            isActive: true,
            lastLogin: true,
            createdAt: true,
            role: {
              select: {
                name: true,
                displayName: true,
                permissions: {
                  select: {
                    name: true,
                    module: true,
                    action: true
                  }
                }
              }
            }
          }
        },
        department: {
          select: {
            id: true,
            name: true,
            description: true,
            location: true
          }
        }
      }
    });

    if (!staff) {
      return res.status(404).json({ error: 'Staff member not found' });
    }

    res.json(staff);
  } catch (error) {
    console.error('Error fetching staff member:', error);
    res.status(500).json({ error: 'Internal server error' });
  }
});

// POST /api/staff - Create new staff member
router.post('/', authenticate, async (req, res) => {
  try {
    const validatedData = createStaffSchema.parse(req.body);
    
    // Check if user exists and doesn't already have a staff profile
    const user = await prisma.user.findUnique({
      where: { id: validatedData.userId },
      include: { staffProfile: true }
    });

    if (!user) {
      return res.status(400).json({ error: 'User not found' });
    }

    if (user.staffProfile) {
      return res.status(400).json({ error: 'User already has a staff profile' });
    }

    // Check if department exists
    const department = await prisma.department.findUnique({
      where: { id: validatedData.departmentId }
    });

    if (!department) {
      return res.status(400).json({ error: 'Department not found' });
    }

    // Check if employee ID is unique
    const existingStaff = await prisma.staff.findUnique({
      where: { employeeId: validatedData.employeeId }
    });

    if (existingStaff) {
      return res.status(400).json({ error: 'Employee ID already exists' });
    }

    const staff = await prisma.staff.create({
      data: {
        ...validatedData,
        hireDate: new Date(validatedData.hireDate)
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

    res.status(201).json(staff);
  } catch (error) {
    if (error instanceof z.ZodError) {
      return res.status(400).json({ error: 'Validation error', details: error.issues });
    }
    console.error('Error creating staff member:', error);
    res.status(500).json({ error: 'Internal server error' });
  }
});

// PUT /api/staff/:id - Update staff member
router.put('/:id', authenticate, async (req, res) => {
  try {
    const { id } = req.params;
    const validatedData = updateStaffSchema.parse(req.body);

    // Check if staff exists
    const existingStaff = await prisma.staff.findUnique({
      where: { id }
    });

    if (!existingStaff) {
      return res.status(404).json({ error: 'Staff member not found' });
    }

    // If employee ID is being updated, check uniqueness
    if (validatedData.employeeId) {
      const conflictingStaff = await prisma.staff.findFirst({
        where: {
          employeeId: validatedData.employeeId,
          id: { not: id }
        }
      });

      if (conflictingStaff) {
        return res.status(400).json({ error: 'Employee ID already exists' });
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

    const updateData: any = { ...validatedData };
    if (validatedData.hireDate) {
      updateData.hireDate = new Date(validatedData.hireDate);
    }

    const staff = await prisma.staff.update({
      where: { id },
      data: updateData,
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

    res.json(staff);
  } catch (error) {
    if (error instanceof z.ZodError) {
      return res.status(400).json({ error: 'Validation error', details: error.issues });
    }
    console.error('Error updating staff member:', error);
    res.status(500).json({ error: 'Internal server error' });
  }
});

// PATCH /api/staff/:id/status - Update staff active status
router.patch('/:id/status', authenticate, async (req, res) => {
  try {
    const { id } = req.params;
    const { isActive } = req.body;

    if (typeof isActive !== 'boolean') {
      return res.status(400).json({ error: 'isActive must be a boolean value' });
    }

    const staff = await prisma.staff.update({
      where: { id },
      data: { isActive },
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

    res.json(staff);
  } catch (error) {
    console.error('Error updating staff status:', error);
    res.status(500).json({ error: 'Internal server error' });
  }
});

// GET /api/staff/departments - Get all departments
router.get('/departments/list', authenticate, async (req, res) => {
  try {
    const departments = await prisma.department.findMany({
      where: { isActive: true },
      include: {
        _count: {
          select: {
            staff: true,
            doctors: true
          }
        }
      },
      orderBy: { name: 'asc' }
    });

    res.json(departments);
  } catch (error) {
    console.error('Error fetching departments:', error);
    res.status(500).json({ error: 'Internal server error' });
  }
});

// POST /api/staff/departments - Create new department
router.post('/departments', authenticate, async (req, res) => {
  try {
    const { name, description, location, headId } = req.body;

    if (!name) {
      return res.status(400).json({ error: 'Department name is required' });
    }

    // Check if department name is unique
    const existingDepartment = await prisma.department.findUnique({
      where: { name }
    });

    if (existingDepartment) {
      return res.status(400).json({ error: 'Department name already exists' });
    }

    // If headId is provided, verify it's a valid doctor
    if (headId) {
      const doctor = await prisma.doctor.findUnique({
        where: { id: headId }
      });

      if (!doctor) {
        return res.status(400).json({ error: 'Invalid department head ID' });
      }
    }

    const department = await prisma.department.create({
      data: {
        name,
        description,
        location,
        headId
      }
    });

    res.status(201).json(department);
  } catch (error) {
    console.error('Error creating department:', error);
    res.status(500).json({ error: 'Internal server error' });
  }
});

// PUT /api/staff/departments/:id - Update department
router.put('/departments/:id', authenticate, async (req, res) => {
  try {
    const { id } = req.params;
    const { name, description, location, headId, isActive } = req.body;

    // Check if department exists
    const existingDepartment = await prisma.department.findUnique({
      where: { id }
    });

    if (!existingDepartment) {
      return res.status(404).json({ error: 'Department not found' });
    }

    // If name is being updated, check uniqueness
    if (name && name !== existingDepartment.name) {
      const conflictingDepartment = await prisma.department.findUnique({
        where: { name }
      });

      if (conflictingDepartment) {
        return res.status(400).json({ error: 'Department name already exists' });
      }
    }

    const updateData: any = {};
    if (name) updateData.name = name;
    if (description !== undefined) updateData.description = description;
    if (location !== undefined) updateData.location = location;
    if (headId !== undefined) updateData.headId = headId;
    if (isActive !== undefined) updateData.isActive = isActive;

    const department = await prisma.department.update({
      where: { id },
      data: updateData
    });

    res.json(department);
  } catch (error) {
    console.error('Error updating department:', error);
    res.status(500).json({ error: 'Internal server error' });
  }
});

// GET /api/staff/by-department/:departmentId - Get staff by department
router.get('/by-department/:departmentId', authenticate, async (req, res) => {
  try {
    const { departmentId } = req.params;
    const { shiftType, isActive } = req.query;

    const where: any = { departmentId };
    
    if (shiftType) where.shiftType = shiftType;
    if (isActive !== undefined) where.isActive = isActive === 'true';

    const staff = await prisma.staff.findMany({
      where,
      include: {
        user: {
          select: {
            id: true,
            firstName: true,
            lastName: true,
            email: true,
            phone: true,
            avatar: true,
            role: {
              select: {
                name: true,
                displayName: true
              }
            }
          }
        }
      },
      orderBy: { user: { firstName: 'asc' } }
    });

    res.json(staff);
  } catch (error) {
    console.error('Error fetching staff by department:', error);
    res.status(500).json({ error: 'Internal server error' });
  }
});

// GET /api/staff/stats - Get staff statistics
router.get('/department-stats/overview', authenticate, async (req, res) => {
  try {
    const today = new Date();
    const startOfMonth = new Date(today.getFullYear(), today.getMonth(), 1);

    const [
      totalStaff,
      activeStaff,
      departmentCount,
      newHiresThisMonth,
      staffByDepartment,
      staffByShift
    ] = await Promise.all([
      prisma.staff.count(),
      prisma.staff.count({ where: { isActive: true } }),
      prisma.department.count({ where: { isActive: true } }),
      prisma.staff.count({
        where: {
          hireDate: { gte: startOfMonth }
        }
      }),
      prisma.staff.groupBy({
        by: ['departmentId'],
        _count: { id: true },
        where: { isActive: true }
      }),
      prisma.staff.groupBy({
        by: ['shiftType'],
        _count: { id: true },
        where: { isActive: true }
      })
    ]);

    // Get department names for the grouped data
    const departmentIds = staffByDepartment.map(item => item.departmentId);
    const departments = await prisma.department.findMany({
      where: { id: { in: departmentIds } },
      select: { id: true, name: true }
    });

    const departmentStats = staffByDepartment.map(item => {
      const dept = departments.find(d => d.id === item.departmentId);
      return {
        departmentId: item.departmentId,
        departmentName: dept?.name || 'Unknown',
        count: item._count.id
      };
    });

    res.json({
      totalStaff,
      activeStaff,
      departmentCount,
      newHiresThisMonth,
      staffByDepartment: departmentStats,
      staffByShift
    });
  } catch (error) {
    console.error('Error fetching staff stats:', error);
    res.status(500).json({ error: 'Internal server error' });
  }
});

// GET /api/staff/search - Advanced search for staff
router.get('/advanced-search/query', authenticate, async (req, res) => {
  try {
    const {
      skills,
      certifications,
      yearsOfExperience,
      department,
      position,
      shiftType
    } = req.query;

    const where: any = { isActive: true };
    
    if (skills) {
      const skillsArray = (skills as string).split(',');
      where.skills = { hasSome: skillsArray };
    }
    
    if (certifications) {
      const certificationsArray = (certifications as string).split(',');
      where.certifications = { hasSome: certificationsArray };
    }
    
    if (department) {
      where.department = { name: { contains: department as string, mode: 'insensitive' } };
    }
    
    if (position) {
      where.position = { contains: position as string, mode: 'insensitive' };
    }
    
    if (shiftType) {
      where.shiftType = shiftType;
    }

    const staff = await prisma.staff.findMany({
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
            name: true,
            location: true
          }
        }
      },
      orderBy: { user: { firstName: 'asc' } }
    });

    // If years of experience filter is provided, we need to calculate it
    let filteredStaff = staff;
    if (yearsOfExperience) {
      const minYears = Number(yearsOfExperience);
      const currentDate = new Date();
      
      filteredStaff = staff.filter(member => {
        const yearsDiff = currentDate.getFullYear() - member.hireDate.getFullYear();
        return yearsDiff >= minYears;
      });
    }

    res.json(filteredStaff);
  } catch (error) {
    console.error('Error in advanced search:', error);
    res.status(500).json({ error: 'Internal server error' });
  }
});

// DELETE /api/staff/:id - Deactivate staff member
router.delete('/:id', authenticate, async (req, res) => {
  try {
    const { id } = req.params;
    const { reason } = req.body;

    const staff = await prisma.staff.findUnique({
      where: { id }
    });

    if (!staff) {
      return res.status(404).json({ error: 'Staff member not found' });
    }

    // Deactivate instead of deleting
    const updatedStaff = await prisma.staff.update({
      where: { id },
      data: { isActive: false }
    });

    // Also deactivate the associated user
    await prisma.user.update({
      where: { id: staff.userId },
      data: { isActive: false }
    });

    res.json({ 
      message: 'Staff member deactivated successfully', 
      staff: updatedStaff,
      reason: reason || 'No reason provided'
    });
  } catch (error) {
    console.error('Error deactivating staff member:', error);
    res.status(500).json({ error: 'Internal server error' });
  }
});

export default router;