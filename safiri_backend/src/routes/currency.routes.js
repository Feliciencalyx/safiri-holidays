import express from 'express';
import { getLiveRates } from '../controllers/currency.controller.js';

const router = express.Router();

router.get('/rates', getLiveRates);

export default router;
