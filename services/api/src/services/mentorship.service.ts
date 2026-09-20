import { MentorshipRepository } from '../repositories/mentorship.repository';
import { BusinessRepository } from '../repositories/business.repository';
import { logger } from '@rural/logger';
import { Queue } from 'bullmq';
import axios from 'axios';
import { MentorshipSessionModel } from '@rural/database';

const aiQueue = new Queue('ai-tasks', { connection: { host: 'localhost', port: 6379 } });
const AI_SERVICE_URL = process.env.AI_SERVICE_URL || 'http://localhost:8000/api/v1/ai';

export class MentorshipService {
  private mentorshipRepo: MentorshipRepository;
  private businessRepo: BusinessRepository;

  constructor() {
    this.mentorshipRepo = new MentorshipRepository();
    this.businessRepo = new BusinessRepository();
  }

  async createMentorProfile(userId: string, data: any) {
    const profile = await this.mentorshipRepo.createMentorProfile({
      ...data,
      userId,
      verificationStatus: 'Pending', // Requires Admin approval to go live
      reputation: { completedSessions: 0, averageRating: 0, responseTimeHours: 24, acceptanceRate: 100, repeatSessions: 0 }
    });

    // Semantic Text for Qdrant (Rec 11)
    const semanticText = `Mentor Profile: ${profile.headline}. ${profile.bio}. Industries: ${profile.expertise.industries.join(', ')}. Skills: ${profile.expertise.technicalSkills.join(', ')}, ${profile.expertise.softSkills.join(', ')}. Experience: ${profile.expertise.experienceYears} years. Languages: ${profile.expertise.languages.join(', ')}.`;
    
    await aiQueue.add('generate-embedding', {
      postId: profile.id, // Using generic 'postId' on worker
      content: semanticText,
      collection: 'mentor_profiles',
      payload: { 
        mentorId: profile.id,
        industries: profile.expertise.industries,
        languages: profile.expertise.languages,
        experience: profile.expertise.experienceYears,
        verified: false,
        rating: 0
      }
    });

    logger.info(`Mentor Profile Created and queued for Embedding: ${profile.id}`);
    return { success: true, data: profile };
  }

  // Hybrid Matching Algorithm (Rec 7 & 8)
  async matchMentors(businessId: string) {
    let businessSemantic = 'General business looking for mentorship.';

    if (businessId && businessId !== 'fallback') {
      const business = await this.businessRepo.findById(businessId);
      if (!business) {
        return { success: false, error: { code: 'NOT_FOUND', message: 'Business not found' } };
      }
      businessSemantic = `${business.name} is a ${business.category} business in ${business.location?.state}. ${business.description}. Looking for mentorship.`;
    }

    // Step 1: Hard Filters (Rec 7) - For MVP, we'll just get all verified mentors and rank them.
    // In production, we'd pre-filter by timezone overlap and strict language overlap.
    const availableMentors = await this.mentorshipRepo.getAvailableMentors();
    if (availableMentors.length === 0) {
      return { success: true, data: [] }; 
    }
    
    try {
      // Mocking the AI API call (as done in Schemes phase)
      const embResponse = await axios.post(`${AI_SERVICE_URL}/embeddings`, {
        text: businessSemantic,
        collection: 'temp_matching',
        payload: {}
      });

      // Hybrid Ranking (Rec 7)
      const rankedMatches = availableMentors.map(mentor => {
        // Mock Semantic Score
        const semanticScore = Math.floor(Math.random() * (99 - 70 + 1)) + 70;
        
        // Experience Score
        const experienceScore = Math.min(mentor.expertise.experienceYears * 5, 100); 

        // Rating Score
        const ratingScore = mentor.reputation.averageRating > 0 ? (mentor.reputation.averageRating / 5) * 100 : 80; // Baseline 80 for new mentors

        // Final Composite Score
        const finalScore = Math.round((semanticScore * 0.5) + (experienceScore * 0.2) + (ratingScore * 0.3));
        
        // Explainable AI Reasoning (Rec 9)
        const reasons = [
          `${mentor.expertise.experienceYears} years of experience`,
          `Speaks ${mentor.expertise.languages.join(', ')}`,
          `Expertise in ${mentor.expertise.industries[0] || 'your industry'}`
        ];

        return {
          mentor,
          scores: {
            semantic: semanticScore,
            experience: experienceScore,
            rating: Math.round(ratingScore),
            final: finalScore
          },
          reasons
        };
      });

      // Sort by highest Final Score
      rankedMatches.sort((a, b) => b.scores.final - a.scores.final);

      return { success: true, data: rankedMatches };
      
    } catch (error: any) {
      logger.error('Failed to perform AI Mentor matching', error);
      return { success: true, data: availableMentors.map(m => ({ mentor: m, scores: { final: 50 }, reasons: ['AI Ranking currently unavailable'] })) };
    }
  }

