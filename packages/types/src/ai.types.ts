export type VoiceActionType = 
  | 'NAVIGATE'
  | 'SEARCH'
  | 'OPEN_SCHEME'
  | 'OPEN_COURSE'
  | 'FIND_MENTOR'
  | 'UNKNOWN';

export type AllowlistedRoutePath =
  | '/dashboard'
  | '/learning'
  | '/mentorship'
  | '/schemes';

export interface VoiceAction {
  action: VoiceActionType;
  path?: AllowlistedRoutePath;
  searchQuery?: string;
  entityId?: string;
  language: 'en' | 'hi' | 'mr';
  speechResponse: string;
  confidence: number;
}
