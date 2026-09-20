import { 
  LayoutDashboard, 
  Users, 
  Building2, 
  Store, 
  BookOpen, 
  Settings, 
  Bell, 
  BarChart, 
  ShieldCheck, 
  GraduationCap, 
  HeartHandshake,
  LineChart
} from "lucide-react"

export interface NavGroup {
  title: string
  items: NavItem[]
}

export interface NavItem {
  title: string
  href: string
  icon: any
  roles: string[]
}

export const navigationConfig: NavGroup[] = [
  {
    title: "Overview",
    items: [
      {
        title: "Dashboard",
        href: "/dashboard",
        icon: LayoutDashboard,
        roles: ["admin", "entrepreneur", "mentor", "ngo", "investor", "government"],
      },
      {
        title: "Analytics",
        href: "/dashboard/analytics",
        icon: BarChart,
        roles: ["admin", "government"],
      },
    ],
  },
  {
    title: "Management",
    items: [
      {
        title: "Users",
        href: "/dashboard/users",
        icon: Users,
        roles: ["admin"],
      },
      {
        title: "Businesses",
        href: "/dashboard/businesses",
        icon: Building2,
        roles: ["admin", "entrepreneur", "investor"],
      },
      {
        title: "Mentorship",
        href: "/dashboard/mentorship",
        icon: GraduationCap,
        roles: ["admin", "mentor", "entrepreneur"],
      },
      {
        title: "Schemes",
        href: "/dashboard/schemes",
        icon: HeartHandshake,
        roles: ["admin", "government", "ngo", "entrepreneur"],
      },
      {
        title: "Market Prices",
        href: "/dashboard/mandi",
        icon: LineChart,
        roles: ["admin", "entrepreneur", "ngo", "government"],
      },
    ],
  },
  {
    title: "AI & Content",
    items: [
      {
        title: "Moderation",
        href: "/dashboard/content",
        icon: ShieldCheck,
        roles: ["admin"],
      },
      {
        title: "Learning Hub",
        href: "/dashboard/learning",
        icon: BookOpen,
        roles: ["admin", "entrepreneur", "mentor"],
      },
    ],
  },
  {
    title: "System",
    items: [
      {
        title: "Observability",
        href: "/dashboard/observability",
        icon: Bell,
        roles: ["admin"],
      },
      {
        title: "Settings",
        href: "/dashboard/settings",
        icon: Settings,
        roles: ["admin", "entrepreneur", "mentor", "ngo", "investor", "government"],
      },
    ],
  },
]
