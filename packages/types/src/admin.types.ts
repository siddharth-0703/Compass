export type AdminRole = 'Super Admin' | 'Platform Admin' | 'Regional Admin' | 'Moderator' | 'Support Staff' | 'Auditor';

export type ReportStatus = 'Pending' | 'Under Review' | 'Resolved' | 'Rejected' | 'Escalated';

export interface IContentReport {
  id?: string;
  reporterId: string;
  targetType: 'User' | 'Post' | 'Listing' | 'Scheme' | 'Course';
  targetId: string;
  reason: string;
  evidence?: string;
  status: ReportStatus;
  
  resolvedByAdminId?: string;
  resolutionNote?: string;
  
  createdAt?: Date;
  updatedAt?: Date;
}

export interface IAdminAuditLog {
  id?: string;
  adminId: string;
  action: string; // e.g. 'Ban User', 'Delete Post'
  targetId: string;
  targetType: string;
  reason: string;
  
  previousState?: any;
  newState?: any;
  
  createdAt?: Date;
}

export interface IPlatformDailyMetric {
  id?: string;
  date: Date;
  
  dailyActiveUsers: number;
  newRegistrations: number;
  activeBusinesses: number;
  marketplaceListingsCreated: number;
  communityPostsCreated: number;
  
  createdAt?: Date;
  updatedAt?: Date;
}
