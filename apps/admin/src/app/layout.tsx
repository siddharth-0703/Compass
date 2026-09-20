export default function RootLayout({ children }: { children: React.ReactNode }) {
  return (
    <html lang="en">
      <body>
        <div style={{ display: 'flex', height: '100vh' }}>
          {/* Minimal Sidebar Layout */}
          <aside style={{ width: '250px', background: '#f4f4f4', padding: '20px' }}>
            <h2>Rural Admin</h2>
            <nav>
              <ul>
                <li><a href="/">Dashboard</a></li>
                <li><a href="/login">Login</a></li>
              </ul>
            </nav>
          </aside>
          <main style={{ flex: 1, padding: '20px' }}>
            {children}
          </main>
        </div>
      </body>
    </html>
  );
}
