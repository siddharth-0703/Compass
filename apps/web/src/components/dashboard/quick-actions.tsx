"use client"

import { motion } from "framer-motion"
import { Building2, GraduationCap, HeartHandshake, Sparkles } from "lucide-react"
import Link from "next/link"

import { useDictionary } from "@/components/providers/DictionaryProvider"

const actions = [
  {
    titleKey: "registerBusiness",
    icon: Building2,
    href: "/dashboard/businesses/new",
    color: "from-emerald-500/10 to-teal-500/10",
    hoverColor: "hover:from-emerald-500/20 hover:to-teal-500/20",
    textColor: "text-emerald-500",
  },
  {
    titleKey: "applyScheme",
    icon: HeartHandshake,
    href: "/dashboard/schemes",
    color: "from-blue-500/10 to-indigo-500/10",
    hoverColor: "hover:from-blue-500/20 hover:to-indigo-500/20",
    textColor: "text-blue-500",
  },
  {
    titleKey: "startLearning",
    icon: GraduationCap,
    href: "/dashboard/learning",
    color: "from-purple-500/10 to-fuchsia-500/10",
    hoverColor: "hover:from-purple-500/20 hover:to-fuchsia-500/20",
    textColor: "text-purple-500",
  },
  {
    titleKey: "talkToAi",
    icon: Sparkles,
    href: "/dashboard/ai-assistant",
    color: "from-primary/10 to-secondary/10",
    hoverColor: "hover:from-primary/20 hover:to-secondary/20",
    textColor: "text-primary",
  },
]

export function QuickActions() {
  const { dict, lang } = useDictionary()

  return (
    <div className="grid grid-cols-2 md:grid-cols-4 gap-4 mb-8">
      {actions.map((action, index) => {
        const Icon = action.icon
        const title = dict.dashboard?.[action.titleKey] || action.titleKey
        return (
          <Link key={action.titleKey} href={`/${lang}${action.href}`}>
            <motion.div
              whileHover={{ translateY: -6 }}
              className={`glass-card p-6 rounded-2xl flex flex-col items-center justify-center text-center space-y-3 cursor-pointer bg-gradient-to-br ${action.color} ${action.hoverColor} transition-colors border border-white/10 h-full`}
            >
              <div className={`p-4 rounded-full bg-background/50 shadow-sm ${action.textColor}`}>
                <Icon className="w-8 h-8" />
              </div>
              <span className="font-semibold text-sm">{title}</span>
            </motion.div>
          </Link>
        )
      })}
    </div>
  )
}
