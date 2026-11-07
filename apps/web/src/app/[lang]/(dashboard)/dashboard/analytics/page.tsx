"use client";

import React, { useState } from "react";
import {
  TrendingUp,
  Users,
  Building2,
  DollarSign,
  Award,
  ArrowUpRight,
  ArrowDownRight,
  Download,
  Calendar,
} from "lucide-react";
import {
  AreaChart,
  Area,
  BarChart,
  Bar,
  PieChart,
  Pie,
  Cell,
  XAxis,
  YAxis,
  CartesianGrid,
  Tooltip,
  ResponsiveContainer,
  Legend,
} from "recharts";
import { Button } from "@/components/ui/button";
import { Card, CardContent, CardHeader, CardTitle, CardDescription } from "@/components/ui/card";
import { Select, SelectContent, SelectItem, SelectTrigger, SelectValue } from "@/components/ui/select";

const REVENUE_DATA = [
  { month: "Jan", volume: 18.5, businesses: 420 },
  { month: "Feb", volume: 22.1, businesses: 580 },
  { month: "Mar", volume: 27.4, businesses: 790 },
  { month: "Apr", volume: 31.8, businesses: 1050 },
  { month: "May", volume: 38.2, businesses: 1420 },
  { month: "Jun", volume: 42.8, businesses: 1842 },
];

const SECTOR_DATA = [
  { name: "Agri-Processing", value: 38, color: "#10b981" },
  { name: "Dairy & Livestock", value: 26, color: "#3b82f6" },
  { name: "Handicrafts & Handloom", value: 18, color: "#8b5cf6" },
  { name: "Food & Spices", value: 12, color: "#f59e0b" },
  { name: "Renewable & Rural Tech", value: 6, color: "#06b6d4" },
];

const SCHEME_DATA = [
  { name: "PM-KMY Pension", applied: 145, approved: 128 },
  { name: "PMMY Mudra Shishu", applied: 230, approved: 194 },
  { name: "NABARD Rural Agri", applied: 95, approved: 82 },
  { name: "Stand-Up India SC/ST", applied: 88, approved: 71 },
  { name: "PM Formalisation (FME)", applied: 110, approved: 92 },
];

const REGIONAL_STATS = [
  { state: "Maharashtra", enterprises: 684, disbursement: "₹48.2 L", growth: "+22%" },
  { state: "Madhya Pradesh", enterprises: 412, disbursement: "₹29.6 L", growth: "+18%" },
  { state: "Gujarat", enterprises: 326, disbursement: "₹24.1 L", growth: "+14%" },
  { state: "Karnataka", enterprises: 248, disbursement: "₹18.5 L", growth: "+11%" },
  { state: "Uttar Pradesh", enterprises: 172, disbursement: "₹12.8 L", growth: "+9%" },
];

