"use client";

import React, { useState } from "react";
import { ShieldAlert, ShieldCheck, CheckCircle2, XCircle, AlertTriangle, Eye, Filter, Sparkles, MessageSquare } from "lucide-react";
import { Button } from "@/components/ui/button";
import { Card, CardContent, CardHeader, CardTitle, CardDescription } from "@/components/ui/card";
import { Badge } from "@/components/ui/badge";
import { useDictionary } from "@/components/providers/DictionaryProvider";

interface ModerationItem {
  id: string;
  author: string;
  role: string;
  content: string;
  source: string;
  flagReason: string;
  aiConfidence: number;
  status: "Pending" | "Approved" | "Rejected";
  timestamp: string;
}

const INITIAL_QUEUE: ModerationItem[] = [
  {
    id: "mod-101",
    author: "Kisan Trading Co.",
    role: "Merchant",
    content: "Guaranteed 100% returns in 10 days on purchase of imported hybrid soybean seeds. WhatsApp us directly.",
    source: "Community Forum",
    flagReason: "Potential financial scam / misleading advertising",
    aiConfidence: 96,
    status: "Pending",
    timestamp: "10 mins ago",
  },
  {
    id: "mod-102",
    author: "Devendra Verma",
    role: "Entrepreneur",
    content: "Selling authentic handcrafted Kolhapur leather chappals with GI tag certification. DM for bulk orders.",
    source: "Marketplace Listing",
    flagReason: "Passed preliminary AI safety verification",
    aiConfidence: 99,
    status: "Approved",
    timestamp: "45 mins ago",
  },
  {
    id: "mod-103",
    author: "Sunita Agro Fertilizers",
    role: "Supplier",
    content: "Unregistered chemical pesticide available at 50% discount without invoice or clearance.",
    source: "Wholesale Board",
    flagReason: "Unregulated hazardous chemical sale",
    aiConfidence: 98,
    status: "Rejected",
    timestamp: "2 hours ago",
  },
  {
    id: "mod-104",
    author: "Pooja Milk Federation",
    role: "Co-operative",
    content: "Looking for dairy cold chain chilling unit partners in Satara district. Subsidized under PMKSY.",
    source: "Partnership Exchange",
    flagReason: "Legitimate collaboration request",
    aiConfidence: 97,
    status: "Approved",
    timestamp: "3 hours ago",
  },
];

