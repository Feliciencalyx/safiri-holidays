require('dotenv').config();
const express = require('express');
const cors = require('cors');
const helmet = require('helmet');
const morgan = require('morgan');

const authRoutes = require('./routes/auth.routes');
const flightRoutes = require('./routes/flights.routes');
const paymentRoutes = require('./routes/payments.routes');
const bookingRoutes = require('./routes/bookings.routes');
const adminRoutes = require('./routes/admin.routes');

const app = express();
const PORT = process.env.PORT || 5000;

// Security & Middleware Stack
app.use(helmet());
app.use(cors({ origin: '*' }));
app.use(express.json());
app.use(morgan('dev'));

// Health Check Endpoint
app.get('/health', (req, res) => {
  res.status(200).json({
    status: 'ONLINE',
    service: 'Safiri Holidays Enterprise API',
    domain: 'api.safiriholidays.com',
    timestamp: new Date().toISOString(),
  });
});

// API Route Mounts
app.use('/api/auth', authRoutes);
app.use('/api/flights', flightRoutes);
app.use('/api/payments', paymentRoutes);
app.use('/api/bookings', bookingRoutes);
app.use('/api/admin', adminRoutes);

// Global Error Handler
app.use((err, req, res, next) => {
  console.error('[SAFIRI BACKEND ERROR]', err);
  res.status(err.status || 500).json({
    success: false,
    message: 'Unable to process your request right now. Please try again or contact support.',
  });
});

app.listen(PORT, '0.0.0.0', () => {
  console.log(`====================================================`);
  console.log(`✈️  Safiri Backend Online on port ${PORT}`);
  console.log(`🌐  Target Domain: https://api.safiriholidays.com`);
  console.log(`====================================================`);
});
