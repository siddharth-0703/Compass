import { AxiosError } from "axios";

export class ApiError extends Error {
  public status: number;
  public code: string;
  public details?: any;

  constructor(message: string, status: number, code: string = "UNKNOWN_ERROR", details?: any) {
    super(message);
    this.name = "ApiError";
    this.status = status;
    this.code = code;
    this.details = details;
  }
}

export function mapAxiosError(error: unknown): ApiError {
  if (error instanceof AxiosError) {
    const data = error.response?.data;
    
    // Handle our backend's structured ErrorResponse
    if (data && !data.success && data.error) {
      return new ApiError(
        data.error.message || "An error occurred",
        error.response?.status || 500,
        data.error.code,
        data.error.details
      );
    }

    return new ApiError(error.message, error.response?.status || 500, "NETWORK_ERROR");
  }

  if (error instanceof Error) {
    return new ApiError(error.message, 500);
  }

  return new ApiError("An unknown error occurred", 500);
}
