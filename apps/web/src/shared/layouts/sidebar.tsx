"use client"

import Link from "next/link"
import { usePathname } from "next/navigation"
import { cn } from "@/lib/utils"
import { navigationConfig } from "@/config/navigation"
import { useAuthStore } from "@/features/auth/stores/auth.store"
import { useState, useEffect } from "react"
import { CompassLogo } from "@/components/shared/CompassLogo"
import { useDictionary } from "@/components/providers/DictionaryProvider"

// Helper to get translation key from English title
function getTranslationKey(title: string): string {
  const map: Record<string, string> = {
    "Overview": "overview",
    "Management": "management",
    "System": "system",
    "AI & Content": "aiAndContent",
    "Dashboard": "dashboard",
    "Settings": "settings",
    "Businesses": "businesses",
    "Mentorship": "mentor",
    "Schemes": "schemes",
    "Market Prices": "mandi",
    "Learning Hub": "learning"
  };
  return map[title] || title;
}

export function Sidebar() {
  const pathname = usePathname()
  const user = useAuthStore((state) => state.user)
  const [mounted, setMounted] = useState(false)
  const { dict, lang } = useDictionary()

  useEffect(() => {
    setMounted(true)
  }, [])

  // In case the backend sends an array of roles or a single string
  const userRoles = user 
    ? (Array.isArray((user as any).roles) ? (user as any).roles : [user.role || 'entrepreneur'])
    : []

  return (
    <div className="flex h-full w-64 flex-col border-r border-border/50 bg-background/60 backdrop-blur-xl">
      <div className="flex h-16 items-center px-6 gap-3">
        <CompassLogo size={24} className="text-teal-500" />
        <span className="font-bold text-xl tracking-tight bg-gradient-to-r from-teal-400 to-blue-500 bg-clip-text text-transparent">
          {dict.common?.compassTitle || "Compass"}
        </span>
      </div>
      <div className="flex-1 overflow-auto py-4">
        {mounted && navigationConfig.map((group, i) => {
          // Filter items based on user roles
          const items = group.items.filter(item => 
            item.roles.some(role => userRoles.includes(role))
          )
          
          if (items.length === 0) return null

          const groupTitle = dict.common?.[getTranslationKey(group.title)] || group.title;

          return (
            <div key={i} className="mb-6 px-4">
              <h4 className="mb-2 px-2 text-xs font-semibold uppercase tracking-wider text-muted-foreground/70">
                {groupTitle}
              </h4>
              <nav className="grid gap-1">
                {items.map((item, index) => {
                  const Icon = item.icon
                  
                  // Construct locale-aware href
                  let href = item.href;
                  if (href.startsWith('/dashboard')) {
                    href = `/${lang}${href}`;
                  }

                  const isActive = pathname === href || (href !== `/${lang}` && pathname.startsWith(`${href}/`))
                  const key = getTranslationKey(item.title);
                  const itemTitle = dict.navigation?.[key] || dict.common?.[key] || item.title;

                  return (
                    <Link key={index} href={href}>
                      <span
                        className={cn(
                          "group flex items-center rounded-lg px-3 py-2 text-sm font-medium transition-all duration-200",
                          isActive 
                            ? "bg-primary/10 text-primary" 
                            : "text-muted-foreground hover:bg-accent/50 hover:text-foreground"
                        )}
                      >
                        <Icon className={cn(
                          "mr-3 h-4 w-4 transition-transform duration-200 group-hover:scale-110",
                          isActive ? "text-primary" : "text-muted-foreground"
                        )} />
                        <span>{itemTitle}</span>
                      </span>
                    </Link>
                  )
                })}
              </nav>
            </div>
          )
        })}
      </div>
    </div>
  )
}
