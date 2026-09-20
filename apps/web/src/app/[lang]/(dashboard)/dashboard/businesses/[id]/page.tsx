"use client"

import { useParams } from "next/navigation"
import { useBusiness } from "@/features/businesses/queries/use-business"
import { useDictionary } from "@/components/providers/DictionaryProvider"
import { Loader2, ArrowLeft, Edit2, Info, CheckCircle2, AlertCircle, Building2, ExternalLink } from "lucide-react"
import Link from "next/link"
import { Button } from "@/components/ui/button"
import { Card, CardContent, CardHeader, CardTitle, CardDescription } from "@/components/ui/card"
import { Badge } from "@/components/ui/badge"

export default function BusinessWorkspacePage() {
  const { dict, lang } = useDictionary()
  const params = useParams()
  const businessId = params.id as string

  const { data: business, isLoading, error } = useBusiness(businessId)

  const t = dict.businessWorkspace || {}

  if (isLoading) {
    return (
      <div className="flex-1 flex items-center justify-center p-8">
        <Loader2 className="h-8 w-8 animate-spin text-slate-400" />
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
            {t.backToBusinesses || "Back to Businesses"}
          </Button>
        </Link>
      </div>
    )
  }

  // Calculate Business Profile Setup completeness
  const checkFields = [
    { name: 'description', val: business.description },
    { name: 'category', val: business.category },
    { name: 'location', val: business.location?.state },
    { name: 'gstNumber', val: business.gstNumber },
    { name: 'msmeNumber', val: business.msmeNumber },
    { name: 'website', val: business.website },
    { name: 'employees', val: business.employees },
    { name: 'stage', val: business.stage },
    { name: 'languages', val: business.languages && business.languages.length > 0 ? true : undefined }
  ]
  const completedFields = checkFields.filter(f => f.val !== undefined && f.val !== null && f.val !== '').length
  const setupPercentage = Math.round((completedFields / checkFields.length) * 100)

  // Status Badge configurations
  const getStatusConfig = (status: string) => {
    switch(status) {
      case 'Verified':
      case 'APPROVED':
        return { color: 'bg-emerald-100 text-emerald-800', icon: <CheckCircle2 className="w-4 h-4 mr-1" />, message: t.statusVerified || "Your business is verified and active." }
      case 'Pending Verification':
      case 'PENDING':
        return { color: 'bg-amber-100 text-amber-800', icon: <Info className="w-4 h-4 mr-1" />, message: t.statusPending || "Your business is currently awaiting verification." }
      case 'Rejected':
        return { color: 'bg-red-100 text-red-800', icon: <AlertCircle className="w-4 h-4 mr-1" />, message: t.statusRejected || "Your business registration requires attention." }
      default:
        return { color: 'bg-slate-100 text-slate-800', icon: <Info className="w-4 h-4 mr-1" />, message: t.statusDraft || "Your business is in draft mode." }
    }
  }

  const statusConfig = getStatusConfig(business.status)

  return (
    <div className="flex-1 space-y-6 p-4 md:p-8 pt-6 max-w-6xl mx-auto w-full bg-slate-50 min-h-full">
      {/* Back button & Breadcrumb */}
      <div className="flex items-center space-x-2 text-slate-500 mb-2">
        <Link href={`/${lang}/dashboard/businesses`} className="hover:text-slate-900 flex items-center transition-colors">
          <ArrowLeft className="h-4 w-4 mr-1" />
          {dict.navigation?.businesses || "Businesses"}
        </Link>
      </div>

      {/* Business at a glance */}
      <Card className="border-slate-200 shadow-sm overflow-hidden">
        <div className={`px-6 py-4 flex flex-col md:flex-row md:items-center justify-between border-b ${statusConfig.color} bg-opacity-50`}>
          <div className="flex items-center text-sm font-medium">
            {statusConfig.icon}
            {statusConfig.message}
          </div>
          <div className="mt-2 md:mt-0 text-sm font-medium opacity-80">
            {t.setupCompleteness || "Setup completeness"}: {setupPercentage}%
          </div>
        </div>
        <CardContent className="p-6">
          <div className="flex flex-col md:flex-row md:items-start justify-between gap-6">
            <div className="space-y-2 flex-1">
              <div className="flex items-center gap-3">
                <h1 className="text-3xl font-bold tracking-tight text-slate-900">{business.name}</h1>
                <Badge variant="outline" className="bg-white">{business.category}</Badge>
              </div>
              
              <div className="text-slate-500 flex items-center gap-2 text-sm">
                <Building2 className="h-4 w-4" />
                {business.location?.district}, {business.location?.state}
              </div>

              <p className="text-slate-700 mt-4 leading-relaxed max-w-3xl">
                {business.description}
              </p>
            </div>

            <Link href={`/${lang}/dashboard/businesses/${business._id}/edit`}>
              <Button className="shrink-0 shadow-sm w-full md:w-auto">
                <Edit2 className="mr-2 h-4 w-4" />
                {dict.businessRegistration?.editTitle || "Edit Business"}
              </Button>
            </Link>
          </div>
        </CardContent>
      </Card>

      <div className="grid grid-cols-1 lg:grid-cols-3 gap-6">
        <div className="lg:col-span-2 space-y-6">
          {/* Business Details */}
          <Card className="border-slate-200 shadow-sm">
            <CardHeader className="pb-3 border-b border-slate-100">
              <CardTitle className="text-lg">{t.businessDetails || "Business Details"}</CardTitle>
            </CardHeader>
            <CardContent className="p-0">
              <div className="grid grid-cols-1 md:grid-cols-2 divide-y md:divide-y-0 md:divide-x divide-slate-100">
                <div className="p-4 space-y-1">
                  <div className="text-sm font-medium text-slate-500">{t.stage || "Stage"}</div>
                  <div className="text-base text-slate-900 capitalize">{business.stage || t.notSpecified || "Not specified"}</div>
                </div>
                <div className="p-4 space-y-1">
                  <div className="text-sm font-medium text-slate-500">{t.employees || "Employees"}</div>
                  <div className="text-base text-slate-900">{business.employees || t.notSpecified || "Not specified"}</div>
                </div>
                <div className="p-4 space-y-1 md:border-t border-slate-100">
                  <div className="text-sm font-medium text-slate-500">{t.website || "Website"}</div>
                  <div className="text-base text-slate-900">
                    {business.website ? (
                      <a href={business.website} target="_blank" rel="noopener noreferrer" className="text-blue-600 hover:underline inline-flex items-center">
                        {business.website} <ExternalLink className="h-3 w-3 ml-1" />
                      </a>
                    ) : (t.notSpecified || "Not specified")}
                  </div>
                </div>
                <div className="p-4 space-y-1 md:border-t border-slate-100">
                  <div className="text-sm font-medium text-slate-500">{t.languages || "Languages"}</div>
                  <div className="text-base text-slate-900">
                    {business.languages?.length > 0 ? business.languages.join(", ") : (t.notSpecified || "Not specified")}
                  </div>
                </div>
              </div>
            </CardContent>
          </Card>

          {/* Registration & Organization */}
          <Card className="border-slate-200 shadow-sm">
            <CardHeader className="pb-3 border-b border-slate-100">
              <CardTitle className="text-lg">{t.registrationOrganization || "Registration & Organization"}</CardTitle>
            </CardHeader>
            <CardContent className="p-0">
              <div className="grid grid-cols-1 md:grid-cols-2 divide-y md:divide-y-0 md:divide-x divide-slate-100">
                <div className="p-4 space-y-1">
                  <div className="text-sm font-medium text-slate-500">{t.gstNumber || "GST Number"}</div>
                  <div className="text-base font-mono text-slate-900">{business.gstNumber || (t.notRegistered || "Not registered")}</div>
                </div>
                <div className="p-4 space-y-1">
                  <div className="text-sm font-medium text-slate-500">{t.msmeNumber || "MSME Number"}</div>
                  <div className="text-base font-mono text-slate-900">{business.msmeNumber || (t.notRegistered || "Not registered")}</div>
                </div>
                <div className="p-4 space-y-1 md:border-t border-slate-100">
                  <div className="text-sm font-medium text-slate-500">{t.womenOwned || "Women Owned"}</div>
                  <div className="text-base text-slate-900">{business.womenOwned ? (t.yes || "Yes") : (t.no || "No")}</div>
                </div>
                <div className="p-4 space-y-1 md:border-t border-slate-100">
                  <div className="text-sm font-medium text-slate-500">{t.fpo || "Farmer Producer Org (FPO)"}</div>
                  <div className="text-base text-slate-900">{business.farmerProducerOrganization ? (t.yes || "Yes") : (t.no || "No")}</div>
                </div>
              </div>
            </CardContent>
          </Card>
        </div>

        {/* Quick Actions Side Panel */}
        <div className="space-y-6">
          <Card className="border-slate-200 shadow-sm bg-slate-900 text-white">
            <CardHeader>
              <CardTitle className="text-lg text-white">{t.quickActionsTitle || "What would you like to do?"}</CardTitle>
              <CardDescription className="text-slate-300">
                {t.quickActionsDesc || "Connect your business to Compass tools."}
              </CardDescription>
            </CardHeader>
            <CardContent className="space-y-3">
              <Link href={`/${lang}/dashboard/mentorship?businessId=${business._id}`} className="block w-full">
                <Button variant="secondary" className="w-full justify-start font-medium h-12 bg-slate-800 text-white hover:bg-slate-700 hover:text-white border-none">
                  {t.findMentor || "Find a Mentor"}
                </Button>
              </Link>
              <Link href={`/${lang}/dashboard/schemes`} className="block w-full">
                <Button variant="secondary" className="w-full justify-start font-medium h-12 bg-slate-800 text-white hover:bg-slate-700 hover:text-white border-none">
                  {t.exploreSchemes || "Explore Schemes"}
                </Button>
              </Link>
              <Link href={`/${lang}/dashboard/mandi`} className="block w-full">
                <Button variant="secondary" className="w-full justify-start font-medium h-12 bg-slate-800 text-white hover:bg-slate-700 hover:text-white border-none">
                  {t.checkMarketPrices || "Check Market Prices"}
                </Button>
              </Link>
              <Link href={`/${lang}/dashboard/learning`} className="block w-full">
                <Button variant="secondary" className="w-full justify-start font-medium h-12 bg-slate-800 text-white hover:bg-slate-700 hover:text-white border-none">
                  {t.continueLearning || "Continue Learning"}
                </Button>
              </Link>
            </CardContent>
          </Card>

          <Card className="border-slate-200 shadow-sm">
            <CardHeader className="pb-3">
              <CardTitle className="text-lg">{t.timeline || "Timeline"}</CardTitle>
            </CardHeader>
            <CardContent className="space-y-4">
              <div>
                <div className="text-sm font-medium text-slate-500">{t.registeredOn || "Registered On"}</div>
                <div className="text-sm text-slate-900">
                  {new Date(business.createdAt).toLocaleDateString(undefined, { year: 'numeric', month: 'long', day: 'numeric' })}
                </div>
              </div>
              <div>
                <div className="text-sm font-medium text-slate-500">{t.lastUpdated || "Last Updated"}</div>
                <div className="text-sm text-slate-900">
                  {new Date(business.updatedAt).toLocaleDateString(undefined, { year: 'numeric', month: 'long', day: 'numeric' })}
                </div>
              </div>
            </CardContent>
          </Card>
        </div>
      </div>
    </div>
  )
}
