import Link from "next/link"
import { Button } from "@/components/ui/button"
import { ThemeToggle } from "@/components/shared/ThemeToggle"
import { CompassLogo } from "@/components/shared/CompassLogo"
import { LanguageSwitcher } from "@/components/LanguageSwitcher"
import { AppDownloadBanner } from "@/components/shared/AppDownloadBanner"
import { getDictionary, Locale } from "@/lib/dictionaries"
import { Smartphone } from "lucide-react"

export default async function MarketingLayout({
  children,
  params,
}: {
  children: React.ReactNode;
  params: Promise<{ lang: string }> | { lang: string };
}) {
  const resolvedParams = await params;
  const lang = resolvedParams?.lang as Locale || 'en';
  const dict = await getDictionary(lang);

  return (
    <div className="flex flex-col min-h-screen bg-background text-foreground transition-colors duration-300">
      <header className="fixed top-0 w-full z-50 bg-background/60 backdrop-blur-md border-b border-white/5">
        <AppDownloadBanner />
        <div className="container mx-auto px-6 h-16 flex items-center justify-between">
          <Link href={`/${lang}`} className="flex items-center gap-2 font-bold text-xl tracking-tight bg-gradient-to-r from-teal-400 to-blue-500 bg-clip-text text-transparent">
            <CompassLogo size={24} className="text-teal-500" />
            Compass
          </Link>
          <nav className="hidden md:flex items-center space-x-8 text-sm font-medium">
            <Link href={`/${lang}#features`} className="text-muted-foreground hover:text-primary transition-colors">{dict.navigation.opportunities}</Link>
            <Link href={`/${lang}#marketplace`} className="text-muted-foreground hover:text-primary transition-colors">{dict.navigation.mandi}</Link>
            <Link href={`/${lang}#mentorship`} className="text-muted-foreground hover:text-primary transition-colors">{dict.navigation.mentor}</Link>
            <Link href={`/${lang}#schemes`} className="text-muted-foreground hover:text-primary transition-colors">{dict.navigation.schemes}</Link>
          </nav>
          <div className="flex items-center space-x-2 md:space-x-4">
            <a href="/downloads/app-release.apk" download className="hidden lg:flex items-center gap-1.5 text-xs font-semibold text-teal-400 hover:text-teal-300 bg-teal-500/10 hover:bg-teal-500/20 border border-teal-500/30 px-3 py-1.5 rounded-full transition-all">
              <Smartphone className="w-3.5 h-3.5" />
              <span>Android App</span>
            </a>
            <LanguageSwitcher />
            <ThemeToggle />
            <Link href={`/${lang}/login`}>
              <Button variant="ghost" className="text-muted-foreground hover:text-primary">{dict.common.login}</Button>
            </Link>
            <Link href={`/${lang}/signup`}>
              <Button className="bg-primary/90 hover:bg-primary text-primary-foreground shadow-lg hover:shadow-primary/25">Get Started</Button>
            </Link>
          </div>
        </div>
      </header>
      
      <main className="flex-1 pt-16">
        {children}
      </main>

      <footer className="border-t border-white/5 bg-background/40 py-12">
        <div className="container mx-auto px-6 grid grid-cols-2 md:grid-cols-4 gap-8 text-sm">
          <div>
            <h4 className="font-semibold mb-4 text-foreground">Platform</h4>
            <ul className="space-y-2 text-muted-foreground">
              <li><Link href={`/${lang}#features`} className="hover:text-primary">{dict.navigation.opportunities}</Link></li>
              <li><Link href={`/${lang}#marketplace`} className="hover:text-primary">{dict.navigation.mandi}</Link></li>
              <li><Link href={`/${lang}#mentorship`} className="hover:text-primary">{dict.navigation.mentor}</Link></li>
            </ul>
          </div>
          <div>
            <h4 className="font-semibold mb-4 text-foreground">Company</h4>
            <ul className="space-y-2 text-muted-foreground">
              <li><Link href={`/${lang}/about`} className="hover:text-primary">About</Link></li>
              <li><Link href={`/${lang}/contact`} className="hover:text-primary">Contact</Link></li>
              <li><Link href={`/${lang}/careers`} className="hover:text-primary">Careers</Link></li>
            </ul>
          </div>
          <div>
            <h4 className="font-semibold mb-4 text-foreground">Resources</h4>
            <ul className="space-y-2 text-muted-foreground">
              <li><a href="/downloads/app-release.apk" download className="text-teal-400 font-medium hover:underline flex items-center gap-1">📱 Download Android App</a></li>
              <li><Link href={`/${lang}/docs`} className="hover:text-primary">Documentation</Link></li>
              <li><Link href={`/${lang}/privacy`} className="hover:text-primary">Privacy</Link></li>
              <li><Link href={`/${lang}/terms`} className="hover:text-primary">Terms</Link></li>
            </ul>
          </div>
          <div>
            <h4 className="font-semibold mb-4 text-foreground">Social</h4>
            <ul className="space-y-2 text-muted-foreground">
              <li><a href="#" className="hover:text-primary">LinkedIn</a></li>
              <li><a href="#" className="hover:text-primary">Twitter</a></li>
            </ul>
          </div>
        </div>
        <div className="container mx-auto px-6 mt-12 pt-8 border-t border-white/5 text-center text-muted-foreground text-xs">
          &copy; {new Date().getFullYear()} Compass. All rights reserved.
        </div>
      </footer>
    </div>
  )
}
