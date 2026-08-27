import express from 'express';
import {
  createPayment,
  handleMTNWebhook,
  handleAirtelWebhook,
  handleIremboWebhook,
  getPaymentStatus,
} from '../controllers/payment.controller.js';

const router = express.Router();

// Create Payment (MoMo, Airtel, Card, Net Banking)
router.post('/create', createPayment);

// Webhook for MTN MoMo Direct Callback
router.post('/mtn/webhook', handleMTNWebhook);

// Webhook for Airtel Money Direct Callback
router.post('/airtel/webhook', handleAirtelWebhook);

// Webhook for IremboPay Signature & Callback Verification
router.post(
  '/irembopay/webhook',
  express.raw({ type: 'application/json' }),
  handleIremboWebhook
);

// Payment Return / Callback URL
router.get('/payment-return', (req, res) => {
  res.send(`
    <html>
      <head><title>Safiri Holidays - Payment Status</title></head>
      <body style="font-family: sans-serif; text-align: center; padding: 50px;">
        <h2>💳 Safiri Holidays Payment Status</h2>
        <p>Thank you! Your payment process has completed.</p>
        <p>You can return to the Safiri Holidays app to view your updated e-ticket.</p>
      </body>
    </html>
  `);
});

// Check Payment Status by Reference
router.get('/status/:reference', getPaymentStatus);

export default router;
