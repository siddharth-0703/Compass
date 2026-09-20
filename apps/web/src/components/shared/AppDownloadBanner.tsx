"use client"

import { useState, useEffect } from "react"
import { Smartphone, Download, X } from "lucide-react"
import { Button } from "@/components/ui/button"

interface AppDownloadBannerProps {
  apkUrl?: string
}

export function AppDownloadBanner({
  apkUrl = "/downloads/app-release.apk",
}: AppDownloadBannerProps) {
  const [isVisible, setIsVisible] = useState(false)

  useEffect(() => {
    // Check if user previously dismissed the banner in this session
    const dismissed = sessionStorage.getItem("compass_apk_banner_dismissed")
    if (!dismissed) {
      setIsVisible(true)
    }
  }, [])

  const handleDismiss = () => {
    setIsVisible(false)
    sessionStorage.setItem("compass_apk_banner_dismissed", "true")
  }

  if (!isVisible) return null

  return (
    <div className="bg-gradient-to-r from-teal-600 via-teal-700 to-blue-700 text-white px-4 py-2.5 shadow-md relative z-50 flex items-center justify-between text-xs sm:text-sm">
      <div className="container mx-auto flex items-center justify-between gap-3">
        <div className="flex items-center gap-2.5">
          <div className="bg-white/20 p-1.5 rounded-full shrink-0">
            <Smartphone className="w-4 h-4 text-white" />
          </div>
          <p className="font-medium">
            <span className="hidden sm:inline">Prefer using an app? </span>
            Get the official <span className="font-bold underline decoration-teal-300">Compass Android App</span> directly on your phone!
          </p>
        </div>

        <div className="flex items-center gap-2 shrink-0">
          <a
            href={apkUrl}
            download="Compass-App.apk"
            className="inline-flex items-center gap-1.5 bg-white text-teal-900 font-semibold px-3 py-1 rounded-md text-xs hover:bg-teal-50 transition-colors shadow-sm"
          >
            <Download className="w-3.5 h-3.5" />
            <span>Download APK</span>
          </a>
          <button
            onClick={handleDismiss}
            className="p-1 hover:bg-white/20 rounded-full transition-colors text-white/80 hover:text-white"
            aria-label="Dismiss banner"
          >
            <X className="w-4 h-4" />
          </button>
        </div>
      </div>
    </div>
  )
}