export default function ContentModerationPage() {
  const { dict } = useDictionary();
  const t = dict.moderation || {};

  const [items, setItems] = useState<ModerationItem[]>(INITIAL_QUEUE);
  const [filter, setFilter] = useState<"All" | "Pending" | "Approved" | "Rejected">("All");

  const handleApprove = (id: string) => {
    setItems((prev) =>
      prev.map((item) => (item.id === id ? { ...item, status: "Approved" } : item))
    );
  };

  const handleReject = (id: string) => {
    setItems((prev) =>
      prev.map((item) => (item.id === id ? { ...item, status: "Rejected" } : item))
    );
  };

  const filteredItems = items.filter((item) => {
    if (filter === "All") return true;
    return item.status === filter;
  });

  const getFilterLabel = (tab: "All" | "Pending" | "Approved" | "Rejected") => {
    switch (tab) {
      case "All": return t.all || "All";
      case "Pending": return t.pending || "Pending";
      case "Approved": return t.approved || "Approved";
      case "Rejected": return t.rejected || "Rejected";
    }
  };

  const getStatusLabel = (status: "Pending" | "Approved" | "Rejected") => {
    switch (status) {
      case "Pending": return t.pending || "Pending";
      case "Approved": return t.approved || "Approved";
      case "Rejected": return t.rejected || "Rejected";
    }
  };

  return (
    <div className="flex-1 space-y-6 p-4 md:p-8 pt-6 max-w-7xl mx-auto w-full">
      {/* Header */}
      <div className="flex flex-col sm:flex-row sm:items-center justify-between gap-4">
        <div>
          <div className="flex items-center gap-2">
            <h1 className="text-3xl font-bold tracking-tight text-foreground">
              {t.title || dict.navigation?.moderation || "AI Content Moderation"}
            </h1>
            <span className="inline-flex items-center gap-1.5 px-2.5 py-0.5 rounded-full text-xs font-semibold bg-primary/10 text-primary border border-primary/20">
              <Sparkles className="h-3.5 w-3.5" />
              {t.safetyEngine || "Automated Safety Engine"}
            </span>
          </div>
          <p className="text-muted-foreground text-sm mt-1">
            {t.description || "Review community discussions, marketplace listings, and AI-flagged enterprise content."}
          </p>
        </div>

        {/* Filter Badges */}
        <div className="flex items-center gap-1.5 bg-muted/60 p-1 rounded-lg border border-border/40 text-xs">
          {(["All", "Pending", "Approved", "Rejected"] as const).map((tab) => (
            <button
              key={tab}
              onClick={() => setFilter(tab)}
              className={`px-3 py-1.5 rounded-md font-medium transition-all ${
                filter === tab
                  ? "bg-background text-foreground shadow-sm"
                  : "text-muted-foreground hover:text-foreground"
              }`}
            >
              {getFilterLabel(tab)}
            </button>
          ))}
        </div>
      </div>

      {/* KPI Stats */}
      <div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-4 gap-4">
        <Card className="border border-border/60 bg-card/80 backdrop-blur-sm shadow-sm">
          <CardHeader className="flex flex-row items-center justify-between space-y-0 pb-2">
            <CardTitle className="text-sm font-medium text-muted-foreground">
              {t.scannedItems || "Scanned Items"}
            </CardTitle>
            <MessageSquare className="h-4 w-4 text-blue-500" />
          </CardHeader>
          <CardContent>
            <div className="text-2xl font-bold text-foreground">1,420</div>
            <p className="text-xs text-muted-foreground mt-1">
              {t.realtimeStream || "Real-time NLP stream"}
            </p>
          </CardContent>
        </Card>

        <Card className="border border-border/60 bg-card/80 backdrop-blur-sm shadow-sm">
          <CardHeader className="flex flex-row items-center justify-between space-y-0 pb-2">
            <CardTitle className="text-sm font-medium text-muted-foreground">
              {t.aiFlagged || "AI Flagged"}
            </CardTitle>
            <AlertTriangle className="h-4 w-4 text-amber-500" />
          </CardHeader>
          <CardContent>
            <div className="text-2xl font-bold text-amber-600 dark:text-amber-400">18</div>
            <p className="text-xs text-muted-foreground mt-1">
              {t.requiresReview || "Requires human review"}
            </p>
          </CardContent>
        </Card>

        <Card className="border border-border/60 bg-card/80 backdrop-blur-sm shadow-sm">
          <CardHeader className="flex flex-row items-center justify-between space-y-0 pb-2">
            <CardTitle className="text-sm font-medium text-muted-foreground">
              {t.cleanScore || "Clean Score"}
            </CardTitle>
            <ShieldCheck className="h-4 w-4 text-emerald-500" />
          </CardHeader>
          <CardContent>
            <div className="text-2xl font-bold text-emerald-600 dark:text-emerald-400">98.7%</div>
            <p className="text-xs text-muted-foreground mt-1">
              {t.trustIndex || "Community trust index"}
            </p>
          </CardContent>
        </Card>

        <Card className="border border-border/60 bg-card/80 backdrop-blur-sm shadow-sm">
          <CardHeader className="flex flex-row items-center justify-between space-y-0 pb-2">
            <CardTitle className="text-sm font-medium text-muted-foreground">
              {t.modelAccuracy || "Model Accuracy"}
            </CardTitle>
            <Sparkles className="h-4 w-4 text-purple-500" />
          </CardHeader>
          <CardContent>
            <div className="text-2xl font-bold text-foreground">99.4%</div>
            <p className="text-xs text-muted-foreground mt-1">
              {t.geminiBenchmark || "Gemini Safety Benchmark"}
            </p>
          </CardContent>
        </Card>
      </div>

      {/* Moderation Review Feed */}
      <Card className="border border-border/60 bg-card/80 backdrop-blur-sm shadow-sm">
        <CardHeader>
          <CardTitle className="text-base font-semibold">
            {t.queueTitle || "Moderation Queue"}
          </CardTitle>
          <CardDescription>
            {t.queueDesc || "Items flagged by the sentiment, policy, and scam prevention classifiers"}
          </CardDescription>
        </CardHeader>
        <CardContent className="space-y-4">
          {filteredItems.length === 0 ? (
            <div className="p-8 text-center text-muted-foreground text-sm">
              {t.noItems || "No items matching the selected filter."}
            </div>
          ) : (
            filteredItems.map((item) => (
              <div
                key={item.id}
                className="p-4 rounded-xl bg-muted/40 border border-border/40 flex flex-col md:flex-row md:items-center justify-between gap-4 transition-all hover:bg-muted/60"
              >
                <div className="space-y-2 flex-1">
                  <div className="flex flex-wrap items-center gap-2">
                    <span className="font-semibold text-foreground text-sm">{item.author}</span>
                    <Badge variant="outline" className="text-[10px] py-0 px-1.5">
                      {item.role}
                    </Badge>
                    <span className="text-xs text-muted-foreground">• {item.source}</span>
                    <span className="text-xs text-muted-foreground">• {item.timestamp}</span>

                    <span
                      className={`ml-auto md:ml-2 text-[11px] font-semibold px-2 py-0.5 rounded-full ${
                        item.status === "Approved"
                          ? "bg-emerald-500/10 text-emerald-600 dark:text-emerald-400 border border-emerald-500/20"
                          : item.status === "Rejected"
                          ? "bg-destructive/10 text-destructive border border-destructive/20"
                          : "bg-amber-500/10 text-amber-600 dark:text-amber-400 border border-amber-500/20"
                      }`}
                    >
                      {getStatusLabel(item.status)}
                    </span>
                  </div>

                  <p className="text-sm text-foreground/90 leading-relaxed font-sans bg-background/50 p-2.5 rounded-lg border border-border/30">
                    &ldquo;{item.content}&rdquo;
                  </p>

                  <div className="flex items-center gap-2 text-xs text-muted-foreground">
                    <span className="font-semibold text-amber-600 dark:text-amber-400">
                      Reason:
                    </span>
                    <span>{item.flagReason}</span>
                    <span className="ml-auto font-mono text-[11px]">
                      AI Confidence: {item.aiConfidence}%
                    </span>
                  </div>
                </div>

                {/* Action Buttons */}
                <div className="flex items-center gap-2 self-end md:self-center shrink-0">
                  {item.status === "Pending" ? (
                    <>
                      <Button
                        size="sm"
                        variant="outline"
                        className="h-8 text-xs border-emerald-500/30 text-emerald-600 hover:bg-emerald-500/10 hover:text-emerald-500 gap-1"
                        onClick={() => handleApprove(item.id)}
                      >
                        <CheckCircle2 className="h-3.5 w-3.5" />
                        {t.approve || "Approve"}
                      </Button>
                      <Button
                        size="sm"
                        variant="outline"
                        className="h-8 text-xs border-destructive/30 text-destructive hover:bg-destructive/10 gap-1"
                        onClick={() => handleReject(item.id)}
                      >
                        <XCircle className="h-3.5 w-3.5" />
                        {t.reject || "Reject"}
                      </Button>
                    </>
                  ) : (
                    <Button
                      size="sm"
                      variant="ghost"
                      className="h-8 text-xs text-muted-foreground"
                      onClick={() =>
                        setItems((prev) =>
                          prev.map((i) =>
                            i.id === item.id ? { ...i, status: "Pending" } : i
                          )
                        )
                      }
                    >
                      Re-evaluate
                    </Button>
                  )}
                </div>
              </div>
            ))
          )}
        </CardContent>
      </Card>
    </div>
  );
}
