import Link from "next/link"
import { Button } from "@/components/ui/button"

export function HeroSection() {
  return (
    <section className="relative pt-32 pb-20 md:pt-48 md:pb-32 overflow-hidden">
      {/* Background imagery / AI pattern */}
      <div className="absolute inset-0 bg-[url('/abstract-pattern.png')] opacity-10 mix-blend-overlay bg-cover bg-center" />
      
      {/* Gradients */}
      <div className="absolute top-1/4 left-1/4 w-96 h-96 bg-primary/20 rounded-full blur-[120px] pointer-events-none" />
      <div className="absolute bottom-1/4 right-1/4 w-96 h-96 bg-secondary/20 rounded-full blur-[120px] pointer-events-none" />

      <div className="container mx-auto px-6 relative z-10 text-center">
        <div className="flex flex-col lg:flex-row items-center gap-12 text-left">
          <div className="flex-1">
            <div className="inline-flex items-center space-x-2 bg-white/5 border border-white/10 rounded-full px-4 py-1.5 shadow-sm backdrop-blur-md mb-8">
              <span className="text-xs font-semibold uppercase tracking-wider text-primary">
                New
              </span>
              <span className="text-sm text-muted-foreground">
                AI-Powered Matching Engine is now live.
              </span>
            </div>
            
            <h1 className="text-5xl md:text-7xl font-extrabold tracking-tight mb-6 max-w-4xl leading-tight">
              Empowering Rural Entrepreneurs with <span className="bg-gradient-to-r from-primary to-secondary bg-clip-text text-transparent">AI</span>
            </h1>
            
            <p className="text-xl text-muted-foreground max-w-2xl mb-10 leading-relaxed">
              Helping businesses access mentorship, marketplaces, government schemes, and learning resources through an intelligent, unified platform.
            </p>
            
            <div className="flex flex-col sm:flex-row items-center gap-4">
              <Link href="/signup">
                <Button size="lg" className="w-full sm:w-auto text-lg h-14 px-8 bg-primary text-primary-foreground hover:bg-primary/90 shadow-lg hover:shadow-primary/25 transition-all">
                  Start Your Journey
                </Button>
              </Link>
              <Link href="#features">
                <Button size="lg" variant="outline" className="w-full sm:w-auto text-lg h-14 px-8 border-white/10 bg-white/5 hover:bg-white/10 backdrop-blur-md transition-all">
                  Explore Platform
                </Button>
              </Link>
            </div>
          </div>
          
          <div className="flex-1 relative w-full aspect-square md:aspect-[4/3] lg:aspect-square max-w-2xl">
            <div className="absolute inset-0 bg-gradient-to-tr from-primary/20 to-secondary/20 rounded-[2rem] transform rotate-3 scale-105 opacity-50 blur-xl" />
            <div className="absolute inset-0 bg-card/40 backdrop-blur-sm border border-white/10 rounded-[2rem] overflow-hidden shadow-2xl">
              <img 
                src="/hero-image-1.jpg" 
                alt="Rural Entrepreneurship with Technology" 
                className="w-full h-full object-cover mix-blend-normal transition-transform duration-700 hover:scale-105"
              />
            </div>
          </div>
        </div>
        
        <div className="mt-20 pt-10 border-t border-white/5">
          <p className="text-sm text-muted-foreground mb-6 uppercase tracking-widest font-semibold">
            Trusted across the ecosystem by
          </p>
          <div className="flex flex-wrap justify-center gap-8 md:gap-16 opacity-50 grayscale">
            {/* Placeholder trust logos */}
            <div className="text-xl font-bold font-serif">NGO Partners</div>
            <div className="text-xl font-bold font-mono">GovInitiatives</div>
            <div className="text-xl font-bold">EduCorp</div>
            <div className="text-xl font-bold italic">AgriTech Startups</div>
          </div>
        </div>
      </div>
    </section>
  )
}
