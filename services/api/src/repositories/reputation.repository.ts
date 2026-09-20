import { UserReputationModel, IUserReputationDocument } from '@rural/database';
import { IUserReputation, ReputationTier } from '@rural/types';

export class ReputationRepository {
  async findByUserId(userId: string): Promise<IUserReputationDocument> {
    let rep = await UserReputationModel.findOne({ userId });
    if (!rep) {
      rep = await UserReputationModel.create({ userId });
    }
    return rep;
  }

  async awardPoints(userId: string, points: number, action: string, newTier: ReputationTier, newBadges: string[]) {
    return UserReputationModel.findOneAndUpdate(
      { userId },
      {
        $inc: { score: points },
        $set: { tier: newTier },
        $addToSet: { badges: { $each: newBadges } },
        $push: { activityHistory: { action, pointsAwarded: points } }
      },
      { new: true, upsert: true }
    );
  }

  async getLeaderboard(limit: number = 10) {
    return UserReputationModel.find({}).sort({ score: -1 }).limit(limit);
  }
}
