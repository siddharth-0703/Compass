export type Role = 'entrepreneur' | 'mentor' | 'admin' | 'investor' | 'ngo' | 'government';

export interface IUser {
  id?: string;
  phone: string;
  email?: string;
  roles: Role[];
  name?: string;
  isVerified: boolean;
  isActive: boolean;
  accountStatus: 'active' | 'suspended' | 'pending_verification';
  profileCompletion: number;
  lastLogin?: Date;
  failedLoginAttempts: number;
  passwordHash?: string;
  createdAt?: Date;
  updatedAt?: Date;
}

export interface ISession {
  id?: string;
  userId: string;
  refreshTokenHash: string;
  deviceName?: string;
  deviceType?: string;
  browser?: string;
  ip?: string;
  lastActive: Date;
  expiresAt: Date;
  isRevoked: boolean;
}

export interface IAuditLog {
  id?: string;
  userId: string;
  action: string;
  ip?: string;
  device?: string;
  browser?: string;
  timestamp: Date;
  metadata?: Record<string, any>;
}

export interface AuthResponse {
  success: boolean;
  data?: {
    user: Partial<IUser>;
    accessToken: string;
  };
  error?: {
    code: string;
    message: string;
  };
}

export type BusinessCategory = 'Agriculture' | 'Food Processing' | 'Handicrafts' | 'Textiles' | 'Retail' | 'Services' | 'Manufacturing' | 'Livestock' | 'Tourism' | 'Education' | 'Technology' | 'Healthcare' | 'Fisheries';

export type BusinessStatus = 'Draft' | 'Pending Verification' | 'Verified' | 'Rejected' | 'Suspended' | 'Archived';

export interface ILocation {
  type: 'Point';
  coordinates: number[]; // [longitude, latitude]
}

export interface IBusinessLocation {
  state: string;
  district: string;
  village?: string;
  pincode: string;
  geo?: ILocation;
}

export interface IBusinessFinancials {
  annualTurnover?: number;
  monthlyRevenue?: number;
  monthlyProfit?: number;
  monthlyExpenses?: number;
}

export interface IBusinessAnalytics {
  views: number;
  followers: number;
  profileCompletion: number;
  marketplaceListings: number;
  mentorSessions: number;
  schemeMatches: number;
  growthScore: number;
}

export interface IBusinessAI {
  embeddingId?: string;
  vectorId?: string;
  summary?: string;
  keywords?: string[];
  tags?: string[];
  classification?: string;
  recommendationScore?: number;
}

export interface IBusiness {
  id?: string;
  userId: string;
  name: string;
  description: string;
  category: BusinessCategory;
  subcategory?: string;
  status: BusinessStatus;
  yearStarted?: number;
  gstNumber?: string;
  msmeNumber?: string;
  registrationType?: string;
  stage?: 'idea' | 'early' | 'growth' | 'mature';
  employees?: number;
  womenOwned: boolean;
  farmerProducerOrganization: boolean;
  website?: string;
  socialMedia?: Record<string, string>;
  languages?: string[];
  operatingHours?: string;
  logoUrl?: string;
  coverImageUrl?: string;
  location: IBusinessLocation;
  financials: IBusinessFinancials;
  analytics: IBusinessAnalytics;
  aiReadyMetadata: IBusinessAI;
  createdAt?: Date;
  updatedAt?: Date;
}
export * from './src/community.types';
export * from './src/scheme.types';
export * from './src/mentorship.types';
export * from './src/learning.types';
export * from './src/analytics.types';
export * from './src/notification.types';
export * from './src/reputation.types';
export * from './src/admin.types';
export * from './src/ingestion.types';
export * from './src/ai.types';