import { NextRequest, NextResponse } from "next/server";
import { cookies } from "next/headers";
import crypto from "crypto";

const BACKEND_URL = process.env.NEXT_PUBLIC_API_URL || "https://compass-1ej0.onrender.com";
const JWT_SECRET = process.env.JWT_SECRET || "rural-platform-jwt-secret-2024";

const DEMO_USER = {
  id: "66e0123456789abcdef01234",
  name: "Siddharth Jaiswar",
  firstName: "Siddharth",
  lastName: "Jaiswar",
  email: "siddharthjaiswar9107@gmail.com",
  phone: "+918779170923",
  role: "admin",
  roles: ["admin", "entrepreneur", "mentor", "ngo", "investor", "government"],
};

function generateDemoAccessToken(user: typeof DEMO_USER): string {
  const header = { alg: "HS256", typ: "JWT" };
  const payload = {
    userId: user.id,
    roles: user.roles,
    email: user.email,
    name: user.name,
    exp: Math.floor(Date.now() / 1000) + (7 * 24 * 60 * 60),
  };

  const encode = (obj: any) => Buffer.from(JSON.stringify(obj)).toString("base64url");
  const encodedHeader = encode(header);
  const encodedPayload = encode(payload);
  const signature = crypto
    .createHmac("sha256", JWT_SECRET)
    .update(`${encodedHeader}.${encodedPayload}`)
    .digest("base64url");

  return `${encodedHeader}.${encodedPayload}.${signature}`;
}

export async function POST(req: NextRequest) {
  try {
    const cookieStore = await cookies();
    const refreshToken = cookieStore.get("refreshToken")?.value;

    if (!refreshToken) {
      return NextResponse.json({ success: false, error: { message: "No refresh token" } }, { status: 401 });
    }

    // If it's a demo refresh token, refresh immediately without hitting backend
    if (refreshToken.startsWith("demo_refresh_token_")) {
      const accessToken = generateDemoAccessToken(DEMO_USER);
      cookieStore.set("accessToken", accessToken, {
        httpOnly: true,
        secure: process.env.NODE_ENV === "production",
        sameSite: "lax",
        maxAge: 7 * 24 * 60 * 60,
        path: "/",
      });
      return NextResponse.json({ success: true, message: "Token refreshed" }, { status: 200 });
    }

    const response = await fetch(`${BACKEND_URL}/api/v1/auth/refresh`, {
      method: "POST",
      headers: { "Content-Type": "application/json" },
      body: JSON.stringify({ refreshToken }),
    });

    const data = await response.json();

    if (!response.ok || !data.success) {
      cookieStore.delete("accessToken");
      cookieStore.delete("refreshToken");
      return NextResponse.json(data, { status: 401 });
    }

    const { accessToken } = data.data;

    cookieStore.set("accessToken", accessToken, {
      httpOnly: true,
      secure: process.env.NODE_ENV === "production",
      sameSite: "lax",
      maxAge: 7 * 24 * 60 * 60,
      path: "/",
    });

    return NextResponse.json({ success: true, message: "Token refreshed" }, { status: 200 });
  } catch (error) {
    return NextResponse.json({ success: false, error: { message: "Internal Auth Error" } }, { status: 500 });
  }
}
