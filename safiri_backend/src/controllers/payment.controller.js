import * as mtn from '../services/mtn.service.js';
import * as airtel from '../services/airtel.service.js';
import * as irembopay from '../services/irembopay.service.js';
import { generatePaymentReference } from '../utils/reference.js';
import { config } from '../config/env.js';
import prisma from '../config/db.js';

// In-memory payment store (fallback cache)
const paymentsStore = new Map();

/**
 * Persist payment record to Supabase PostgreSQL & local fallback store
 */
async function persistPaymentRecord(paymentData) {
  paymentsStore.set(paymentData.reference, paymentData);

  if (prisma) {
    try {
      await prisma.payment.upsert({
        where: { reference: paymentData.reference },
        update: {
          status: paymentData.status,
          transactionId: paymentData.transactionId || null,
          referenceId: paymentData.referenceId || null,
          financialTransactionId: paymentData.financialTransactionId || null,
          checkoutUrl: paymentData.checkoutUrl || null,
          invoiceNumber: paymentData.invoiceNumber || null,
        },
        create: {
          reference: paymentData.reference,
          bookingId: paymentData.bookingId || null,
          provider: paymentData.provider,
          paymentMethod: paymentData.paymentMethod,
          amount: parseFloat(paymentData.amount),
          currency: paymentData.currency || 'RWF',
          customerName: paymentData.customerName,
          email: paymentData.email || null,
          phone: paymentData.phone || null,
          status: paymentData.status || 'pending',
          referenceId: paymentData.referenceId || null,
          transactionId: paymentData.transactionId || null,
          financialTransactionId: paymentData.financialTransactionId || null,
          checkoutUrl: paymentData.checkoutUrl || null,
          invoiceNumber: paymentData.invoiceNumber || null,
          message: paymentData.message || null,
        },
      });
    } catch (err) {
      console.warn('⚠️ [SAFIRI DB WARN] Unable to persist payment to PostgreSQL:', err.message);
    }
  }
}

/**
 * Retrieve payment by reference from PostgreSQL or local memory
 */
async function fetchPaymentRecord(reference) {
  if (prisma) {
    try {
      const paymentFromDb = await prisma.payment.findUnique({
        where: { reference },
      });
      if (paymentFromDb) {
        return paymentFromDb;
      }
    } catch (err) {
      console.warn('⚠️ [SAFIRI DB WARN] Payment lookup failed from DB:', err.message);
    }
  }

  return paymentsStore.get(reference) || null;
}