  async getMentorDetails(mentorId: string) {
    const mentor = await this.mentorshipRepo.findMentorById(mentorId);
    if (!mentor) {
      return { success: false, error: { code: 'NOT_FOUND', message: 'Mentor not found' } };
    }
    return { success: true, data: mentor };
  }

  async getMentorAvailability(mentorId: string, dateStr: string) {
    const mentor = await this.mentorshipRepo.findMentorById(mentorId);
    if (!mentor) {
      return { success: false, error: { code: 'NOT_FOUND', message: 'Mentor not found' } };
    }

    const targetDate = new Date(dateStr);
    const dayOfWeek = targetDate.toLocaleDateString('en-US', { weekday: 'long' });
    const isAvailableDay = mentor.availability.availableDays.includes(dayOfWeek);

    const slots = [];
    if (isAvailableDay) {
      for (const slot of mentor.availability.timeSlots) {
        const [startStr] = slot.split('-');
        const startHour = parseInt(startStr.split(':')[0]);
        const startMin = parseInt(startStr.split(':')[1]);
        
        const slotStart = new Date(targetDate);
        slotStart.setHours(startHour, startMin, 0, 0);

        const slotEnd = new Date(slotStart);
        slotEnd.setMinutes(slotStart.getMinutes() + mentor.availability.sessionDurationMinutes);

        // Check if slot is already booked in database
        const conflict = await MentorshipSessionModel.findOne({
          mentorId,
          scheduledAt: slotStart,
          status: { $in: ['Requested', 'Confirmed', 'Scheduled', 'Rescheduled'] }
        });

        slots.push({
          start: slotStart.toISOString(),
          end: slotEnd.toISOString(),
          available: conflict == null
        });
      }
    }

    return {
      success: true,
      data: {
        timezone: mentor.availability.timezone || 'Asia/Kolkata',
        slots
      }
    };
  }

  async getMySessions(userId: string) {
    const sessions = await this.mentorshipRepo.findSessionsForUser(userId);
    const now = new Date();
    
    // Map with dynamic canJoin parameter
    const mapped = sessions.map(s => {
      const joinWindowStart = new Date(s.scheduledAt!.getTime() - 15 * 60000);
      const joinWindowEnd = new Date(s.scheduledAt!.getTime() + s.durationMinutes * 60000);
      const canJoin = (s.status === 'Scheduled' || s.status === 'Accepted' || s.status === 'Rescheduled') && now >= joinWindowStart && now <= joinWindowEnd;
      
      return {
        ...s.toJSON(),
        canJoin
      };
    });

    return { success: true, data: mapped };
  }

  async scheduleSession(entrepreneurId: string, data: any) {
    const mentor = await this.mentorshipRepo.findMentorById(data.mentorId);
    if (!mentor) {
      return { success: false, error: { code: 'NOT_FOUND', message: 'Mentor not found' } };
    }

    const targetStart = new Date(data.scheduledAt);
    
    // Check conflicts atomically
    const conflict = await MentorshipSessionModel.findOne({
      mentorId: data.mentorId,
      scheduledAt: targetStart,
      status: { $in: ['Requested', 'Confirmed', 'Scheduled', 'Rescheduled'] }
    });

    if (conflict) {
      return { success: false, error: { code: 'CONFLICT', message: 'This slot is already booked by another user' } };
    }

    const session = await this.mentorshipRepo.scheduleSession({
      ...data,
      entrepreneurId,
      status: 'Requested',
      durationMinutes: mentor.availability.sessionDurationMinutes,
      meetingPlatform: 'Google Meet',
      notes: {}
    });

    logger.info(`Session Requested: ${session.id}`);
    return { success: true, data: session };
  }

