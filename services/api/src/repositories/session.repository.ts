import { SessionModel, ISessionDocument } from '@rural/database';
import { ISession } from '@rural/types';

export class SessionRepository {
  async createSession(sessionData: Partial<ISession>): Promise<ISessionDocument> {
    const session = new SessionModel(sessionData);
    return session.save();
  }

  async findSessionByHash(hash: string): Promise<ISessionDocument | null> {
    return SessionModel.findOne({ refreshTokenHash: hash, isRevoked: false });
  }

  async revokeSession(hash: string): Promise<void> {
    await SessionModel.findOneAndUpdate({ refreshTokenHash: hash }, { isRevoked: true });
  }
}
