import supabase from '../config/supabase.js';

/**
 * Middleware to verify Supabase Auth Bearer Tokens from Authorization Header
 */
export async function verifySupabaseToken(req, res, next) {
  const authHeader = req.headers.authorization || req.headers.Authorization;

  if (!authHeader || !authHeader.startsWith('Bearer ')) {
    return res.status(401).json({
      success: false,
      message: 'Access Denied: Missing or malformed Bearer authorization token',
    });
  }

  const token = authHeader.split(' ')[1];

  if (!supabase) {
    return res.status(500).json({
      success: false,
      message: 'Supabase client is not configured on backend server',
    });
  }

  try {
    const { data: { user }, error } = await supabase.auth.getUser(token);

    if (error || !user) {
      return res.status(401).json({
        success: false,
        message: 'Invalid or expired Supabase authorization token',
        error: error?.message,
      });
    }

    // Attach authenticated Supabase user to request object
    req.supabaseUser = user;
    req.user = {
      id: user.id,
      email: user.email,
      role: user.role || 'customer',
      user_metadata: user.user_metadata,
    };

    next();
  } catch (err) {
    return res.status(500).json({
      success: false,
      message: 'Internal server error verifying Supabase token',
      error: err.message,
    });
  }
}
