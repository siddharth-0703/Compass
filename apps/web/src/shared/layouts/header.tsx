"use client"

import { Bell, Search, User, LogOut, Settings as SettingsIcon, Sun, Moon } from "lucide-react"
import { Button } from "@/components/ui/button"
import { Input } from "@/components/ui/input"
import { useTheme } from "next-themes"
import { useRouter } from "next/navigation"
import axios from "axios"
import { useAuthStore } from "@/features/auth/stores/auth.store"
import {
  DropdownMenu,
  DropdownMenuContent,
  DropdownMenuItem,
  DropdownMenuLabel,
  DropdownMenuSeparator,
  DropdownMenuTrigger,
} from "@/components/ui/dropdown-menu"
import { LanguageSwitcher } from "@/components/LanguageSwitcher"
import { useDictionary } from "@/components/providers/DictionaryProvider"

export function Header() {
  const { setTheme, theme } = useTheme()
  const router = useRouter()
  const { user, logout } = useAuthStore()
  const { dict, lang } = useDictionary()

  const handleLogout = async () => {
    try {
      await axios.post("/api/auth/logout")
      logout()
      router.push(`/${lang}/login`)
      router.refresh()
    } catch (error) {
      console.error("Failed to log out:", error)
    }
  }

  return (
    <header className="flex h-14 items-center gap-4 border-b bg-background px-6 lg:h-[60px]">
      <div className="w-full flex-1">
        <form onSubmit={(e) => e.preventDefault()}>
          <div className="relative">
            <Search className="absolute left-2.5 top-2.5 h-4 w-4 text-muted-foreground" />
            <Input
              type="search"
              placeholder={dict.common?.search || "Search..."}
              className="w-full appearance-none bg-background pl-8 shadow-none md:w-2/3 lg:w-1/3"
            />
          </div>
        </form>
      </div>
      <LanguageSwitcher />
      <Button
        variant="ghost"
        size="icon"
        className="rounded-full"
        onClick={() => setTheme(theme === "light" ? "dark" : "light")}
      >
        <span className="sr-only">Toggle theme</span>
        <div className="flex h-5 w-5 items-center justify-center rotate-0 scale-100 transition-all dark:-rotate-90 dark:scale-0 text-lg leading-none">
          🌞
        </div>
        <div className="absolute flex h-5 w-5 items-center justify-center rotate-90 scale-0 transition-all dark:rotate-0 dark:scale-100 text-lg leading-none">
          🌙
        </div>
      </Button>
      <Button variant="ghost" size="icon" className="relative rounded-full">
        <Bell className="h-5 w-5" />
        <span className="sr-only">Toggle notifications</span>
        <div className="absolute top-2 right-2 h-2 w-2 rounded-full bg-destructive" />
      </Button>
      
      <DropdownMenu>
        <DropdownMenuTrigger className="inline-flex items-center justify-center whitespace-nowrap text-sm font-medium transition-colors hover:bg-accent hover:text-accent-foreground h-9 w-9 rounded-full">
          <User className="h-5 w-5" />
          <span className="sr-only">Toggle user menu</span>
        </DropdownMenuTrigger>
        <DropdownMenuContent align="end" className="w-56">
          <DropdownMenuLabel className="font-normal">
            <div className="flex flex-col space-y-1">
              <p className="text-sm font-medium leading-none">{user?.firstName || user?.lastName || "Administrator"}</p>
              <p className="text-xs leading-none text-muted-foreground">{user?.email || ""}</p>
            </div>
          </DropdownMenuLabel>
          <DropdownMenuSeparator />
          <DropdownMenuItem onClick={() => router.push(`/${lang}/dashboard/settings`)}>
            <SettingsIcon className="mr-2 h-4 w-4" />
            <span>{dict.common?.settings || "Settings"}</span>
          </DropdownMenuItem>
          <DropdownMenuSeparator />
          <DropdownMenuItem onClick={handleLogout} className="text-destructive focus:bg-destructive/10">
            <LogOut className="mr-2 h-4 w-4" />
            <span>{dict.common?.logout || "Log out"}</span>
          </DropdownMenuItem>
        </DropdownMenuContent>
      </DropdownMenu>
    </header>
  )
}
