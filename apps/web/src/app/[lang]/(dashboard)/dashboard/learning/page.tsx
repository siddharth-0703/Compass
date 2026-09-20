"use client"

import { useState } from "react"
import { motion, AnimatePresence } from "framer-motion"
import { Search, ArrowLeft, BookOpen, Clock, ChevronRight, Play } from "lucide-react"
import { Button } from "@/components/ui/button"
import { Input } from "@/components/ui/input"

// Import Data & Types
import { courses } from "@/features/learning/data/courses"
import { categories } from "@/features/learning/data/categories"
import { Course, LanguageCode } from "@/features/learning/types/learning.types"

// Import Components
import { CourseCard } from "@/features/learning/components/CourseCard"
import { VideoPlayer } from "@/features/learning/components/VideoPlayer"
import { PlaylistSidebar } from "@/features/learning/components/PlaylistSidebar"
import { CourseTabs } from "@/features/learning/components/CourseTabs"
import { useDictionary } from "@/components/providers/DictionaryProvider"

export default function RuralBusinessAcademy() {
  const { dict, lang } = useDictionary()
  const t = dict.learningHub || {}

  const [activeCategory, setActiveCategory] = useState("All")
  const [searchQuery, setSearchQuery] = useState("")
  
  // LMS State
  const [selectedCourseId, setSelectedCourseId] = useState<string | null>(null)
  const [selectedLang, setSelectedLang] = useState<LanguageCode>((lang as LanguageCode) || "en")
  const [activeLessonId, setActiveLessonId] = useState<string | null>(null)
  
  // Progress State (mock)
  const [completedLessons, setCompletedLessons] = useState<Record<string, string[]>>({})

  // Find active data
  const selectedCourse = courses.find(c => c.id === selectedCourseId)
  const activePlaylist = selectedCourse ? selectedCourse.languages[selectedLang] : null
  const activeLesson = activePlaylist ? activePlaylist.lessons.find(l => l.id === activeLessonId) : null
  
  const courseCompletedLessons = selectedCourse ? (completedLessons[selectedCourse.id] || []) : []
  const progressPercentage = activePlaylist 
    ? (courseCompletedLessons.length / activePlaylist.lessons.length) * 100 
    : 0

  // Find featured course (highest progress, or default to first course)
  const featuredCourse = courses.find(c => {
    const courseCompleted = completedLessons[c.id] || []
    return courseCompleted.length > 0
  }) || courses[0]
  
  const featuredCompleted = completedLessons[featuredCourse.id] || []
  const featuredPlaylist = featuredCourse.languages[lang as keyof typeof featuredCourse.languages] || featuredCourse.languages.en
  const featuredProgress = featuredPlaylist.lessons.length > 0 
    ? Math.round((featuredCompleted.length / featuredPlaylist.lessons.length) * 100)
    : 0

  // Filtering
  const filteredCourses = courses.filter(course => {
    const matchesCategory = activeCategory === "All" || course.category === activeCategory
    const matchesSearch = course.title.toLowerCase().includes(searchQuery.toLowerCase()) || 
                          course.tags.some(tag => tag.toLowerCase().includes(searchQuery.toLowerCase()))
    return matchesCategory && matchesSearch
  })

  // Start / Resume Course
  const handleStartCourse = (course: Course) => {
    setSelectedCourseId(course.id)
    const initialLang = (Object.keys(course.languages).includes(lang) ? lang : "en") as LanguageCode
    setSelectedLang(initialLang)
    
    // Find first lesson or resume
    const playlist = course.languages[initialLang] || course.languages.en
    const firstLessonId = playlist.lessons[0]?.id
    
    // If progress exists, we could resume the last viewed. For now, start from first.
    setActiveLessonId(firstLessonId || null)
    
    window.scrollTo({ top: 0, behavior: 'smooth' })
  }

  // Mark lesson as complete
  const markLessonComplete = () => {
    if (!selectedCourseId || !activeLessonId || !activePlaylist) return;
    
    setCompletedLessons(prev => {
      const currentCompleted = prev[selectedCourseId] || []
      if (!currentCompleted.includes(activeLessonId)) {
        return {
          ...prev,
          [selectedCourseId]: [...currentCompleted, activeLessonId]
        }
      }
      return prev
    })

    // Auto-advance to next lesson
    const currentIndex = activePlaylist.lessons.findIndex(l => l.id === activeLessonId)
    if (currentIndex < activePlaylist.lessons.length - 1) {
      setActiveLessonId(activePlaylist.lessons[currentIndex + 1].id)
    }
  }

  const navigateLesson = (direction: 'prev' | 'next') => {
    if (!activePlaylist || !activeLessonId) return;
    const currentIndex = activePlaylist.lessons.findIndex(l => l.id === activeLessonId)
    
    if (direction === 'prev' && currentIndex > 0) {
      setActiveLessonId(activePlaylist.lessons[currentIndex - 1].id)
    } else if (direction === 'next' && currentIndex < activePlaylist.lessons.length - 1) {
      setActiveLessonId(activePlaylist.lessons[currentIndex + 1].id)
    }
  }

  // Render the Course Player View
  if (selectedCourse && activePlaylist) {
    return (
      <div className="flex-1 space-y-6 p-4 md:p-8 pt-6 max-w-7xl mx-auto w-full pb-20">
        <Button variant="ghost" onClick={() => setSelectedCourseId(null)} className="mb-2 -ml-4 text-muted-foreground hover:text-foreground">
          <ArrowLeft className="w-4 h-4 mr-2" /> {t.backToDashboard || "Back to LMS Dashboard"}
        </Button>

        <div className="grid lg:grid-cols-3 gap-8">
          {/* Video Player Section */}
          <div className="lg:col-span-2 space-y-6">
            <VideoPlayer 
              videoId={activeLesson?.videoId} 
              title={activeLesson?.title || "No Lesson Selected"} 
            />

            <div className="flex flex-col md:flex-row justify-between items-start md:items-center gap-4 border-b border-white/10 pb-4">
              <div>
                <div className="flex flex-wrap gap-2 mb-3">
                  <span className="text-[10px] font-bold uppercase tracking-wider bg-primary/10 text-primary px-2 py-1 rounded border border-primary/20">
                    {t.categories?.[selectedCourse.category] || selectedCourse.category}
                  </span>
                  <span className="text-[10px] font-bold uppercase tracking-wider bg-muted text-muted-foreground px-2 py-1 rounded border border-white/10">
                    {t.difficulties?.[selectedCourse.difficulty] || selectedCourse.difficulty}
                  </span>
                </div>
                <h1 className="text-2xl md:text-3xl font-bold mb-2">{activeLesson?.title}</h1>
                <p className="text-muted-foreground text-sm">{selectedCourse.languages[selectedLang]?.title || selectedCourse.title}</p>
              </div>

              {/* Dynamic Language Selector */}
              <div className="bg-muted/40 border border-white/10 rounded-2xl p-1.5 flex gap-1 items-center self-stretch md:self-auto justify-center">
                <span className="text-[10px] font-bold text-muted-foreground uppercase px-2">{t.language || "Language:"}</span>
                {Object.keys(selectedCourse.languages).map((langKey) => (
                  <button
                    key={langKey}
                    onClick={() => {
                      setSelectedLang(langKey as LanguageCode);
                      // Reset to first lesson of new language
                      const newPlaylist = selectedCourse.languages[langKey as LanguageCode];
                      setActiveLessonId(newPlaylist.lessons[0]?.id || null);
                    }}
                    className={`px-3 py-1.5 rounded-xl text-xs font-semibold transition-all uppercase ${
                      selectedLang === langKey ? "bg-primary text-primary-foreground shadow" : "text-muted-foreground hover:text-foreground"
                    }`}
                  >
                    {langKey}
                  </button>
                ))}
              </div>
            </div>

            {/* Course Tabs (Resources, Notes) */}
            {activeLesson && <CourseTabs lesson={activeLesson} />}

            {/* Bottom Controls */}
            <div className="flex flex-col sm:flex-row justify-between items-center gap-4 pt-6 mt-6 border-t border-white/10">
              <Button 
                variant="outline" 
                onClick={() => navigateLesson('prev')}
                disabled={activePlaylist.lessons.findIndex(l => l.id === activeLessonId) === 0}
              >
                {t.previousLesson || "Previous Lesson"}
              </Button>
              
              <Button onClick={markLessonComplete} className="w-full sm:w-auto font-bold px-8 shadow-lg shadow-primary/20">
                {t.markAsComplete || "Mark as Complete"}
              </Button>

              <Button 
                variant="outline" 
                onClick={() => navigateLesson('next')}
                disabled={activePlaylist.lessons.findIndex(l => l.id === activeLessonId) === activePlaylist.lessons.length - 1}
              >
                {t.nextLesson || "Next Lesson"} <ChevronRight className="w-4 h-4 ml-1" />
              </Button>
            </div>
          </div>

          {/* Lessons Sidebar */}
          <div className="lg:col-span-1">
            <PlaylistSidebar 
              lessons={activePlaylist.lessons}
              activeLessonId={activeLessonId || ""}
              completedLessonIds={courseCompletedLessons}
              progressPercentage={progressPercentage}
              onSelectLesson={setActiveLessonId}
            />
          </div>
        </div>
      </div>
    )
  }

  // Render the Dashboard View
  return (
    <div className="flex-1 space-y-8 p-4 md:p-8 pt-6 max-w-7xl mx-auto w-full pb-20">
      
      {/* Header */}
      <div className="flex flex-col gap-2 mb-8">
        <div className="flex items-center gap-3">
          <span className="px-3 py-1 text-xs font-bold uppercase tracking-wider bg-primary/10 text-primary rounded-full border border-primary/20">
            {t.enterpriseLms || "Enterprise LMS"}
          </span>
        </div>
        <h1 className="text-3xl md:text-4xl font-extrabold tracking-tight">{t.pageTitle || "Learning Hub"}</h1>
        <p className="text-muted-foreground">{t.pageDescription || "Gain practical skills in finance, agriculture, and entrepreneurship."}</p>
      </div>

      {/* Hero: Continue Learning */}
      {featuredCourse && (
        <motion.div 
          initial={{ opacity: 0, y: 20 }}
          animate={{ opacity: 1, y: 0 }}
          className="glass-panel p-1 rounded-3xl border border-white/10 overflow-hidden relative group cursor-pointer"
          onClick={() => handleStartCourse(featuredCourse)}
        >
          {/* Ambient background glow */}
          <div className="absolute top-0 right-0 -mt-20 -mr-20 h-64 w-64 rounded-full bg-primary/10 blur-3xl" />
          
          <div className="grid md:grid-cols-12 gap-0 relative z-10">
            {/* Image Side */}
            <div className="md:col-span-4 lg:col-span-3 relative h-48 md:h-auto min-h-[200px] overflow-hidden rounded-t-3xl md:rounded-l-3xl md:rounded-tr-none">
              <img 
                src={featuredCourse.image} 
                alt={featuredCourse.title} 
                className="object-cover w-full h-full transition-transform duration-700 group-hover:scale-105"
              />
              <div className="absolute inset-0 bg-gradient-to-t from-background/80 to-transparent md:bg-gradient-to-r md:from-transparent md:to-background" />
              <div className="absolute inset-0 flex items-center justify-center opacity-0 group-hover:opacity-100 transition-opacity bg-black/20">
                 <div className="w-12 h-12 rounded-full bg-primary/90 flex items-center justify-center shadow-xl shadow-primary/30 backdrop-blur-md transform scale-90 group-hover:scale-100 transition-all">
                   <Play className="w-5 h-5 text-white fill-white ml-1" />
                 </div>
              </div>
            </div>

            {/* Content Side */}
            <div className="md:col-span-8 lg:col-span-9 p-6 md:p-8 flex flex-col justify-center bg-background/40 backdrop-blur-md rounded-b-3xl md:rounded-r-3xl md:rounded-bl-none">
              <div className="flex flex-wrap items-center gap-3 mb-3">
                <span className="flex items-center gap-1.5 text-xs font-semibold bg-secondary/10 text-secondary px-2.5 py-1 rounded-full">
                  <BookOpen className="w-3.5 h-3.5" />
                  {Math.max(...Object.values(featuredCourse.languages).map(lang => lang.lessons.length))} {t.lessons || "lessons"}
                </span>
                <span className="flex items-center gap-1.5 text-xs font-semibold bg-muted text-muted-foreground px-2.5 py-1 rounded-full">
                  <Clock className="w-3.5 h-3.5" />
                  {featuredCourse.duration}
                </span>
                <div className="flex gap-1">
                  {Object.keys(featuredCourse.languages).map(lang => (
                    <span key={lang} className="text-[10px] font-bold border border-white/10 px-1.5 py-0.5 rounded text-muted-foreground uppercase">
                      {lang}
                    </span>
                  ))}
                </div>
              </div>

              <h2 className="text-2xl md:text-3xl font-bold mb-2 text-foreground">{featuredCourse.title}</h2>
              <p className="text-muted-foreground text-sm mb-6 max-w-2xl">
                {featuredCourse.languages[selectedLang]?.description || featuredCourse.languages.en.description}
              </p>
              
              <div className="space-y-3 mb-6 max-w-xl">
                <div className="flex justify-between text-sm font-medium">
                  <span>{t.progress || "Progress"}</span>
                  <span className="text-primary">{featuredProgress}% {t.complete || "complete"}</span>
                </div>
                <div className="h-2 w-full bg-muted rounded-full overflow-hidden">
                  <motion.div 
                    initial={{ width: 0 }}
                    animate={{ width: `${featuredProgress}%` }}
                    transition={{ duration: 1, ease: "easeOut" }}
                    className="h-full bg-primary rounded-full relative"
                  >
                    <div className="absolute top-0 right-0 bottom-0 w-8 bg-gradient-to-r from-transparent to-white/30" />
                  </motion.div>
                </div>
              </div>

              <div>
                <Button size="lg" className="rounded-full shadow-lg shadow-primary/20 gap-2 h-12 px-8 font-semibold">
                  <Play className="w-4 h-4 fill-foreground" /> {t.resumeCourse || "Resume Course"}
                </Button>
              </div>
            </div>
          </div>
        </motion.div>
      )}

      {/* Categories & Search */}
      <div className="flex flex-col md:flex-row justify-between items-start md:items-center gap-4 sticky top-0 z-20 bg-background/80 backdrop-blur-xl py-4 border-b border-white/5 -mx-4 px-4 md:mx-0 md:px-0">
        <div className="flex overflow-x-auto pb-2 -mb-2 w-full md:w-auto scrollbar-hide gap-2 mask-linear-fade">
          {categories.map(category => {
            const translatedCategory = t.categories?.[category] || category
            return (
            <button
              key={category}
              onClick={() => setActiveCategory(category)}
              className={`px-4 py-2 rounded-full text-sm font-medium whitespace-nowrap transition-all ${
                activeCategory === category 
                  ? 'bg-foreground text-background shadow-md' 
                  : 'bg-muted/50 text-muted-foreground hover:bg-muted hover:text-foreground border border-white/5'
              }`}
            >
              {translatedCategory}
            </button>
          )})}
        </div>
        
        <div className="relative w-full md:w-64 shrink-0">
          <Search className="w-4 h-4 absolute left-3 top-1/2 -translate-y-1/2 text-muted-foreground" />
          <Input 
            type="text" 
            placeholder={t.searchPlaceholder || "Search courses..."}
            value={searchQuery}
            onChange={(e) => setSearchQuery(e.target.value)}
            className="pl-9 rounded-full bg-muted/30 border-white/10 focus-visible:ring-primary focus-visible:border-primary"
          />
        </div>
      </div>

      {/* Recommended & Continue Learning Header */}
      <div className="flex items-center justify-between mb-4">
        <h2 className="text-xl font-bold flex items-center gap-2">
          <BookOpen className="w-5 h-5 text-primary" /> {t.recommendedCourses || "Recommended Courses"}
        </h2>
      </div>

      {/* Course Grid */}
      <motion.div layout className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 xl:grid-cols-4 gap-6">
        <AnimatePresence>
          {filteredCourses.map((course, idx) => {
            const courseCompleted = completedLessons[course.id] || []
            const firstLangPlaylist = Object.values(course.languages)[0]
            const progress = firstLangPlaylist && firstLangPlaylist.lessons.length > 0 
              ? Math.round((courseCompleted.length / firstLangPlaylist.lessons.length) * 100)
              : 0
            
            return (
              <CourseCard
                key={course.id}
                course={course}
                progress={progress}
                isCompleted={progress === 100}
                onStartCourse={handleStartCourse}
              />
            )
          })}
        </AnimatePresence>
      </motion.div>

      {filteredCourses.length === 0 && (
        <div className="py-20 text-center flex flex-col items-center justify-center">
          <div className="w-16 h-16 rounded-full bg-muted flex items-center justify-center mb-4 text-muted-foreground">
            <Search className="w-8 h-8" />
          </div>
          <h3 className="text-xl font-bold mb-2">{t.noCoursesFound || "No courses found"}</h3>
          <p className="text-muted-foreground">{t.adjustSearch || "Try adjusting your search or category filter."}</p>
          <Button variant="outline" className="mt-4" onClick={() => { setSearchQuery(""); setActiveCategory("All"); }}>
            {t.clearFilters || "Clear Filters"}
          </Button>
        </div>
      )}
    </div>
  )
}
