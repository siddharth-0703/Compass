import { useQuery } from '@tanstack/react-query'
import { apiClient } from '@/shared/api/client/axios'
import { queryKeys } from '@/shared/query/query-keys'

export function useBusinesses(params: {
  page?: number
  pageSize?: number
  search?: string
  sortBy?: string
  sortOrder?: 'asc' | 'desc'
  status?: string
  category?: string
}) {
  return useQuery({
    queryKey: queryKeys.businesses.list(params),
    queryFn: async () => {
      const response = await apiClient.get("/api/proxy/businesses/me", { params })
      const businesses = response.data?.data || []
      return {
        ...response.data,
        data: {
          items: businesses,
          pagination: {
            totalItems: businesses.length,
            totalPages: 1,
            currentPage: 1,
            pageSize: businesses.length || 20
          }
        }
      }
    },
  })
}