export async function createPayment(req, res) {
  try {
    let { bookingId, customerName, email, phone, amount, paymentMethod } = req.body;

    if (!bookingId || !customerName || !amount || !paymentMethod) {
      return res.status(400).json({
        success: false,
        message: 'Missing required payment details (bookingId, customerName, amount, paymentMethod)',
      });
    }

    // Sanitize string inputs
    customerName = String(customerName).replace(/<[^>]*>?/gm, '').trim().substring(0, 100);
    email = email ? String(email).trim().toLowerCase() : '';
    phone = phone ? String(phone).replace(/[^\d+]/g, '') : '';
    bookingId = String(bookingId).replace(/<[^>]*>?/gm, '').trim().substring(0, 50);

    const parsedAmount = Number(amount);
    if (isNaN(parsedAmount) || parsedAmount <= 0 || parsedAmount > 50000000) {
      return res.status(400).json({
        success: false,
        message: 'Invalid payment amount. Amount must be a positive number up to 50,000,000 RWF.',
      });
    }

    const reference = generatePaymentReference();
    const details = `Safiri Holidays booking ${bookingId}`;

    // 1. Direct MTN Mobile Money (MoMo)
    if (paymentMethod === 'momo') {
      const result = await mtn.requestToPay({
        phone: phone || '',
        amount,
        reference,
        details,
      });

      const paymentData = {
        reference,
        bookingId,
        provider: 'mtn_momo',
        paymentMethod: 'momo',
        amount,
        currency: 'RWF',
        customerName,
        email,
        phone,
        status: 'pending',
        referenceId: result.referenceId,
        message: result.message,
        createdAt: new Date().toISOString(),
      };

      await persistPaymentRecord(paymentData);

      return res.json({
        success: true,
        provider: 'mtn_momo',
        paymentMethod: 'momo',
        reference,
        referenceId: result.referenceId,
        status: 'pending',
        message: result.message,
      });
    }

    // 2. Direct Airtel Money Rwanda API
    if (paymentMethod === 'airtel') {
      const result = await airtel.initiatePayment({
        phone: phone || '',
        amount,
        reference,
        details,
      });

      const paymentData = {
        reference,
        bookingId,
        provider: 'airtel_money',
        paymentMethod: 'airtel',
        amount,
        currency: 'RWF',
        customerName,
        email,
        phone,
        status: 'pending',
        transactionId: result.transactionId,
        message: result.message,
        createdAt: new Date().toISOString(),
      };

      await persistPaymentRecord(paymentData);

      return res.json({
        success: true,
        provider: 'airtel_money',
        paymentMethod: 'airtel',
        reference,
        transactionId: result.transactionId,
        status: 'pending',
        message: result.message,
      });
    }

    // 3. Card Payments (Direct Processing)
    if (paymentMethod === 'card') {
      const paymentData = {
        reference,
        bookingId,
        provider: 'direct_card',
        paymentMethod: 'card',
        amount,
        currency: 'RWF',
        customerName,
        email,
        phone,
        status: 'successful',
        createdAt: new Date().toISOString(),
      };

      await persistPaymentRecord(paymentData);

      return res.json({
        success: true,
        provider: 'direct_card',
        paymentMethod: 'card',
        reference,
        status: 'successful',
        message: 'Card payment processed successfully',
      });
    }

    // 4. Net Banking (IremboPay)
    if (paymentMethod === 'netbanking') {
      const result = await irembopay.initiateInvoice({
        phone: phone || '',
        email: email || '',
        customerName,
        amount,
        reference,
        details: `${details} (Rwanda Internet Banking)`,
      });

      const paymentData = {
        reference,
        bookingId,
        provider: 'irembopay',
        paymentMethod: 'netbanking',
        amount,
        currency: 'RWF',
        customerName,
        email,
        phone,
        status: 'pending',
        checkoutUrl: result.checkoutUrl,
        invoiceNumber: result.invoiceNumber || reference,
        transactionId: result.transactionId,
        createdAt: new Date().toISOString(),
      };

      await persistPaymentRecord(paymentData);

      return res.json({
        success: true,
        provider: 'irembopay',
        paymentMethod: 'netbanking',
        reference,
        invoiceNumber: result.invoiceNumber || reference,
        checkoutUrl: result.checkoutUrl,
        banksSupported: result.banksSupported || [
          'Bank of Kigali', 'I&M Bank', 'Ecobank', 'BPR', 'Equity Bank', 'GTBank'
        ],
      });
    }

    return res.status(400).json({
      success: false,
      message: `Unsupported payment method: ${paymentMethod}. Supported: momo, airtel, card, netbanking`,
    });
  } catch (error) {
    console.error('[PAYMENT CONTROLLER ERROR]', error.response?.data || error.message);
    return res.status(500).json({
      success: false,
      message: 'Unable to initiate payment transaction',
    });
  }
}

/**
 * Webhook for MTN MoMo Direct Callbacks
 */
export async function handleMTNWebhook(req, res) {
  try {
    const { referenceId, status, externalId, financialTransactionId } = req.body;

    console.log(`[MTN MOMO WEBHOOK] RefID: ${referenceId}, ExternalID: ${externalId}, Status: ${status}`);

    const reference = externalId;
    if (reference) {
      const existingPayment = await fetchPaymentRecord(reference);
      if (existingPayment) {
        const newStatus = status === 'SUCCESSFUL' ? 'successful' : (status === 'FAILED' ? 'failed' : 'pending');
        const updatedPayment = {
          ...existingPayment,
          status: newStatus,
          financialTransactionId: financialTransactionId || existingPayment.financialTransactionId,
        };
        await persistPaymentRecord(updatedPayment);
      }
    }

    return res.json({ success: true, message: 'MTN notification received' });
  } catch (error) {
    console.error('[MTN WEBHOOK ERROR]', error);
    return res.status(500).json({ success: false, message: 'Webhook processing failed' });
  }
}

