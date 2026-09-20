import { NextResponse } from 'next/server'
import type { NextRequest } from 'next/server'

const locales = ['en', 'hi', 'mr'];
const defaultLocale = 'en';

function getLocale(request: NextRequest) {
  const cookieLocale = request.cookies.get('NEXT_LOCALE')?.value;
  if (cookieLocale && locales.includes(cookieLocale)) {
    return cookieLocale;
  }
  
  const acceptLang = request.headers.get('Accept-Language');
  if (acceptLang) {
    const preferred = acceptLang.split(',')[0].toLowerCase();
    if (preferred.startsWith('hi')) return 'hi';
    if (preferred.startsWith('mr')) return 'mr';
    if (preferred.startsWith('en')) return 'en';
  }
  
  return defaultLocale;
}

export function proxy(request: NextRequest) {
  const { pathname } = request.nextUrl

  // 1. Check if the pathname has a supported locale
  const pathnameHasLocale = locales.some(
    (locale) => pathname.startsWith(`/${locale}/`) || pathname === `/${locale}`
  );

  let currentLocale = defaultLocale;
  let pathnameWithoutLocale = pathname;

  if (pathnameHasLocale) {
    currentLocale = pathname.split('/')[1];
    pathnameWithoutLocale = pathname.replace(`/${currentLocale}`, '') || '/';
  } else {
    // Redirect to the URL with the locale
    const locale = getLocale(request);
    request.nextUrl.pathname = `/${locale}${pathname}`;
    return NextResponse.redirect(request.nextUrl);
  }

  // 2. Authentication Logic
  const token = request.cookies.get('accessToken')?.value
  const refreshToken = request.cookies.get('refreshToken')?.value
  const isAuthenticated = !!(token || refreshToken)

  const isAuthRoute = pathnameWithoutLocale.startsWith('/login') || pathnameWithoutLocale.startsWith('/signup')
  const isProtectedRoute = pathnameWithoutLocale.startsWith('/dashboard')

  // If trying to access protected route without token, redirect to login
  if (isProtectedRoute && !isAuthenticated) {
    const loginUrl = new URL(`/${currentLocale}/login`, request.url)
    // Save the attempted URL to redirect back after login
    loginUrl.searchParams.set('callbackUrl', pathname)
    return NextResponse.redirect(loginUrl)
  }

  // If already authenticated and trying to access login/signup, redirect to dashboard
  if (isAuthRoute && isAuthenticated) {
    return NextResponse.redirect(new URL(`/${currentLocale}/dashboard`, request.url))
  }

  return NextResponse.next()
}

export const config = {
  // Run proxy middleware on all paths except static files, images, favicon, api routes
  matcher: ['/((?!api|_next/static|_next/image|favicon.ico|hero-image|logo|.*\\.).*)'],
}
