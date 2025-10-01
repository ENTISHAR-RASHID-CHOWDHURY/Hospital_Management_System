export const HOSPITAL_ROLES = [
  'admin',
  'doctor',
  'nurse',
  'receptionist',
  'pharmacist',
  'laboratory',
  'patient',
] as const;

export type HospitalRole = (typeof HOSPITAL_ROLES)[number];

export const ROLE_DISPLAY_NAMES: Record<HospitalRole, string> = {
  admin: 'Admin / Management',
  doctor: 'Doctor',
  nurse: 'Nurse / Medical Staff',
  receptionist: 'Reception / Front Desk',
  pharmacist: 'Pharmacist',
  laboratory: 'Laboratory Staff',
  patient: 'Patient',
};
