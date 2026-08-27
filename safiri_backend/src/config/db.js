import { PrismaClient } from '@prisma/client';
import dotenv from 'dotenv';

dotenv.config();

let prisma = null;
let isDbConnected = false;

const databaseUrl = process.env.DATABASE_URL;

if (databaseUrl && !databaseUrl.includes('YOUR_SUPABASE_POSTGRESQL_URL')) {
  try {
    prisma = new PrismaClient({
      log: process.env.NODE_ENV === 'development' ? ['query', 'info', 'warn', 'error'] : ['error'],
    });
    isDbConnected = true;
    console.log('✅ [SAFIRI DB] Prisma Client initialized for Supabase PostgreSQL');
  } catch (error) {
    console.error('⚠️ [SAFIRI DB ERROR] Failed to initialize Prisma Client:', error.message);
  }
} else {
  console.log('ℹ️ [SAFIRI DB] DATABASE_URL not set or using template. Operating with graceful database fallback.');
}

/**
 * Helper to check DB connectivity
 */
export async function testDbConnection() {
  if (!prisma) return false;
  try {
    await prisma.$queryRaw`SELECT 1`;
    return true;
  } catch (error) {
    console.warn('⚠️ [SAFIRI DB] Could not reach Supabase PostgreSQL database:', error.message);
    return false;
  }
}

export { prisma, isDbConnected };
export default prisma;
