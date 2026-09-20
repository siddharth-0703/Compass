import { BusinessRepository } from '../repositories/business.repository';
import { logger } from '@rural/logger';

export class BusinessService {
  private repo: BusinessRepository;

  constructor() {
    this.repo = new BusinessRepository();
  }

  async createBusiness(userId: string, data: any) {
    // Recommendation 1: Support multiple businesses, but we can limit to 3 for free tier logic
    const existingBusinesses = await this.repo.findByUserId(userId);
    if (existingBusinesses.length >= 3) {
      return { success: false, error: { code: 'LIMIT_EXCEEDED', message: 'You can only register up to 3 businesses' } };
    }

    const business = await this.repo.create({
      ...data,
      userId,
      status: 'Pending Verification',
      analytics: {
        views: 0, followers: 0, profileCompletion: 50, marketplaceListings: 0, mentorSessions: 0, schemeMatches: 0, growthScore: 0
      },
      aiReadyMetadata: {}
    });

    logger.info(`Business Created: ${business.id} by user ${userId}`);
    
    // Future Event Emitter (Rec 17): EventBus.publish('BUSINESS_CREATED', { businessId: business.id })
    // Will trigger AI service to generate embeddings asynchronously
    
    return { success: true, data: business };
  }

  async getMyBusinesses(userId: string) {
    const businesses = await this.repo.findByUserId(userId);
    return { success: true, data: businesses };
  }

  async getBusinessById(id: string) {
    const business = await this.repo.findById(id);
    if (!business) {
      return { success: false, error: { code: 'NOT_FOUND', message: 'Business not found' } };
    }
    return { success: true, data: business };
  }

  async updateBusiness(userId: string, businessId: string, updateData: any) {
    const business = await this.repo.findById(businessId);
    if (!business) {
      return { success: false, error: { code: 'NOT_FOUND', message: 'Business not found' } };
    }
    
    if (business.userId.toString() !== userId.toString()) {
      return { success: false, error: { code: 'FORBIDDEN', message: 'You do not own this business' } };
    }

    // Auto-transition out of Draft mode when they update their profile
    if (business.status === 'Draft') {
      updateData.status = 'Pending Verification';
    }

    const updated = await this.repo.update(businessId, updateData);
    logger.info(`Business Updated: ${businessId}`);
    return { success: true, data: updated };
  }

  async deleteBusiness(userId: string, businessId: string) {
    const business = await this.repo.findById(businessId);
    if (!business) {
      return { success: false, error: { code: 'NOT_FOUND', message: 'Business not found' } };
    }
    
    if (business.userId.toString() !== userId.toString()) {
      return { success: false, error: { code: 'FORBIDDEN', message: 'You do not own this business' } };
    }

    const deleted = await this.repo.delete(businessId);
    logger.info(`Business Deleted: ${businessId}`);
    return { success: deleted, data: null };
  }
}
