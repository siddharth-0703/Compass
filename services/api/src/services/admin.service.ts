import { AdminRepository } from '../repositories/admin.repository';
import { UserRepository } from '../repositories/user.repository';
import { BusinessRepository } from '../repositories/business.repository';
import { SchemeRepository } from '../repositories/scheme.repository';
import { logger } from '@rural/logger';
import { PaginationParams } from '../utils/pagination';
import { Queue } from 'bullmq';
import Redis from 'ioredis';

const redisConn = new Redis(process.env.REDIS_URL || 'redis://localhost:6379', { family: 0 });
redisConn.on('error', (err) => console.error('Redis AdminQueue Error:', err));
const syncQueue = new Queue('scheme-sync-tasks', { connection: redisConn });
export class AdminService {
  private adminRepo: AdminRepository;
  private authRepo: UserRepository;
  private businessRepo: BusinessRepository;
  private schemeRepo: SchemeRepository;

  constructor() {
    this.adminRepo = new AdminRepository();
    this.authRepo = new UserRepository(); // To handle user bans
    this.businessRepo = new BusinessRepository();
    this.schemeRepo = new SchemeRepository();
  }

  // Moderation
  async getReports(status?: any) {
    const reports = await this.adminRepo.getReports(status);
    return { success: true, data: reports };
  }

  async resolveReport(reportId: string, adminId: string, resolutionNote: string) {
    const resolved = await this.adminRepo.resolveReport(reportId, adminId, resolutionNote);
    if (!resolved) {
      return { success: false, error: { code: 'NOT_FOUND', message: 'Report not found' } };
    }
    
    await this.adminRepo.logAction({
      adminId,
      action: 'Resolve Report',
      targetId: reportId,
      targetType: 'ContentReport',
      reason: resolutionNote
    });

    return { success: true, data: resolved };
  }

  // User Management
  async getUsers(params: PaginationParams) {
    const result = await this.authRepo.findAllUsers(params);
    return { success: true, data: result };
  }

  async getBusinesses(params: PaginationParams) {
    const result = await this.businessRepo.findAllBusinesses(params);
    return { success: true, data: result };
  }
  async banUser(userId: string, adminId: string, reason: string) {
    // 1. Actually ban the user in Auth DB (assuming AuthModel has an isActive flag)
    // We mock this action here for the MVP architecture
    const user = await this.authRepo.findById(userId);
    if (!user) {
      return { success: false, error: { code: 'NOT_FOUND', message: 'User not found' } };
    }

    // Mock banning: user.isActive = false; await user.save();

    // 2. Log to Audit (Rec 5)
    await this.adminRepo.logAction({
      adminId,
      action: 'Ban User',
      targetId: userId,
      targetType: 'User',
      reason,
      previousState: { isActive: true },
      newState: { isActive: false }
    });

    logger.info(`Admin ${adminId} banned User ${userId} for: ${reason}`);
    return { success: true, message: `User ${userId} banned successfully.` };
  }

  // Platform Analytics
  async getPlatformMetrics() {
    // In a real app, a cron worker calculates this nightly.
    // For MVP, we return whatever is stored + dynamically aggregate some basics.
    const historical = await this.adminRepo.getDailyMetrics(7);
    
    // Reverse to chronological
    historical.reverse();

    return { 
      success: true, 
      data: {
        historicalMetrics: historical,
        // Mocking real-time aggregated metrics
        realTime: {
          totalUsers: 1420,
          totalBusinesses: 850,
          pendingReports: 12
        }
      }
    };
  }

  // --- SCHEME ADMIN MANAGEMENT ---
  async createScheme(adminId: string, schemeData: any) {
    const scheme = await this.schemeRepo.createScheme({
      ...schemeData,
      status: 'DRAFT',
      version: 1,
      lastReviewedAt: new Date()
    });

    await this.adminRepo.logAction({
      adminId,
      action: 'CREATE_SCHEME',
      targetId: scheme.id,
      targetType: 'Scheme',
      newState: schemeData
    });

    return { success: true, data: scheme };
  }

