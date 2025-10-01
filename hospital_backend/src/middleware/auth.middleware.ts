import { NextFunction, Request, Response } from 'express';
import { PrismaClient } from '@prisma/client';

import { verifyAccessToken } from '../utils/token';

const prisma = new PrismaClient();

export function authenticate(req: Request, res: Response, next: NextFunction) {
  const authHeader = req.headers.authorization;
  if (!authHeader || !authHeader.startsWith('Bearer ')) {
    return res.status(401).json({ message: 'Unauthorized' });
  }

  const token = authHeader.substring(7);

  try {
    const payload = verifyAccessToken(token);
    req.user = payload;
    return next();
  } catch (error) {
    return res.status(401).json({ message: 'Invalid or expired token' });
  }
}

export function requireRoles(...roles: string[]) {
  return (req: Request, res: Response, next: NextFunction) => {
    const userRole = req.user?.role;
    if (!userRole) {
      return res.status(401).json({ message: 'Unauthorized' });
    }

    if (!roles.includes(userRole)) {
      return res.status(403).json({ message: 'Forbidden' });
    }

    return next();
  };
}

// Data filtering utilities for role-based access
export const DataFilters = {
  // Patient data filtering based on user role
  filterPatientData: (patient: any, userRole: string, userId: string) => {
    const basePatientInfo = {
      id: patient.id,
      firstName: patient.firstName,
      lastName: patient.lastName,
      dateOfBirth: patient.dateOfBirth,
      gender: patient.gender,
      phone: patient.phone,
      email: patient.email,
    };

    switch (userRole) {
      case 'PATIENT':
        // Patients can only see their own full records
        if (patient.id === userId) {
          return {
            ...patient,
            // Exclude sensitive staff notes
            internalNotes: undefined,
            staffNotes: undefined,
          };
        }
        return null; // Cannot see other patients

      case 'DOCTOR':
        // Doctors see full medical records but not billing/HR data
        return {
          ...patient,
          // Exclude financial details
          billingInfo: undefined,
          insuranceDetails: patient.insuranceDetails ? {
            provider: patient.insuranceDetails.provider,
            policyNumber: patient.insuranceDetails.policyNumber,
            // Exclude sensitive insurance data
          } : undefined,
        };

      case 'NURSE':
        // Nurses see care-related information
        return {
          ...basePatientInfo,
          allergies: patient.allergies,
          emergencyContact: patient.emergencyContact,
          currentMedications: patient.currentMedications,
          vitalSigns: patient.vitalSigns,
          carePlans: patient.carePlans,
          // Exclude detailed medical history and billing
          medicalHistory: undefined,
          billingInfo: undefined,
          diagnosticNotes: undefined,
        };

      case 'RECEPTIONIST':
        // Receptionists see demographics and appointment info
        return {
          ...basePatientInfo,
          address: patient.address,
          emergencyContact: patient.emergencyContact,
          insuranceDetails: patient.insuranceDetails ? {
            provider: patient.insuranceDetails.provider,
            policyNumber: patient.insuranceDetails.policyNumber,
          } : undefined,
          // Exclude clinical data
          medicalHistory: undefined,
          vitalSigns: undefined,
          prescriptions: undefined,
          labResults: undefined,
        };

      case 'PHARMACIST':
        // Pharmacists see prescription-related data only
        return {
          ...basePatientInfo,
          allergies: patient.allergies,
          currentMedications: patient.currentMedications,
          prescriptions: patient.prescriptions,
          // Exclude other medical data
          medicalHistory: undefined,
          vitalSigns: undefined,
          labResults: undefined,
          billingInfo: undefined,
        };

      case 'LAB_TECHNICIAN':
        // Lab staff see basic info and lab orders only
        return {
          ...basePatientInfo,
          labOrders: patient.labOrders,
          labResults: patient.labResults,
          // Exclude other medical data
          medicalHistory: undefined,
          prescriptions: undefined,
          billingInfo: undefined,
        };

      case 'BILLING_MANAGER':
      case 'ACCOUNTANT':
        // Billing staff see financial data but not clinical details
        return {
          ...basePatientInfo,
          billingInfo: patient.billingInfo,
          insuranceDetails: patient.insuranceDetails,
          // Exclude clinical data
          medicalHistory: undefined,
          vitalSigns: undefined,
          prescriptions: undefined,
          labResults: undefined,
        };

      case 'SUPER_ADMIN':
        // Super admin sees aggregated data, not detailed clinical notes
        return {
          ...patient,
          // Exclude sensitive clinical notes
          privateNotes: undefined,
          doctorNotes: patient.doctorNotes?.map((note: any) => ({
            ...note,
            content: '[Clinical Note - Access Restricted]',
          })),
        };

      default:
        return null;
    }
  },

  // Doctor profile filtering for public/patient view
  filterDoctorProfile: (doctor: any, userRole: string, isPublicView: boolean = false) => {
    const publicDoctorInfo = {
      id: doctor.id,
      firstName: doctor.firstName,
      lastName: doctor.lastName,
      specialization: doctor.specialization,
      qualifications: doctor.qualifications,
      department: doctor.department,
      consultationFee: doctor.consultationFee,
      avatar: doctor.avatar,
      availableSlots: doctor.availableSlots,
      // Public schedule without personal details
      schedule: doctor.schedule?.map((slot: any) => ({
        dayOfWeek: slot.dayOfWeek,
        startTime: slot.startTime,
        endTime: slot.endTime,
        isAvailable: slot.isAvailable,
      })),
    };

    if (isPublicView || userRole === 'PATIENT') {
      return publicDoctorInfo;
    }

    switch (userRole) {
      case 'DOCTOR':
        // Doctors see professional info but not HR data
        return {
          ...doctor,
          salary: undefined,
          personalContact: undefined,
          emergencyContact: undefined,
          bankDetails: undefined,
        };

      case 'NURSE':
      case 'RECEPTIONIST':
        // Staff see work-related info
        return {
          ...publicDoctorInfo,
          phone: doctor.phone,
          email: doctor.email,
          licenseNumber: doctor.licenseNumber,
        };

      case 'SUPER_ADMIN':
      case 'FACILITY_MANAGER':
        // Management sees full professional profile
        return {
          ...doctor,
          // Exclude sensitive HR data
          salary: undefined,
          bankDetails: undefined,
        };

      default:
        return publicDoctorInfo;
    }
  },

  // Billing data filtering
  filterBillingData: (bill: any, userRole: string, userId: string) => {
    switch (userRole) {
      case 'PATIENT':
        // Patients see only their own bills
        if (bill.patient?.id === userId) {
          return {
            ...bill,
            // Exclude internal financial details
            internalNotes: undefined,
            profitMargin: undefined,
            costBreakdown: undefined,
          };
        }
        return null;

      case 'DOCTOR':
        // Doctors see bills for their patients (limited)
        return {
          id: bill.id,
          billNumber: bill.billNumber,
          patientName: `${bill.patient?.firstName} ${bill.patient?.lastName}`,
          totalAmount: bill.totalAmount,
          status: bill.status,
          createdAt: bill.createdAt,
          // Exclude detailed financial data
          items: undefined,
          payments: undefined,
        };

      case 'NURSE':
      case 'RECEPTIONIST':
        // Limited access to billing for operational needs
        return {
          id: bill.id,
          billNumber: bill.billNumber,
          patientInfo: {
            name: `${bill.patient?.firstName} ${bill.patient?.lastName}`,
            id: bill.patient?.id,
          },
          totalAmount: bill.totalAmount,
          status: bill.status,
          dueDate: bill.dueDate,
          // Exclude detailed items and internal notes
        };

      case 'BILLING_MANAGER':
      case 'ACCOUNTANT':
        // Full access to financial data
        return bill;

      case 'SUPER_ADMIN':
        // Admin sees financial summaries, not detailed transactions
        return {
          ...bill,
          items: bill.items?.length || 0,
          paymentsCount: bill.payments?.length || 0,
          // Summary data only
        };

      default:
        return null;
    }
  },

  // Lab results filtering
  filterLabResults: (result: any, userRole: string, userId: string) => {
    switch (userRole) {
      case 'PATIENT':
        // Patients see their own results with interpretation
        if (result.order?.patient?.id === userId) {
          return {
            ...result,
            // Include patient-friendly interpretation
            interpretation: result.interpretation || 'Please consult your doctor for interpretation',
          };
        }
        return null;

      case 'DOCTOR':
        // Doctors see full results and analysis
        return result;

      case 'NURSE':
        // Nurses see results relevant to care
        return {
          ...result,
          // Exclude complex diagnostic reasoning
          detailedAnalysis: undefined,
          differentialDiagnosis: undefined,
        };

      case 'LAB_TECHNICIAN':
        // Lab staff see technical details
        return {
          ...result,
          // Exclude clinical interpretation
          clinicalSignificance: undefined,
          treatmentRecommendations: undefined,
        };

      case 'RECEPTIONIST':
        // Receptionists see only basic status
        return {
          id: result.id,
          status: result.status,
          completedAt: result.completedAt,
          patientName: `${result.order?.patient?.firstName} ${result.order?.patient?.lastName}`,
        };

      default:
        return null;
    }
  },

  // Prescription filtering
  filterPrescriptionData: (prescription: any, userRole: string, userId: string) => {
    switch (userRole) {
      case 'PATIENT':
        // Patients see their own prescriptions
        if (prescription.patient?.id === userId) {
          return {
            ...prescription,
            // Include patient instructions
            patientInstructions: prescription.patientInstructions,
            // Exclude internal notes
            internalNotes: undefined,
            costAnalysis: undefined,
          };
        }
        return null;

      case 'DOCTOR':
        // Doctors see full prescription details
        return prescription;

      case 'PHARMACIST':
        // Pharmacists see dispensing-related information
        return {
          ...prescription,
          // Include medication details and dispensing instructions
          medications: prescription.medications,
          dispensingInstructions: prescription.dispensingInstructions,
          // Exclude diagnostic reasoning
          diagnosticNotes: undefined,
          treatmentPlan: undefined,
        };

      case 'NURSE':
        // Nurses see administration-related info
        return {
          ...prescription,
          medications: prescription.medications?.map((med: any) => ({
            name: med.medication?.name,
            dosage: med.dosage,
            frequency: med.frequency,
            instructions: med.instructions,
          })),
          // Exclude prescribing rationale
          clinicalReasoning: undefined,
        };

      default:
        return null;
    }
  },
};
