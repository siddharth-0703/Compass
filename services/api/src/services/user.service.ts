import { SavedSchemeModel } from '../models/saved-scheme.model';
import { IGovernmentScheme } from '@rural/types';
import { SchemeRepository } from '../repositories/scheme.repository';

export class UserService {
  private schemeRepo: SchemeRepository;

  constructor() {
    this.schemeRepo = new SchemeRepository();
  }

  async saveScheme(userId: string, schemeId: string) {
    try {
      await SavedSchemeModel.create({ userId, schemeId });
      return { success: true };
    } catch (error: any) {
      if (error.code === 11000) {
        // Duplicate key, means it's already saved
        return { success: true };
      }
      throw error;
    }
  }

  async removeSavedScheme(userId: string, schemeId: string) {
    await SavedSchemeModel.deleteOne({ userId, schemeId });
    return { success: true };
  }

  async getSavedSchemes(userId: string) {
    const saved = await SavedSchemeModel.find({ userId }).sort({ savedAt: -1 }).lean();
    if (!saved.length) return { success: true, data: [] };

    const schemeIds = saved.map(s => s.schemeId);
    
    // Ideally we would fetch them all in one query, but for now we fetch one by one
    // or if schemeRepo supports bulk fetch:
    const data = [];
    for (const id of schemeIds) {
      const scheme = await this.schemeRepo.findById(id);
      if (scheme) {
        data.push({
          schemeId: scheme.id,
          schemeName: scheme.name,
          category: scheme.category,
          ministry: scheme.ministry,
          shortDescription: scheme.shortDescription,
          savedAt: saved.find(s => s.schemeId === id)?.savedAt
        });
      }
    }

    return { success: true, data };
  }
}

export const userService = new UserService();
