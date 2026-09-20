export type LanguageCode = "en" | "hi" | "mr";

export interface Resource {
  name: string;
  url: string;
  size: string;
}

export interface Quiz {
  id: string;
  title: string;
  questions: any[]; // Placeholder for full quiz schema
  passingScore: number;
  timeLimit: number;
  attempts: number;
}

export interface Assignment {
  id: string;
  title: string;
  description: string;
  dueDate?: Date;
}

export interface Lesson {
  id: string;
  title: string;
  description: string;
  duration: string;
  videoId?: string;
  resources?: Resource[];
  quiz?: Quiz[];
  assignment?: Assignment[];
  downloadable?: boolean;
  downloadStatus?: "none" | "downloading" | "downloaded";
  fileSize?: string;
}

export interface LanguagePlaylist {
  title: string;
  description: string;
  lessons: Lesson[];
}

export interface Instructor {
  id: string;
  name: string;
  title: string;
  organization: string;
  bio: string;
  languages: LanguageCode[];
  experience: string;
  avatar: string;
}

export interface Course {
  id: string; // e.g. "organic-farming"
  title: string;
  category: string;
  difficulty: "Beginner" | "Intermediate" | "Advanced";
  duration: string;
  image: string;
  instructorId: string;
  
  // Dynamic languages map
  languages: Record<LanguageCode, LanguagePlaylist>;
  
  // Future ready metadata
  rating: number;
  students: number;
  lastUpdated: string;
  estimatedHours: number;
  tags: string[];
  prerequisites: string[];
  learningOutcomes: string[];
  certificateAvailable: boolean;
  offlineSupported: boolean;
  
  // AI Recs
  aiRecommendationScore?: number;
  relatedCourses?: string[];
  skillLevel?: string;
  careerPath?: string;
}

export interface CourseProgress {
  courseId: string;
  completedLessons: string[]; // Array of lesson IDs completed
  totalLessons: number;
  percentage: number;
  lastLesson: string; // The ID of the last lesson opened
  lastOpened: Date;
  startedAt: Date;
  completedAt?: Date;
  certificateIssued: boolean;
}

export interface Certificate {
  id: string;
  courseId: string;
  userId: string;
  issuedAt: Date;
  verificationCode: string;
  downloadUrl: string;
}

export interface Note {
  id: string;
  lessonId: string;
  timestamp: number; // Video timestamp in seconds
  text: string;
  createdAt: Date;
}
