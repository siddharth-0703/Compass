import { NotificationRepository } from '../repositories/notification.repository';
import { Queue } from 'bullmq';
import { logger } from '@rural/logger';

const notificationQueue = new Queue('notification-tasks', { connection: { host: 'localhost', port: 6379 } });

export class NotificationService {
  private notificationRepo: NotificationRepository;

  constructor() {
    this.notificationRepo = new NotificationRepository();
  }

  // Instead of creating synchronously, we push to BullMQ (Rec 5)
  async enqueueNotification(data: any) {
    await notificationQueue.add('deliver-notification', data);
    logger.info(`Notification queued for User ${data.userId}`);
  }

  async getUnread(userId: string) {
    const unread = await this.notificationRepo.getUnreadByUserId(userId);
    return { success: true, data: unread };
  }

  async getAll(userId: string) {
    const notifications = await this.notificationRepo.getAllByUserId(userId);
    return { success: true, data: notifications };
  }

  async markAsRead(notificationId: string, userId: string) {
    const notification = await this.notificationRepo.markAsRead(notificationId, userId);
    return { success: true, data: notification };
  }

  async markAllAsRead(userId: string) {
    await this.notificationRepo.markAllAsRead(userId);
    return { success: true };
  }
}
