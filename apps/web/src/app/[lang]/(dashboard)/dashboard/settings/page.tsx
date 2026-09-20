"use client"

import { useDictionary } from "@/components/providers/DictionaryProvider"
import { useAuthStore } from "@/features/auth/stores/auth.store"
import { useTheme } from "next-themes"
import { useRouter, usePathname } from "next/navigation"
import { useEffect, useState } from "react"
import { Card, CardContent, CardHeader, CardTitle } from "@/components/ui/card"
import { Button } from "@/components/ui/button"
import { Select, SelectContent, SelectItem, SelectTrigger, SelectValue } from "@/components/ui/select"
import { Label } from "@/components/ui/label"

export default function SettingsPage() {
  const { dict, lang } = useDictionary()
  const { user, logout } = useAuthStore()
  const { theme, setTheme } = useTheme()
  const router = useRouter()
  const pathname = usePathname()
  
  const [mounted, setMounted] = useState(false)

  useEffect(() => {
    setMounted(true)
  }, [])

  const handleSignOut = () => {
    logout()
    router.push(`/${lang}/login`)
  }

  const handleLanguageChange = (newLang: string | null) => {
    if (!newLang || newLang === lang) return
    // Replace the current locale prefix with the new one
    // pathname is like /en/dashboard/settings
    const newPath = pathname.replace(`/${lang}`, `/${newLang}`)
    router.push(newPath)
  }

  if (!mounted) {
    return null // Prevent hydration mismatch
  }

  const s = dict.settings;

  const renderRole = (role: string) => {
    return s?.roles?.[role as keyof typeof s.roles] || role
  }

  const userRoles = user 
    ? (Array.isArray((user as any).roles) ? (user as any).roles : [user.role || 'entrepreneur'])
    : []

  return (
    <div className="flex flex-col h-full max-w-3xl mx-auto w-full pb-10">
      <div className="flex flex-col space-y-2 mb-8 mt-4">
        <h2 className="text-3xl font-bold tracking-tight capitalize">{s?.pageTitle || "Settings"}</h2>
        <p className="text-muted-foreground">{s?.pageDescription || "Manage your Compass preferences and account."}</p>
      </div>

      <div className="space-y-6">
        {/* ACCOUNT SECTION */}
        <Card>
          <CardHeader>
            <CardTitle>{s?.account?.title || "Account"}</CardTitle>
          </CardHeader>
          <CardContent className="space-y-4">
            <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
              <div className="space-y-1">
                <Label className="text-muted-foreground text-xs uppercase">{s?.account?.name || "Name"}</Label>
                <div className="font-medium">{user?.name || (user?.firstName ? `${user.firstName} ${user.lastName || ''}` : null) || (s?.account?.notProvided || "Not provided")}</div>
              </div>
              
              <div className="space-y-1">
                <Label className="text-muted-foreground text-xs uppercase">{s?.account?.email || "Email"}</Label>
                <div className="font-medium">{user?.email || (s?.account?.notProvided || "Not provided")}</div>
              </div>

              <div className="space-y-1">
                <Label className="text-muted-foreground text-xs uppercase">{s?.account?.phone || "Phone"}</Label>
                <div className="font-medium">{user?.phone || (s?.account?.notProvided || "Not provided")}</div>
              </div>

              <div className="space-y-1">
                <Label className="text-muted-foreground text-xs uppercase">{s?.account?.role || "Role"}</Label>
                <div className="font-medium capitalize">{userRoles.map(renderRole).join(', ') || (s?.account?.notProvided || "Not provided")}</div>
              </div>
            </div>
            
            <div className="pt-4 mt-4 border-t">
              <Button variant="destructive" onClick={handleSignOut}>
                {s?.account?.signOut || "Sign Out"}
              </Button>
            </div>
          </CardContent>
        </Card>

        {/* LANGUAGE SECTION */}
        <Card>
          <CardHeader>
            <CardTitle>{s?.language?.title || "Language"}</CardTitle>
          </CardHeader>
          <CardContent>
            <div className="flex flex-col sm:flex-row sm:items-center justify-between gap-4">
              <div className="space-y-1">
                <Label>{s?.language?.description || "Application Language"}</Label>
              </div>
              <Select value={lang} onValueChange={handleLanguageChange}>
                <SelectTrigger className="w-[180px]">
                  <SelectValue placeholder="Language" />
                </SelectTrigger>
                <SelectContent>
                  <SelectItem value="en">English</SelectItem>
                  <SelectItem value="hi">हिंदी (Hindi)</SelectItem>
                  <SelectItem value="mr">मराठी (Marathi)</SelectItem>
                </SelectContent>
              </Select>
            </div>
          </CardContent>
        </Card>

        {/* APPEARANCE SECTION */}
        <Card>
          <CardHeader>
            <CardTitle>{s?.appearance?.title || "Appearance"}</CardTitle>
          </CardHeader>
          <CardContent>
            <div className="flex flex-col sm:flex-row sm:items-center justify-between gap-4">
              <div className="space-y-1">
                <Label>{s?.appearance?.description || "Theme"}</Label>
              </div>
              <Select value={theme} onValueChange={(val) => { if (val) setTheme(val) }}>
                <SelectTrigger className="w-[180px]">
                  <SelectValue placeholder="Theme" />
                </SelectTrigger>
                <SelectContent>
                  <SelectItem value="system">{s?.appearance?.system || "System"}</SelectItem>
                  <SelectItem value="light">{s?.appearance?.light || "Light"}</SelectItem>
                  <SelectItem value="dark">{s?.appearance?.dark || "Dark"}</SelectItem>
                </SelectContent>
              </Select>
            </div>
          </CardContent>
        </Card>

        {/* ABOUT SECTION */}
        <Card>
          <CardHeader>
            <CardTitle>{s?.about?.title || "About Compass"}</CardTitle>
          </CardHeader>
          <CardContent>
            <div className="space-y-1">
              <div className="font-medium text-lg text-teal-600 dark:text-teal-400">Compass Platform</div>
              <div className="text-sm text-muted-foreground">{s?.about?.version || "Version"} 0.1.0</div>
            </div>
          </CardContent>
        </Card>

      </div>
    </div>
  )
}
