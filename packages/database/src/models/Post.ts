import mongoose, { Schema, Document } from 'mongoose';
import { IPost } from '@rural/types';

export interface IPostDocument extends Omit<IPost, 'id'>, Document {}

const postSchema = new Schema<IPostDocument>({
  groupId: { type: String, required: true, index: true },
  authorId: { type: String, required: true, index: true },
  postType: { type: String, enum: ['Question', 'Discussion', 'Success Story', 'Announcement', 'Business Opportunity', 'Marketplace Promotion', 'Learning Resource', 'Government Update', 'Poll'], required: true },
  content: { type: String, required: true },
  mediaUrls: { type: [String], default: [] },
  tags: { type: [String], default: [], index: true },
  language: { type: String, default: 'en' },
  upvotes: { type: Number, default: 0 },
  commentCount: { type: Number, default: 0 },
  isFlagged: { type: Boolean, default: false },
  aiModerationStatus: { type: String, enum: ['Pending', 'Clean', 'Toxic', 'Spam'], default: 'Pending' },
  embeddingId: { type: String }
}, { timestamps: true });

export const PostModel = mongoose.models.Post || mongoose.model<IPostDocument>('Post', postSchema);
