import express from 'express';
import { createVisaApplication, getVisaApplication, updateVisaDocument } from '../controllers/visa.controller.js';

const router = express.Router();

// Visa Application Routes
router.post('/applications', createVisaApplication);
router.get('/applications/:id', getVisaApplication);
router.put('/applications/:id/documents', updateVisaDocument);

export default router;
