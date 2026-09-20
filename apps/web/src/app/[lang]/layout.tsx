import type { Metadata } from "next";
import { Plus_Jakarta_Sans } from "next/font/google";
import "../globals.css";
import { AppProviders } from "@/providers";
import { notFound } from "next/navigation";
import { DictionaryProvider } from "@/components/providers/DictionaryProvider";
import { getDictionary, Locale } from "@/lib/dictionaries";

const plusJakartaSans = Plus_Jakarta_Sans({
  variable: "--font-sans",
  subsets: ["latin"],
  display: "swap",
});

export const metadata: Metadata = {
  title: "Compass Admin",
  description: "Enterprise administration dashboard.",
};

const locales = ['en', 'hi', 'mr'];

export default async function RootLayout({
  children,
  params,
}: Readonly<{
  children: React.ReactNode;
  params: Promise<{ lang: string }> | { lang: string };
}>) {
  // Await params for Next.js 15+ compatibility
  const resolvedParams = await params;
  const lang = resolvedParams?.lang || 'en';

  if (!locales.includes(lang)) {
    notFound();
  }
  
  const dict = await getDictionary(lang as Locale);

  return (
    <html
      lang={lang}
      suppressHydrationWarning
      className={`${plusJakartaSans.variable} font-sans h-full antialiased`}
    >
      <body className="min-h-full flex flex-col">
        <DictionaryProvider dict={dict} lang={lang}>
          <AppProviders>{children}</AppProviders>
        </DictionaryProvider>
      </body>
    </html>
  );
}
