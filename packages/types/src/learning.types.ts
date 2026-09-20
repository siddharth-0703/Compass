export type LearningCategory = 'Marketing' | 'Finance' | 'Accounting' | 'GST' | 'FSSAI' | 'MSME' | 'Digital Marketing' | 'Export' | 'Branding' | 'Packaging' | 'Business Planning' | 'Agriculture' | 'Food Processing' | 'Handicrafts' | 'Manufacturing' | 'Leadership' | 'Technology' | 'AI Tools';

export type LearningDifficulty = 'Beginner' | 'Intermediate' | 'Advanced' | 'Expert';

export type LearningFormat = 'Video' | 'Article' | 'PDF' | 'Audio' | 'Interactive Lesson' | 'Quiz' | 'Case Study' | 'Government Guide' | 'Business Template' | 'Checklist' | 'Workshop' | 'Webinar';

export interface LocalizedMediaSource {
  contentUrl: string;
  provider: 'YOUTUBE' | 'MP4' | 'HLS';
  contentType: 'VIDEO';
}

export interface LocalizedMedia {
  en?: LocalizedMediaSource;
  hi?: LocalizedMediaSource;
  mr?: LocalizedMediaSource;
}

export interface ILesson {
  id: string;
  title: string;
  description: string;
  durationSeconds: number;
  media?: LocalizedMedia;
  resources: string[];
  order: number;
  isPublished: boolean;
  contentStatus: 'NOT_CONFIGURED' | 'CONFIGURED' | 'VERIFIED' | 'UNAVAILABLE';
}

export interface IModule {
  id: string;
  title: string;
  description: string;
  order: number;
  lessons: ILesson[];
}

export interface ICourse {
  id?: string;
  title: string;
  description: string;
  categories: LearningCategory[];
  difficulty: LearningDifficulty;
  thumbnailUrl?: string;
  modules: IModule[];
  createdAt?: Date;
  updatedAt?: Date;
}

export interface ILessonProgress {
  userId: string;
  courseId: string;
  moduleId: string;
  lessonId: string;
  positionSeconds: number;
  durationSeconds: number;
  percentage: number;
  completed: boolean;
  clientUpdatedAt: Date;
}

export type EnrollmentStatus = 'Started' | 'In Progress' | 'Completed' | 'Dropped';

export interface ICourseEnrollment {
  id?: string;
  userId: string;
  courseId: string;
  status: EnrollmentStatus;
  progressPercentage: number;
  completedLessons: string[]; // List of completed lesson IDs
  lastAccessedAt?: Date;
  certificateEarned: boolean;
  createdAt?: Date;
  updatedAt?: Date;
}
