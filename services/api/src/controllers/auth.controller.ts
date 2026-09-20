import { Request, Response, NextFunction } from 'express';
import { AuthService } from '../services/auth.service';

const authService = new AuthService();

export class AuthController {
  async register(req: Request, res: Response, next: NextFunction) {
    try {
      const response = await authService.register(req.body);
      if (!response.success) {
        return res.status(400).json(response);
      }
      res.status(201).json(response);
    } catch (error) {
      next(error);
    }
  }

  async login(req: Request, res: Response, next: NextFunction) {
    try {
      const metadata = {
        ip: req.ip,
        browser: req.headers['user-agent']
      };
      const response = await authService.login(req.body, metadata);
      
      if (!response.success) {
        return res.status(401).json(response);
      }
      
      // Normally we would set the refresh token as an HttpOnly cookie here
      // For MVP, we'll assume the client manages the refresh token exchange logic
      res.status(200).json(response);
    } catch (error) {
      next(error);
    }
  }

  async verifyOtp(req: Request, res: Response, next: NextFunction) {
    try {
      const { phone, otp } = req.body;
      // OTP Strategy (Rec 2): We simulate verification here
      console.log(`[Mock] Verifying OTP ${otp} for phone ${phone}`);
      if (otp === '123456') { // Mock logic for MVP
        res.status(200).json({ success: true, message: 'OTP verified successfully' });
      } else {
        res.status(400).json({ success: false, error: { code: 'INVALID_OTP', message: 'OTP is incorrect' }});
      }
    } catch (error) {
      next(error);
    }
  }
}
