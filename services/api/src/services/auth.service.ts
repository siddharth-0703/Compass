import { UserRepository } from '../repositories/user.repository';
import { SessionRepository } from '../repositories/session.repository';
import { hashPassword, comparePassword, generateAccessToken, generateRefreshToken, hashRefreshToken } from '@rural/auth';
import { logger } from '@rural/logger';
import { AuthResponse } from '@rural/types';

export class AuthService {
  private userRepo: UserRepository;
  private sessionRepo: SessionRepository;

  constructor() {
    this.userRepo = new UserRepository();
    this.sessionRepo = new SessionRepository();
  }

  async register(data: any): Promise<AuthResponse> {
    const existingUser = await this.userRepo.findByPhone(data.phone);
    if (existingUser) {
      return { success: false, error: { code: 'USER_EXISTS', message: 'Phone number already registered' } };
    }

    const hashedPassword = await hashPassword(data.password);
    const user = await this.userRepo.create({
      phone: data.phone,
      email: data.email,
      name: data.name,
      roles: [data.role || 'entrepreneur'],
      passwordHash: hashedPassword,
      isVerified: false,
      isActive: true,
      accountStatus: 'pending_verification',
      profileCompletion: 10,
      failedLoginAttempts: 0
    });

    logger.info(`New user registered: ${user.phone}`);
    return { success: true, data: { user: { id: user.id, roles: user.roles, phone: user.phone }, accessToken: '' } };
  }

  async login(data: any, clientMetadata: any): Promise<AuthResponse> {
    let user = null;
    if (data.email) {
      user = await this.userRepo.findByEmail(data.email);
    } else if (data.phone) {
      user = await this.userRepo.findByPhone(data.phone);
    }

    if (!user || !user.passwordHash) {
      return { success: false, error: { code: 'AUTH_FAILED', message: 'Invalid credentials' } };
    }

    const isMatch = await comparePassword(data.password, user.passwordHash);
    if (!isMatch) {
      await this.userRepo.incrementFailedLogins(user.id as string);
      return { success: false, error: { code: 'AUTH_FAILED', message: 'Invalid credentials' } };
    }

    // Success
    await this.userRepo.updateLastLogin(user.id as string);
    const accessToken = generateAccessToken(user);
    
    // Refresh Token Logic (Rec 3 & 4)
    const refreshToken = generateRefreshToken();
    const tokenHash = hashRefreshToken(refreshToken);
    const expiresAt = new Date();
    expiresAt.setDate(expiresAt.getDate() + 7); // 7 days

    await this.sessionRepo.createSession({
      userId: user.id as string,
      refreshTokenHash: tokenHash,
      ip: clientMetadata.ip,
      browser: clientMetadata.browser,
      expiresAt,
      isRevoked: false,
      lastActive: new Date()
    });

    logger.info(`User logged in: ${user.phone}`);
    return { 
      success: true, 
      data: { user: { id: user.id, roles: user.roles, name: user.name, phone: user.phone, email: user.email }, accessToken } 
    };
  }
}
