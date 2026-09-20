import { PostModel, IPostDocument } from '@rural/database';
import { IPost } from '@rural/types';

export class PostRepository {
  async createPost(data: Partial<IPost>): Promise<IPostDocument> {
    const post = new PostModel(data);
    return post.save();
  }

  async getPostsByGroup(groupId: string) {
    return PostModel.find({ groupId, isFlagged: false }).sort({ createdAt: -1 }).limit(20);
  }

  async updateAIStatus(postId: string, status: string) {
    await PostModel.findByIdAndUpdate(postId, { aiModerationStatus: status });
  }
}
