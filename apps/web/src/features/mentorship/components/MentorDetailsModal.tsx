"use client"

import { DemoMentor } from "../types"
import { useDictionary } from "@/components/providers/DictionaryProvider"
import { Button } from "@/components/ui/button"
import { MapPin, Globe, Briefcase, CheckCircle2 } from "lucide-react"
import {
  Dialog,
  DialogContent,
  DialogDescription,
  DialogHeader,
  DialogTitle,
  DialogFooter,
} from "@/components/ui/dialog"
import { Badge } from "@/components/ui/badge"

interface MentorDetailsModalProps {
  mentor: DemoMentor | null;
  isOpen: boolean;
  onClose: () => void;
  isPending: boolean;
  onRequestClick: (mentorId: string) => void;
}

export function MentorDetailsModal({ mentor, isOpen, onClose, isPending, onRequestClick }: MentorDetailsModalProps) {
  const { dict } = useDictionary()
  const mDict = dict.mentorship || {}

  if (!mentor) return null

  const getInitials = (name: string) => {
    return name
      .split(" ")
      .map(n => n[0])
      .join("")
      .substring(0, 2)
      .toUpperCase()
  }

  return (
    <Dialog open={isOpen} onOpenChange={(open) => !open && onClose()}>
      <DialogContent className="sm:max-w-[600px] max-h-[90vh] overflow-y-auto">
        <DialogHeader>
          <div className="flex items-center gap-4 mt-4">
            <div className="h-16 w-16 rounded-full bg-primary/10 flex items-center justify-center flex-shrink-0">
              <span className="text-2xl font-bold text-primary">
                {getInitials(mentor.name)}
              </span>
            </div>
            <div>
              <DialogTitle className="text-xl">{mentor.name}</DialogTitle>
              <DialogDescription className="flex items-center mt-1 text-base font-medium text-foreground">
                {(mDict.expertise as any)?.[mentor.expertise] || mentor.expertise}
              </DialogDescription>
            </div>
          </div>
        </DialogHeader>

        <div className="space-y-6 py-4">
          <div>
            <h4 className="font-medium mb-2 text-sm">{mDict.about || "About"}</h4>
            <p className="text-sm text-muted-foreground">{mentor.bio}</p>
          </div>

          <div className="grid grid-cols-2 gap-4">
            <div>
              <h4 className="font-medium mb-2 text-sm flex items-center gap-1">
                <MapPin className="h-4 w-4" /> {mDict.locationLabel || "Location"}
              </h4>
              <Badge variant="outline" className="font-normal text-xs">
                 {(mDict.locations as any)?.[mentor.location] || mentor.location}
              </Badge>
            </div>
            <div>
              <h4 className="font-medium mb-2 text-sm flex items-center gap-1">
                <Briefcase className="h-4 w-4" /> {mDict.experienceLabel || "Experience"}
              </h4>
              <div className="text-sm text-muted-foreground">
                 {mentor.experience} {mDict.years || "years"}
              </div>
            </div>
            <div className="col-span-2">
              <h4 className="font-medium mb-2 text-sm flex items-center gap-1">
                <Globe className="h-4 w-4" /> {mDict.languagesLabel || "Languages"}
              </h4>
              <div className="flex flex-wrap gap-1">
                {mentor.languages.map((lang, i) => (
                  <Badge variant="secondary" key={i} className="font-normal text-xs">
                    {(mDict.languages as any)?.[lang] || lang}
                  </Badge>
                ))}
              </div>
            </div>
          </div>
        </div>

        <DialogFooter>
          {isPending ? (
            <Button className="w-full sm:w-auto" variant="secondary" disabled>
              <CheckCircle2 className="w-4 h-4 mr-2" />
              {mDict.requestPending || "Request Pending"}
            </Button>
          ) : (
            <Button className="w-full sm:w-auto" variant="default" onClick={() => onRequestClick(mentor.id)}>
              {mDict.requestMentorship || "Request Mentorship"}
            </Button>
          )}
        </DialogFooter>
      </DialogContent>
    </Dialog>
  )
}
