"use client"

import { useState } from "react"
import { useUsers } from "@/features/users/queries/use-users"
import { columns, UserRow } from "@/features/users/components/columns"
import { DataTable } from "@/shared/components/data-table/DataTable"
import { DataTablePagination } from "@/shared/components/data-table/DataTablePagination"

export default function UsersPage() {
  const [pagination, setPagination] = useState({
    pageIndex: 0, // 0-based for TanStack Table
    pageSize: 20,
  })

  // We add +1 to pageIndex because the API expects 1-based page index
  const { data, isLoading, isPlaceholderData } = useUsers({
    page: pagination.pageIndex + 1,
    pageSize: pagination.pageSize,
  })

  const items = (data?.data?.items || []) as UserRow[]
  const totalItems = data?.data?.pagination?.totalItems || 0
  const pageCount = data?.data?.pagination?.totalPages || -1

  return (
    <div className="flex-1 space-y-4 p-4 md:p-8 pt-6">
      <div className="flex items-center justify-between space-y-2">
        <h2 className="text-3xl font-bold tracking-tight">Users</h2>
      </div>
      
      <div className="space-y-4">
        <DataTable
          columns={columns}
          data={items}
          pageCount={pageCount}
          pagination={pagination}
          onPaginationChange={setPagination}
          isLoading={isLoading}
          isPlaceholderData={isPlaceholderData}
        />
        <DataTablePagination 
          table={{
            getState: () => ({ pagination }),
            setPageIndex: (index: number) => setPagination(prev => ({ ...prev, pageIndex: index })),
            setPageSize: (size: number) => setPagination({ pageIndex: 0, pageSize: size }),
            getCanPreviousPage: () => pagination.pageIndex > 0,
            getCanNextPage: () => pagination.pageIndex < pageCount - 1,
            getPageCount: () => pageCount,
            previousPage: () => setPagination(prev => ({ ...prev, pageIndex: prev.pageIndex - 1 })),
            nextPage: () => setPagination(prev => ({ ...prev, pageIndex: prev.pageIndex + 1 })),
          } as any}
          totalItems={totalItems} 
        />
      </div>
    </div>
  )
}
