import mongoose, { Schema, Document } from 'mongoose';
import { INotification } from '@rural/types';

export interface INotificationDocument extends Omit<INotification, 'id'>, Document {}

const notificationSchema = new Schema<INotificationDocument>({
  userId: { type: String, required: true, index: true },
  category: { type: String, required: true, index: true },
  priority: { type: String, required: true },
  status: { type: String, default: 'Created', index: true },
  
  title: { type: String, required: true },
  message: { type: String, required: true },
  actionUrl: { type: String },
  
  channel: { type: String, default: 'In-App' },
  deliveryAttempts: { type: Number, default: 0 },
  
  readAt: { type: Date }
}, { timestamps: true });

export const NotificationModel = mongoose.models.Notification || mongoose.model<INotificationDocument>('Notification', notificationSchema);
