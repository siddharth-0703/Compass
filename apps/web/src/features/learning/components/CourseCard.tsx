import { Course } from "../types/learning.types";
import { Play, Award, BookOpen, Clock, ChevronRight, CheckCircle } from "lucide-react";
import { Button } from "@/components/ui/button";
import { motion } from "framer-motion";
import { useDictionary } from "@/components/providers/DictionaryProvider";

interface CourseCardProps {
  course: Course;
  progress?: number;
  isCompleted?: boolean;
  onStartCourse: (course: Course) => void;
}

export function CourseCard({ course, progress = 0, isCompleted = false, onStartCourse }: CourseCardProps) {
  const { dict, lang } = useDictionary();
  const t = dict.learningHub || {};
  
  return (
    <motion.div
      layout
      initial={{ opacity: 0, scale: 0.95, y: 20 }}
      animate={{ opacity: 1, scale: 1, y: 0 }}
      exit={{ opacity: 0, scale: 0.95 }}
      whileHover={{ y: -8 }}
      onClick={() => onStartCourse(course)}
      className="glass-card rounded-2xl overflow-hidden border border-white/10 flex flex-col group cursor-pointer h-full"
    >
      <div className="relative h-48 w-full overflow-hidden">
        <img 
          src={course.image}
          alt={course.title}
          className="object-cover w-full h-full transition-transform duration-700 group-hover:scale-110"
        />
        <div className="absolute inset-0 bg-gradient-to-t from-background/90 via-background/20 to-transparent" />
        
        {isCompleted && (
          <div className="absolute top-3 right-3 bg-success text-success-foreground text-xs font-bold px-2 py-1 rounded flex items-center gap-1 shadow-lg">
            <Award className="w-3.5 h-3.5" /> Certified
          </div>
        )}

        <div className="absolute inset-0 flex items-center justify-center opacity-0 group-hover:opacity-100 transition-opacity bg-black/20">
          <div className="w-12 h-12 rounded-full bg-primary/90 flex items-center justify-center shadow-xl shadow-primary/30 backdrop-blur-md transform scale-90 group-hover:scale-100 transition-all">
            <Play className="w-5 h-5 text-white fill-white ml-1" />
          </div>
        </div>
        
        <div className="absolute bottom-3 left-3 right-3 flex justify-between items-end">
          <div className="flex gap-1.5">
            <span className="text-[10px] font-bold uppercase tracking-wider bg-background/80 backdrop-blur-md px-2 py-1 rounded text-foreground border border-white/10">
              {t.categories?.[course.category] || course.category}
            </span>
            <span className="text-[10px] font-bold uppercase tracking-wider bg-background/80 backdrop-blur-md px-2 py-1 rounded text-muted-foreground border border-white/10">
              {t.difficulties?.[course.difficulty] || course.difficulty}
            </span>
          </div>
        </div>
      </div>

      <div className="p-5 flex flex-col flex-1">
        <h3 className="font-bold text-lg leading-tight mb-3 group-hover:text-primary transition-colors line-clamp-2">
          {course.languages?.[lang as keyof typeof course.languages]?.title || course.title}
        </h3>
        
        <div className="flex items-center gap-3 text-xs text-muted-foreground mb-4">
          <span className="flex items-center gap-1">
            <BookOpen className="w-3.5 h-3.5" /> 
            {Math.max(...Object.values(course.languages).map(lang => lang.lessons.length))} {t.lessons || "lessons"}
          </span>
          <span className="w-1 h-1 rounded-full bg-muted-foreground/30" />
          <span className="flex items-center gap-1"><Clock className="w-3.5 h-3.5" /> {course.duration}</span>
        </div>

        <div className="mt-auto space-y-4">
          {progress > 0 ? (
            <div className="space-y-1.5">
              <div className="flex justify-between text-[10px] font-bold text-muted-foreground uppercase tracking-wider">
                <span>{t.progress || "Progress"}</span>
                <span className={isCompleted ? "text-success" : "text-primary"}>
                  {progress}%
                </span>
              </div>
              <div className="h-1.5 w-full bg-muted rounded-full overflow-hidden">
                <div 
                  className={`h-full rounded-full ${isCompleted ? 'bg-success' : 'bg-primary'}`} 
                  style={{ width: `${progress}%` }} 
                />
              </div>
            </div>
          ) : (
            <div className="flex gap-1">
              {Object.keys(course.languages).map(lang => (
                <span key={lang} className="text-[10px] font-medium border border-white/10 px-1.5 py-0.5 rounded text-muted-foreground bg-muted/30 uppercase">
                  {lang}
                </span>
              ))}
            </div>
          )}

          <Button 
            variant={progress > 0 ? (isCompleted ? "outline" : "default") : "secondary"} 
            className="w-full justify-between group/btn rounded-xl"
          >
            {isCompleted ? (t.completed || "Review Course") : progress > 0 ? (t.resumeCourse || "Continue") : (t.startCourse || "Start Course")}
            {isCompleted ? (
              <CheckCircle className="w-4 h-4 text-success" />
            ) : (
              <ChevronRight className="w-4 h-4 group-hover/btn:translate-x-1 transition-transform" />
            )}
          </Button>
        </div>
      </div>
    </motion.div>
  );
}
