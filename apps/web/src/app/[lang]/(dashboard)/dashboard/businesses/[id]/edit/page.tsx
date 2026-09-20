"use client"

import { useParams } from "next/navigation"
import { useBusiness } from "@/features/businesses/queries/use-business"
import { BusinessRegistrationForm } from "@/features/businesses/components/BusinessRegistrationForm"
import { useDictionary } from "@/components/providers/DictionaryProvider"
import { Loader2 } from "lucide-react"
import Link from "next/link"
import { Button } from "@/components/ui/button"
import { ArrowLeft } from "lucide-react"

export default function EditBusinessPage() {
  const { dict, lang } = useDictionary()
  const params = useParams()
  const businessId = params.id as string

  const { data: business, isLoading, error } = useBusiness(businessId)

  if (isLoading) {
    return (
      <div className="flex-1 flex items-center justify-center p-8">
        <Loader2 className="h-8 w-8 animate-spin text-muted-foreground" />
      </div>
    )
  }

  if (error || !business) {
    return (
      <div className="flex-1 flex flex-col items-center justify-center p-8 space-y-4">
        <div className="text-destructive font-semibold text-lg">
          {dict.businessRegistration?.notFound || "Business not found."}
        </div>
        <Link href={`/${lang}/dashboard/businesses`}>
          <Button variant="outline">
            <ArrowLeft className="mr-2 h-4 w-4" />
            {dict.common?.back || "Back to Businesses"}
          </Button>
        </Link>
      </div>
    )
  }

  return (
    <div className="flex-1 space-y-4 p-4 md:p-8 pt-6 max-w-4xl mx-auto w-full">
      <div className="flex items-center space-x-4 mb-6">
        <Link href={`/${lang}/dashboard/businesses`}>
          <Button variant="ghost" size="icon" className="hover:bg-muted">
            <ArrowLeft className="h-5 w-5" />
          </Button>
        </Link>
        <h2 className="text-3xl font-bold tracking-tight text-slate-900">
          {dict.businessRegistration?.editTitle || "Edit Business"}
        </h2>
      </div>
      
      <div className="bg-white p-6 rounded-2xl border border-slate-200 shadow-sm">
        <BusinessRegistrationForm initialData={business} />
      </div>
    </div>
  )
}
