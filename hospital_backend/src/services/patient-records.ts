import type { Prisma } from '@prisma/client';
import { z } from 'zod';

// Fields a patient record needs, shared by staff registration
// (POST /api/patients) and patient self-registration.
export const patientCreateSchema = z.object({
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

// What a patient supplies about themselves. Name and email come from their
// account unless they give a different name.
export const selfPatientProfileSchema = patientCreateSchema
  .omit({ firstName: true, lastName: true, email: true })
  .extend({
    firstName: z.string().min(1).optional(),
    lastName: z.string().min(1).optional(),
  });

export type SelfPatientProfile = z.infer<typeof selfPatientProfileSchema>;

type Db = Pick<Prisma.TransactionClient, 'patient'>;

export async function nextPatientNumber(db: Db): Promise<string> {
  const patientCount = await db.patient.count();
  return `PAT${new Date().getFullYear()}${String(patientCount + 1).padStart(6, '0')}`;
}

/** Creates a patient record linked to a user account. */
export async function createPatientForUser(
  db: Db,
  user: { id: number; firstName: string; lastName: string; email: string },
  profile: SelfPatientProfile,
) {
  return db.patient.create({
    data: {
      userId: user.id,
      firstName: profile.firstName ?? user.firstName,
      lastName: profile.lastName ?? user.lastName,
      email: user.email,
      dateOfBirth: profile.dateOfBirth,
      gender: profile.gender,
      phone: profile.phone,
      address: profile.address,
      emergencyContact: profile.emergencyContact,
      bloodType: profile.bloodType,
      allergies: profile.allergies,
      chronicConditions: profile.chronicConditions,
      insuranceInfo: profile.insuranceInfo,
      patientNumber: await nextPatientNumber(db),
      status: 'ACTIVE',
    },
  });
}
