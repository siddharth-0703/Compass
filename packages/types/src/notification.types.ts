export type NotificationCategory = 'Government Scheme' | 'Mentorship' | 'Marketplace' | 'Community' | 'Learning' | 'Business Analytics' | 'System' | 'Security' | 'Achievement' | 'Reminder';
export type NotificationPriority = 'Critical' | 'High' | 'Medium' | 'Low' | 'Silent';
export type NotificationStatus = 'Created' | 'Queued' | 'Sent' | 'Delivered' | 'Read' | 'Archived' | 'Expired' | 'Failed';

export interface INotification {
  id?: string;
  userId: string;
  category: NotificationCategory;
  priority: NotificationPriority;
  status: NotificationStatus;
  
  title: string;
  message: string;
  actionUrl?: string; // Where the user should go when they click
  
  channel: 'In-App' | 'Email' | 'Push' | 'SMS' | 'WhatsApp';
  deliveryAttempts: number;
  
  createdAt?: Date;
  readAt?: Date;
  updatedAt?: Date;
}
