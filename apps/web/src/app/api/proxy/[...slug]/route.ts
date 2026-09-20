import { NextRequest } from "next/server";
import { cookies } from "next/headers";

const BACKEND_URL = process.env.NEXT_PUBLIC_API_URL || "http://localhost:4000";

async function handleProxy(req: NextRequest, { params }: { params: Promise<{ slug: string[] }> }) {
  const cookieStore = await cookies();
  const accessToken = cookieStore.get("accessToken")?.value;

  const slugArgs = await params;
  const path = slugArgs.slug.join("/");
  const url = new URL(`${BACKEND_URL}/api/v1/${path}`);

  // Forward search params
  req.nextUrl.searchParams.forEach((value, key) => {
    url.searchParams.append(key, value);
  });

  const headers = new Headers();
  const contentType = req.headers.get("content-type");
  if (contentType) {
    headers.set("Content-Type", contentType);
  }

  const authHeader = req.headers.get("authorization");
  if (authHeader) {
    headers.set("Authorization", authHeader);
  } else if (accessToken) {
    headers.set("Authorization", `Bearer ${accessToken}`);
  }

  // Next.js consumes the body stream, so we must clone it or pass it.
  const hasBody = !["GET", "HEAD"].includes(req.method);
  const body = hasBody ? await req.text() : undefined;

  try {
    const response = await fetch(url.toString(), {
      method: req.method,
      headers,
      body,
    });

    const responseData = await response.text();

    return new Response(responseData, {
      status: response.status,
      statusText: response.statusText,
      headers: {
        "Content-Type": response.headers.get("content-type") || "application/json",
      },
    });
  } catch (error) {
    console.error("Proxy fetch error:", error);
    return new Response(JSON.stringify({ success: false, error: { message: "Internal Proxy Error" } }), {
      status: 500,
      headers: { "Content-Type": "application/json" },
    });
  }
}

export const GET = handleProxy;
export const POST = handleProxy;
export const PUT = handleProxy;
export const PATCH = handleProxy;
export const DELETE = handleProxy;
