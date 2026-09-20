import { Store, GraduationCap, HeartHandshake, Bot, ShieldCheck, TrendingUp } from "lucide-react"

const features = [
  {
    title: "Digital Marketplace",
    description: "Sell products to a wider audience with AI-powered search and recommendations.",
    icon: Store,
  },
  {
    title: "Expert Mentorship",
    description: "Connect with industry experts who understand the challenges of rural entrepreneurship.",
    icon: GraduationCap,
  },
  {
    title: "Government Schemes",
    description: "Instantly discover and apply for matching grants and government support programs.",
    icon: HeartHandshake,
  },
  {
    title: "AI Business Assistant",
    description: "Get real-time insights, multilingual support, and business advice powered by AI.",
    icon: Bot,
  },
  {
    title: "Trust & Safety",
    description: "Secure transactions and verified profiles to ensure a safe ecosystem for everyone.",
    icon: ShieldCheck,
  },
  {
    title: "Growth Forecasting",
    description: "Leverage advanced analytics to forecast trends and optimize your operations.",
    icon: TrendingUp,
  },
]

export function FeatureGrid() {
  return (
    <section id="features" className="py-24 bg-background/50 border-t border-white/5 relative">
      <div className="container mx-auto px-6">
        <div className="text-center mb-16 max-w-2xl mx-auto">
          <h2 className="text-3xl md:text-5xl font-bold mb-4">
            Everything you need to grow
          </h2>
          <p className="text-muted-foreground text-lg">
            A unified platform designed specifically to bridge the gap between rural potential and global opportunity.
          </p>
        </div>

        <div className="grid md:grid-cols-2 lg:grid-cols-3 gap-8">
          {features.map((feature, index) => {
            const Icon = feature.icon
            return (
              <div 
                key={index}
                className="group relative glass-card p-8 rounded-2xl overflow-hidden transition-all duration-300 hover:shadow-primary/10 hover:-translate-y-2"
              >
                <div className="absolute top-0 right-0 p-6 opacity-5 group-hover:opacity-10 transition-opacity duration-500">
                  <Icon className="w-24 h-24 text-primary" />
                </div>
                <div className="relative z-10">
                  <div className="w-12 h-12 rounded-xl bg-primary/10 flex items-center justify-center text-primary mb-6 group-hover:scale-110 transition-transform duration-300">
                    <Icon className="w-6 h-6" />
                  </div>
                  <h3 className="text-xl font-bold mb-3">{feature.title}</h3>
                  <p className="text-muted-foreground leading-relaxed">
                    {feature.description}
                  </p>
                </div>
              </div>
            )
          })}
        </div>
      </div>
    </section>
  )
}
