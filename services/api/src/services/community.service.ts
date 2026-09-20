import { GroupRepository } from '../repositories/group.repository';
import { PostRepository } from '../repositories/post.repository';
import { logger } from '@rural/logger';
import { Queue } from 'bullmq';

// BullMQ Queue for AI background tasks (Rec 9)
const aiQueue = new Queue('ai-tasks', { connection: { host: 'localhost', port: 6379 } });

export class CommunityService {
  private groupRepo: GroupRepository;
  private postRepo: PostRepository;

  constructor() {
    this.groupRepo = new GroupRepository();
    this.postRepo = new PostRepository();
  }

  async createGroup(userId: string, data: any) {
    const group = await this.groupRepo.createGroup({
      ...data,
      ownerId: userId,
      memberCount: 0
    });

    // Automatically make the creator an Owner
    await this.groupRepo.addMember({
      groupId: group.id,
      userId,
      role: 'Owner',
      status: 'Approved'
    });

    logger.info(`Group Created: ${group.id}`);
    return { success: true, data: group };
  }

  async createPost(userId: string, data: any) {
    // 1. Check if user is a member of the group
    const isMember = await this.groupRepo.isMember(data.groupId, userId);
    if (!isMember) {
      return { success: false, error: { code: 'FORBIDDEN', message: 'You must be a member of this group to post.' } };
    }

    // 2. Synchronous basic moderation (Rec 8 Step 1)
    const badWords = ['spam', 'scam', 'hack'];
    const isToxic = badWords.some(word => data.content.toLowerCase().includes(word));
    
    if (isToxic) {
      return { success: false, error: { code: 'BLOCKED', message: 'Post violates community guidelines.' } };
    }

    // 3. Create the post
    const post = await this.postRepo.createPost({
      ...data,
      authorId: userId,
      aiModerationStatus: 'Pending',
      isFlagged: false
    });

    // 4. Asynchronous AI Embedding Task (Rec 9 & 10)
    await aiQueue.add('generate-embedding', {
      postId: post.id,
      groupId: post.groupId,
      authorId: post.authorId,
      content: post.content,
      tags: post.tags,
      collection: 'community_posts'
    });

    logger.info(`Post created and queued for AI Embedding: ${post.id}`);
    return { success: true, data: post };
  }

  async getGroupPosts(groupId: string) {
    const posts = await this.postRepo.getPostsByGroup(groupId);
    return { success: true, data: posts };
  }
}
