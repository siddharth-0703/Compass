import { useQuery } from '@tanstack/react-query'
import { apiClient } from '@/shared/api/client/axios'
import { queryKeys } from '@/shared/query/query-keys'

export function useBusiness(id: string) {
  return useQuery({
    queryKey: queryKeys.businesses.detail(id),
    queryFn: async () => {
      if (!id) return null
      const response = await apiClient.get(`/api/proxy/businesses/${id}`)
      return response.data?.data
    },
    enabled: !!id,
  })
}
