import { Sidebar } from "./sidebar"
import { Header } from "./header"

interface DashboardShellProps {
  children: React.ReactNode
}

export function DashboardShell({ children }: DashboardShellProps) {
  return (
    <div className="flex min-h-screen w-full bg-muted/40">
      <div className="hidden border-r bg-background md:block md:w-64 fixed inset-y-0">
        <Sidebar />
      </div>
      <div className="flex flex-col w-full md:pl-64">
        <Header />
        <main className="flex-1 space-y-4 p-8 pt-6">
          {children}
        </main>
      </div>
    </div>
  )
}
