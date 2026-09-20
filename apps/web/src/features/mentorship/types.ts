export interface MentorProfile {
  id: string;
  userId: string;
  headline: string;
  bio: string;
  expertise: {
    industries: string[];
    businessStages: string[];
    businessFunctions: string[];
    technicalSkills: string[];
    softSkills: string[];
    languages: string[];
    experienceYears: number;
  };
  availability: {
    timezone: string;
    availableDays: string[];
    timeSlots: string[];
    sessionDurationMinutes: number;
    bufferTimeMinutes: number;
    maxSessionsPerWeek: number;
  };
  sessionType: string;
  reputation: {
    averageRating: number;
    totalSessions: number;
    totalReviews: number;
  };
  isVerified: boolean;
  status: string;
  createdAt: string;
  updatedAt: string;
}

export interface MentorshipSession {
  id: string;
  mentorId: string;
  businessId: string;
  entrepreneurId: string;
  status: 'Requested' | 'Pending' | 'Accepted' | 'Rejected' | 'Scheduled' | 'In Progress' | 'Completed' | 'Cancelled' | 'No Show' | 'Rescheduled';
  scheduledAt?: string;
  durationMinutes: number;
  meetingPlatform: string;
  meetingLink?: string;
  goals: string[];
  notes?: {
    mentorObservations?: string;
    businessChallenges?: string;
    recommendations?: string;
    nextActions?: string;
    entrepreneurProgress?: string;
  };
  rating?: number;
  feedback?: string;
  canJoin?: boolean;
}

export interface MentorMatchResponse {
  mentor: MentorProfile;
  scores: {
    final: number;
    experience?: number;
    rating?: number;
  };
  reasons: string[];
}

export interface DemoMentor {
  id: string;
  name: string;
  expertise: string;
  experience: number;
  location: string;
  languages: string[];
  availability: 'available' | 'limited';
  bio: string;
}
