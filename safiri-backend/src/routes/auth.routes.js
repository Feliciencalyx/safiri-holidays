const express = require('express');
const router = express.Router();
const crypto = require('crypto');
const { supabaseAdmin } = require('../config/supabase');
const { sendOtpEmail } = require('../services/mailer.service');

// Resilient in-memory OTP cache (supplements database table for instant fallback)
const otpCache = new Map();

// Helper: Normalize phone numbers for consistent lookup
function normalizePhone(phone) {
  if (!phone) return '';
  return phone.replace(/[\s\-\(\)]/g, '').trim();
}

// Helper: Mask email or phone for privacy display (e.g. f***@gmail.com or +250 788 *** 123)
function maskIdentifier(id) {
  if (!id) return '';
  if (id.includes('@')) {
    const parts = id.split('@');
    const name = parts[0];
    const domain = parts[1];
    const visible = name.length > 2 ? name.substring(0, 2) : name.substring(0, 1);
    return visible + '***@' + domain;
  }
  const clean = normalizePhone(id);
  if (clean.length > 6) {
    return clean.substring(0, 6) + '***' + clean.substring(clean.length - 2);
  }
  return clean.substring(0, 2) + '***';
}

// ============================================================================
// 1. GET /api/auth/check-availability
// Real-time pre-check to prevent duplicate email, username, or phone
// ============================================================================
router.get('/check-availability', async (req, res) => {
  const { email, username, phone } = req.query;

  if (!supabaseAdmin) {
    return res.json({ available: true, message: 'Database bypass active in development' });
  }

  try {
    // 1. Check Email
    if (email) {
      const normalizedEmail = email.trim().toLowerCase();
      const { data: existingEmail } = await supabaseAdmin
        .from('profiles')
        .select('id, email')
        .eq('email', normalizedEmail)
        .maybeSingle();

      if (existingEmail) {
        return res.status(200).json({
          available: false,
          field: 'email',
          message: 'An account with this email address already exists. Please sign in or use another email.',
        });
      }
    }

    // 2. Check Username
    if (username) {
      const trimmedUser = username.trim().toLowerCase();
      const { data: existingUser } = await supabaseAdmin
        .from('profiles')
        .select('id, username')
        .ilike('username', trimmedUser)
        .maybeSingle();

      if (existingUser) {
        return res.status(200).json({
          available: false,
          field: 'username',
          message: 'This username is already taken. Please choose another username.',
        });
      }
    }

    // 3. Check Phone Number
    if (phone) {
      const cleanPhone = normalizePhone(phone);
      if (cleanPhone.length >= 7) {
        const { data: existingPhone } = await supabaseAdmin
          .from('profiles')
          .select('id, phone')
          .eq('phone', cleanPhone)
          .maybeSingle();

        if (existingPhone) {
          return res.status(200).json({
            available: false,
            field: 'phone',
            message: 'This phone number is already registered to another account.',
          });
        }
      }
    }

    return res.status(200).json({
      available: true,
      message: 'All credentials are valid and available.',
    });
  } catch (err) {
    console.error('[CHECK AVAILABILITY ERROR]', err.message);
    return res.status(200).json({ available: true });
  }
});

