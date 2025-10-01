import { Router } from 'express';
import { authenticate, AuthenticatedRequest } from '../middleware/auth';

const router = Router();

// GET /api/appointments - Get all appointments with demo data
(router.get as any)('/', authenticate, async (req: AuthenticatedRequest, res: any) => {
  try {
    // Demo appointments data
    const demoAppointments = [
      {
        id: 'apt_001',
        patientId: 'pat_001',
        doctorId: 'doc_001',
        appointmentDate: new Date(Date.now() + 2 * 60 * 60 * 1000), // 2 hours from now
        duration: 30,
        type: 'CONSULTATION',
        status: 'CONFIRMED',
        reason: 'Regular checkup',
        notes: 'First visit',
        roomNumber: 'Room 101',
        isUrgent: false,
        createdAt: new Date(Date.now() - 24 * 60 * 60 * 1000), // 1 day ago
        updatedAt: new Date(Date.now() - 1 * 60 * 60 * 1000), // 1 hour ago
        patient: {
          id: 'pat_001',
          firstName: 'John',
          lastName: 'Smith',
          email: 'john.smith@email.com',
          phone: '+1-555-0101',
          dateOfBirth: new Date('1985-06-15'),
        },
        doctor: {
          id: 'doc_001',
          user: {
            firstName: 'Dr. Sarah',
            lastName: 'Wilson',
            email: 'sarah.wilson@hospital.com',
            phone: '+1-555-0201',
          },
          specialty: 'CARDIOLOGY',
          department: {
            name: 'Cardiology',
          },
        },
      },
      {
        id: 'apt_002',
        patientId: 'pat_002',
        doctorId: 'doc_002',
        appointmentDate: new Date(Date.now() + 24 * 60 * 60 * 1000), // 1 day from now
        duration: 45,
        type: 'FOLLOW_UP',
        status: 'SCHEDULED',
        reason: 'Follow-up examination',
        notes: null,
        roomNumber: 'Room 202',
        isUrgent: false,
        createdAt: new Date(Date.now() - 6 * 60 * 60 * 1000), // 6 hours ago
        updatedAt: new Date(Date.now() - 6 * 60 * 60 * 1000), // 6 hours ago
        patient: {
          id: 'pat_002',
          firstName: 'Emily',
          lastName: 'Johnson',
          email: 'emily.johnson@email.com',
          phone: '+1-555-0102',
          dateOfBirth: new Date('1990-09-22'),
        },
        doctor: {
          id: 'doc_002',
          user: {
            firstName: 'Dr. David',
            lastName: 'Lee',
            email: 'david.lee@hospital.com',
            phone: '+1-555-0202',
          },
          specialty: 'NEUROLOGY',
          department: {
            name: 'Neurology',
          },
        },
      },
      {
        id: 'apt_003',
        patientId: 'pat_003',
        doctorId: 'doc_001',
        appointmentDate: new Date(Date.now() + 48 * 60 * 60 * 1000), // 2 days from now
        duration: 60,
        type: 'CONSULTATION',
        status: 'SCHEDULED',
        reason: 'Chest pain evaluation',
        notes: 'Patient reports occasional chest discomfort',
        roomNumber: 'Room 103',
        isUrgent: true,
        createdAt: new Date(Date.now() - 12 * 60 * 60 * 1000), // 12 hours ago
        updatedAt: new Date(Date.now() - 12 * 60 * 60 * 1000), // 12 hours ago
        patient: {
          id: 'pat_003',
          firstName: 'Michael',
          lastName: 'Brown',
          email: 'michael.brown@email.com',
          phone: '+1-555-0103',
          dateOfBirth: new Date('1975-03-10'),
        },
        doctor: {
          id: 'doc_001',
          user: {
            firstName: 'Dr. Sarah',
            lastName: 'Wilson',
            email: 'sarah.wilson@hospital.com',
            phone: '+1-555-0201',
          },
          specialty: 'CARDIOLOGY',
          department: {
            name: 'Cardiology',
          },
        },
      },
    ];

    res.json({ appointments: demoAppointments });
  } catch (error) {
    console.error('Error fetching appointments:', error);
    res.status(500).json({ message: 'Failed to fetch appointments' });
  }
});

// GET /api/appointments/:id - Get appointment by ID
(router.get as any)('/:id', authenticate, async (req: AuthenticatedRequest, res: any) => {
  try {
    const appointmentId = req.params.id;

    // Demo data for specific appointment
    const appointment = {
      id: appointmentId,
      patientId: 'pat_001',
      doctorId: 'doc_001',
      appointmentDate: new Date(Date.now() + 2 * 60 * 60 * 1000),
      duration: 30,
      type: 'CONSULTATION',
      status: 'CONFIRMED',
      reason: 'Regular checkup',
      notes: 'First visit',
      roomNumber: 'Room 101',
      isUrgent: false,
      createdAt: new Date(Date.now() - 24 * 60 * 60 * 1000),
      updatedAt: new Date(Date.now() - 1 * 60 * 60 * 1000),
      patient: {
        id: 'pat_001',
        firstName: 'John',
        lastName: 'Smith',
        email: 'john.smith@email.com',
        phone: '+1-555-0101',
        dateOfBirth: new Date('1985-06-15'),
      },
      doctor: {
        id: 'doc_001',
        user: {
          firstName: 'Dr. Sarah',
          lastName: 'Wilson',
          email: 'sarah.wilson@hospital.com',
          phone: '+1-555-0201',
        },
        specialty: 'CARDIOLOGY',
        department: {
          name: 'Cardiology',
        },
      },
    };

    res.json({ appointment });
  } catch (error) {
    console.error('Error fetching appointment:', error);
    res.status(500).json({ message: 'Failed to fetch appointment' });
  }
});

export default router;