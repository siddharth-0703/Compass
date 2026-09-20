"use client"

import { motion } from "framer-motion"
import { Users, ArrowRight, MessageSquare, ThumbsUp } from "lucide-react"
import { Button } from "@/components/ui/button"
import { useDictionary } from "@/components/providers/DictionaryProvider"

const discussions = [
  { id: 1, author: "Rajesh Kumar", role: "Farmer", topic: "Best organic pesticide for tomato crops?", likes: 24, replies: 12, time: "2h ago" },
  { id: 2, author: "Anita Devi", role: "Artisan", topic: "Looking for bulk buyers for handmade bamboo baskets.", likes: 45, replies: 8, time: "5h ago" },
]

export function CommunityWidget() {
  const { dict } = useDictionary()
  const t = dict.dashboard?.communityWidget || {}

  return (
    <div className="glass-panel rounded-3xl p-6 border border-white/10 flex flex-col h-full">
      <div className="flex justify-between items-center mb-6">
        <div className="flex items-center gap-2">
          <div className="p-2 bg-purple-500/10 text-purple-500 rounded-lg">
            <Users className="w-5 h-5" />
          </div>
          <h3 className="text-xl font-bold">{t.title || "Community Feed"}</h3>
        </div>
        <Button variant="ghost" size="sm" className="text-muted-foreground hover:text-foreground">
          {t.viewAll || "View All"} <ArrowRight className="w-4 h-4 ml-1" />
        </Button>
      </div>

      <div className="space-y-4 flex-1">
        {discussions.map((post, idx) => (
          <motion.div 
            key={post.id}
            initial={{ opacity: 0, x: 10 }}
            animate={{ opacity: 1, x: 0 }}
            transition={{ delay: 0.3 + (idx * 0.1) }}
            className="p-4 rounded-2xl bg-background/50 border border-white/5 hover:bg-background/80 transition-colors cursor-pointer group"
          >
            <div className="flex items-center gap-2 mb-2">
              <div className="w-6 h-6 rounded-full bg-primary/20 text-primary flex items-center justify-center text-[10px] font-bold">
                {post.author.charAt(0)}
              </div>
              <span className="text-xs font-semibold">{t.posts?.[post.id]?.author || post.author}</span>
              <span className="text-[10px] text-muted-foreground bg-muted px-1.5 py-0.5 rounded-full">{t.posts?.[post.id]?.role || post.role}</span>
              <span className="text-[10px] text-muted-foreground ml-auto">{t.posts?.[post.id]?.time || post.time}</span>
            </div>
            
            <p className="text-sm text-foreground font-medium mb-3 group-hover:text-primary transition-colors">
              {t.posts?.[post.id]?.topic || post.topic}
            </p>
            
            <div className="flex items-center gap-4 text-xs text-muted-foreground">
              <div className="flex items-center gap-1 hover:text-foreground">
                <ThumbsUp className="w-3 h-3" /> {post.likes}
              </div>
              <div className="flex items-center gap-1 hover:text-foreground">
                <MessageSquare className="w-3 h-3" /> {post.replies} {t.replies || "Replies"}
              </div>
            </div>
          </motion.div>
        ))}
      </div>
    </div>
  )
}