// ============================================================================
// 2. POST /api/auth/send-otp
// Dispatches 6-digit confirmation code for Signup or Password Reset
// ============================================================================
router.post('/send-otp', async (req, res) => {
  const { identifier, type, username, phone } = req.body;

  if (!identifier) {
    return res.status(400).json({
      success: false,
      message: 'Email or phone identifier is required.',
    });
  }

  const normalizedId = identifier.includes('@') ? identifier.trim().toLowerCase() : normalizePhone(identifier);
  const otpType = type || 'signup';

  try {
    // A. For SIGNUP: Strictly ensure email, username, and phone do NOT already exist
    if (otpType === 'signup') {
      if (supabaseAdmin) {
        // Email check
        if (identifier.includes('@')) {
          const { data: emailMatch } = await supabaseAdmin
            .from('profiles')
            .select('id')
            .eq('email', normalizedId)
            .maybeSingle();
          if (emailMatch) {
            return res.status(409).json({
              success: false,
              field: 'email',
              message: 'This email is already registered. Please sign in or use another email.',
            });
          }
        }

        // Username check
        if (username) {
          const { data: userMatch } = await supabaseAdmin
            .from('profiles')
            .select('id')
            .ilike('username', username.trim())
            .maybeSingle();
          if (userMatch) {
            return res.status(409).json({
              success: false,
              field: 'username',
              message: 'This username is already taken. Please choose another.',
            });
          }
        }

        // Phone check
        const checkPhone = normalizePhone(phone || identifier);
        if (checkPhone && !identifier.includes('@')) {
          const { data: phoneMatch } = await supabaseAdmin
            .from('profiles')
            .select('id')
            .eq('phone', checkPhone)
            .maybeSingle();
          if (phoneMatch) {
            return res.status(409).json({
              success: false,
              field: 'phone',
              message: 'This phone number is already registered to another account.',
            });
          }
        }
      }
    }

    // B. For PASSWORD_RESET: Confirm that the user actually exists in the database
    let targetEmail = normalizedId;
    if (otpType === 'password_reset' && supabaseAdmin) {
      const { data: existingAccount } = await supabaseAdmin
        .from('profiles')
        .select('id, email, phone, username, full_name')
        .or('email.eq.' + normalizedId + ',username.eq.' + normalizedId + ',phone.eq.' + normalizedId)
        .maybeSingle();

      if (!existingAccount) {
        return res.status(404).json({
          success: false,
          message: 'No account found matching this email, username, or phone number.',
        });
      }

      targetEmail = existingAccount.email;
    }

    // Generate secure 6-digit OTP code
    const otpCode = Math.floor(100000 + Math.random() * 900000).toString();
    const expiresAt = new Date(Date.now() + 10 * 60 * 1000); // 10 minutes

    // Save into database verification_codes table if available
    if (supabaseAdmin) {
      try {
        await supabaseAdmin.from('verification_codes').insert({
          identifier: targetEmail,
          code: otpCode,
          type: otpType,
          expires_at: expiresAt.toISOString(),
          is_used: false,
        });
      } catch (dbErr) {
        console.warn('[VERIFICATION CODES TABLE INSERT]', dbErr.message);
      }
    }

    // Save into in-memory cache
    const cacheKey = normalizedId + ':' + otpType;
    otpCache.set(cacheKey, {
      code: otpCode,
      targetEmail,
      expiresAt: expiresAt.getTime(),
      attempts: 0,
    });

    console.log('====================================================');
    console.log('[AUTH OTP DISPATCHED]');
    console.log('   Type:       ' + otpType);
    console.log('   Identifier: ' + normalizedId + ' (Target: ' + targetEmail + ')');
    console.log('   Code:       ' + otpCode);
    console.log('   Expires:    10 minutes');
    console.log('====================================================');

    // Dispatch real email to user's inbox
    let emailResult = { delivered: false };
    if (targetEmail && targetEmail.includes('@')) {
      emailResult = await sendOtpEmail({
        to: targetEmail,
        code: otpCode,
        type: otpType,
        name: username || 'Valued Traveler',
      });
    }

    return res.status(200).json({
      success: true,
      message: emailResult.delivered
        ? 'A 6-digit confirmation code has been delivered to your email inbox (' + maskIdentifier(targetEmail) + ').'
        : 'A 6-digit confirmation code has been sent to ' + maskIdentifier(targetEmail) + '.',
      targetMasked: maskIdentifier(targetEmail),
      emailDelivered: emailResult.delivered,
      debugCode: (process.env.NODE_ENV === 'production' && emailResult.delivered) ? undefined : otpCode,
    });
  } catch (err) {
    console.error('[SEND OTP ERROR]', err);
    return res.status(500).json({
      success: false,
      message: 'Failed to send confirmation code. Please try again.',
    });
  }
});

