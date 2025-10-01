import { Router } from 'express';

import authRoutes from './auth';
import patientsRoutes from './patients_fixed';
import appointmentsRoutes from './appointments';
// import doctorsRoutes from './doctors';
import pharmacyRoutes from './pharmacy_minimal';
// import laboratoryRoutes from './laboratory';
// import billingRoutes from './billing';
// import facilityRoutes from './facility';

const router = Router();

// Core routes
router.use('/auth', authRoutes);
router.use('/patients', patientsRoutes);
// router.use('/doctors', doctorsRoutes);
router.use('/appointments', appointmentsRoutes);
router.use('/pharmacy', pharmacyRoutes);
// router.use('/laboratory', laboratoryRoutes);
// router.use('/billing', billingRoutes);
// router.use('/facility', facilityRoutes);

export default router;
