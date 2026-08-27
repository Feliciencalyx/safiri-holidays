const { createClient } = require('@supabase/supabase-js');

const SUPABASE_URL = process.env.SUPABASE_URL || 'https://ttnbiybejkwdwgkhfunh.supabase.co';
const SUPABASE_SERVICE_ROLE_KEY =
  process.env.SUPABASE_SERVICE_ROLE_KEY ||
  'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3OiOiJzdXBhYmFzZSIsInJlZiI6InR0bmJpeWJlamt3ZHdna2hmdW5oIiwicm9sZSI6InNlcnZpY2Vfcm9sZSIsImlhdCI6MTc4Nzc0MDYzNCwiZXhwIjoyMTAzMzE2NjM0fQ.IxFXNBcmtygpPO2WVoBRkOpTwHYfcHErhFxCbky2I_w';

let supabaseAdmin;
try {
  supabaseAdmin = createClient(SUPABASE_URL, SUPABASE_SERVICE_ROLE_KEY, {
    auth: {
      autoRefreshToken: false,
      persistSession: false,
    },
  });
} catch (e) {
  console.error('[SUPABASE INIT WARNING]', e.message);
}

module.exports = { supabaseAdmin };
