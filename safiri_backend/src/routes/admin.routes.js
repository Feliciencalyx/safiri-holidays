import express from 'express';
import { getDashboardStats, getAllBookings, getAllPayments } from '../controllers/admin.controller.js';
import { verifyToken } from '../middleware/auth.middleware.js';

const router = express.Router();

// Admin Dashboard Routes (Protected with authentication)
router.get('/stats', verifyToken, getDashboardStats);
router.get('/bookings', verifyToken, getAllBookings);
router.get('/payments', verifyToken, getAllPayments);

export default router;
