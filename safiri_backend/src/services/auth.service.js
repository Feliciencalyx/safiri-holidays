import bcrypt from 'bcryptjs';
import jwt from 'jsonwebtoken';
import { randomUUID } from 'crypto';
import { config } from '../config/env.js';
import prisma from '../config/db.js';

/**
 * Sign JWT token for authenticated user
 */
export function signUserToken(user) {
  const payload = {
    id: user.id,
    email: user.email,
    username: user.username,
    name: user.name,
    role: user.role,
  };

  return jwt.sign(payload, config.jwt.secret, {
    expiresIn: config.jwt.expiresIn,
  });
}

/**
 * Register new user
 */
export async function registerUser({ name, email, username, password, role = 'customer', phone = '' }) {
  const normalizedEmail = email.toLowerCase().trim();
  const normalizedUsername = (username || email.split('@')[0]).toLowerCase().trim();

  if (!prisma) {
    throw new Error('Database connection unavailable');
  }

  const existingUser = await prisma.user.findFirst({
    where: {
      OR: [
        { email: normalizedEmail },
        { username: normalizedUsername },
      ],
    },
  });

  if (existingUser) {
    throw new Error('User with this email or username already exists');
  }

  const passwordHash = await bcrypt.hash(password, 10);
  const newUser = await prisma.user.create({
    data: {
      name,
      email: normalizedEmail,
      username: normalizedUsername,
      passwordHash,
      role: role === 'admin' ? 'admin' : 'customer',
      phone,
    },
  });

  const token = signUserToken(newUser);
  return {
    user: {
      id: newUser.id,
      name: newUser.name,
      email: newUser.email,
      username: newUser.username,
      role: newUser.role,
      phone: newUser.phone,
    },
    token,
  };
}

/**
 * Authenticate user by credentials
 */
export async function loginUser({ usernameOrEmail, password }) {
  const identifier = String(usernameOrEmail).toLowerCase().trim();

  if (!prisma) {
    throw new Error('Database connection unavailable');
  }

  const user = await prisma.user.findFirst({
    where: {
      OR: [
        { email: identifier },
        { username: identifier },
      ],
    },
  });

  if (!user) {
    throw new Error('Invalid email/username or password');
  }

  const isPasswordValid = await bcrypt.compare(password, user.passwordHash);
  if (!isPasswordValid) {
    throw new Error('Invalid email/username or password');
  }

  const token = signUserToken(user);
  return {
    user: {
      id: user.id,
      name: user.name,
      email: user.email,
      username: user.username,
      role: user.role,
      phone: user.phone,
    },
    token,
  };
}

/**
 * Authenticate or register user via Google Single Sign-On (OAuth)
 */
export async function googleAuthenticate({ googleToken, email, name, picture }) {
  const userEmail = (email || 'google.user@safiriholidays.com').toLowerCase().trim();
  const userName = name || 'Google Verified User';
  const username = userEmail.split('@')[0];

  if (!prisma) {
    throw new Error('Database connection unavailable');
  }

  let user = await prisma.user.findUnique({ where: { email: userEmail } });
  if (!user) {
    user = await prisma.user.create({
      data: {
        id: `user_g_${randomUUID().substring(0, 8)}`,
        name: userName,
        email: userEmail,
        username,
        passwordHash: await bcrypt.hash('GOOGLE_OAUTH_VERIFIED', 10),
        role: 'customer',
        phone: '+250788000000',
      },
    });
  }

  const token = signUserToken(user);
  return {
    user: {
      id: user.id,
      name: user.name,
      email: user.email,
      username: user.username,
      role: user.role,
      phone: user.phone,
      picture,
    },
    token,
  };
}

/**
 * Get User profile by email or ID
 */
export async function getUserProfile(emailOrUsername) {
  const identifier = String(emailOrUsername).toLowerCase().trim();

  if (!prisma) {
    return null;
  }

  const user = await prisma.user.findFirst({
    where: {
      OR: [
        { email: identifier },
        { username: identifier },
        { id: identifier },
      ],
    },
  });

  if (!user) return null;

  return {
    id: user.id,
    name: user.name,
    email: user.email,
    username: user.username,
    role: user.role,
    phone: user.phone,
    createdAt: user.createdAt,
  };
}
