"use client"

import { useAuthStore } from "@/features/auth/stores/auth.store"
import { Badge } from "@/components/ui/badge"
import { motion } from "framer-motion"
import { Sparkles, TrendingUp, CloudSun, Target, BookOpen } from "lucide-react"
import { useState, useEffect } from "react"
import { useDictionary } from "@/components/providers/DictionaryProvider"

export function HeroBanner() {
  const user = useAuthStore((state) => state.user)
  const [mounted, setMounted] = useState(false)
  const { dict } = useDictionary()

  useEffect(() => {
    setMounted(true)
  }, [])

  return (
    <motion.div 
      initial={{ opacity: 0, y: 20 }}
      animate={{ opacity: 1, y: 0 }}
      transition={{ duration: 0.6, ease: "easeOut" }}
      className="relative overflow-hidden rounded-3xl p-8 mb-8 shadow-2xl border border-white/10 bg-card"
    >
      {/* Background Layer: Authentic Rural Image with Glass Overlay & Vignette */}
      <div 
        className="absolute inset-0 bg-cover bg-center opacity-[0.18] mix-blend-luminosity dark:mix-blend-overlay dark:opacity-[0.25]"
        style={{ backgroundImage: "url('/hero-image-1.jpg')" }}
      />
      {/* Gradients and vignette */}
      <div className="absolute inset-0 bg-gradient-to-br from-background/90 via-background/60 to-transparent z-0" />
      <div className="absolute inset-0 shadow-[inset_0_0_100px_rgba(0,0,0,0.5)] opacity-50 z-0 pointer-events-none" />
      <div className="absolute -top-40 -right-40 w-[600px] h-[600px] bg-primary/20 rounded-full blur-[120px] pointer-events-none z-0" />

      <div className="relative z-10 flex flex-col lg:flex-row justify-between gap-8">
        
        {/* Left Side: Welcome & AI Insight */}
        <div className="flex-1 space-y-6">
          <div className="inline-flex items-center space-x-2 bg-white/5 border border-white/10 rounded-full px-4 py-1.5 shadow-sm backdrop-blur-md">
            <Sparkles className="w-4 h-4 text-primary" />
            <span className="text-xs font-semibold uppercase tracking-widest text-muted-foreground">
              {dict.dashboard?.aiCommandCenter || "AI Business Command Center"}
            </span>
          </div>
          
          <div>
            <h1 className="text-4xl md:text-5xl font-extrabold tracking-tight mb-3">
              {dict.dashboard?.welcome || "Welcome back"}, {" "}
              <span className="bg-gradient-to-r from-primary to-secondary bg-clip-text text-transparent">
                {mounted ? (user?.firstName || user?.lastName || 'Siddharth') : 'Siddharth'}
              </span>
            </h1>
            
            <motion.div 
              initial={{ opacity: 0, x: -20 }}
              animate={{ opacity: 1, x: 0 }}
              transition={{ delay: 0.3 }}
              className="mt-6 p-4 rounded-xl bg-primary/5 border border-primary/20 max-w-2xl backdrop-blur-md"
            >
              <div className="flex gap-3">
                <Sparkles className="h-5 w-5 text-primary shrink-0 mt-0.5" />
                <div>
                  <h4 className="text-sm font-semibold mb-1 text-foreground">{dict.dashboard?.todaysRecommendation || "Today's AI Recommendation"}</h4>
                  <p className="text-sm text-muted-foreground">
                    {dict.dashboard?.aiInsightText || '"Organic millet demand is increasing in Maharashtra. Based on your profile, consider increasing your inventory. 3 new Government Schemes also match your business."'}
                  </p>
                </div>
              </div>
            </motion.div>
          </div>
        </div>

        {/* Right Side: Quick Intelligence Stats */}
        <div className="grid grid-cols-2 gap-4 w-full lg:w-auto shrink-0">
          
          {/* Stat 1: Business Score */}
          <div className="glass-card p-4 rounded-2xl flex flex-col justify-center bg-card/40 backdrop-blur-md border border-white/10">
            <p className="text-xs font-medium text-muted-foreground mb-1 uppercase tracking-wider">{dict.dashboard?.businessScore || "Business Score"}</p>
            <div className="flex items-end gap-2">
              <span className="text-3xl font-bold text-foreground">92</span>
              <span className="text-sm text-muted-foreground mb-1">/100</span>
            </div>
            <div className="mt-2 w-full h-1.5 bg-muted rounded-full overflow-hidden">
              <motion.div initial={{ width: 0 }} animate={{ width: "92%" }} transition={{ duration: 1, delay: 0.5 }} className="h-full bg-success" />
            </div>
          </div>

          {/* Stat 2: Marketplace Demand */}
          <div className="glass-card p-4 rounded-2xl flex flex-col justify-center bg-card/40 backdrop-blur-md border border-white/10">
            <div className="flex justify-between items-start mb-1">
              <p className="text-xs font-medium text-muted-foreground uppercase tracking-wider">{dict.dashboard?.marketDemand || "Market Demand"}</p>
              <TrendingUp className="h-4 w-4 text-primary" />
            </div>
            <div className="flex items-center gap-2">
              <span className="text-3xl font-bold text-foreground">{dict.dashboard?.high || "High"}</span>
            </div>
            <p className="text-xs text-primary font-medium mt-1 flex items-center">
              {dict.dashboard?.demandTrend || "↑ 14% this week"}
            </p>
          </div>

          {/* Stat 3: Weather */}
          <div className="glass-card p-4 rounded-2xl flex flex-col justify-center bg-card/40 backdrop-blur-md border border-white/10">
            <div className="flex justify-between items-start mb-1">
              <p className="text-xs font-medium text-muted-foreground uppercase tracking-wider">{dict.dashboard?.weather || "Weather"}</p>
              <CloudSun className="h-4 w-4 text-secondary" />
            </div>
            <div className="flex items-end gap-1">
              <span className="text-3xl font-bold text-foreground">28°C</span>
            </div>
            <p className="text-xs text-muted-foreground mt-1">{dict.dashboard?.weatherDesc || "Ideal for harvesting"}</p>
          </div>

          {/* Stat 4: Scheme Matches */}
          <div className="glass-card p-4 rounded-2xl flex flex-col justify-center bg-card/40 backdrop-blur-md border border-white/10">
            <div className="flex justify-between items-start mb-1">
              <p className="text-xs font-medium text-muted-foreground uppercase tracking-wider">{dict.dashboard?.schemeMatches || "Scheme Matches"}</p>
              <Target className="h-4 w-4 text-accent-foreground" />
            </div>
            <span className="text-3xl font-bold text-foreground">3</span>
            <p className="text-xs text-accent-foreground font-medium mt-1">{dict.dashboard?.applyByFriday || "Apply by Friday"}</p>
          </div>

        </div>
      </div>
    </motion.div>
  )
}
