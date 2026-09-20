import { HeroSection } from "@/components/marketing/HeroSection"
import { FeatureGrid } from "@/components/marketing/FeatureGrid"

export default function LandingPage() {
  return (
    <div className="flex flex-col min-h-screen">
      <HeroSection />
      <FeatureGrid />
    </div>
  )
}
