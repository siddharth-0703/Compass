import { ReputationRepository } from '../repositories/reputation.repository';
import { NotificationService } from './notification.service';
import { ReputationTier } from '@rural/types';
import { logger } from '@rural/logger';

export class ReputationService {
  private reputationRepo: ReputationRepository;
  private notificationService: NotificationService;

  constructor() {
    this.reputationRepo = new ReputationRepository();
    this.notificationService = new NotificationService();
  }

  async getReputation(userId: string) {
    const rep = await this.reputationRepo.findByUserId(userId);
    return { success: true, data: rep };
  }

  // Hybrid Points + Tier System Engine (Rec MVP approach)
  async awardPoints(userId: string, points: number, action: string) {
    const currentRep = await this.reputationRepo.findByUserId(userId);
    const newScore = currentRep.score + points;
    
    // Evaluate Tier
    let newTier: ReputationTier = currentRep.tier;
    const newBadges: string[] = [];

    if (newScore >= 500 && currentRep.tier !== 'Diamond') newTier = 'Diamond';
    else if (newScore >= 300 && currentRep.tier !== 'Platinum') newTier = 'Platinum';
    else if (newScore >= 150 && currentRep.tier !== 'Gold') newTier = 'Gold';
    else if (newScore >= 50 && currentRep.tier !== 'Silver') newTier = 'Silver';

    // Evaluate Badges
    if (action === 'Profile Created' && !currentRep.badges.includes('Verified Entrepreneur')) {
      newBadges.push('Verified Entrepreneur');
    }
    if (action === 'Course Completed' && !currentRep.badges.includes('Learning Champion')) {
      newBadges.push('Learning Champion');
    }

    const updatedRep = await this.reputationRepo.awardPoints(userId, points, action, newTier, newBadges);

    // If tier changed or badges earned, enqueue an Achievement Notification
    if (newTier !== currentRep.tier || newBadges.length > 0) {
      await this.notificationService.enqueueNotification({
        userId,
        category: 'Achievement',
        priority: 'Medium',
        title: 'Reputation Upgrade!',
        message: `You earned ${points} points for '${action}'. You are now a ${newTier} member!`,
      });
    }

    return { success: true, data: updatedRep };
  }

  async getLeaderboard() {
    const leaderboard = await this.reputationRepo.getLeaderboard();
    return { success: true, data: leaderboard };
  }
}
