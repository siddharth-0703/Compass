import { GroupModel, MembershipModel, IGroupDocument } from '@rural/database';
import { IGroup, IMembership } from '@rural/types';

export class GroupRepository {
  async createGroup(data: Partial<IGroup>): Promise<IGroupDocument> {
    const group = new GroupModel(data);
    return group.save();
  }

  async addMember(data: Partial<IMembership>) {
    const membership = new MembershipModel(data);
    await membership.save();
    await GroupModel.findByIdAndUpdate(data.groupId, { $inc: { memberCount: 1 } });
  }

  async findGroups(query: any = {}) {
    return GroupModel.find(query).limit(50);
  }

  async isMember(groupId: string, userId: string): Promise<boolean> {
    const membership = await MembershipModel.findOne({ groupId, userId, status: 'Approved' });
    return !!membership;
  }
}
