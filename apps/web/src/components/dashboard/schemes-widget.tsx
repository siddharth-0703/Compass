"use client"

import { motion } from "framer-motion"
import { HeartHandshake, ArrowRight, Clock, CheckCircle2 } from "lucide-react"
import { Button } from "@/components/ui/button"

const schemes = [
  { 
    id: 1, 
    title: "PMFME Scheme", 
    description: "Financial, technical and business support for micro food processing enterprises.",
    matchScore: 98,
    deadline: "2026-09-30",
    status: "Highly Recommended"
  },
  { 
    id: 2, 
    title: "NABARD Agri-Clinic", 
    description: "Subsidy on capital costs for starting clinic/agribusiness center.",
    matchScore: 85,
    deadline: "2026-10-15",
    status: "Eligible"
  },
]

export function SchemesWidget() {
  return (
    <div className="glass-panel rounded-3xl p-6 border border-white/10 flex flex-col h-full">
      <div className="flex justify-between items-center mb-6">
        <div className="flex items-center gap-2">
          <div className="p-2 bg-blue-500/10 text-blue-500 rounded-lg">
            <HeartHandshake className="w-5 h-5" />
          </div>
          <h3 className="text-xl font-bold">Government Schemes</h3>
        </div>
        <Button variant="ghost" size="sm" className="text-muted-foreground hover:text-foreground">
          View All <ArrowRight className="w-4 h-4 ml-1" />
        </Button>
      </div>

      <div className="space-y-4 flex-1">
        {schemes.map((scheme, idx) => (
          <motion.div 
            key={scheme.id}
            initial={{ opacity: 0, y: 10 }}
            animate={{ opacity: 1, y: 0 }}
            transition={{ delay: 0.2 + (idx * 0.1) }}
            className="p-4 rounded-2xl bg-background/50 border border-white/5 hover:bg-background/80 transition-colors"
          >
            <div className="flex justify-between items-start mb-2">
              <h4 className="font-semibold text-foreground">{scheme.title}</h4>
              <div className="flex items-center gap-1 bg-success/10 text-success px-2 py-0.5 rounded-full text-xs font-semibold">
                <CheckCircle2 className="w-3 h-3" />
                {scheme.matchScore}% Match
              </div>
            </div>
            
            <p className="text-sm text-muted-foreground line-clamp-2 mb-4">
              {scheme.description}
            </p>
            
            <div className="flex items-center justify-between mt-auto">
              <div className="flex items-center gap-1 text-xs text-muted-foreground">
                <Clock className="w-3 h-3" />
                Due {(() => {
                  const [year, month, day] = scheme.deadline.split("-")
                  const months = ["Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"]
                  return `${day} ${months[parseInt(month, 10) - 1]}, ${year}`
                })()}
              </div>
              <Button size="sm" className="h-8 text-xs rounded-full">Apply Now</Button>
            </div>
          </motion.div>
        ))}
      </div>
    </div>
  )
}
