export const queryKeys = {
  users: {
    all: ['users'] as const,
    list: (filters: Record<string, any>) => ['users', 'list', filters] as const,
    detail: (id: string) => ['users', 'detail', id] as const,
  },
  businesses: {
    all: ['businesses'] as const,
    list: (filters: Record<string, any>) => ['businesses', 'list', filters] as const,
    detail: (id: string) => ['businesses', 'detail', id] as const,
  },
  reports: {
    all: ['reports'] as const,
    list: (filters: Record<string, any>) => ['reports', 'list', filters] as const,
  },
  metrics: {
    platform: () => ['metrics', 'platform'] as const,
  }
} as const;
