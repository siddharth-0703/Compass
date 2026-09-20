"use client"

import { BusinessRegistrationForm } from "@/features/businesses/components/BusinessRegistrationForm"
import { useDictionary } from "@/components/providers/DictionaryProvider"

export default function NewBusinessPage() {
  const { dict } = useDictionary()

  return (
    <div className="flex-1 space-y-4 p-4 md:p-8 pt-6 max-w-4xl mx-auto w-full">
      <div className="flex items-center justify-between space-y-2 mb-6">
        <h2 className="text-3xl font-bold tracking-tight">
          {dict.businessRegistration?.title || "Register New Business"}
        </h2>
      </div>
      
      <div className="glass-card p-6 rounded-2xl border border-white/10 bg-background/50">
        <BusinessRegistrationForm />
      </div>
    </div>
  )
}
