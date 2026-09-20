import { NotificationModel, INotificationDocument } from '@rural/database';
import { INotification } from '@rural/types';

export class NotificationRepository {
  async create(data: Partial<INotification>): Promise<INotificationDocument> {
    const notification = new NotificationModel(data);
    return notification.save();
  }

  async getUnreadByUserId(userId: string) {
    return NotificationModel.find({ userId, status: { $in: ['Delivered', 'Sent'] } }).sort({ createdAt: -1 });
  }

  async getAllByUserId(userId: string, limit: number = 50) {
    return NotificationModel.find({ userId }).sort({ createdAt: -1 }).limit(limit);
  }

  async markAsRead(notificationId: string, userId: string) {
    return NotificationModel.findOneAndUpdate(
      { _id: notificationId, userId },
      { status: 'Read', readAt: new Date() },
      { new: true }
    );
  }

  async markAllAsRead(userId: string) {
    return NotificationModel.updateMany(
      { userId, status: { $in: ['Delivered', 'Sent'] } },
      { status: 'Read', readAt: new Date() }
    );
  }
}
