import express from 'express';
import { register, login, googleLogin, getMe } from '../controllers/auth.controller.js';
import { verifyToken } from '../middleware/auth.middleware.js';

const router = express.Router();

// Public Authentication Endpoints
router.post('/register', register);
router.post('/login', login);
router.post('/google', googleLogin);

// Protected Endpoint - Current Authenticated User Profile
router.get('/me', verifyToken, getMe);

export default router;
