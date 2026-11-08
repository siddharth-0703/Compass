"use client"

import { useState } from "react"
import { useParams, useRouter } from "next/navigation"
import { zodResolver } from "@hookform/resolvers/zod"
import { useForm } from "react-hook-form"
import * as z from "zod"
import Link from "next/link"
import { ShieldCheck, Zap } from "lucide-react"

import { Button } from "@/components/ui/button"
import {
  Form,
  FormControl,
  FormField,
  FormItem,
  FormLabel,
  FormMessage,
} from "@/components/ui/form"
import { Input } from "@/components/ui/input"
import { useAuthStore } from "@/features/auth/stores/auth.store"
import axios from "axios"

const formSchema = z.object({
  identifier: z.string().min(3, {
    message: "Please enter a valid email or phone number.",
  }),
  password: z.string().min(8, {
    message: "Password must be at least 8 characters.",
  }),
})

export default function LoginPage() {
  const router = useRouter()
  const params = useParams()
  const lang = (params?.lang as string) || "en"
  const setUser = useAuthStore((state) => state.setUser)
  const [error, setError] = useState<string | null>(null)
  const [isLoading, setIsLoading] = useState(false)

  const form = useForm<z.infer<typeof formSchema>>({
    resolver: zodResolver(formSchema),
    defaultValues: {
      identifier: "siddharthjaiswar9107@gmail.com",
      password: "Sid@1234567",
    },
  })

  async function onSubmit(values: z.infer<typeof formSchema>) {
    setIsLoading(true)
    setError(null)
    
    try {
      const isEmail = values.identifier.includes('@')
      const payload = {
        email: isEmail ? values.identifier : undefined,
        phone: !isEmail ? values.identifier : undefined,
        password: values.password
      }

      // Call the BFF proxy route handler to set HttpOnly cookies
      const response = await axios.post("/api/auth/login", payload)
      
      if (response.data.success) {
        // Store user metadata in Zustand
        setUser(response.data.data.user)
        
        // Redirect to dashboard
        router.push(`/${lang}/dashboard`)
        router.refresh()
      }
    } catch (err: any) {
      if (err.response?.data?.error?.message) {
        setError(err.response.data.error.message)
      } else {
        setError("An unexpected error occurred. Please try again.")
      }
    } finally {
      setIsLoading(false)
    }
  }

  async function handleQuickDemoLogin() {
    setIsLoading(true)
    setError(null)
    try {
      const response = await axios.post("/api/auth/login", {
        identifier: "siddharthjaiswar9107@gmail.com",
        password: "Sid@1234567",
        isDemo: true,
      })
      if (response.data.success) {
        setUser(response.data.data.user)
        router.push(`/${lang}/dashboard`)
        router.refresh()
      }
    } catch (err: any) {
      setError("An unexpected error occurred. Please try again.")
    } finally {
      setIsLoading(false)
    }
  }

  return (
    <div className="flex min-h-screen bg-background">
      <div className="flex-1 flex flex-col items-center justify-center p-8 md:p-16">
        <div className="w-full max-w-md space-y-8">
          <div className="text-center">
            <h2 className="text-3xl font-extrabold text-foreground mb-2">Welcome back</h2>
            <p className="text-muted-foreground text-lg">
              Don't have an account?{" "}
              <Link href={`/${lang}/signup`} className="text-primary hover:underline font-semibold">
                Sign up
              </Link>
            </p>
          </div>

          <div className="flex items-center justify-between p-3 rounded-lg bg-emerald-500/10 border border-emerald-500/20 text-xs text-emerald-600 dark:text-emerald-400">
            <span className="font-medium">🎓 Demo Mode: Credentials pre-filled for instant 2-min presentation</span>
            <span className="font-semibold px-2 py-0.5 rounded bg-emerald-500/20 uppercase tracking-wider text-[10px]">Instant</span>
          </div>

          <Form {...form}>
            <form onSubmit={form.handleSubmit(onSubmit)} className="space-y-6">
              {error && (
                <div className="p-3 text-sm text-destructive-foreground bg-destructive/20 rounded-md border border-destructive">
                  {error}
                </div>
              )}
              
              <FormField
                control={form.control}
                name="identifier"
                render={({ field }) => (
                  <FormItem>
                    <FormLabel>Email or Phone Number</FormLabel>
                    <FormControl>
                      <Input 
                        placeholder="you@example.com or +919876543210" 
                        {...field} 
                        className="flex h-12 w-full rounded-md border border-input bg-transparent px-3 py-1 text-base shadow-sm transition-colors focus-visible:outline-none focus-visible:ring-1 focus-visible:ring-ring"
                      />
                    </FormControl>
                    <FormMessage />
                  </FormItem>
                )}
              />
              <FormField
                control={form.control}
                name="password"
                render={({ field }) => (
                  <FormItem>
                    <div className="flex items-center justify-between">
                      <FormLabel>Password</FormLabel>
                      <Link href="#" className="text-sm font-medium text-primary hover:underline">
                        Forgot password?
                      </Link>
                    </div>
                    <FormControl>
                      <Input 
                        type="password" 
                        placeholder="••••••••" 
                        {...field} 
                        className="flex h-12 w-full rounded-md border border-input bg-transparent px-3 py-1 text-base shadow-sm transition-colors focus-visible:outline-none focus-visible:ring-1 focus-visible:ring-ring"
                      />
                    </FormControl>
                    <FormMessage />
                  </FormItem>
                )}
              />

              <Button 
                type="button" 
                variant="outline"
                className="w-full h-12 text-base font-semibold border-emerald-500/40 text-emerald-600 dark:text-emerald-400 hover:bg-emerald-500/10 hover:text-emerald-500 transition-all flex items-center justify-center gap-2 shadow-sm"
                onClick={handleQuickDemoLogin}
                disabled={isLoading}
              >
                <Zap className="h-5 w-5 fill-emerald-500 text-emerald-500" />
                ⚡ Instant Demo Login (1-Click)
              </Button>

              <Button type="submit" className="w-full h-12 text-lg font-semibold bg-primary text-primary-foreground hover:bg-primary/90" disabled={isLoading}>
                {isLoading ? "Signing in..." : "Sign in"}
              </Button>

              <div className="relative my-4">
                <div className="absolute inset-0 flex items-center">
                  <span className="w-full border-t border-border" />
                </div>
                <div className="relative flex justify-center text-xs uppercase">
                  <span className="bg-background px-2 text-muted-foreground">
                    Or continue with
                  </span>
                </div>
              </div>

              <Button 
                type="button" 
                variant="outline" 
                className="w-full h-12 text-base font-semibold"
                onClick={() => alert("Google Sign-In integration pending backend support.")}
              >
                <svg className="mr-2 h-5 w-5" viewBox="0 0 24 24">
                  <path
                    d="M22.56 12.25c0-.78-.07-1.53-.2-2.25H12v4.26h5.92c-.26 1.37-1.04 2.53-2.21 3.31v2.77h3.57c2.08-1.92 3.28-4.74 3.28-8.09z"
                    fill="#4285F4"
                  />
                  <path
                    d="M12 23c2.97 0 5.46-.98 7.28-2.66l-3.57-2.77c-.98.66-2.23 1.06-3.71 1.06-2.86 0-5.29-1.93-6.16-4.53H2.18v2.84C3.99 20.53 7.7 23 12 23z"
                    fill="#34A853"
                  />
                  <path
                    d="M5.84 14.09c-.22-.66-.35-1.36-.35-2.09s.13-1.43.35-2.09V7.07H2.18C1.43 8.55 1 10.22 1 12s.43 3.45 1.18 4.93l2.85-2.22.81-.62z"
                    fill="#FBBC05"
                  />
                  <path
                    d="M12 5.38c1.62 0 3.06.56 4.21 1.64l3.15-3.15C17.45 2.09 14.97 1 12 1 7.7 1 3.99 3.47 2.18 7.07l3.66 2.84c.87-2.6 3.3-4.53 6.16-4.53z"
                    fill="#EA4335"
                  />
                </svg>
                Sign in with Google
              </Button>
            </form>
          </Form>
        </div>
      </div>

      <div className="hidden lg:flex w-1/2 relative bg-secondary/10 items-center justify-center p-12 overflow-hidden">
        <div className="absolute inset-0 bg-gradient-to-tl from-primary/30 to-secondary/30 mix-blend-overlay" />
        <img 
          src="/hero-image-2.jpg" 
          alt="Agriculture Icons" 
          className="absolute inset-0 w-full h-full object-cover mix-blend-multiply opacity-50"
        />
        <div className="relative z-10 max-w-lg text-white text-right w-full">
          <h1 className="text-4xl md:text-5xl font-bold mb-6 text-white drop-shadow-lg">
            Empower your rural enterprise.
          </h1>
          <p className="text-xl text-white/90 drop-shadow-md">
            Manage your digital marketplace, learn new skills, and connect with peers around the world.
          </p>
        </div>
      </div>
    </div>
  )
}