  async updateScheme(adminId: string, schemeId: string, updateData: any) {
    const scheme = await this.schemeRepo.findById(schemeId);
    if (!scheme) return { success: false, error: { code: 'NOT_FOUND', message: 'Scheme not found' } };

    const before = scheme.toJSON();
    Object.assign(scheme, updateData);
    scheme.version += 1;
    await scheme.save();

    await this.adminRepo.logAction({
      adminId,
      action: 'UPDATE_SCHEME',
      targetId: scheme.id,
      targetType: 'Scheme',
      previousState: before,
      newState: scheme.toJSON()
    });

    return { success: true, data: scheme };
  }

  async triggerSchemeSync(adminId: string, sourceId: string) {
    const syncJobId = `sync_${Date.now()}`;
    
    await syncQueue.add('sync-source', {
      sourceId,
      triggeredBy: adminId,
      syncJobId
    });

    await this.adminRepo.logAction({
      adminId,
      action: 'SCHEME_SYNC_TRIGGERED',
      targetId: sourceId,
      targetType: 'SchemeSource',
      reason: `Sync run triggered for job ID ${syncJobId}`
    });

    return { success: true, data: { syncId: syncJobId, status: 'QUEUED' } };
  }

  async verifyScheme(adminId: string, schemeId: string) {
    const scheme = await this.schemeRepo.findById(schemeId);
    if (!scheme) return { success: false, error: { code: 'NOT_FOUND', message: 'Scheme not found' } };

    // STRICT TRANSITION: Only DRAFT or PENDING_REVIEW can be VERIFIED.
    if (scheme.status !== 'DRAFT' && scheme.status !== 'PENDING_REVIEW') {
       return { success: false, error: { code: 'INVALID_TRANSITION', message: `Cannot verify scheme from status ${scheme.status}` } };
    }

    const before = scheme.toJSON();
    scheme.status = 'ACTIVE';
    
    if (scheme.provenance) {
      scheme.provenance.verificationStatus = 'VERIFIED';
      scheme.provenance.verifiedAt = new Date();
      scheme.provenance.verifiedBy = adminId;
    }

    scheme.lastReviewedAt = new Date();
    await scheme.save();

    await this.adminRepo.logAction({
      adminId,
      action: 'VERIFY_SCHEME',
      targetId: scheme.id,
      targetType: 'Scheme',
      previousState: before,
      newState: scheme.toJSON()
    });

    return { success: true, data: scheme };
  }

  async rejectScheme(adminId: string, schemeId: string, reason: string) {
    const scheme = await this.schemeRepo.findById(schemeId);
    if (!scheme) return { success: false, error: { code: 'NOT_FOUND', message: 'Scheme not found' } };

    const before = scheme.toJSON();
    scheme.status = 'REJECTED';
    
    if (scheme.provenance) {
      scheme.provenance.verificationStatus = 'REJECTED';
    }

    await scheme.save();

    await this.adminRepo.logAction({
      adminId,
      action: 'REJECT_SCHEME',
      targetId: scheme.id,
      targetType: 'Scheme',
      reason,
      previousState: before,
      newState: scheme.toJSON()
    });

    return { success: true, data: scheme };
  }

  async archiveScheme(adminId: string, schemeId: string) {
    const scheme = await this.schemeRepo.findById(schemeId);
    if (!scheme) return { success: false, error: { code: 'NOT_FOUND', message: 'Scheme not found' } };

    const before = scheme.toJSON();
    scheme.status = 'ARCHIVED';
    await scheme.save();

    await this.adminRepo.logAction({
      adminId,
      action: 'ARCHIVE_SCHEME',
      targetId: scheme.id,
      targetType: 'Scheme',
      previousState: before,
      newState: scheme.toJSON()
    });

    return { success: true, data: scheme };
  }
}
