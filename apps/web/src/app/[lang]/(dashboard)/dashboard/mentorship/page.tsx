"use client"

import { useDictionary } from "@/components/providers/DictionaryProvider"
import { MentorshipDashboard } from "@/features/mentorship/components/MentorshipDashboard"

export default function Page() {
  const { dict } = useDictionary()
  const mDict = dict.mentorship || {}

  return (
    <div className="flex flex-col h-full">
      <div className="flex items-center justify-between space-y-2 mb-6">
        <div>
          <h2 className="text-3xl font-bold tracking-tight capitalize">{mDict.pageTitle || "Mentorship"}</h2>
          <p className="text-muted-foreground mt-1">
            {mDict.pageDescription || "Connect with experienced mentors who can help you make better decisions and grow your business."}
          </p>
        </div>
      </div>
      
      <div className="flex-1">
        <MentorshipDashboard />
      </div>
    </div>
  )
}
