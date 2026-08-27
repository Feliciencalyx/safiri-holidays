import * as authService from '../services/auth.service.js';

/**
 * POST /api/auth/register
 */
export async function register(req, res) {
  try {
    const { name, email, username, password, role, phone } = req.body;

    if (!name || !email || !password) {
      return res.status(400).json({
        success: false,
        message: 'Missing required registration fields (name, email, password)',
      });
    }

    if (password.length < 6) {
      return res.status(400).json({
        success: false,
        message: 'Password must be at least 6 characters long',
      });
    }

    const result = await authService.registerUser({
      name,
      email,
      username,
      password,
      role,
      phone,
    });

    return res.status(201).json({
      success: true,
      message: 'User registered successfully',
      user: result.user,
      token: result.token,
    });
  } catch (error) {
    return res.status(400).json({
      success: false,
      message: error.message || 'Registration failed',
    });
  }
}

/**
 * POST /api/auth/login
 */
export async function login(req, res) {
  try {
    const { usernameOrEmail, email, username, password } = req.body;

    const identifier = usernameOrEmail || email || username;

    if (!identifier || !password) {
      return res.status(400).json({
        success: false,
        message: 'Please provide email/username and password',
      });
    }

    const result = await authService.loginUser({
      usernameOrEmail: identifier,
      password,
    });

    return res.json({
      success: true,
      message: 'Login successful',
      user: result.user,
      token: result.token,
    });
  } catch (error) {
    return res.status(401).json({
      success: false,
      message: error.message || 'Invalid credentials',
    });
  }
}

/**
 * GET /api/auth/me
 */
export async function getMe(req, res) {
  try {
    const userProfile = authService.getUserProfile(req.user.email);
    if (!userProfile) {
      return res.status(440).json({
        success: false,
        message: 'User profile not found',
      });
    }

    return res.json({
      success: true,
      user: userProfile,
    });
  } catch (error) {
    return res.status(500).json({
      success: false,
      message: 'Unable to retrieve user profile',
    });
  }
}

/**
 * POST /api/auth/google
 */
export async function googleLogin(req, res) {
  try {
    const { googleToken, email, name, picture } = req.body;

    const result = await authService.googleAuthenticate({
      googleToken,
      email,
      name,
      picture,
    });

    return res.json({
      success: true,
      message: 'Google authentication successful',
      user: result.user,
      token: result.token,
    });
  } catch (error) {
    return res.status(400).json({
      success: false,
      message: error.message || 'Google authentication failed',
    });
  }
}
