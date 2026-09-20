import { useQuery } from '@tanstack/react-query'
import { api } from '@/shared/api/client/axios'
import { queryKeys } from '@/shared/query/query-keys'

export function useUsers(params: {
  page?: number
  pageSize?: number
  search?: string
  sortBy?: string
  sortOrder?: 'asc' | 'desc'
  role?: string
}) {
  return useQuery({
    queryKey: queryKeys.users.list(params),
    queryFn: async () => {
      // The generated SDK might throw an ApiError if status != 2xx
      // But we mapped 200 properly. Let's return the data
      return api.admin.getAdminUsers(
        params.page,
        params.pageSize,
        params.search,
        params.sortBy,
        params.sortOrder,
        params.role
      )
    },
  })
}
