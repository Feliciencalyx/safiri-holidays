// Polyfill WebSocket for Node.js < 22 environments so @supabase/realtime-js doesn't crash initialization
if (!globalThis.WebSocket) {
  globalThis.WebSocket = class {};
}

const { createClient } = require('@supabase/supabase-js');

const SUPABASE_URL = process.env.SUPABASE_URL || 'https://ttnbiybejkwdwgkhfunh.supabase.co';
const SUPABASE_SERVICE_ROLE_KEY = process.env.SUPABASE_SERVICE_ROLE_KEY || '';

let supabaseAdmin;
try {
  if (SUPABASE_URL && SUPABASE_SERVICE_ROLE_KEY) {
    supabaseAdmin = createClient(SUPABASE_URL, SUPABASE_SERVICE_ROLE_KEY, {
      auth: {
        autoRefreshToken: false,
        persistSession: false,
      },
    });
  }
} catch (e) {
  console.error('[SUPABASE INIT WARNING]', e.message);
}

module.exports = { supabaseAdmin };
