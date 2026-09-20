"use client"

import { DemoMentor } from "../types"
import { useDictionary } from "@/components/providers/DictionaryProvider"
import { Card, CardContent, CardFooter, CardHeader } from "@/components/ui/card"
import { Badge } from "@/components/ui/badge"
import { Button } from "@/components/ui/button"
import { Clock, Globe, Briefcase, MapPin, CheckCircle2 } from "lucide-react"

interface MentorCardProps {
  mentor: DemoMentor;
  isPending: boolean;
  onViewProfile: (mentor: DemoMentor) => void;
  onRequestMentorship: (mentorId: string) => void;
}

export function MentorCard({ mentor, isPending, onViewProfile, onRequestMentorship }: MentorCardProps) {
  const { dict } = useDictionary()
  const mDict = dict.mentorship || {}

  const getInitials = (name: string) => {
    return name
      .split(" ")
      .map(n => n[0])
      .join("")
      .substring(0, 2)
      .toUpperCase()
  }

  return (
    <Card className="flex flex-col h-full hover:border-primary/50 transition-colors">
      <CardHeader className="flex flex-row items-start gap-4 space-y-0">
        <div className="h-12 w-12 rounded-full bg-primary/10 flex items-center justify-center flex-shrink-0">
          <span className="text-xl font-bold text-primary">
            {getInitials(mentor.name)}
          </span>
        </div>
        <div className="flex-1 space-y-1">
          <h3 className="font-semibold text-lg line-clamp-1">{mentor.name}</h3>
          <div className="flex items-center text-sm text-muted-foreground">
             <span className="line-clamp-1">{(mDict.expertise as any)?.[mentor.expertise] || mentor.expertise}</span>
          </div>
        </div>
      </CardHeader>
      
      <CardContent className="flex-1 space-y-4">
        <p className="text-sm text-muted-foreground line-clamp-2">
          {mentor.bio}
        </p>

        <div className="space-y-2">
          <div className="flex items-center gap-2 text-sm">
            <Clock className="h-4 w-4 text-muted-foreground shrink-0" />
            <span className="text-muted-foreground">
              {mentor.experience} {mDict.years || "years"} {mDict.experienceLabel || "experience"}
            </span>
          </div>

          <div className="flex items-start gap-2 text-sm">
            <MapPin className="h-4 w-4 text-muted-foreground shrink-0 mt-0.5" />
            <span className="text-muted-foreground line-clamp-1">
              {(mDict.locations as any)?.[mentor.location] || mentor.location}
            </span>
          </div>

          <div className="flex items-start gap-2 text-sm">
            <Globe className="h-4 w-4 text-muted-foreground shrink-0 mt-0.5" />
            <span className="text-muted-foreground line-clamp-1">
              {mentor.languages.map(l => (mDict.languages as any)?.[l] || l).join(", ")}
            </span>
          </div>

          <div className="flex items-start gap-2 text-sm pt-1">
             <Badge variant={mentor.availability === "available" ? "default" : "secondary"} className="font-normal">
               {mentor.availability === "available" ? (mDict.available || "Available") : (mDict.unavailable || "Limited")}
             </Badge>
          </div>
        </div>
      </CardContent>

      <CardFooter className="flex flex-col gap-2">
        {isPending ? (
          <Button className="w-full" variant="secondary" disabled>
            <CheckCircle2 className="w-4 h-4 mr-2" />
            {mDict.requestPending || "Request Pending"}
          </Button>
        ) : (
          <Button className="w-full" variant="default" onClick={() => onRequestMentorship(mentor.id)}>
            {mDict.requestMentorship || "Request Mentorship"}
          </Button>
        )}
        <Button className="w-full" variant="outline" onClick={() => onViewProfile(mentor)}>
          {mDict.viewProfile || "View Profile"}
        </Button>
      </CardFooter>
    </Card>
  )
}
