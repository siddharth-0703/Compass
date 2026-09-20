import jwt from 'jsonwebtoken';
import crypto from 'crypto';
import { IUser } from '@rural/types';

const JWT_SECRET = process.env.JWT_SECRET || 'supersecret';
const REFRESH_SECRET = process.env.JWT_REFRESH_SECRET || 'superrefreshsecret';
const JWT_EXPIRY = process.env.JWT_EXPIRY || '15m';

export const generateAccessToken = (user: Partial<IUser>): string => {
  return jwt.sign(
    { userId: user.id, roles: user.roles }, 
    JWT_SECRET, 
    { expiresIn: JWT_EXPIRY as any }
  );
};

export const verifyAccessToken = (token: string) => {
  return jwt.verify(token, JWT_SECRET);
};

export const generateRefreshToken = (): string => {
  return crypto.randomBytes(40).toString('hex');
};

export const hashRefreshToken = (token: string): string => {
  return crypto.createHash('sha256').update(token).digest('hex');
};
