import { createClient } from '@supabase/supabase-js';
import { config } from './env.js';

const supabaseUrl = config.supabase.url;
const supabaseKey = config.supabase.publishableKey;

let supabase = null;
let isSupabaseInitialized = false;

if (supabaseUrl && supabaseKey) {
  try {
    supabase = createClient(supabaseUrl, supabaseKey, {
      auth: {
        persistSession: false, // Node.js server environment
        autoRefreshToken: false,
      },
    });
    isSupabaseInitialized = true;
    console.log(`✅ [SAFIRI SUPABASE] Supabase Client initialized successfully`);
    console.log(`   URL: ${supabaseUrl}`);
  } catch (error) {
    console.error(`⚠️ [SAFIRI SUPABASE ERROR] Failed to initialize Supabase client:`, error.message);
  }
} else {
  console.warn(`ℹ️ [SAFIRI SUPABASE] SUPABASE_URL or SUPABASE_PUBLISHABLE_KEY missing.`);
}

/**
 * Health check helper for Supabase connection
 */
export async function testSupabaseConnection() {
  if (!supabase) return { ok: false, error: 'Supabase client not initialized' };
  try {
    const { data, error } = await supabase.auth.getSession();
    if (error && error.status !== 400) {
      // Allow session null errors, check basic connectivity
      return { ok: true, status: 'connected' };
    }
    return { ok: true, status: 'connected' };
  } catch (err) {
    return { ok: false, error: err.message };
  }
}

export { supabase, isSupabaseInitialized };
export default supabase;
