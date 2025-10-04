import { PrismaClient } from '@prisma/client';
import * as bcrypt from 'bcrypt';

import { HOSPITAL_ROLES, type HospitalRole, ROLE_DISPLAY_NAMES } from '../src/constants/roles';

const prisma = new PrismaClient();

type PrismaRole = Awaited<ReturnType<typeof prisma.role.findMany>>[number];

type DashboardSeed = Record<HospitalRole, Array<{
  title: string;
  description: string;
  icon: string;
  routeName: string;
  queryParams?: Record<string, unknown>;
}>>;

const dashboardSeeds: DashboardSeed = {
  admin: [
    {
      title: 'Staff Management',
      description: 'Approve new staff accounts and manage roles',
      icon: 'manage_accounts',
      routeName: '/admin/staff',
    },
    {
      title: 'Finance Overview',
      description: 'Monitor hospital revenue and outstanding invoices',
      icon: 'analytics',
      routeName: '/admin/finance',
    },
  ],
  doctor: [
    {
      title: 'Patient Appointments',
      description: 'View and manage your upcoming appointments',
      icon: 'calendar_month',
      routeName: '/doctor/appointments',
    },
    {
      title: 'Patient Records',
      description: 'Access patient medical history and notes',
      icon: 'folder_shared',
      routeName: '/doctor/patients',
    },
  ],
  nurse: [
    {
      title: 'Ward Roster',
      description: 'Check your shift schedule and assigned wards',
      icon: 'schedule',
      routeName: '/nurse/roster',
    },
    {
      title: 'Medication Admin',
      description: 'Track medication rounds and patient vitals',
      icon: 'medical_services',
      routeName: '/nurse/medication',
    },
  ],
  receptionist: [
    {
      title: 'Check-In Queue',
      description: 'Manage today’s patient check-ins',
      icon: 'event_available',
      routeName: '/reception/queue',
    },
    {
      title: 'Billing Support',
      description: 'Assist patients with invoices and payments',
      icon: 'receipt_long',
      routeName: '/reception/billing',
    },
  ],
  pharmacist: [
    {
      title: 'Prescription Orders',
      description: 'Fulfil and track pending prescriptions',
      icon: 'inventory',
      routeName: '/pharmacy/prescriptions',
    },
    {
      title: 'Stock Levels',
      description: 'Review low inventory alerts',
      icon: 'local_shipping',
      routeName: '/pharmacy/inventory',
    },
  ],
  laboratory: [
    {
      title: 'Lab Requests',
      description: 'Process incoming lab test requests',
      icon: 'science',
      routeName: '/lab/requests',
    },
    {
      title: 'Results Upload',
      description: 'Publish results to patient records',
      icon: 'upload_file',
      routeName: '/lab/results',
    },
  ],
  patient: [
    {
      title: 'Upcoming Visits',
      description: 'Track your scheduled appointments',
      icon: 'event_available',
      routeName: '/patient/appointments',
    },
    {
      title: 'Billing Statements',
      description: 'Review invoices and payment history',
      icon: 'receipt_long',
      routeName: '/patient/billing',
    },
  ],
};

async function main() {
  for (const name of HOSPITAL_ROLES) {
    await prisma.role.upsert({
      where: { name },
      update: { 
        description: ROLE_DISPLAY_NAMES[name],
        displayName: ROLE_DISPLAY_NAMES[name]
      },
      create: { 
        name, 
        description: ROLE_DISPLAY_NAMES[name],
        displayName: ROLE_DISPLAY_NAMES[name]
      },
    });
  }

  const roles = await prisma.role.findMany({ where: { name: { in: [...HOSPITAL_ROLES] } } });
  const roleByName = new Map<HospitalRole, PrismaRole>(
    roles.map((role: PrismaRole) => [role.name as HospitalRole, role]),
  );

  for (const name of HOSPITAL_ROLES) {
    const role = roleByName.get(name);
    if (!role) {
      continue;
    }

    const options = dashboardSeeds[name] ?? [];

    if (options.length === 0) {
      await prisma.dashboardOption.deleteMany({ where: { roleId: role.id } });
      continue;
    }

    const titles = options.map((option) => option.title);

    await prisma.dashboardOption.deleteMany({
      where: {
        roleId: role.id,
        title: { notIn: titles },
      },
    });

    await Promise.all(
      options.map((option) =>
        prisma.dashboardOption.upsert({
          where: {
            roleId_title: {
              roleId: role.id,
              title: option.title,
            },
          },
          update: {
            description: option.description,
            icon: option.icon,
            routeName: option.routeName,
          },
          create: {
            title: option.title,
            description: option.description,
            icon: option.icon,
            routeName: option.routeName,
            roleId: role.id,
          },
        }),
      ),
    );
  }

  // Create demo users
  const allRoles = await prisma.role.findMany();
  const roleMap = allRoles.reduce((acc, role) => {
    acc[role.name] = role.id;
    return acc;
  }, {} as Record<string, number>);

  const demoUsers = [
    {
      email: 'admin@hospital.com',
      password: 'admin123',
      firstName: 'Admin',
      lastName: 'User',
      role: 'SUPER_ADMIN'
    },
    {
      email: 'doctor@hospital.com',
      password: 'doctor123',
      firstName: 'Dr. John',
      lastName: 'Smith',
      role: 'DOCTOR'
    },
    {
      email: 'nurse@hospital.com',
      password: 'nurse123',
      firstName: 'Sarah',
      lastName: 'Johnson',
      role: 'NURSE'
    },
    {
      email: 'receptionist@hospital.com',
      password: 'receptionist123',
      firstName: 'Lisa',
      lastName: 'Davis',
      role: 'RECEPTIONIST'
    },
    {
      email: 'pharmacist@hospital.com',
      password: 'pharmacist123',
      firstName: 'David',
      lastName: 'Wilson',
      role: 'PHARMACIST'
    },
    {
      email: 'lab@hospital.com',
      password: 'lab123',
      firstName: 'Robert',
      lastName: 'Martinez',
      role: 'LAB_TECHNICIAN'
    },
    {
      email: 'billing@hospital.com',
      password: 'billing123',
      firstName: 'Jennifer',
      lastName: 'Anderson',
      role: 'BILLING_MANAGER'
    },
    {
      email: 'facility@hospital.com',
      password: 'facility123',
      firstName: 'Thomas',
      lastName: 'Taylor',
      role: 'FACILITY_MANAGER'
    },
    {
      email: 'accountant@hospital.com',
      password: 'accountant123',
      firstName: 'Patricia',
      lastName: 'White',
      role: 'ACCOUNTANT'
    },
    {
      email: 'patient@hospital.com',
      password: 'patient123',
      firstName: 'Michael',
      lastName: 'Brown',
      role: 'PATIENT'
    }
  ];

  console.log('Creating demo users...');
  
  for (const userData of demoUsers) {
    const hashedPassword = await bcrypt.hash(userData.password, 12);
    
    await prisma.user.upsert({
      where: { email: userData.email },
      update: {},
      create: {
        email: userData.email,
        passwordHash: hashedPassword,
        firstName: userData.firstName,
        lastName: userData.lastName,
        displayName: `${userData.firstName} ${userData.lastName}`,
        roleId: roleMap[userData.role],
        isActive: true,
      },
    });
    
    console.log(`Created user: ${userData.email} (${userData.role})`);
  }

  console.log('Seed completed successfully!');
}

main()
  .then(async () => {
    await prisma.$disconnect();
  })
  .catch(async (e) => {
    console.error(e);
    await prisma.$disconnect();
    throw e;
  });