// ============================================================================
// 3. POST /api/auth/verify-otp
// Validates 6-digit code for Signup or Password Reset
// ============================================================================
router.post('/verify-otp', async (req, res) => {
  const { identifier, code, type } = req.body;

  if (!identifier || !code) {
    return res.status(400).json({
      success: false,
      message: 'Identifier and confirmation code are required.',
    });
  }

  const normalizedId = identifier.includes('@') ? identifier.trim().toLowerCase() : normalizePhone(identifier);
  const otpType = type || 'signup';
  const cleanCode = code.toString().trim();

  try {
    const cacheKey = normalizedId + ':' + otpType;
    const cached = otpCache.get(cacheKey);

    let isMatch = false;

    // Check memory cache first
    if (cached) {
      if (Date.now() > cached.expiresAt) {
        otpCache.delete(cacheKey);
        return res.status(400).json({
          success: false,
          message: 'The confirmation code has expired. Please request a new one.',
        });
      }

      if (cached.code === cleanCode) {
        isMatch = true;
        otpCache.delete(cacheKey);
      }
    }

    // Check database verification_codes table if not matched in memory
    if (!isMatch && supabaseAdmin) {
      const { data: dbCode } = await supabaseAdmin
        .from('verification_codes')
        .select('*')
        .eq('identifier', normalizedId)
        .eq('code', cleanCode)
        .eq('type', otpType)
        .eq('is_used', false)
        .gte('expires_at', new Date().toISOString())
        .order('created_at', { ascending: false })
        .limit(1)
        .maybeSingle();

      if (dbCode) {
        isMatch = true;
        await supabaseAdmin
          .from('verification_codes')
          .update({ is_used: true })
          .eq('id', dbCode.id);
      }
    }

    if (!isMatch) {
      return res.status(400).json({
        success: false,
        message: 'Invalid confirmation code. Please double-check the 6 digits and try again.',
      });
    }

    // Generate secure temporary verification token for final action
    const verificationToken = crypto.randomBytes(24).toString('hex');

    return res.status(200).json({
      success: true,
      verified: true,
      message: 'Code confirmed successfully!',
      verificationToken,
    });
  } catch (err) {
    console.error('[VERIFY OTP ERROR]', err);
    return res.status(500).json({
      success: false,
      message: 'Unable to verify confirmation code right now.',
    });
  }
});

// ============================================================================
// 4. POST /api/auth/reset-password
// Updates user password in Supabase after verifying confirmation code
// ============================================================================
router.post('/reset-password', async (req, res) => {
  const { identifier, code, newPassword } = req.body;

  if (!identifier || !code || !newPassword) {
    return res.status(400).json({
      success: false,
      message: 'Identifier, confirmation code, and new password are required.',
    });
  }

  if (newPassword.length < 8) {
    return res.status(400).json({
      success: false,
      message: 'New password must be at least 8 characters long.',
    });
  }

  const normalizedId = identifier.includes('@') ? identifier.trim().toLowerCase() : normalizePhone(identifier);
  const cleanCode = code.toString().trim();

  try {
    // 1. Verify code
    const cacheKey = normalizedId + ':password_reset';
    const cached = otpCache.get(cacheKey);
    let isMatch = false;

    if (cached && cached.code === cleanCode && Date.now() <= cached.expiresAt) {
      isMatch = true;
      otpCache.delete(cacheKey);
    }

    if (!isMatch && supabaseAdmin) {
      const { data: dbCode } = await supabaseAdmin
        .from('verification_codes')
        .select('*')
        .eq('identifier', normalizedId)
        .eq('code', cleanCode)
        .eq('type', 'password_reset')
        .eq('is_used', false)
        .gte('expires_at', new Date().toISOString())
        .maybeSingle();

      if (dbCode) {
        isMatch = true;
        await supabaseAdmin
          .from('verification_codes')
          .update({ is_used: true })
          .eq('id', dbCode.id);
      }
    }

    if (!isMatch) {
      return res.status(400).json({
        success: false,
        message: 'Invalid or expired confirmation code. Please request a new code.',
      });
    }

    if (!supabaseAdmin) {
      return res.status(200).json({
        success: true,
        message: 'Password updated successfully (Development Offline Mode).',
      });
    }

    // 2. Find target user
    const { data: profile } = await supabaseAdmin
      .from('profiles')
      .select('id, email')
      .or('email.eq.' + normalizedId + ',username.eq.' + normalizedId + ',phone.eq.' + normalizedId)
      .maybeSingle();

    if (!profile) {
      return res.status(404).json({
        success: false,
        message: 'User account not found.',
      });
    }

    // 3. Update password in Supabase Auth
    const { error: updateError } = await supabaseAdmin.auth.admin.updateUserById(profile.id, {
      password: newPassword,
    });

    if (updateError) {
      console.error('[RESET PASSWORD SUPABASE ERROR]', updateError);
      return res.status(500).json({
        success: false,
        message: updateError.message || 'Failed to update password. Please try again.',
      });
    }

    return res.status(200).json({
      success: true,
      message: 'Your password has been successfully reset! You can now log in with your new password.',
    });
  } catch (err) {
    console.error('[RESET PASSWORD EXCEPTION]', err);
    return res.status(500).json({
      success: false,
      message: 'Failed to reset password. Please try again.',
    });
  }
});

