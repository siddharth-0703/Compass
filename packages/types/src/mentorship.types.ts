export interface IMentorExpertise {
  industries: string[];
  businessStages: string[];
  businessFunctions: string[];
  technicalSkills: string[];
  softSkills: string[];
  languages: string[];
  experienceYears: number;
}

export interface IMentorAvailability {
  timezone: string;
  availableDays: string[]; // e.g., 'Monday', 'Wednesday'
  timeSlots: string[]; // e.g., '10:00-12:00'
  sessionDurationMinutes: number;
  bufferTimeMinutes: number;
  maxSessionsPerWeek: number;
}

export interface IMentorReputation {
  completedSessions: number;
  averageRating: number;
  responseTimeHours: number;
  acceptanceRate: number;
  repeatSessions: number;
}

export type MentorVerificationStatus = 'Pending' | 'Verified' | 'Rejected' | 'Suspended';

export interface IMentorProfile {
  id?: string;
  userId: string;
  headline: string;
  bio: string;
  expertise: IMentorExpertise;
  availability: IMentorAvailability;
  reputation: IMentorReputation;
  verificationStatus: MentorVerificationStatus;
  verificationSource?: string;
  sessionType: 'Free' | 'Paid' | 'Sponsored'; // MVP uses 'Free'
  embeddingId?: string;
  createdAt?: Date;
  updatedAt?: Date;
}

export type SessionStatus = 'Requested' | 'Pending' | 'Accepted' | 'Rejected' | 'Scheduled' | 'In Progress' | 'Completed' | 'Cancelled' | 'No Show' | 'Rescheduled';

export interface ISessionNotes {
  mentorObservations?: string;
  businessChallenges?: string;
  recommendations?: string;
  nextActions?: string;
  entrepreneurProgress?: string;
}

export interface IMentorshipSession {
  id?: string;
  mentorId: string;
  businessId: string;
  entrepreneurId: string;
  status: SessionStatus;
  scheduledAt?: Date;
  durationMinutes: number;
  meetingPlatform: 'Google Meet' | 'Zoom' | 'Microsoft Teams' | 'In-App WebRTC';
  meetingLink?: string;
  goals: string[];
  notes: ISessionNotes;
  rating?: number;
  feedback?: string;
  createdAt?: Date;
  updatedAt?: Date;
}
