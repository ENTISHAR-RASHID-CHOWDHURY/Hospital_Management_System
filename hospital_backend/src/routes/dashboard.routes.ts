import { Router } from 'express';

import { HOSPITAL_ROLES } from '../constants/roles';
import { authenticate, requireRoles } from '../middleware/auth.middleware';
import { getDashboardOptionsHandler } from '../modules/dashboard/dashboard.controller';

const router = Router();

router.get('/options', authenticate, requireRoles(...HOSPITAL_ROLES), getDashboardOptionsHandler);

export default router;