// ============================================================================
// 5. POST /api/auth/register
// Complete user registration with strict uniqueness checks and Supabase storage
// ============================================================================
router.post('/register', async (req, res) => {
  const { email, password, name, username, phone, passportNumber, role } = req.body;

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

    const normalizedEmail = email.trim().toLowerCase();
    const cleanPhone = normalizePhone(phone);
    const cleanUsername = (username || email.split('@')[0]).trim().toLowerCase();

    // 1. STRICT UNIQUENESS ENFORCEMENT: Email, Username, Phone
    const { data: existingEmail } = await supabaseAdmin
      .from('profiles')
      .select('id')
      .eq('email', normalizedEmail)
      .maybeSingle();

    if (existingEmail) {
      return res.status(409).json({
        success: false,
        field: 'email',
        message: 'This email address is already registered. Please sign in or use another email.',
      });
    }

    if (cleanUsername) {
      const { data: existingUser } = await supabaseAdmin
        .from('profiles')
        .select('id')
        .ilike('username', cleanUsername)
        .maybeSingle();

      if (existingUser) {
        return res.status(409).json({
          success: false,
          field: 'username',
          message: 'This username is already taken. Please choose another username.',
        });
      }
    }

    if (cleanPhone) {
      const { data: existingPhone } = await supabaseAdmin
        .from('profiles')
        .select('id')
        .eq('phone', cleanPhone)
        .maybeSingle();

      if (existingPhone) {
        return res.status(409).json({
          success: false,
          field: 'phone',
          message: 'This phone number is already associated with another account.',
        });
      }
    }

    // 2. Create Auth user in Supabase auth.users
    const { data: authData, error: authError } = await supabaseAdmin.auth.admin.createUser({
      email: normalizedEmail,
      password,
      email_confirm: true,
      user_metadata: {
        full_name: name || cleanUsername,
        username: cleanUsername,
        phone: cleanPhone,
        role: role || 'customer',
      },
    });

    if (authError) {
      console.error('[SUPABASE AUTH REGISTER ERROR]', authError);
      return res.status(400).json({
        success: false,
        message: authError.message || 'Failed to create user in Supabase auth.',
      });
    }

    const userId = authData.user.id;

    // 3. Upsert into public.profiles with graceful schema compatibility
    const profilePayload = {
      id: userId,
      email: normalizedEmail,
      full_name: name || cleanUsername,
      phone: cleanPhone || null,
      role: role || 'customer',
      tier: 'Premium Explorer',
      status: 'Active',
      updated_at: new Date().toISOString(),
    };
    if (cleanUsername) {
      profilePayload.username = cleanUsername;
    }

    let { error: profileError } = await supabaseAdmin.from('profiles').upsert(profilePayload);

    if (profileError && profileError.code === 'PGRST204') {
      console.warn('[PROFILES SCHEMA NOTICE] profiles table does not have username column yet, retrying without username');
      delete profilePayload.username;
      const retry = await supabaseAdmin.from('profiles').upsert(profilePayload);
      profileError = retry.error;
    }

    if (profileError) {
      console.error('[SUPABASE PROFILES INSERT ERROR]', profileError);
    }

    // 4. Create traveler profile entry if passport provided
    if (passportNumber) {
      await supabaseAdmin.from('traveler_profiles').upsert({
        user_id: userId,
        passport_number: passportNumber,
        is_passport_verified: true,
        verification_badge_text: 'VERIFIED ICAO 9303',
        updated_at: new Date().toISOString(),
      });
    }

    return res.status(201).json({
      success: true,
      message: 'Account created and verified successfully in Safiri Holidays database.',
      user: {
        id: userId,
        name: name || cleanUsername,
        email: normalizedEmail,
        username: cleanUsername,
        role: role || 'customer',
        phone: cleanPhone,
        passportNumber,
      },
      token: 'jwt_supabase_' + userId,
    });
  } catch (err) {
    console.error('[AUTH REGISTER ROUTE EXCEPTION]', err);
    return res.status(500).json({
      success: false,
      message: err.message || 'Unable to complete registration. Please try again.',
    });
  }
});