export default function AnalyticsPage() {
  const [timeRange, setTimeRange] = useState("6m");

  return (
    <div className="flex-1 space-y-6 p-4 md:p-8 pt-6 max-w-7xl mx-auto w-full">
      {/* Page Header */}
      <div className="flex flex-col sm:flex-row sm:items-center justify-between gap-4">
        <div>
          <h1 className="text-3xl font-bold tracking-tight text-foreground">Platform Analytics</h1>
          <p className="text-muted-foreground text-sm mt-1">
            Ecosystem growth, financial disbursement, scheme adoption, and sector benchmarks.
          </p>
        </div>

        <div className="flex items-center gap-3">
          <Select value={timeRange} onValueChange={(val) => { if (val) setTimeRange(val); }}>
            <SelectTrigger className="w-36 h-9 text-xs">
              <Calendar className="mr-2 h-3.5 w-3.5" />
              <SelectValue placeholder="Period" />
            </SelectTrigger>
            <SelectContent>
              <SelectItem value="1m">Last 30 Days</SelectItem>
              <SelectItem value="3m">Last 3 Months</SelectItem>
              <SelectItem value="6m">Last 6 Months</SelectItem>
              <SelectItem value="1y">Year to Date</SelectItem>
            </SelectContent>
          </Select>

          <Button variant="outline" size="sm" className="h-9 text-xs gap-1.5">
            <Download className="h-3.5 w-3.5" />
            Export Report
          </Button>
        </div>
      </div>

      {/* Primary KPI Grid */}
      <div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-4 gap-4">
        <Card className="border border-border/60 bg-card/80 backdrop-blur-sm shadow-sm">
          <CardHeader className="flex flex-row items-center justify-between space-y-0 pb-2">
            <CardTitle className="text-sm font-medium text-muted-foreground">Marketplace Volume</CardTitle>
            <DollarSign className="h-4 w-4 text-emerald-500" />
          </CardHeader>
          <CardContent>
            <div className="text-2xl font-bold text-foreground">₹42.8 Lakh</div>
            <div className="flex items-center text-xs text-emerald-600 dark:text-emerald-400 font-medium mt-1">
              <ArrowUpRight className="h-3.5 w-3.5 mr-0.5" />
              +18.4% from last period
            </div>
          </CardContent>
        </Card>

        <Card className="border border-border/60 bg-card/80 backdrop-blur-sm shadow-sm">
          <CardHeader className="flex flex-row items-center justify-between space-y-0 pb-2">
            <CardTitle className="text-sm font-medium text-muted-foreground">Active Entrepreneurs</CardTitle>
            <Users className="h-4 w-4 text-blue-500" />
          </CardHeader>
          <CardContent>
            <div className="text-2xl font-bold text-foreground">1,842</div>
            <div className="flex items-center text-xs text-emerald-600 dark:text-emerald-400 font-medium mt-1">
              <ArrowUpRight className="h-3.5 w-3.5 mr-0.5" />
              +124 newly registered
            </div>
          </CardContent>
        </Card>

        <Card className="border border-border/60 bg-card/80 backdrop-blur-sm shadow-sm">
          <CardHeader className="flex flex-row items-center justify-between space-y-0 pb-2">
            <CardTitle className="text-sm font-medium text-muted-foreground">Scheme Success Rate</CardTitle>
            <Award className="h-4 w-4 text-purple-500" />
          </CardHeader>
          <CardContent>
            <div className="text-2xl font-bold text-foreground">84.2%</div>
            <div className="flex items-center text-xs text-emerald-600 dark:text-emerald-400 font-medium mt-1">
              <ArrowUpRight className="h-3.5 w-3.5 mr-0.5" />
              567 subsidies sanctioned
            </div>
          </CardContent>
        </Card>

        <Card className="border border-border/60 bg-card/80 backdrop-blur-sm shadow-sm">
          <CardHeader className="flex flex-row items-center justify-between space-y-0 pb-2">
            <CardTitle className="text-sm font-medium text-muted-foreground">Avg. Mandi Premium</CardTitle>
            <TrendingUp className="h-4 w-4 text-amber-500" />
          </CardHeader>
          <CardContent>
            <div className="text-2xl font-bold text-foreground">+14.2%</div>
            <div className="flex items-center text-xs text-emerald-600 dark:text-emerald-400 font-medium mt-1">
              <ArrowUpRight className="h-3.5 w-3.5 mr-0.5" />
              Above local wholesale MSP
            </div>
          </CardContent>
        </Card>
      </div>

      {/* Main Charts Row */}
      <div className="grid grid-cols-1 lg:grid-cols-7 gap-6">
        {/* Growth Trends */}
        <Card className="lg:col-span-4 border border-border/60 bg-card/80 backdrop-blur-sm shadow-sm">
          <CardHeader>
            <CardTitle className="text-base font-semibold">Growth & Platform Adoption</CardTitle>
            <CardDescription>Monthly transaction volume (₹ Lakh) and registered businesses</CardDescription>
          </CardHeader>
          <CardContent className="h-72">
            <ResponsiveContainer width="100%" height="100%">
              <AreaChart data={REVENUE_DATA} margin={{ top: 10, right: 10, left: -20, bottom: 0 }}>
                <defs>
                  <linearGradient id="volumeGrad" x1="0" y1="0" x2="0" y2="1">
                    <stop offset="5%" stopColor="#10b981" stopOpacity={0.4} />
                    <stop offset="95%" stopColor="#10b981" stopOpacity={0.0} />
                  </linearGradient>
                </defs>
                <CartesianGrid strokeDasharray="3 3" opacity={0.15} />
                <XAxis dataKey="month" stroke="#888888" fontSize={12} tickLine={false} />
                <YAxis stroke="#888888" fontSize={12} tickLine={false} />
                <Tooltip
                  contentStyle={{
                    backgroundColor: "rgba(15, 23, 42, 0.9)",
                    border: "1px solid rgba(255,255,255,0.1)",
                    borderRadius: "8px",
                    color: "#fff",
                  }}
                />
                <Area type="monotone" dataKey="volume" name="Volume (₹ Lakh)" stroke="#10b981" strokeWidth={2.5} fillOpacity={1} fill="url(#volumeGrad)" />
              </AreaChart>
            </ResponsiveContainer>
          </CardContent>
        </Card>

        {/* Sector Breakdown */}
        <Card className="lg:col-span-3 border border-border/60 bg-card/80 backdrop-blur-sm shadow-sm">
          <CardHeader>
            <CardTitle className="text-base font-semibold">Enterprises by Sector</CardTitle>
            <CardDescription>Distribution of rural businesses on the platform</CardDescription>
          </CardHeader>
          <CardContent className="h-72 flex flex-col justify-center">
            <ResponsiveContainer width="100%" height="70%">
              <PieChart>
                <Pie data={SECTOR_DATA} cx="50%" cy="50%" innerRadius={50} outerRadius={75} paddingAngle={4} dataKey="value">
                  {SECTOR_DATA.map((entry, index) => (
                    <Cell key={`cell-${index}`} fill={entry.color} />
                  ))}
                </Pie>
                <Tooltip />
              </PieChart>
            </ResponsiveContainer>
            <div className="grid grid-cols-2 gap-2 text-xs mt-2">
              {SECTOR_DATA.map((item) => (
                <div key={item.name} className="flex items-center gap-1.5">
                  <span className="h-2 w-2 rounded-full" style={{ backgroundColor: item.color }} />
                  <span className="text-muted-foreground truncate">{item.name}</span>
                  <span className="font-semibold text-foreground ml-auto">{item.value}%</span>
                </div>
              ))}
            </div>
          </CardContent>
        </Card>
      </div>

      {/* Secondary Row: Scheme Performance & Regional Table */}
      <div className="grid grid-cols-1 lg:grid-cols-7 gap-6">
        {/* Scheme Application Performance */}
        <Card className="lg:col-span-4 border border-border/60 bg-card/80 backdrop-blur-sm shadow-sm">
          <CardHeader>
            <CardTitle className="text-base font-semibold">Government Scheme Applications</CardTitle>
            <CardDescription>Applications submitted vs. successfully sanctioned</CardDescription>
          </CardHeader>
          <CardContent className="h-72">
            <ResponsiveContainer width="100%" height="100%">
              <BarChart data={SCHEME_DATA} margin={{ top: 10, right: 10, left: -20, bottom: 0 }}>
                <CartesianGrid strokeDasharray="3 3" opacity={0.15} />
                <XAxis dataKey="name" stroke="#888888" fontSize={11} tickLine={false} />
                <YAxis stroke="#888888" fontSize={12} tickLine={false} />
                <Tooltip
                  contentStyle={{
                    backgroundColor: "rgba(15, 23, 42, 0.9)",
                    border: "1px solid rgba(255,255,255,0.1)",
                    borderRadius: "8px",
                    color: "#fff",
                  }}
                />
                <Legend wrapperStyle={{ fontSize: "12px", paddingTop: "8px" }} />
                <Bar dataKey="applied" name="Submitted" fill="#94a3b8" radius={[4, 4, 0, 0]} />
                <Bar dataKey="approved" name="Sanctioned" fill="#10b981" radius={[4, 4, 0, 0]} />
              </BarChart>
            </ResponsiveContainer>
          </CardContent>
        </Card>

        {/* Regional Activity Table */}
        <Card className="lg:col-span-3 border border-border/60 bg-card/80 backdrop-blur-sm shadow-sm flex flex-col justify-between">
          <CardHeader>
            <CardTitle className="text-base font-semibold">Top Performing States</CardTitle>
            <CardDescription>Regional entrepreneurship uptake & subsidy flow</CardDescription>
          </CardHeader>
          <CardContent className="space-y-4">
            {REGIONAL_STATS.map((stat) => (
              <div key={stat.state} className="flex items-center justify-between p-2.5 rounded-lg bg-muted/40 border border-border/30">
                <div>
                  <div className="font-semibold text-foreground text-sm">{stat.state}</div>
                  <div className="text-xs text-muted-foreground">{stat.enterprises} Active Units</div>
                </div>
                <div className="text-right">
                  <div className="font-semibold text-sm text-foreground">{stat.disbursement}</div>
                  <div className="text-xs text-emerald-600 dark:text-emerald-400 font-medium">{stat.growth} YoY</div>
                </div>
              </div>
            ))}
          </CardContent>
        </Card>
      </div>
    </div>
  );
}
