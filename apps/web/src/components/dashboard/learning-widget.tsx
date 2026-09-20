"use client"

import { motion } from "framer-motion"
import { GraduationCap, ArrowRight, PlayCircle } from "lucide-react"
import { Button } from "@/components/ui/button"
import { useDictionary } from "@/components/providers/DictionaryProvider"

const courses = [
  { id: 1, title: "FSSAI Certification Basics", progress: 65, totalModules: 10, completedModules: 6 },
  { id: 2, title: "Digital Payments for Rural Shops", progress: 0, totalModules: 5, completedModules: 0, aiRecommended: true },
]

export function LearningWidget() {
  const { dict } = useDictionary()
  const t = dict.dashboard?.learningWidget || {}

  return (
    <div className="glass-panel rounded-3xl p-6 border border-white/10 flex flex-col h-full">
      <div className="flex justify-between items-center mb-6">
        <div className="flex items-center gap-2">
          <div className="p-2 bg-pink-500/10 text-pink-500 rounded-lg">
            <GraduationCap className="w-5 h-5" />
          </div>
          <h3 className="text-xl font-bold">{t.title || "Learning Hub"}</h3>
        </div>
        <Button variant="ghost" size="sm" className="text-muted-foreground hover:text-foreground">
          {t.viewAll || "View All"} <ArrowRight className="w-4 h-4 ml-1" />
        </Button>
      </div>

      <div className="space-y-4 flex-1">
        {courses.map((course, idx) => (
          <motion.div 
            key={course.id}
            initial={{ opacity: 0, y: 10 }}
            animate={{ opacity: 1, y: 0 }}
            transition={{ delay: 0.4 + (idx * 0.1) }}
            className="p-4 rounded-2xl bg-background/50 border border-white/5 hover:bg-background/80 transition-colors"
          >
            <div className="flex justify-between items-start mb-3">
              <div>
                {course.aiRecommended && (
                  <span className="text-[10px] font-bold uppercase tracking-wider text-primary mb-1 block">
                    ✨ {t.aiRecommended || "AI Recommended"}
                  </span>
                )}
                <h4 className="font-semibold text-foreground text-sm">{t.courses?.[course.id]?.title || course.title}</h4>
              </div>
              <div className="w-8 h-8 rounded-full bg-primary/10 text-primary flex items-center justify-center shrink-0">
                <PlayCircle className="w-4 h-4 ml-0.5" />
              </div>
            </div>
            
            {course.progress > 0 ? (
              <div>
                <div className="flex justify-between text-xs text-muted-foreground mb-1">
                  <span>{course.progress}% {t.completed || "Completed"}</span>
                  <span>{course.completedModules}/{course.totalModules} {t.modules || "Modules"}</span>
                </div>
                <div className="w-full h-1.5 bg-muted rounded-full overflow-hidden">
                  <div className="h-full bg-primary rounded-full" style={{ width: `${course.progress}%` }} />
                </div>
              </div>
            ) : (
              <Button size="sm" variant="outline" className="w-full h-8 text-xs rounded-full">
                {t.startCourse || "Start Course"}
              </Button>
            )}
          </motion.div>
        ))}
      </div>
    </div>
  )
}