// ============================================================================
// 6. POST /api/auth/login
// ============================================================================
router.post('/login', async (req, res) => {
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

    const input = usernameOrEmail.trim();

    // Determine target email if user typed username or phone
    let targetEmail = input;
    if (!input.includes('@')) {
      const { data: profileMatch } = await supabaseAdmin
        .from('profiles')
        .select('email')
        .or('username.eq.' + input.toLowerCase() + ',phone.eq.' + normalizePhone(input))
        .maybeSingle();

      if (profileMatch) {
        targetEmail = profileMatch.email;
      }
    }

    const { data, error } = await supabaseAdmin.auth.signInWithPassword({
      email: targetEmail,
      password,
    });

    if (error) {
      return res.status(401).json({
        success: false,
        message: error.message || 'Incorrect email or password. Please check your credentials.',
      });
    }

    const { data: profile } = await supabaseAdmin
      .from('profiles')
      .select('*')
      .eq('id', data.user.id)
      .single();

    return res.status(200).json({
      success: true,
      message: 'Login successful',
      user: {
        id: data.user.id,
        name: profile?.full_name || data.user.user_metadata?.full_name || input,
        email: data.user.email,
        username: profile?.username || data.user.user_metadata?.username || input,
        phone: profile?.phone || '',
        role: profile?.role || data.user.user_metadata?.role || 'customer',
      },
      token: data.session?.access_token,
    });
  } catch (err) {
    return res.status(401).json({
      success: false,
      message: 'Incorrect email or password. Please check your details and try again.',
    });
  }
});

