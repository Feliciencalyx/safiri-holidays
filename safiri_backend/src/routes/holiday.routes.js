import express from 'express';
import {
  getHolidayPackages,
  createHolidayEnquiry,
  getLiveDestinations,
  getSafiriHolidaysServerStatus,
} from '../controllers/holiday.controller.js';

const router = express.Router();

// Holiday Package Routes & safiriholidays.com Server Integration
router.get('/packages', getHolidayPackages);
router.get('/destinations', getLiveDestinations);
router.get('/live-status', getSafiriHolidaysServerStatus);
router.post('/enquiries', createHolidayEnquiry);

export default router;
