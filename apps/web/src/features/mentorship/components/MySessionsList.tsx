"use client"

import { MentorshipSession } from "../types"
import { useDictionary } from "@/components/providers/DictionaryProvider"
import { Card, CardContent } from "@/components/ui/card"
import { Badge } from "@/components/ui/badge"
import { Button } from "@/components/ui/button"
import { Calendar, Clock, Video, FileText } from "lucide-react"

interface MySessionsListProps {
  sessions: MentorshipSession[];
}

export function MySessionsList({ sessions }: MySessionsListProps) {
  const { dict } = useDictionary()
  const mDict = dict.mentorship || {}

  if (sessions.length === 0) {
    return (
      <div className="text-center py-12 bg-card rounded-lg border border-dashed">
        <Calendar className="mx-auto h-12 w-12 text-muted-foreground/50 mb-4" />
        <h3 className="text-lg font-medium">{mDict.noMentorsFound || "No sessions found"}</h3>
        <p className="text-muted-foreground">{mDict.noMentorsDesc || "You haven't requested any mentorship sessions yet."}</p>
      </div>
    )
  }

  const getStatusColor = (status: string) => {
    switch (status) {
      case 'Requested':
      case 'Pending':
        return 'bg-yellow-500/10 text-yellow-500 border-yellow-500/20'
      case 'Accepted':
      case 'Scheduled':
      case 'Rescheduled':
        return 'bg-blue-500/10 text-blue-500 border-blue-500/20'
      case 'In Progress':
        return 'bg-purple-500/10 text-purple-500 border-purple-500/20'
      case 'Completed':
        return 'bg-green-500/10 text-green-500 border-green-500/20'
      case 'Rejected':
      case 'Cancelled':
      case 'No Show':
        return 'bg-red-500/10 text-red-500 border-red-500/20'
      default:
        return 'bg-secondary text-secondary-foreground'
    }
  }

  return (
    <div className="space-y-4">
      {sessions.map((session) => {
        const dateObj = session.scheduledAt ? new Date(session.scheduledAt) : null
        const dateStr = dateObj ? dateObj.toLocaleDateString() : 'TBD'
        const timeStr = dateObj ? dateObj.toLocaleTimeString([], { hour: '2-digit', minute: '2-digit' }) : 'TBD'
        
        // Use dictionary for status localization, fallback to raw status
        const localizedStatus = (mDict.status as any)?.[session.status] || session.status

        return (
          <Card key={session.id}>
            <CardContent className="p-4 sm:p-6 flex flex-col sm:flex-row gap-4 justify-between items-start sm:items-center">
              <div className="space-y-2 flex-1">
                <div className="flex items-center gap-2">
                  <Badge variant="outline" className={getStatusColor(session.status)}>
                    {localizedStatus}
                  </Badge>
                  <span className="text-sm font-medium text-muted-foreground">
                    {mDict.idPrefix || "ID:"} {session.id.substring(session.id.length - 6).toUpperCase()}
                  </span>
                </div>
                
                <h4 className="font-semibold text-lg line-clamp-1">
                  {mDict.sessionRegarding || "Session regarding:"} {session.goals?.[0] || mDict.generalMentorship || "General Mentorship"}
                </h4>
                
                <div className="flex flex-wrap items-center gap-4 text-sm text-muted-foreground">
                  <div className="flex items-center gap-1">
                    <Calendar className="h-4 w-4" />
                    {dateStr}
                  </div>
                  <div className="flex items-center gap-1">
                    <Clock className="h-4 w-4" />
                    {timeStr} ({session.durationMinutes} min)
                  </div>
                  <div className="flex items-center gap-1">
                    <Video className="h-4 w-4" />
                    {session.meetingPlatform}
                  </div>
                </div>
              </div>

              <div className="flex flex-col sm:items-end gap-2 w-full sm:w-auto">
                {session.canJoin && session.meetingLink && (
                  <Button className="w-full sm:w-auto gap-2" onClick={() => window.open(session.meetingLink, '_blank')}>
                    <Video className="h-4 w-4" />
                    {mDict.joinMeeting || "Join Meeting"}
                  </Button>
                )}
                
                {session.status === 'Completed' && session.notes && (
                  <Button variant="outline" size="sm" className="w-full sm:w-auto gap-2">
                    <FileText className="h-4 w-4" />
                    {mDict.viewNotes || "View Notes"}
                  </Button>
                )}
              </div>
            </CardContent>
          </Card>
        )
      })}
    </div>
  )
}
