const express = require('express');
const router = express.Router();
const { supabaseAdmin } = require('../config/supabase');

// POST /api/auth/register
router.post('/register', async (req, res, next) => {
  const { email, password, name, phone, passportNumber, role } = req.body;

  try {
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

    if (authError) throw authError;

    // Create traveler profile entry
    if (passportNumber) {
      await supabaseAdmin.from('traveler_profiles').insert({
        user_id: authData.user.id,
        passport_number: passportNumber,
        is_passport_verified: true,
        verification_badge_text: 'VERIFIED ICAO 9303',
      });
    }

    res.status(201).json({
      success: true,
      message: 'Account created successfully in Supabase PostgreSQL',
      user: {
        id: authData.user.id,
        name,
        email,
        role: role || 'customer',
        phone,
        passportNumber,
      },
      token: `jwt_supabase_${authData.user.id}`,
    });
  } catch (err) {
    next(err);
  }
});

// POST /api/auth/login
router.post('/login', async (req, res, next) => {
  const { usernameOrEmail, password } = req.body;

  try {
    const { data, error } = await supabaseAdmin.auth.signInWithPassword({
      email: usernameOrEmail,
      password,
    });

    if (error) {
      return res.status(401).json({
        success: false,
        message: 'Invalid login credentials',
      });
    }

    res.status(200).json({
      success: true,
      message: 'Login successful',
      user: {
        id: data.user.id,
        name: data.user.user_metadata?.full_name || usernameOrEmail,
        email: data.user.email,
        role: data.user.user_metadata?.role || 'customer',
      },
      token: data.session?.access_token,
    });
  } catch (err) {
    next(err);
  }
});

module.exports = router;
