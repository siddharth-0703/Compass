import axios, { AxiosError, AxiosRequestConfig } from 'axios';

let isRefreshing = false;
let failedQueue: {
  resolve: (value?: unknown) => void;
  reject: (reason?: any) => void;
}[] = [];

export const processQueue = (error: AxiosError | null, token: string | null = null) => {
  failedQueue.forEach(prom => {
    if (error) {
      prom.reject(error);
    } else {
      prom.resolve(token);
    }
  });

  failedQueue = [];
};

export const addRequestToQueue = (originalRequest: AxiosRequestConfig) => {
  return new Promise((resolve, reject) => {
    failedQueue.push({ resolve, reject });
  }).then(token => {
    return axios(originalRequest);
  }).catch(err => {
    return Promise.reject(err);
  });
};

export const getIsRefreshing = () => isRefreshing;
export const setIsRefreshing = (state: boolean) => {
  isRefreshing = state;
};
