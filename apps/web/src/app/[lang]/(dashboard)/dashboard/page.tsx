"use client"

import { HeroBanner } from "@/components/dashboard/hero-banner"
import { MetricCard } from "@/components/dashboard/metric-card"
import { QuickActions } from "@/components/dashboard/quick-actions"
import { CommunityWidget } from "@/components/dashboard/community-widget"
import { LearningWidget } from "@/components/dashboard/learning-widget"
import { Building2, GraduationCap, Users } from "lucide-react"
import { useDictionary } from "@/components/providers/DictionaryProvider"

export default function DashboardPage() {
  const { dict } = useDictionary()

  return (
    <div className="flex-1 space-y-8 p-4 md:p-8 pt-6 max-w-7xl mx-auto w-full">
      
      {/* 1. Hero Intelligence Banner */}
      <HeroBanner />

      {/* 2. Quick Actions */}
      <div className="space-y-4">
        <h2 className="text-xl font-bold tracking-tight">{dict.dashboard?.quickActions || "Quick Actions"}</h2>
        <QuickActions />
      </div>

      {/* 3. Business Health (Metrics) */}
      <div className="space-y-4">
        <h2 className="text-xl font-bold tracking-tight">{dict.dashboard?.businessHealth || "Business Health"}</h2>
        <div className="grid gap-4 md:grid-cols-2 lg:grid-cols-3">
          <MetricCard
            title={dict.dashboard?.activeBusinesses || "Active Businesses"}
            value="42"
            trend={dict.dashboard?.fromLastMonth || "from last month"}
            trendValue={12}
            icon={<Building2 className="h-4 w-4" />}
            sparklineData={[{value: 30}, {value: 35}, {value: 32}, {value: 38}, {value: 40}, {value: 42}]}
          />
          <MetricCard
            title={dict.dashboard?.communityMembers || "Community Members"}
            value="1,248"
            trend={dict.dashboard?.fromLastWeek || "from last week"}
            trendValue={24}
            icon={<Users className="h-4 w-4" />}
            sparklineData={[{value: 1000}, {value: 1050}, {value: 1100}, {value: 1150}, {value: 1200}, {value: 1248}]}
          />
          <MetricCard
            title={dict.dashboard?.learningHours || "Learning Hours"}
            value="320"
            trend={dict.dashboard?.newHoursLogged || "new hours logged"}
            trendValue={5}
            icon={<GraduationCap className="h-4 w-4" />}
            sparklineData={[{value: 200}, {value: 220}, {value: 250}, {value: 280}, {value: 300}, {value: 320}]}
          />
        </div>
      </div>

      {/* 5. Engagement & Growth Grid */}
      <div className="grid gap-6 md:grid-cols-2 lg:grid-cols-12">
        <div className="lg:col-span-5">
          <LearningWidget />
        </div>
        <div className="lg:col-span-7">
          <CommunityWidget />
        </div>
      </div>
      
    </div>
  )
}