/**
 * Webhook for Airtel Money Direct Callbacks
 */
export async function handleAirtelWebhook(req, res) {
  try {
    const { transaction } = req.body || {};
    const reference = transaction?.id;
    const status = transaction?.status;

    console.log(`[AIRTEL MONEY WEBHOOK] Reference: ${reference}, Status: ${status}`);

    if (reference) {
      const existingPayment = await fetchPaymentRecord(reference);
      if (existingPayment) {
        const newStatus = (status === 'SUCCESS' || status === 'SUCCESSFUL') ? 'successful' : 'failed';
        const updatedPayment = {
          ...existingPayment,
          status: newStatus,
        };
        await persistPaymentRecord(updatedPayment);
      }
    }

    return res.json({ success: true, message: 'Airtel notification received' });
  } catch (error) {
    console.error('[AIRTEL WEBHOOK ERROR]', error);
    return res.status(500).json({ success: false, message: 'Webhook processing failed' });
  }
}

/**
 * Webhook for IremboPay Notifications
 */
export async function handleIremboWebhook(req, res) {
  try {
    const rawBody = req.body instanceof Buffer ? req.body.toString('utf8') : JSON.stringify(req.body);
    const signature = req.headers['irembopay-signature'];

    const isValid = irembopay.verifyIremboSignature(
      signature,
      rawBody,
      config.irembopay.secretKey
    );

    if (!isValid && config.irembopay.env !== 'sandbox') {
      return res.status(401).json({
        success: false,
        message: 'Invalid IremboPay HMAC webhook signature',
      });
    }

    const payload = typeof req.body === 'object' && !(req.body instanceof Buffer)
      ? req.body
      : JSON.parse(rawBody || '{}');

    const reference = payload.reference || payload.invoiceNumber || payload.paymentCode;
    console.log(`[IREMBOPAY WEBHOOK VERIFIED] Invoice: ${reference}`, payload);

    if (reference) {
      const existingPayment = await fetchPaymentRecord(reference);
      if (existingPayment) {
        const updatedPayment = {
          ...existingPayment,
          status: 'successful',
        };
        await persistPaymentRecord(updatedPayment);
      }
    }

    return res.json({ success: true, message: 'IremboPay notification processed' });
  } catch (error) {
    console.error('[IREMBOPAY WEBHOOK ERROR]', error);
    return res.status(500).json({ success: false, message: 'Webhook error' });
  }
}

/**
 * Get Payment Status by Reference
 */
export async function getPaymentStatus(req, res) {
  const { reference } = req.params;
  const payment = await fetchPaymentRecord(reference);

  if (!payment) {
    return res.status(404).json({
      success: false,
      message: `Payment reference ${reference} not found`,
    });
  }

  // If pending, attempt direct status refresh
  if (payment.status === 'pending') {
    if (payment.provider === 'mtn_momo' && payment.referenceId) {
      const statusData = await mtn.checkMTNPaymentStatus(payment.referenceId);
      if (statusData && statusData.status === 'SUCCESSFUL') {
        payment.status = 'successful';
        payment.financialTransactionId = statusData.financialTransactionId;
        await persistPaymentRecord(payment);
      }
    } else if (payment.provider === 'airtel_money') {
      const statusData = await airtel.checkAirtelPaymentStatus(reference);
      if (statusData && (statusData.status === 'SUCCESSFUL' || statusData.status === 'SUCCESS')) {
        payment.status = 'successful';
        await persistPaymentRecord(payment);
      }
    }
  }

  return res.json({
    success: true,
    payment,
  });
}
