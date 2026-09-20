import { BusinessModel, IBusinessDocument } from '@rural/database';
import { IBusiness } from '@rural/types';
import { PaginationParams, PaginatedResult } from '../utils/pagination';

export class BusinessRepository {
  async create(data: Partial<IBusiness>): Promise<IBusinessDocument> {
    const business = new BusinessModel(data);
    return business.save();
  }

  async findById(id: string): Promise<IBusinessDocument | null> {
    return BusinessModel.findById(id);
  }

  async findByUserId(userId: string): Promise<IBusinessDocument[]> {
    return BusinessModel.find({ userId });
  }

  async update(id: string, updateData: Partial<IBusiness>): Promise<IBusinessDocument | null> {
    return BusinessModel.findByIdAndUpdate(id, updateData, { new: true });
  }

  async delete(id: string): Promise<boolean> {
    const result = await BusinessModel.findByIdAndDelete(id);
    return !!result;
  }

  async findAllBusinesses(params: PaginationParams): Promise<PaginatedResult<IBusinessDocument>> {
    const page = params.page || 1;
    const pageSize = params.pageSize || 20;
    const skip = (page - 1) * pageSize;

    const query: any = {};
    if (params.search) {
      query.$or = [
        { name: { $regex: params.search, $options: 'i' } },
        { description: { $regex: params.search, $options: 'i' } }
      ];
    }
    
    if (params.filters?.status) {
      query.status = params.filters.status;
    }
    if (params.filters?.category) {
      query.category = params.filters.category;
    }

    const sortConfig: any = {};
    if (params.sortBy) {
      sortConfig[params.sortBy] = params.sortOrder === 'desc' ? -1 : 1;
    } else {
      sortConfig.createdAt = -1;
    }

    const [items, totalItems] = await Promise.all([
      BusinessModel.find(query).sort(sortConfig).skip(skip).limit(pageSize).populate('userId', 'phone email'),
      BusinessModel.countDocuments(query)
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