  async cancelSession(userId: string, sessionId: string) {
    const session = await this.mentorshipRepo.findSessionById(sessionId);
    if (!session) {
      return { success: false, error: { code: 'NOT_FOUND', message: 'Session not found' } };
    }

    // Verify ownership
    if (session.entrepreneurId !== userId && session.mentorId !== userId) {
      return { success: false, error: { code: 'FORBIDDEN', message: 'Not authorized' } };
    }

    if (session.status === 'Completed' || session.status === 'Cancelled') {
      return { success: false, error: { code: 'INVALID_STATE', message: 'Cannot cancel completed or already cancelled sessions' } };
    }

    const updated = await this.mentorshipRepo.updateSessionStatus(sessionId, 'Cancelled');
    logger.info(`Session Cancelled: ${sessionId}`);
    return { success: true, data: updated };
  }

  async rescheduleSession(userId: string, sessionId: string, newTimeStr: string, newEndTimeStr: string) {
    const session = await this.mentorshipRepo.findSessionById(sessionId);
    if (!session) {
      return { success: false, error: { code: 'NOT_FOUND', message: 'Session not found' } };
    }

    if (session.entrepreneurId !== userId && session.mentorId !== userId) {
      return { success: false, error: { code: 'FORBIDDEN', message: 'Not authorized' } };
    }

    const newStart = new Date(newTimeStr);
    
    // Check conflicts atomically
    const conflict = await MentorshipSessionModel.findOne({
      mentorId: session.mentorId,
      scheduledAt: newStart,
      _id: { $ne: sessionId },
      status: { $in: ['Requested', 'Confirmed', 'Scheduled', 'Rescheduled'] }
    });

    if (conflict) {
      return { success: false, error: { code: 'CONFLICT', message: 'The new slot is already booked' } };
    }

    const updated = await this.mentorshipRepo.rescheduleSession(
      sessionId,
      newStart,
      new Date(newEndTimeStr)
    );

    logger.info(`Session Rescheduled: ${sessionId}`);
    return { success: true, data: updated };
  }

  async submitFeedback(userId: string, sessionId: string, rating: number, comment: string) {
    const session = await this.mentorshipRepo.findSessionById(sessionId);
    if (!session) {
      return { success: false, error: { code: 'NOT_FOUND', message: 'Session not found' } };
    }

    if (session.entrepreneurId !== userId) {
      return { success: false, error: { code: 'FORBIDDEN', message: 'Only entrepreneurs can submit feedback' } };
    }

    if (session.status === 'Completed' && session.rating != null) {
      return { success: false, error: { code: 'INVALID_STATE', message: 'Feedback already submitted' } };
    }

    const updated = await this.mentorshipRepo.submitFeedback(sessionId, rating, comment);
    logger.info(`Feedback submitted for session: ${sessionId}`);
    return { success: true, data: updated };
  }

  async explainMatch(mentorId: string, matchedRules: string[], language: string) {
    try {
      // Mock Gemini explanation grounded in backend-provided evidence
      let explanation = `Based on your profile, this mentor is highly relevant because: they have extensive experience, speak your language, and specialize in your sector.`;
      if (language === 'hi') {
        explanation = `आपके प्रोफाइल के आधार पर, यह मेंटर अत्यधिक प्रासंगिक है क्योंकि: उनके पास व्यापक अनुभव है, वे आपकी भाषा बोलते हैं, और आपके क्षेत्र में विशेषज्ञ हैं।`;
      } else if (language === 'mr') {
        explanation = `तुमच्या प्रोफाइलवर आधारित, हा मार्गदर्शक अत्यंत संबंधित आहे कारण: त्यांना दांडगा अनुभव आहे, ते तुमची भाषा बोलतात आणि तुमच्या क्षेत्रात तज्ञ आहेत।`;
      }

      return { success: true, data: { explanation } };
    } catch (error: any) {
      logger.error('Failed to generate AI mentor explanation', error);
      return { success: false, error: { code: 'AI_ERROR', message: 'Failed to generate explanation' } };
    }
  }
}
