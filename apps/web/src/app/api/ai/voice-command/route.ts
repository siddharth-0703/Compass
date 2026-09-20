import { NextRequest, NextResponse } from "next/server";
import { GoogleGenerativeAI } from "@google/generative-ai";

const apiKey = process.env.GEMINI_API_KEY;

export async function POST(req: NextRequest) {
  try {
    if (!apiKey) {
      console.warn("GEMINI_API_KEY not set in environment.");
      return NextResponse.json(
        { success: false, error: "API key not configured" },
        { status: 500 }
      );
    }

    const { query, currentLanguage = "en" } = await req.json();

    if (!query) {
      return NextResponse.json(
        { success: false, error: "No query provided" },
        { status: 400 }
      );
    }

    const genAI = new GoogleGenerativeAI(apiKey);
    const model = genAI.getGenerativeModel({
      model: "gemini-flash-latest",
      generationConfig: {
        responseMimeType: "application/json",
        temperature: 0.1, // low temp for predictable routing
      },
    });

    const prompt = `You are an AI assistant for the Compass rural entrepreneur portal.
Map the user query to an action.
Actions: 
- NAVIGATE: to routes /dashboard/schemes, /dashboard/learning, /dashboard/mentorship, /dashboard
- SEARCH: search courses or schemes.
- ANSWER: if the user asks a general question (e.g., "what is marketing?", "how to grow tomatoes?"). Answer concisely in 1-2 short sentences.
- UNKNOWN: if totally unrelated.

JSON schema: {"action":"NAVIGATE"|"SEARCH"|"ANSWER"|"UNKNOWN","path":string,"speechResponse":string,"searchQuery"?:string,"confidence":number(0.0-1.0)}
Language for speechResponse: ${currentLanguage}
(Note: for ANSWER and UNKNOWN actions, set "path" to an empty string "")
Query: "${query}"

Respond with ONLY the raw JSON object. Do not include markdown formatting, backticks, or any other text.`;

    const result = await model.generateContent(prompt);
    let responseText = result.response.text();
    
    // Strip markdown formatting if gemini-pro returns it
    responseText = responseText.replace(/```json/g, '').replace(/```/g, '').trim();
    
    let actionPayload;
    try {
      actionPayload = JSON.parse(responseText);
    } catch (e) {
      // Fallback if parsing fails
      actionPayload = {
        action: "UNKNOWN",
        path: "",
        speechResponse: "I am having trouble understanding that.",
        confidence: 0
      };
    }

    return NextResponse.json({
      success: true,
      data: actionPayload,
    });
  } catch (error: any) {
    console.error("AI Voice Command Error:", error);
    return NextResponse.json(
      { success: false, error: error.message || "Internal server error" },
      { status: 500 }
    );
  }
}
