export type ReputationTier = 'Bronze' | 'Silver' | 'Gold' | 'Platinum' | 'Diamond' | 'Community Leader';

export interface IReputationActivity {
  action: string;
  pointsAwarded: number;
  timestamp: Date;
}

export interface IUserReputation {
  id?: string;
  userId: string;
  
  score: number;
  tier: ReputationTier;
  trustScore: number; // Distinct from reputation
  
  badges: string[]; // e.g. ['Verified Entrepreneur', 'Learning Champion']
  milestones: string[];
  
  activityHistory: IReputationActivity[];

  createdAt?: Date;
  updatedAt?: Date;
}
