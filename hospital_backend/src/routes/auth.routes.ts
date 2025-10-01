import { Router } from 'express';

import { authenticate } from '../middleware/auth.middleware';
import { loginHandler, meHandler, refreshHandler, registerHandler, rolesHandler } from '../modules/auth/auth.controller';

const router = Router();

router.get('/roles', rolesHandler);
router.post('/register', registerHandler);
router.post('/login', loginHandler);
router.post('/refresh', refreshHandler);
router.get('/me', authenticate, meHandler);

export default router;
