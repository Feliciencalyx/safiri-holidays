import dotenv from 'dotenv';
dotenv.config();

export const config = {
  port: process.env.PORT || 5000,
  backendUrl: process.env.BACKEND_URL || 'http://localhost:5000',
  databaseUrl: process.env.DATABASE_URL || '',
  
  // MTN MoMo Direct API Configuration
  mtnMoMo: {
    apiUrl: process.env.MTN_MOMO_API_URL || 'https://sandbox.momodeveloper.mtn.com',
    subscriptionKey: process.env.MTN_MOMO_SUBSCRIPTION_KEY || 'YOUR_MTN_SUBSCRIPTION_KEY',
    apiUser: process.env.MTN_MOMO_API_USER || 'YOUR_MTN_API_USER',
    apiKey: process.env.MTN_MOMO_API_KEY || 'YOUR_MTN_API_KEY',
    targetEnv: process.env.MTN_MOMO_TARGET_ENV || 'sandbox',
  },

  // Airtel Money Direct API Configuration
  airtelMoney: {
    apiUrl: process.env.AIRTEL_MONEY_API_URL || 'https://openapiuat.airtel.africa',
    clientId: process.env.AIRTEL_MONEY_CLIENT_ID || 'YOUR_AIRTEL_CLIENT_ID',
    clientSecret: process.env.AIRTEL_MONEY_CLIENT_SECRET || 'YOUR_AIRTEL_CLIENT_SECRET',
    country: process.env.AIRTEL_MONEY_COUNTRY || 'RW',
    currency: process.env.AIRTEL_MONEY_CURRENCY || 'RWF',
  },

  // IremboPay Gateway Configuration
  irembopay: {
    secretKey: process.env.IREMBOPAY_SECRET_KEY || 'sandbox_irembo_secret_key',
    publicKey: process.env.IREMBOPAY_PUBLIC_KEY || 'sandbox_irembo_public_key',
    env: process.env.IREMBOPAY_ENV || 'sandbox',
    apiUrl: process.env.IREMBOPAY_API_URL || 'https://api.irembo.gov.rw/payment/v1',
  },

  // JWT Security Configuration
  jwt: {
    secret: process.env.JWT_SECRET || 'safiri_jwt_secret_key_2026_super_secure',
    expiresIn: process.env.JWT_EXPIRES_IN || '7d',
  },

  // Supabase Configuration
  supabase: {
    url: process.env.SUPABASE_URL || 'https://ttnbiybejkwdwgkhfunh.supabase.co',
    publishableKey: process.env.SUPABASE_PUBLISHABLE_KEY || process.env.SUPABASE_ANON_KEY || 'sb_publishable_dCaPGKN5eSpJv-L_c_EGnQ_XMq3DrSS',
    serviceRoleKey: process.env.SUPABASE_SERVICE_ROLE_KEY || '',
  },
};
