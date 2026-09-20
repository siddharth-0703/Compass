import mongoose, { Schema, Document } from 'mongoose';

export interface ISavedScheme extends Document {
  userId: string;
  schemeId: string;
  savedAt: Date;
}

const savedSchemeSchema = new Schema(
  {
    userId: { type: String, required: true, index: true },
    schemeId: { type: String, required: true },
    savedAt: { type: Date, default: Date.now },
  },
  { timestamps: true }
);

savedSchemeSchema.index({ userId: 1, schemeId: 1 }, { unique: true });

export const SavedSchemeModel = mongoose.model<ISavedScheme>('SavedScheme', savedSchemeSchema);
