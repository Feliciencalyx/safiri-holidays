import prisma from '../config/db.js';

/**
 * GET /api/admin/stats
 * Dashboard summary statistics for Safiri Concierge Admin
 */
export async function getDashboardStats(req, res) {
  try {
    let totalUsers = 0;
    let totalBookings = 0;
    let totalRevenueRwf = 0;
    let successfulPaymentsCount = 0;
    let pendingPaymentsCount = 0;
    let failedPaymentsCount = 0;
    
    let mtnMomoCount = 0;
    let airtelMoneyCount = 0;
    let irembopayCount = 0;
    let directCardCount = 0;
    let recentActivity = [];

    if (prisma) {
      try {
        totalUsers = await prisma.user.count();
        totalBookings = await prisma.booking.count();
        const paymentRecords = await prisma.payment.findMany();

        if (paymentRecords.length > 0) {
          totalRevenueRwf = paymentRecords
            .filter((p) => p.status === 'successful')
            .reduce((sum, p) => sum + (p.amount || 0), 0);

          successfulPaymentsCount = paymentRecords.filter((p) => p.status === 'successful').length;
          pendingPaymentsCount = paymentRecords.filter((p) => p.status === 'pending').length;
          failedPaymentsCount = paymentRecords.filter((p) => p.status === 'failed').length;

          mtnMomoCount = paymentRecords.filter((p) => p.provider === 'mtn_momo').length;
          airtelMoneyCount = paymentRecords.filter((p) => p.provider === 'airtel_money').length;
          irembopayCount = paymentRecords.filter((p) => p.provider === 'irembopay').length;
          directCardCount = paymentRecords.filter((p) => p.provider === 'direct_card').length;

          recentActivity = paymentRecords.slice(0, 5).map((p) => ({
            id: p.id,
            type: p.status === 'successful' ? 'PAYMENT_SUCCESS' : 'PAYMENT_PENDING',
            title: `${p.provider.toUpperCase()} Payment`,
            description: `${p.customerName} paid ${p.amount} ${p.currency} for ${p.bookingId || 'booking'}`,
            time: p.createdAt,
            status: p.status.toUpperCase(),
          }));
        }
      } catch (dbErr) {
        console.warn('⚠️ [SAFIRI ADMIN WARN] Admin DB aggregation error:', dbErr.message);
      }
    }

    const exchangeRateRwfToUsd = 1380; // 1 USD = 1,380 RWF
    const totalRevenueUsd = Math.round((totalRevenueRwf / exchangeRateRwfToUsd) * 100) / 100;

    return res.json({
      success: true,
      timestamp: new Date().toISOString(),
      metrics: {
        totalUsers,
        totalBookings,
        totalRevenueRwf,
        totalRevenueUsd,
        successfulPaymentsCount,
        pendingPaymentsCount,
        failedPaymentsCount,
      },
      gateways: {
        mtnMomo: mtnMomoCount,
        airtelMoney: airtelMoneyCount,
        irembopay: irembopayCount,
        directCard: directCardCount,
      },
      recentActivity,
    });
  } catch (error) {
    console.error('[ADMIN CONTROLLER ERROR]', error);
    return res.status(500).json({
      success: false,
      message: 'Failed to retrieve admin dashboard metrics',
    });
  }
}

/**
 * GET /api/admin/bookings
 * List all flight bookings for admin concierge
 */
export async function getAllBookings(req, res) {
  try {
    let bookings = [];

    if (prisma) {
      try {
        bookings = await prisma.booking.findMany({
          orderBy: { createdAt: 'desc' },
          take: 50,
        });
      } catch (err) {
        console.warn('[ADMIN DB WARN] Failed to fetch bookings list:', err.message);
      }
    }

    return res.json({
      success: true,
      count: bookings.length,
      bookings,
    });
  } catch (error) {
    return res.status(500).json({ success: false, message: 'Failed to retrieve bookings list' });
  }
}

/**
 * GET /api/admin/payments
 * List all payment transactions
 */
export async function getAllPayments(req, res) {
  try {
    let payments = [];

    if (prisma) {
      try {
        payments = await prisma.payment.findMany({
          orderBy: { createdAt: 'desc' },
          take: 50,
        });
      } catch (err) {
        console.warn('[ADMIN DB WARN] Failed to fetch payments list:', err.message);
      }
    }

    return res.json({
      success: true,
      count: payments.length,
      payments,
    });
  } catch (error) {
    return res.status(500).json({ success: false, message: 'Failed to retrieve payment logs' });
  }
}