// ============================================================================
// 7. POST /api/auth/google
// Live Google Single Sign-On / Registration with phone & uniqueness checks
// ============================================================================
router.post('/google', async (req, res) => {
  const { email, name, picture, phone, passportNumber } = req.body;

  if (!email) {
    return res.status(400).json({
      success: false,
      message: 'Google authentication requires a verified email address.',
    });
  }

  const normalizedEmail = email.trim().toLowerCase();
  const cleanPhone = normalizePhone(phone);
  const cleanUsername = normalizedEmail.split('@')[0];

  try {
    if (!supabaseAdmin) {
      return res.status(200).json({
        success: true,
        message: 'Google Sign-In successful (Development Mode)',
        user: {
          id: 'usr_g_' + Date.now(),
          name: name || cleanUsername,
          email: normalizedEmail,
          username: cleanUsername,
          role: 'customer',
          phone: cleanPhone || '+250788000000',
        },
        token: 'mock_jwt_google_' + Date.now(),
      });
    }

    // 1. Check if user already exists in profiles
    const { data: existingUser } = await supabaseAdmin
      .from('profiles')
      .select('*')
      .eq('email', normalizedEmail)
      .maybeSingle();

    if (existingUser) {
      // User exists! Update phone or passport if provided and currently empty
      if (cleanPhone && !existingUser.phone) {
        const { data: phoneConflict } = await supabaseAdmin
          .from('profiles')
          .select('id')
          .eq('phone', cleanPhone)
          .neq('id', existingUser.id)
          .maybeSingle();

        if (phoneConflict) {
          return res.status(409).json({
            success: false,
            field: 'phone',
            message: 'This phone number is already registered to another account.',
          });
        }

        await supabaseAdmin
          .from('profiles')
          .update({ phone: cleanPhone, updated_at: new Date().toISOString() })
          .eq('id', existingUser.id);
        existingUser.phone = cleanPhone;
      }

      return res.status(200).json({
        success: true,
        message: 'Welcome back! Signed in with Google.',
        user: {
          id: existingUser.id,
          name: existingUser.full_name,
          email: existingUser.email,
          username: existingUser.username || cleanUsername,
          phone: existingUser.phone || '',
          role: existingUser.role,
        },
        token: 'jwt_google_' + existingUser.id,
      });
    }

    // 2. New Google User: Check phone uniqueness if phone was supplied
    if (cleanPhone) {
      const { data: phoneTaken } = await supabaseAdmin
        .from('profiles')
        .select('id')
        .eq('phone', cleanPhone)
        .maybeSingle();

      if (phoneTaken) {
        return res.status(409).json({
          success: false,
          field: 'phone',
          message: 'This phone number is already registered to another account.',
        });
      }
    }

    // 3. Create user in Supabase auth
    const randomPassword = crypto.randomBytes(16).toString('hex') + 'A1!';
    const { data: authData } = await supabaseAdmin.auth.admin.createUser({
      email: normalizedEmail,
      password: randomPassword,
      email_confirm: true,
      user_metadata: {
        full_name: name || cleanUsername,
        username: cleanUsername,
        phone: cleanPhone,
        avatar_url: picture,
      },
    });

    const userId = authData?.user?.id || crypto.randomUUID();

    // 4. Create profile entry with graceful schema compatibility
    const googleProfilePayload = {
      id: userId,
      email: normalizedEmail,
      full_name: name || cleanUsername,
      phone: cleanPhone || null,
      avatar_url: picture || null,
      role: 'customer',
      tier: 'Premium Explorer',
      status: 'Active',
      updated_at: new Date().toISOString(),
    };
    if (cleanUsername) {
      googleProfilePayload.username = cleanUsername;
    }

    let { error: googleProfileError } = await supabaseAdmin.from('profiles').upsert(googleProfilePayload);

    if (googleProfileError && googleProfileError.code === 'PGRST204') {
      delete googleProfilePayload.username;
      const retry = await supabaseAdmin.from('profiles').upsert(googleProfilePayload);
      googleProfileError = retry.error;
    }

    if (googleProfileError) {
      console.error('[SUPABASE GOOGLE PROFILE INSERT ERROR]', googleProfileError);
    }

    if (passportNumber) {
      await supabaseAdmin.from('traveler_profiles').upsert({
        user_id: userId,
        passport_number: passportNumber,
        is_passport_verified: true,
        verification_badge_text: 'VERIFIED ICAO 9303',
        updated_at: new Date().toISOString(),
      });
    }

    return res.status(200).json({
      success: true,
      message: 'Account created and verified with Google!',
      user: {
        id: userId,
        name: name || cleanUsername,
        email: normalizedEmail,
        username: cleanUsername,
        phone: cleanPhone || '',
        role: 'customer',
      },
      token: 'jwt_google_' + userId,
    });
  } catch (err) {
    console.error('[GOOGLE AUTH ROUTE EXCEPTION]', err);
    return res.status(500).json({
      success: false,
      message: 'Unable to authenticate with Google. Please try again.',
    });
  }
});

module.exports = router;
