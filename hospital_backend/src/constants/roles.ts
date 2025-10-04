export const HOSPITAL_ROLES = [
  'SUPER_ADMIN',
  'DOCTOR',
  'NURSE',
  'RECEPTIONIST',
  'PHARMACIST',
  'LAB_TECHNICIAN',
  'BILLING_MANAGER',
  'FACILITY_MANAGER',
  'ACCOUNTANT',
  'PATIENT',
] as const;

export type HospitalRole = (typeof HOSPITAL_ROLES)[number];

export const ROLE_DISPLAY_NAMES: Record<HospitalRole, string> = {
  SUPER_ADMIN: 'Super Administrator',
  DOCTOR: 'Doctor',
  NURSE: 'Nurse',
  RECEPTIONIST: 'Receptionist',
  PHARMACIST: 'Pharmacist',
  LAB_TECHNICIAN: 'Laboratory Technician',
  BILLING_MANAGER: 'Billing Manager',
  FACILITY_MANAGER: 'Facility Manager',
  ACCOUNTANT: 'Accountant',
  PATIENT: 'Patient',
};

