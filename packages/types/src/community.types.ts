import { IBusinessLocation } from '../index';

export type GroupVisibility = 'Public' | 'Private' | 'Invite Only' | 'Verified Only';
export type GroupType = 'location' | 'industry' | 'government' | 'learning' | 'private' | 'public' | 'hybrid';

export interface IGroup {
  id?: string;
  name: string;
  description: string;
  type: GroupType;
  visibility: GroupVisibility;
  tags: string[];
  location?: IBusinessLocation;
  industry?: string;
  memberCount: number;
  ownerId: string;
  coverImageUrl?: string;
  createdAt?: Date;
  updatedAt?: Date;
}

export type MembershipRole = 'Owner' | 'Admin' | 'Moderator' | 'Member';
export type MembershipStatus = 'Pending' | 'Approved' | 'Rejected' | 'Blocked';

export interface IMembership {
  id?: string;
  groupId: string;
  userId: string;
  role: MembershipRole;
  status: MembershipStatus;
  joinedAt?: Date;
}

export type PostType = 'Question' | 'Discussion' | 'Success Story' | 'Announcement' | 'Business Opportunity' | 'Marketplace Promotion' | 'Learning Resource' | 'Government Update' | 'Poll';

export interface IPost {
  id?: string;
  groupId: string;
  authorId: string;
  postType: PostType;
  content: string;
  mediaUrls?: string[];
  tags: string[];
  language?: string;
  upvotes: number;
  commentCount: number;
  isFlagged: boolean;
  aiModerationStatus: 'Pending' | 'Clean' | 'Toxic' | 'Spam';
  embeddingId?: string;
  createdAt?: Date;
  updatedAt?: Date;
}

export interface IComment {
  id?: string;
  postId: string;
  authorId: string;
  content: string;
  upvotes: number;
  isFlagged: boolean;
  createdAt?: Date;
  updatedAt?: Date;
}

export type ReactionType = 'Like' | 'Helpful' | 'Interesting' | 'Celebrate' | 'Support';

export interface IReaction {
  id?: string;
  targetId: string;
  targetType: 'Post' | 'Comment';
  userId: string;
  type: ReactionType;
  createdAt?: Date;
}
