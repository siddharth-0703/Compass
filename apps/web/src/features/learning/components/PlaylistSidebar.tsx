import { Lesson } from "../types/learning.types";
import { CheckCircle, Play, Clock } from "lucide-react";
import { useDictionary } from "@/components/providers/DictionaryProvider";

interface PlaylistSidebarProps {
  lessons: Lesson[];
  activeLessonId: string;
  completedLessonIds: string[];
  progressPercentage: number;
  onSelectLesson: (lessonId: string) => void;
}

export function PlaylistSidebar({ 
  lessons, 
  activeLessonId, 
  completedLessonIds, 
  progressPercentage, 
  onSelectLesson 
}: PlaylistSidebarProps) {
  const { dict } = useDictionary();
  const t = dict.learningHub || {};

  return (
    <div className="glass-panel p-6 rounded-3xl border border-white/10 h-full max-h-[800px] flex flex-col">
      <div className="mb-6">
        <h3 className="text-xl font-bold mb-2">{t.courseContent || "Course Content"}</h3>
        <div className="flex items-center gap-2 text-sm text-muted-foreground mb-4">
          <span>{lessons.length} {t.lessons || "lessons"}</span>
          <span>•</span>
          <span>{completedLessonIds.length} {t.completed?.toLowerCase() || "completed"}</span>
        </div>
        
        <div className="space-y-1.5 mb-2">
          <div className="flex justify-between text-xs font-bold text-muted-foreground uppercase tracking-wider">
            <span>{t.progress || "Course Progress"}</span>
            <span className="text-primary">{Math.round(progressPercentage)}%</span>
          </div>
          <div className="h-2 w-full bg-muted rounded-full overflow-hidden">
            <div 
              className="h-full bg-primary rounded-full transition-all duration-500" 
              style={{ width: `${progressPercentage}%` }} 
            />
          </div>
        </div>
      </div>

      <div className="space-y-2 overflow-y-auto pr-2 scrollbar-thin flex-1">
        {lessons.map((lesson, idx) => {
          const isCompleted = completedLessonIds.includes(lesson.id);
          const isActive = activeLessonId === lesson.id;
          
          return (
            <button
              key={lesson.id}
              onClick={() => onSelectLesson(lesson.id)}
              className={`w-full flex items-start gap-3 p-3 rounded-xl transition-all text-left ${
                isActive 
                  ? "bg-primary/10 border border-primary/20" 
                  : "hover:bg-muted/50 border border-transparent"
              }`}
            >
              <div className="mt-0.5 shrink-0">
                {isCompleted ? (
                  <CheckCircle className="w-5 h-5 text-success" />
                ) : isActive ? (
                  <Play className="w-5 h-5 text-primary fill-primary" />
                ) : (
                  <div className="w-5 h-5 rounded-full border-2 border-muted-foreground/30 flex items-center justify-center">
                    <span className="text-[10px] font-bold text-muted-foreground">{idx + 1}</span>
                  </div>
                )}
              </div>
              <div>
                <h4 className={`text-sm font-semibold leading-tight mb-1 ${isActive ? "text-foreground" : "text-muted-foreground"}`}>
                  {lesson.title}
                </h4>
                <p className="text-xs text-muted-foreground flex items-center gap-1">
                  <Clock className="w-3 h-3" /> {lesson.duration}
                </p>
              </div>
            </button>
          )
        })}
      </div>
    </div>
  );
}
