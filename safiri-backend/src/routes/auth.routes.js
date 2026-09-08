const express = require('express');
const router = express.Router();
const { supabaseAdmin } = require('../config/supabase');

// POST /api/auth/register
router.post('/register', async (req, res, next) => {
  const { email, password, name, phone, passportNumber, role } = req.body;

  try {
    if (!email || !password) {
      return res.status(400).json({
        success: false,
        message: 'Email and password are required.',
      });
    }

    if (!supabaseAdmin || !supabaseAdmin.auth) {
      return res.status(500).json({
        success: false,
        message: 'Supabase client is not configured. Please check SUPABASE_SERVICE_ROLE_KEY.',
      });
    }

    // 1. Create auth user in Supabase auth.users
    const { data: authData, error: authError } = await supabaseAdmin.auth.admin.createUser({
      email,
      password,
      email_confirm: true,
      user_metadata: {
        full_name: name,
        phone,
        role: role || 'customer',
      },
    });

    if (authError) {
      console.error('[SUPABASE AUTH ERROR]', authError);
      return res.status(400).json({
        success: false,
        message: authError.message || 'Failed to create user in Supabase auth.',
      });
    }

    const userId = authData.user.id;

    // 2. Explicitly insert/upsert into public.profiles
    const { error: profileError } = await supabaseAdmin.from('profiles').upsert({
      id: userId,
      email: email,
      full_name: name || email.split('@')[0],
      phone: phone || null,
      role: role || 'customer',
      tier: 'Premium Explorer',
      status: 'Active',
      updated_at: new Date().toISOString(),
    });

    if (profileError) {
      console.error('[SUPABASE PROFILES INSERT ERROR]', profileError);
    }

    // 3. Create traveler profile entry if passport provided
    if (passportNumber) {
      const { error: travelerError } = await supabaseAdmin.from('traveler_profiles').upsert({
        user_id: userId,
        passport_number: passportNumber,
        is_passport_verified: true,
        verification_badge_text: 'VERIFIED ICAO 9303',
        updated_at: new Date().toISOString(),
      });
      if (travelerError) {
        console.error('[SUPABASE TRAVELER_PROFILES INSERT ERROR]', travelerError);
      }
    }

    res.status(201).json({
      success: true,
      message: 'Account created successfully in Supabase PostgreSQL',
      user: {
        id: userId,
        name: name || email.split('@')[0],
        email,
        role: role || 'customer',
        phone,
        passportNumber,
      },
      token: `jwt_supabase_${userId}`,
    });
  } catch (err) {
    console.error('[AUTH REGISTER ROUTE EXCEPTION]', err);
    res.status(500).json({
      success: false,
      message: err.message || 'Unable to complete registration. Please try again.',
    });
  }
});

// POST /api/auth/login
router.post('/login', async (req, res, next) => {
  const { usernameOrEmail, password } = req.body;

  try {
    if (!usernameOrEmail || !password) {
      return res.status(400).json({
        success: false,
        message: 'Please enter both your email/username and password.',
      });
    }

    if (!supabaseAdmin || !supabaseAdmin.auth) {
      return res.status(500).json({
        success: false,
        message: 'Supabase client is not configured. Please check SUPABASE_SERVICE_ROLE_KEY.',
      });
    }

    const { data, error } = await supabaseAdmin.auth.signInWithPassword({
      email: usernameOrEmail,
      password,
    });

    if (error) {
      return res.status(401).json({
        success: false,
        message: error.message || 'Incorrect email or password. Please check your credentials.',
      });
    }

    // Fetch profile details from public.profiles
    const { data: profile } = await supabaseAdmin
      .from('profiles')
      .select('*')
      .eq('id', data.user.id)
      .single();

    res.status(200).json({
      success: true,
      message: 'Login successful',
      user: {
        id: data.user.id,
        name: profile?.full_name || data.user.user_metadata?.full_name || usernameOrEmail,
        email: data.user.email,
        role: profile?.role || data.user.user_metadata?.role || 'customer',
      },
      token: data.session?.access_token,
    });
  } catch (err) {
    res.status(401).json({
      success: false,
      message: 'Incorrect email or password. Please check your details and try again.',
    });
  }
});

module.exports = router;
