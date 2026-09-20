import axios, { AxiosError } from "axios";
import { getIsRefreshing, setIsRefreshing, processQueue, addRequestToQueue } from "./retry-queue";
import { RuralApi } from "../generated";

// Attach interceptors to the global axios instance since the generated SDK uses it
axios.interceptors.response.use(
  (response) => {
    return response;
  },
  async (error: AxiosError) => {
    const originalRequest = error.config;

    if (!originalRequest) {
      return Promise.reject(error);
    }

    if (error.response?.status === 401) {
      // Prevent infinite loop if the refresh token endpoint itself returns 401
      if (originalRequest.url?.includes("/auth/refresh")) {
        if (typeof window !== "undefined") {
          window.location.href = "/login";
        }
        return Promise.reject(error);
      }

      if (!getIsRefreshing()) {
        setIsRefreshing(true);

        try {
          // Call the BFF refresh route
          await axios.post("/api/auth/refresh");

          setIsRefreshing(false);
          processQueue(null, "refreshed");

          // Replay original request
          return axios(originalRequest);
        } catch (refreshError: any) {
          setIsRefreshing(false);
          processQueue(refreshError, null);
          
          if (typeof window !== "undefined") {
            window.location.href = "/login";
          }
          return Promise.reject(refreshError);
        }
      }

      // If already refreshing, add to queue
      return addRequestToQueue(originalRequest);
    }

    return Promise.reject(error);
  }
);

export { axios as apiClient };

export const api = new RuralApi({
  BASE: "/api/proxy",
});
