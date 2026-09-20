"use client"

import { useState } from "react"
import { useBusinesses } from "@/features/businesses/queries/use-businesses"
import { columns, BusinessRow } from "@/features/businesses/components/columns"
import { DataTable } from "@/shared/components/data-table/DataTable"
import { DataTablePagination } from "@/shared/components/data-table/DataTablePagination"
import { Button } from "@/components/ui/button"
import { Input } from "@/components/ui/input"
import { Card, CardContent, CardHeader, CardTitle } from "@/components/ui/card"
import Link from "next/link"
import { Plus, Search, Building2, Clock, CheckCircle2 } from "lucide-react"
import { useDictionary } from "@/components/providers/DictionaryProvider"

export default function BusinessesPage() {
  const { dict, lang } = useDictionary()
  const [searchTerm, setSearchTerm] = useState("")
  const [pagination, setPagination] = useState({
    pageIndex: 0,
    pageSize: 20,
  })

  // Debounce search term could be implemented here, but for now we pass it directly
  const { data, isLoading, isPlaceholderData } = useBusinesses({
    page: pagination.pageIndex + 1,
    pageSize: pagination.pageSize,
    search: searchTerm || undefined,
  })

  const items = (data?.data?.items || []) as BusinessRow[]
  const totalItems = data?.data?.pagination?.totalItems || 0
  const pageCount = data?.data?.pagination?.totalPages || -1

  // Compute metrics from the currently fetched items (or ideal would be from an API endpoint)
  const totalBusinesses = totalItems
  const pendingBusinesses = items.filter(b => b.status === 'Draft' || b.status === 'Pending Verification').length
  const activeBusinesses = items.filter(b => b.status === 'Verified' || b.status === 'APPROVED').length

  return (
    <div className="flex-1 space-y-8 p-4 md:p-8 pt-6 bg-slate-50 min-h-full">
      <div className="flex flex-col sm:flex-row sm:items-center justify-between space-y-4 sm:space-y-0">
        <div>
          <h2 className="text-3xl font-bold tracking-tight text-slate-900">{dict.dashboard?.activeBusinesses || "Businesses"}</h2>
          <p className="text-slate-500 mt-1">Manage and track all your registered businesses</p>
        </div>
        <Link href={`/${lang}/dashboard/businesses/new`}>
          <Button className="shadow-sm">
            <Plus className="mr-2 h-4 w-4" />
            {dict.dashboard?.registerBusiness || "Register Business"}
          </Button>
        </Link>
      </div>
      
      {/* Metrics Section */}
      <div className="grid gap-4 md:grid-cols-3">
        <Card className="shadow-sm border-slate-200">
          <CardHeader className="flex flex-row items-center justify-between space-y-0 pb-2">
            <CardTitle className="text-sm font-medium text-slate-600">Total Businesses</CardTitle>
            <Building2 className="h-4 w-4 text-slate-400" />
          </CardHeader>
          <CardContent>
            <div className="text-2xl font-bold text-slate-900">{totalBusinesses}</div>
          </CardContent>
        </Card>
        <Card className="shadow-sm border-slate-200">
          <CardHeader className="flex flex-row items-center justify-between space-y-0 pb-2">
            <CardTitle className="text-sm font-medium text-slate-600">Pending Verification</CardTitle>
            <Clock className="h-4 w-4 text-amber-500" />
          </CardHeader>
          <CardContent>
            <div className="text-2xl font-bold text-slate-900">{pendingBusinesses}</div>
          </CardContent>
        </Card>
        <Card className="shadow-sm border-slate-200">
          <CardHeader className="flex flex-row items-center justify-between space-y-0 pb-2">
            <CardTitle className="text-sm font-medium text-slate-600">Verified & Active</CardTitle>
            <CheckCircle2 className="h-4 w-4 text-emerald-500" />
          </CardHeader>
          <CardContent>
            <div className="text-2xl font-bold text-slate-900">{activeBusinesses}</div>
          </CardContent>
        </Card>
      </div>

      <Card className="shadow-sm border-slate-200">
        <div className="p-6">
          <div className="flex items-center mb-6 max-w-sm">
            <div className="relative w-full">
              <Search className="absolute left-2.5 top-2.5 h-4 w-4 text-slate-500" />
              <Input
                placeholder="Search businesses..."
                className="pl-9 bg-white"
                value={searchTerm}
                onChange={(e) => setSearchTerm(e.target.value)}
              />
            </div>
          </div>
          
          <div className="space-y-4">
            {items.length === 0 && !isLoading ? (
              <div className="flex flex-col items-center justify-center py-16 text-center border rounded-lg border-dashed border-slate-300 bg-slate-50/50">
                <div className="h-16 w-16 bg-white rounded-full flex items-center justify-center shadow-sm mb-4">
                  <Building2 className="h-8 w-8 text-slate-400" />
                </div>
                <h3 className="text-lg font-semibold text-slate-900">No businesses found</h3>
                <p className="text-slate-500 max-w-sm mt-1 mb-4">
                  {searchTerm 
                    ? "Try adjusting your search filters to find what you're looking for." 
                    : "You haven't registered any businesses yet. Register your first business to get started."}
                </p>
                {!searchTerm && (
                  <Link href={`/${lang}/dashboard/businesses/new`}>
                    <Button variant="outline" className="shadow-sm">Register a Business</Button>
                  </Link>
                )}
              </div>
            ) : (
              <>
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
              </>
            )}
          </div>
        </div>
      </Card>
    </div>
  )
}
