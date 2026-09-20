import { MentorProfileModel, MentorshipSessionModel, IMentorProfileDocument, IMentorshipSessionDocument } from '@rural/database';
import { IMentorProfile, IMentorshipSession } from '@rural/types';

export class MentorshipRepository {
  async createMentorProfile(data: Partial<IMentorProfile>): Promise<IMentorProfileDocument> {
    const profile = new MentorProfileModel(data);
    return profile.save();
  }

  async getAvailableMentors() {
    return MentorProfileModel.find({ verificationStatus: 'Verified' });
  }

  async findMentorById(id: string) {
    return MentorProfileModel.findById(id);
  }

  async scheduleSession(data: Partial<IMentorshipSession>): Promise<IMentorshipSessionDocument> {
    const session = new MentorshipSessionModel(data);
    return session.save();
  }

  async findSessionsForUser(userId: string): Promise<IMentorshipSessionDocument[]> {
    return MentorshipSessionModel.find({
      $or: [
        { entrepreneurId: userId },
        { mentorId: userId }
      ]
    }).sort({ scheduledAt: -1 });
  }

  async findSessionById(sessionId: string): Promise<IMentorshipSessionDocument | null> {
    return MentorshipSessionModel.findById(sessionId);
  }

  async updateSessionStatus(sessionId: string, status: string): Promise<IMentorshipSessionDocument | null> {
    return MentorshipSessionModel.findByIdAndUpdate(
      sessionId,
      { status },
      { new: true }
    );
  }

  async rescheduleSession(
    sessionId: string, 
    newTime: Date, 
    newEndTime: Date
  ): Promise<IMentorshipSessionDocument | null> {
    return MentorshipSessionModel.findByIdAndUpdate(
      sessionId,
      { 
        scheduledAt: newTime, 
        durationMinutes: Math.round((newEndTime.getTime() - newTime.getTime()) / 60000),
        status: 'Rescheduled'
      },
      { new: true }
    );
  }

  async submitFeedback(
    sessionId: string, 
    rating: number, 
    feedback: string
  ): Promise<IMentorshipSessionDocument | null> {
    return MentorshipSessionModel.findByIdAndUpdate(
      sessionId,
      { rating, feedback, status: 'Completed' },
      { new: true }
    );
  }
}
