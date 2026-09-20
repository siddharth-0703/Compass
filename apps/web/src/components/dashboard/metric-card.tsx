"use client"

import { ReactNode } from "react"
import { Card, CardContent, CardHeader, CardTitle } from "@/components/ui/card"
import { cn } from "@/lib/utils"
import { motion } from "framer-motion"
import { LineChart, Line, ResponsiveContainer } from "recharts"
import { TrendingUp, TrendingDown } from "lucide-react"

interface MetricCardProps {
  title: string
  value: string | number
  trend?: string
  trendValue?: number
  icon?: ReactNode
  className?: string
  sparklineData?: any[]
}

export function MetricCard({ title, value, trend, trendValue, icon, className, sparklineData }: MetricCardProps) {
  const isPositive = (trendValue || 0) > 0
  const isNegative = (trendValue || 0) < 0
  
  // Default sparkline data if none provided
  const data = sparklineData || [
    { value: 40 }, { value: 30 }, { value: 45 }, { value: 50 }, { value: 45 }, { value: 60 }, { value: isPositive ? 80 : 30 }
  ]

  const strokeColor = isPositive ? "hsl(var(--success))" : isNegative ? "hsl(var(--destructive))" : "hsl(var(--primary))"

  return (
    <motion.div whileHover={{ translateY: -6 }} transition={{ duration: 0.2 }}>
      <Card className={cn("glass-card relative overflow-hidden group h-full border border-white/10", className)}>
        <div className="absolute top-0 right-0 -mt-4 -mr-4 h-24 w-24 rounded-full bg-primary/10 blur-2xl transition-all duration-500 group-hover:bg-primary/20" />
        <CardHeader className="flex flex-row items-center justify-between space-y-0 pb-2 relative z-10">
          <CardTitle className="text-sm font-semibold text-muted-foreground uppercase tracking-wider">{title}</CardTitle>
          {icon && <div className="text-primary/80 bg-primary/10 p-2 rounded-lg">{icon}</div>}
        </CardHeader>
        <CardContent className="relative z-10">
          <div className="flex justify-between items-end mt-2">
            <div>
              <div className="text-3xl font-bold tracking-tight text-foreground">{value}</div>
              {trend && (
                <p className="text-xs mt-2 flex items-center font-medium">
                  <span className={cn(
                    "mr-1.5 flex items-center px-1.5 py-0.5 rounded-full text-[10px]",
                    isPositive ? "bg-success/10 text-success" : isNegative ? "bg-destructive/10 text-destructive" : "bg-muted text-muted-foreground"
                  )}>
                    {isPositive ? <TrendingUp className="w-3 h-3 mr-1" /> : isNegative ? <TrendingDown className="w-3 h-3 mr-1" /> : null}
                    {Math.abs(trendValue || 0)}%
                  </span>
                  <span className="text-muted-foreground">{trend}</span>
                </p>
              )}
            </div>
            
            {/* Sparkline */}
            <div className="h-[40px] w-[80px] opacity-70 group-hover:opacity-100 transition-opacity">
              <ResponsiveContainer width="100%" height="100%">
                <LineChart data={data}>
                  <Line 
                    type="monotone" 
                    dataKey="value" 
                    stroke={strokeColor} 
                    strokeWidth={2} 
                    dot={false}
                    isAnimationActive={true}
                  />
                </LineChart>
              </ResponsiveContainer>
            </div>
          </div>
        </CardContent>
      </Card>
    </motion.div>
  )
}
