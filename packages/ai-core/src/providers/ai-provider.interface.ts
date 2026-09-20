export interface GenerateRequest {
  prompt: string;
  systemInstruction?: string;
  temperature?: number;
  responseSchema?: any; // Zod schema or JSON schema depending on provider capabilities
}

export interface GenerateResponse {
  text: string;
  usageMetadata?: {
    promptTokenCount: number;
    candidatesTokenCount: number;
    totalTokenCount: number;
  };
}

export interface AIProvider {
  name: string;
  generateContent(request: GenerateRequest): Promise<GenerateResponse>;
}
