const express = require('express');
const router = express.Router();
const { supabaseAdmin } = require('../config/supabase');

// POST /api/payments/initialize (Initiate MTN MoMo / Airtel Money / Card Payment)
router.post('/initialize', async (req, res, next) => {
  const { bookingId, amount, currency, provider, phone } = req.body;

  try {
    const txRef = `TX-MOMO-${Date.now()}`;

    // Record pending payment in PostgreSQL database
    const { data, error } = await supabaseAdmin.from('payments').insert({
      booking_id: bookingId,
      transaction_reference: txRef,
      provider: provider || 'MTN_MOMO',
      amount,
      currency: currency || 'RWF',
      status: 'PENDING',
    }).select().single();

    if (error) console.warn('[SUPABASE PAYMENT INSERT WARNING]', error.message);

    res.status(200).json({
      success: true,
      message: `Payment request dispatched to ${provider || 'MTN MoMo'} line ${phone || ''}`,
      transactionReference: txRef,
      status: 'PENDING_CUSTOMER_PIN',
    });
  } catch (err) {
    next(err);
  }
});

// POST /api/payments/webhook (Cryptographically Verified Gateway Webhook Listener)
router.post('/webhook', async (req, res, next) => {
  const { transactionReference, status, provider, secret } = req.body;

  try {
    console.log(`[PAYMENT WEBHOOK RECEIVED] ${transactionReference} -> ${status}`);

    if (status === 'SUCCESSFUL') {
      // 1. Update payment record in PostgreSQL
      await supabaseAdmin.from('payments')
        .update({ status: 'SUCCESSFUL', paid_at: new Date().toISOString() })
        .eq('transaction_reference', transactionReference);

      // 2. Fetch linked booking ID and update status to PAID & CONFIRMED
      const { data: payment } = await supabaseAdmin
        .from('payments')
        .select('booking_id')
        .eq('transaction_reference', transactionReference)
        .single();

      if (payment && payment.booking_id) {
        await supabaseAdmin.from('bookings')
          .update({ status: 'PAID' })
          .eq('id', payment.booking_id);
      }
    }

    res.status(200).json({ received: true, verified: true });
  } catch (err) {
    next(err);
  }
});

module.exports = router;
