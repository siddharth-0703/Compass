import { useState } from "react";
import { Lesson } from "../types/learning.types";
import { Download, FileText, LayoutList } from "lucide-react";
import { useDictionary } from "@/components/providers/DictionaryProvider";

interface CourseTabsProps {
  lesson: Lesson;
}

export function CourseTabs({ lesson }: CourseTabsProps) {
  const { dict } = useDictionary();
  const t = dict.learningHub || {};
  
  const [activeTab, setActiveTab] = useState<"overview" | "resources" | "notes">("overview");

  return (
    <div className="mt-6 border border-white/10 rounded-2xl overflow-hidden glass-panel">
      <div className="flex border-b border-white/10 overflow-x-auto scrollbar-hide">
        <button
          onClick={() => setActiveTab("overview")}
          className={`flex-1 py-3 px-4 text-sm font-semibold flex items-center justify-center gap-2 border-b-2 transition-colors ${
            activeTab === "overview" ? "border-primary text-foreground bg-primary/5" : "border-transparent text-muted-foreground hover:bg-muted/30"
          }`}
        >
          <LayoutList className="w-4 h-4" /> {t.overview || "Overview"}
        </button>
        <button
          onClick={() => setActiveTab("resources")}
          className={`flex-1 py-3 px-4 text-sm font-semibold flex items-center justify-center gap-2 border-b-2 transition-colors ${
            activeTab === "resources" ? "border-primary text-foreground bg-primary/5" : "border-transparent text-muted-foreground hover:bg-muted/30"
          }`}
        >
          <Download className="w-4 h-4" /> {t.resources || "Resources"}
        </button>
        <button
          onClick={() => setActiveTab("notes")}
          className={`flex-1 py-3 px-4 text-sm font-semibold flex items-center justify-center gap-2 border-b-2 transition-colors ${
            activeTab === "notes" ? "border-primary text-foreground bg-primary/5" : "border-transparent text-muted-foreground hover:bg-muted/30"
          }`}
        >
          <FileText className="w-4 h-4" /> {t.notes || "Notes"}
        </button>
      </div>

      <div className="p-6">
        {activeTab === "overview" && (
          <div className="space-y-4 animate-in fade-in slide-in-from-bottom-2">
            <h3 className="text-lg font-bold">{t.aboutThisLesson || "About this lesson"}</h3>
            <p className="text-muted-foreground text-sm leading-relaxed">
              {lesson.description || "No description provided for this lesson."}
            </p>
          </div>
        )}

        {activeTab === "resources" && (
          <div className="space-y-4 animate-in fade-in slide-in-from-bottom-2">
            <h3 className="text-lg font-bold">{t.downloadableResources || "Downloadable Resources"}</h3>
            {lesson.resources && lesson.resources.length > 0 ? (
              <div className="grid gap-3">
                {lesson.resources.map((res, i) => (
                  <div key={i} className="flex items-center justify-between p-3 rounded-xl bg-muted/40 border border-white/5">
                    <div className="flex items-center gap-3">
                      <div className="w-10 h-10 rounded-lg bg-primary/10 text-primary flex items-center justify-center">
                        <FileText className="w-5 h-5" />
                      </div>
                      <div>
                        <h4 className="text-sm font-semibold">{res.name}</h4>
                        <p className="text-xs text-muted-foreground">{res.size}</p>
                      </div>
                    </div>
                    <a href={res.url} className="text-primary hover:underline text-sm font-medium">{t.download || "Download"}</a>
                  </div>
                ))}
              </div>
            ) : (
              <p className="text-muted-foreground text-sm">{t.noResources || "No resources attached to this lesson."}</p>
            )}
          </div>
        )}

        {activeTab === "notes" && (
          <div className="space-y-4 animate-in fade-in slide-in-from-bottom-2">
            <h3 className="text-lg font-bold">{t.myNotes || "My Notes"}</h3>
            <div className="p-4 rounded-xl border border-white/10 bg-muted/20 text-center">
              <p className="text-muted-foreground text-sm mb-3">{t.takeNotes || "Take notes while watching to retain knowledge."}</p>
              <button className="text-xs font-semibold bg-primary text-primary-foreground px-4 py-2 rounded-lg">
                {t.addNote || "+ Add Note"}
              </button>
            </div>
          </div>
        )}
      </div>
    </div>
  );
}
