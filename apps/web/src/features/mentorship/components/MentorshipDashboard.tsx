"use client"

import { useState } from "react"
import { DemoMentor } from "../types"
import { demoMentors } from "../data/demoMentors"
import { MentorSearchFilters } from "./MentorSearchFilters"
import { MentorCard } from "./MentorCard"
import { MentorDetailsModal } from "./MentorDetailsModal"
import { useDictionary } from "@/components/providers/DictionaryProvider"
import { Button } from "@/components/ui/button"
import { Info, CheckCircle2 } from "lucide-react"
import {
  Dialog,
  DialogContent,
  DialogDescription,
  DialogHeader,
  DialogTitle,
  DialogFooter,
} from "@/components/ui/dialog"

export function MentorshipDashboard() {
  const { dict } = useDictionary()
  const mDict = dict.mentorship || {}

  // Filters
  const [searchTerm, setSearchTerm] = useState("")
  const [expertiseFilter, setExpertiseFilter] = useState("all")
  const [availabilityFilter, setAvailabilityFilter] = useState("all")
  const [locationFilter, setLocationFilter] = useState("all")
  const [languageFilter, setLanguageFilter] = useState("all")

  // Modal & Request State
  const [selectedMentor, setSelectedMentor] = useState<DemoMentor | null>(null)
  const [pendingRequests, setPendingRequests] = useState<Record<string, boolean>>({})
  const [showConfirmDialog, setShowConfirmDialog] = useState(false)

  // Filter Logic
  const filteredMentors = demoMentors.filter(mentor => {
    // 1. Search filter (case-insensitive across name, bio, expertise, location, languages)
    if (searchTerm) {
      const term = searchTerm.toLowerCase()
      const searchSpace = [
        mentor.name,
        mentor.bio,
        mentor.expertise,
        mentor.location,
        ...mentor.languages
      ].join(" ").toLowerCase()
      
      if (!searchSpace.includes(term)) {
        return false
      }
    }

    // 2. Expertise filter
    if (expertiseFilter !== "all" && mentor.expertise !== expertiseFilter) {
      return false
    }

    // 3. Location filter
    if (locationFilter !== "all" && mentor.location !== locationFilter) {
      return false
    }

    // 4. Language filter
    if (languageFilter !== "all" && !mentor.languages.includes(languageFilter)) {
      return false
    }

    // 5. Availability filter
    if (availabilityFilter !== "all") {
      if (availabilityFilter === "available" && mentor.availability !== "available") return false
      if (availabilityFilter === "limited" && mentor.availability === "available") return false
    }

    return true
  })

  const handleRequestMentorship = (mentorId: string) => {
    setPendingRequests(prev => ({ ...prev, [mentorId]: true }))
    setSelectedMentor(null)
    setShowConfirmDialog(true)
  }

  return (
    <div className="w-full">
      {/* Demo Banner */}
      <div className="bg-primary/10 border border-primary/20 rounded-lg p-4 mb-6 flex items-start gap-3">
        <Info className="text-primary w-5 h-5 shrink-0 mt-0.5" />
        <div>
          <h3 className="font-semibold text-primary">{mDict.demoModeTitle || "Demo Mode"}</h3>
          <p className="text-sm text-primary/80">
            {mDict.demoModeDesc || "The mentor profiles shown here are fictional examples used to demonstrate the Compass mentorship experience."}
          </p>
        </div>
      </div>

      <div className="space-y-6">
        <MentorSearchFilters 
          searchTerm={searchTerm}
          setSearchTerm={setSearchTerm}
          expertiseFilter={expertiseFilter}
          setExpertiseFilter={setExpertiseFilter}
          availabilityFilter={availabilityFilter}
          setAvailabilityFilter={setAvailabilityFilter}
          locationFilter={locationFilter}
          setLocationFilter={setLocationFilter}
          languageFilter={languageFilter}
          setLanguageFilter={setLanguageFilter}
        />

        {filteredMentors.length > 0 ? (
          <div>
            <p className="text-sm text-muted-foreground mb-4">
              {(mDict.mentorsAvailableDemo || "{count} mentors available for demonstration").replace('{count}', filteredMentors.length.toString())}
            </p>
            <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 xl:grid-cols-4 gap-6">
              {filteredMentors.map(mentor => (
                <MentorCard 
                  key={mentor.id} 
                  mentor={mentor} 
                  isPending={!!pendingRequests[mentor.id]}
                  onViewProfile={setSelectedMentor} 
                  onRequestMentorship={handleRequestMentorship}
                />
              ))}
            </div>
          </div>
        ) : (
          <div className="text-center py-20 bg-card rounded-lg border border-dashed">
            <h3 className="text-lg font-medium mb-2">{mDict.noMentorsFound || "No mentors found"}</h3>
            <p className="text-muted-foreground">{mDict.noMentorsDesc || "Try changing your search or filters."}</p>
            <Button variant="link" onClick={() => {
              setSearchTerm("")
              setExpertiseFilter("all")
              setAvailabilityFilter("all")
              setLocationFilter("all")
              setLanguageFilter("all")
            }}>
              {mDict.clearFilters || "Clear Filters"}
            </Button>
          </div>
        )}
      </div>

      <MentorDetailsModal 
        mentor={selectedMentor} 
        isOpen={!!selectedMentor} 
        onClose={() => setSelectedMentor(null)} 
        isPending={selectedMentor ? !!pendingRequests[selectedMentor.id] : false}
        onRequestClick={handleRequestMentorship}
      />

      {/* Confirmation Dialog */}
      <Dialog open={showConfirmDialog} onOpenChange={setShowConfirmDialog}>
        <DialogContent className="sm:max-w-[425px]">
          <DialogHeader className="text-center sm:text-center">
            <div className="mx-auto w-12 h-12 rounded-full bg-primary/10 flex items-center justify-center mb-4">
              <CheckCircle2 className="w-6 h-6 text-primary" />
            </div>
            <DialogTitle className="text-xl">
              {mDict.requestConfirmTitle || "Request Mentorship"}
            </DialogTitle>
            <DialogDescription className="text-center pt-2">
              {mDict.requestConfirmDesc || "Demo mentorship request created. In the production version, this would be routed through the Compass mentorship system."}
            </DialogDescription>
          </DialogHeader>
          <DialogFooter className="sm:justify-center mt-4">
            <Button onClick={() => setShowConfirmDialog(false)} className="w-full sm:w-auto min-w-[120px]">
              Okay
            </Button>
          </DialogFooter>
        </DialogContent>
      </Dialog>
    </div>
  )
}
