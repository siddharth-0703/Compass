import { UserModel, IUserDocument } from '@rural/database';
import { IUser } from '@rural/types';
import { PaginationParams, PaginatedResult } from '../utils/pagination';

export class UserRepository {
  async create(userData: Partial<IUser>): Promise<IUserDocument> {
    const user = new UserModel(userData);
    return user.save();
  }

  async findByPhone(phone: string): Promise<IUserDocument | null> {
    return UserModel.findOne({ phone });
  }

  async findByEmail(email: string): Promise<IUserDocument | null> {
    return UserModel.findOne({ email });
  }

  async findById(id: string): Promise<IUserDocument | null> {
    return UserModel.findById(id);
  }

  async updateLastLogin(id: string): Promise<void> {
    await UserModel.findByIdAndUpdate(id, { 
      lastLogin: new Date(), 
      failedLoginAttempts: 0 
    });
  }

  async incrementFailedLogins(id: string): Promise<void> {
    await UserModel.findByIdAndUpdate(id, { 
      $inc: { failedLoginAttempts: 1 } 
    });
  }

  async findAllUsers(params: PaginationParams): Promise<PaginatedResult<IUserDocument>> {
    const page = params.page || 1;
    const pageSize = params.pageSize || 20;
    const skip = (page - 1) * pageSize;

    const query: any = {};
    if (params.search) {
      query.$or = [
        { phone: { $regex: params.search, $options: 'i' } },
        { email: { $regex: params.search, $options: 'i' } }
      ];
    }
    
    if (params.filters?.role) {
      query.role = params.filters.role;
    }

    const sortConfig: any = {};
    if (params.sortBy) {
      sortConfig[params.sortBy] = params.sortOrder === 'desc' ? -1 : 1;
    } else {
      sortConfig.createdAt = -1;
    }

    const [items, totalItems] = await Promise.all([
      UserModel.find(query).sort(sortConfig).skip(skip).limit(pageSize),
      UserModel.countDocuments(query)
    ]);

    const totalPages = Math.ceil(totalItems / pageSize);

    return {
      items,
      pagination: {
        page,
        pageSize,
        totalItems,
        totalPages,
        hasNext: page < totalPages,
        hasPrevious: page > 1
      }
    };
  }
}
