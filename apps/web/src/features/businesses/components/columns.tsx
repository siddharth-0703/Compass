"use client"

import { ColumnDef } from "@tanstack/react-table"
import { Badge } from "@/components/ui/badge"
import { Button, buttonVariants } from "@/components/ui/button"
import { cn } from "@/lib/utils"
import { Trash2, Edit2, Eye } from "lucide-react"
import { useQueryClient } from "@tanstack/react-query"
import { queryKeys } from "@/shared/query/query-keys"
import { apiClient } from "@/shared/api/client/axios"
import Link from "next/link"
import { useState } from "react"
import {
  AlertDialog,
  AlertDialogAction,
  AlertDialogCancel,
  AlertDialogContent,
  AlertDialogDescription,
  AlertDialogFooter,
  AlertDialogHeader,
  AlertDialogTitle,
  AlertDialogTrigger,
} from "@/components/ui/alert-dialog"
import { useParams } from "next/navigation"

export type BusinessRow = {
  _id: string
  name: string
  category: string
  status: string
  userId?: {
    _id: string
    phone: string
    email?: string
  }
  gstNumber?: string
  createdAt: string
}

export const columns: ColumnDef<BusinessRow>[] = [
  {
    accessorKey: "name",
    header: "Business Name",
  },
  {
    accessorKey: "category",
    header: "Category",
    cell: ({ row }) => {
      return <Badge variant="outline">{row.getValue("category")}</Badge>
    }
  },
  {
    accessorKey: "gstNumber",
    header: "Reg No.",
    cell: ({ row }) => {
      return <span>{row.getValue("gstNumber") || "-"}</span>
    }
  },
  {
    accessorKey: "status",
    header: "Status",
    cell: ({ row }) => {
      const status = row.getValue("status") as string
      return (
        <Badge variant={status === "PENDING" ? "secondary" : status === "APPROVED" ? "default" : "destructive"}>
          {status}
        </Badge>
      )
    },
  },
  {
    accessorKey: "createdAt",
    header: "Registered On",
    cell: ({ row }) => {
      const date = new Date(row.getValue("createdAt"))
      return <span>{date.toLocaleDateString()}</span>
    },
  },
  {
    id: "actions",
    cell: ({ row }) => {
      const business = row.original
      const queryClient = useQueryClient()
      const [isDeleting, setIsDeleting] = useState(false)
      const lang = typeof window !== 'undefined' ? window.location.pathname.split('/')[1] : 'en'

      const handleDelete = async () => {
        setIsDeleting(true)
        try {
          const res = await apiClient.delete(`/api/proxy/businesses/${business._id}`)
          if (res.data?.success) {
            queryClient.invalidateQueries({ queryKey: queryKeys.businesses.all })
          }
        } catch (error) {
          console.error("Failed to delete business", error)
        } finally {
          setIsDeleting(false)
        }
      }

      return (
        <div className="flex items-center justify-end gap-2">
          <Link 
            href={`/${lang}/dashboard/businesses/${business._id}`} 
            className={cn(buttonVariants({ variant: "ghost", size: "icon" }), "text-slate-600 hover:bg-slate-100 hover:text-slate-900")} 
            title="View Workspace"
          >
            <Eye className="h-4 w-4" />
          </Link>
          <Link 
            href={`/${lang}/dashboard/businesses/${business._id}/edit`} 
            className={cn(buttonVariants({ variant: "ghost", size: "icon" }), "text-slate-600 hover:bg-slate-100 hover:text-slate-900")} 
            title="Edit Business"
          >
            <Edit2 className="h-4 w-4" />
          </Link>
          <AlertDialog>
            <AlertDialogTrigger render={<Button variant="ghost" size="icon" className="text-destructive hover:bg-destructive/10 hover:text-destructive" title="Delete Business" />}>
              <Trash2 className="h-4 w-4" />
            </AlertDialogTrigger>
            <AlertDialogContent>
              <AlertDialogHeader>
                <AlertDialogTitle>Are you absolutely sure?</AlertDialogTitle>
                <AlertDialogDescription>
                  This action cannot be undone. This will permanently delete your business registration for <strong>{business.name}</strong> and remove all associated data.
                </AlertDialogDescription>
              </AlertDialogHeader>
              <AlertDialogFooter>
                <AlertDialogCancel disabled={isDeleting}>Cancel</AlertDialogCancel>
                <AlertDialogAction onClick={handleDelete} disabled={isDeleting} className="bg-destructive text-destructive-foreground hover:bg-destructive/90">
                  {isDeleting ? "Deleting..." : "Delete Business"}
                </AlertDialogAction>
              </AlertDialogFooter>
            </AlertDialogContent>
          </AlertDialog>
        </div>
      )
    },
  }
]
