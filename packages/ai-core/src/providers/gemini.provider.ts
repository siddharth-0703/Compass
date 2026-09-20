import { GoogleGenAI } from '@google/genai';
import { AIProvider, GenerateRequest, GenerateResponse } from './ai-provider.interface';

export class GeminiProvider implements AIProvider {
  name = 'gemini';
  private apiKeys: string[];
  private currentKeyIndex = 0;
  private defaultModel = 'gemini-2.5-flash';

  constructor(apiKey?: string | string[]) {
    // In production, this falls back to GOOGLE_GENAI_API_KEY env var
    if (Array.isArray(apiKey) && apiKey.length > 0) {
      this.apiKeys = apiKey;
    } else if (typeof apiKey === 'string') {
      this.apiKeys = [apiKey];
    } else {
      this.apiKeys = [process.env.GOOGLE_GENAI_API_KEY || 'mock-key'];
    }
  }

  async generateContent(request: GenerateRequest): Promise<GenerateResponse> {
    const key = this.apiKeys[this.currentKeyIndex];
    this.currentKeyIndex = (this.currentKeyIndex + 1) % this.apiKeys.length;
    
    const ai = new GoogleGenAI({ apiKey: key });

    const response = await ai.models.generateContent({
      model: this.defaultModel,
      contents: request.prompt,
      config: {
        systemInstruction: request.systemInstruction,
        temperature: request.temperature,
        // @google/genai maps responseSchema to standard Gemini schema
        responseMimeType: request.responseSchema ? 'application/json' : 'text/plain',
        responseSchema: request.responseSchema, 
      }
    });

    return {
      text: response.text || '',
      usageMetadata: response.usageMetadata ? {
        promptTokenCount: response.usageMetadata.promptTokenCount ?? 0,
        candidatesTokenCount: response.usageMetadata.candidatesTokenCount ?? 0,
        totalTokenCount: response.usageMetadata.totalTokenCount ?? 0,
      } : undefined
    };
  }
}
