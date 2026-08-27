import express from 'express';
import cors from 'cors';
import helmet from 'helmet';
import { rateLimit } from 'express-rate-limit';
import dotenv from 'dotenv';
import flightsRouter from './routes/flights.js';
import paymentRoutes from './routes/payment.routes.js';
import authRoutes from './routes/auth.routes.js';
import adminRoutes from './routes/admin.routes.js';
import visaRoutes from './routes/visa.routes.js';
import holidayRoutes from './routes/holiday.routes.js';
import currencyRoutes from './routes/currency.routes.js';
import supabase, { testSupabaseConnection } from './config/supabase.js';

dotenv.config();

const app = express();
const PORT = process.env.PORT || 5000;

// 1. Hide Server Technology Stack (Fingerprinting Protection)
app.disable('x-powered-by');

// 2. HTTP Security Headers (HSTS, Content Security Policy, X-Frame-Options)
app.use(
  helmet({
    contentSecurityPolicy: {
      directives: {
        defaultSrc: ["'self'"],
        scriptSrc: ["'self'"],
        styleSrc: ["'self'", "'unsafe-inline'"],
        imgSrc: ["'self'", 'data:', 'https:'],
        connectSrc: ["'self'", 'https://sandbox.momodeveloper.mtn.com', 'https://openapiuat.airtel.africa', 'https://api.duffel.com', 'https://ttnbiybejkwdwgkhfunh.supabase.co', 'https://*.supabase.co'],
      },
    },
    crossOriginEmbedderPolicy: false,
  })
);

// 3. Restricted CORS Policy
const allowedOrigins = [
  'http://localhost:5000',
  'http://localhost:3000',
  'http://127.0.0.1:5000',
  'http://10.0.2.2:5000', // Android Emulator Host
  'https://safiriholidays.com',
  'https://www.safiriholidays.com',
  'https://api.safiriholidays.com',
];

app.use(
  cors({
    origin: (origin, callback) => {
      // Allow requests with no origin (like mobile apps, curl, postman) or matching whitelist
      if (!origin || allowedOrigins.some((allowed) => origin.startsWith(allowed.replace('*', '')))) {
        return callback(null, true);
      }
      return callback(new Error('CORS Policy: Request origin not allowed by security rules'));
    },
    methods: ['GET', 'POST', 'PUT', 'DELETE', 'OPTIONS'],
    allowedHeaders: ['Content-Type', 'Authorization', 'X-Reference-Id', 'Ocp-Apim-Subscription-Key', 'irembopay-signature'],
    credentials: true,
  })
);

// 4. Request Payload Size Limit (Protect against DoS payload floods)
app.use(express.json({ limit: '10kb' }));
app.use(express.urlencoded({ extended: true, limit: '10kb' }));

// 5. Global API Rate Limiting (100 requests per 15 minutes per IP)
const globalLimiter = rateLimit({
  windowMs: 15 * 60 * 1000, // 15 minutes
  max: 100,
  standardHeaders: true,
  legacyHeaders: false,
  message: {
    success: false,
    message: 'Too many requests from this IP. Please try again after 15 minutes.',
  },
});

app.use('/api/', globalLimiter);

// 6. Strict Payment Rate Limiting (15 request attempts per 5 minutes per IP)
const paymentLimiter = rateLimit({
  windowMs: 5 * 60 * 1000, // 5 minutes
  max: 15,
  standardHeaders: true,
  legacyHeaders: false,
  message: {
    success: false,
    message: 'Payment rate limit exceeded. Please wait a few minutes before trying again.',
  },
});

app.use('/api/payments/create', paymentLimiter);

// Health Check Route
app.get('/api/health', async (req, res) => {
  const supabaseHealth = await testSupabaseConnection();
  res.json({
    status: 'online',
    system: 'Safiri Holidays Backend Server',
    database: 'Supabase PostgreSQL & Supabase Client API',
    supabaseStatus: supabaseHealth.status || 'initialized',
    flightEngine: 'Safiri Global Flight Engine',
    paymentGateways: ['MTN Mobile Money Direct (MoMo)', 'Airtel Money Rwanda Direct', 'IremboPay'],
    timestamp: new Date().toISOString(),
  });
});

// Authentication & Authorization Routes (JWT & RBAC)
app.use('/api/auth', authRoutes);

// Safiri Flight Engine Routes
app.use('/api/flights', flightsRouter);

// Safiri Payments API Routes (MTN, Airtel, IremboPay)
app.use('/api/payments', paymentRoutes);

// Safiri Concierge Admin Dashboard Routes
app.use('/api/admin', adminRoutes);

// Visa Application Tracking Routes
app.use('/api/visas', visaRoutes);

// Curated Holiday Packages Routes
app.use('/api/holidays', holidayRoutes);

// Real-Time Forex Currency Rates API Routes
app.use('/api/currency', currencyRoutes);

// 7. Centralized Secure Error Handler (Prevents stack trace leaks in production)
app.use((err, req, res, next) => {
  console.error('[SAFIRI SECURITY LOG] Unhandled Error:', err.stack || err.message);
  
  const statusCode = err.statusCode || 500;
  const isProd = process.env.NODE_ENV === 'production';

  res.status(statusCode).json({
    success: false,
    message: isProd ? 'An internal system error occurred.' : err.message,
    ...(isProd ? {} : { stack: err.stack }),
  });
});

app.listen(PORT, '0.0.0.0', () => {
  console.log(`====================================================`);
  console.log(`✈️  Safiri Holidays Security Hardened Backend Active`);
  console.log(`🔒  Security Headers (Helmet) & Rate Limiter Active`);
  console.log(`🌍  Listening on: http://0.0.0.0:${PORT}`);
  console.log(`====================================================`);
});
