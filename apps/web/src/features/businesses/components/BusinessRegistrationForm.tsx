"use client"

import { useState } from "react"
import { useForm } from "react-hook-form"
import { zodResolver } from "@hookform/resolvers/zod"
import * as z from "zod"
import axios from "axios"
import { useRouter } from "next/navigation"

import { useQueryClient } from "@tanstack/react-query"
import { useDictionary } from "@/components/providers/DictionaryProvider"
import { queryKeys } from "@/shared/query/query-keys"
import { Button } from "@/components/ui/button"
import {
  Form,
  FormControl,
  FormDescription,
  FormField,
  FormItem,
  FormLabel,
  FormMessage,
} from "@/components/ui/form"
import { Input } from "@/components/ui/input"
import { Textarea } from "@/components/ui/textarea"

const BusinessCategories = [
  'Agriculture', 'Food Processing', 'Handicrafts', 'Textiles', 'Retail', 
  'Services', 'Manufacturing', 'Livestock', 'Tourism', 'Education', 
  'Technology', 'Healthcare', 'Fisheries'
] as const

const formSchema = z.object({
  name: z.string().min(3, "Must be at least 3 characters").max(100),
  description: z.string().min(10, "Must be at least 10 characters").max(2000),
  category: z.enum(BusinessCategories),
  gstNumber: z.string().optional(),
  msmeNumber: z.string().optional(),
  womenOwned: z.boolean().optional(),
  farmerProducerOrganization: z.boolean().optional(),
  stage: z.enum(['idea', 'early', 'growth', 'mature']).optional().or(z.literal('')),
  employees: z.coerce.number().min(0).optional().or(z.literal('')),
  website: z.string().url("Must be a valid URL").optional().or(z.literal('')),
  languages: z.string().optional(),
  location: z.object({
    state: z.string().min(2, "State is required"),
    district: z.string().min(2, "District is required"),
    pincode: z.string().regex(/^\d{6}$/, "Must be a valid 6-digit PIN code"),
  }),
})

type FormValues = z.infer<typeof formSchema>

interface BusinessRegistrationFormProps {
  initialData?: any
}

export function BusinessRegistrationForm({ initialData }: BusinessRegistrationFormProps) {
  const { dict, lang } = useDictionary()
  const router = useRouter()
  const queryClient = useQueryClient()
  const [isSubmitting, setIsSubmitting] = useState(false)
  const [errorMsg, setErrorMsg] = useState("")

  const t = dict.businessRegistration || {}

  const form = useForm<FormValues>({
    resolver: zodResolver(formSchema),
    defaultValues: {
      name: initialData?.name || "",
      description: initialData?.description || "",
      category: initialData?.category || "Agriculture",
      gstNumber: initialData?.gstNumber || "",
      msmeNumber: initialData?.msmeNumber || "",
      womenOwned: !!initialData?.womenOwned,
      farmerProducerOrganization: !!initialData?.farmerProducerOrganization,
      stage: initialData?.stage || "",
      employees: initialData?.employees?.toString() || "",
      website: initialData?.website || "",
      languages: initialData?.languages?.join(", ") || "",
      location: {
        state: initialData?.location?.state || "",
        district: initialData?.location?.district || "",
        pincode: initialData?.location?.pincode || "",
      },
    },
  })

  async function onSubmit(data: FormValues) {
    setIsSubmitting(true)
    setErrorMsg("")
    try {
      const payload = {
        ...data,
        stage: data.stage === "" ? undefined : data.stage,
        employees: data.employees === "" ? undefined : Number(data.employees),
        website: data.website === "" ? undefined : data.website,
        languages: data.languages ? data.languages.split(',').map((l: string) => l.trim()).filter(Boolean) : undefined
      }

      let response;
      if (initialData?._id) {
        response = await axios.patch(`/api/proxy/businesses/${initialData._id}`, payload)
      } else {
        response = await axios.post("/api/proxy/businesses", payload)
      }
      if (response.data?.success) {
        await queryClient.invalidateQueries({ queryKey: queryKeys.businesses.all })
        router.push(`/${lang}/dashboard/businesses`)
        router.refresh()
      } else {
        setErrorMsg(response.data?.error?.message || t.errorMsg || "Failed to register business")
      }
    } catch (error: any) {
      console.error(error)
      setErrorMsg(error.response?.data?.error?.message || t.errorMsg || "An error occurred while registering")
    } finally {
      setIsSubmitting(false)
    }
  }

  return (
    <Form {...form}>
      <form onSubmit={form.handleSubmit(onSubmit)} className="space-y-6">
        {errorMsg && (
          <div className="p-3 bg-red-500/10 border border-red-500/20 rounded text-red-500 text-sm">
            {errorMsg}
          </div>
        )}

        <div className="grid grid-cols-1 md:grid-cols-2 gap-6">
          <div className="space-y-4">
            <h3 className="font-semibold text-lg">{t.basicInfo || "Basic Information"}</h3>
            
            <FormField
              control={form.control}
              name="name"
              render={({ field }) => (
                <FormItem>
                  <FormLabel>{t.businessName || "Business Name"} *</FormLabel>
                  <FormControl>
                    <Input placeholder={t.businessNamePlaceholder || "Enter business name"} {...field} />
                  </FormControl>
                  <FormMessage />
                </FormItem>
              )}
            />

            <FormField
              control={form.control}
              name="category"
              render={({ field }) => (
                <FormItem>
                  <FormLabel>{t.category || "Category"} *</FormLabel>
                  <FormControl>
                    <select
                      className="flex h-10 w-full rounded-md border border-input bg-transparent px-3 py-2 text-sm ring-offset-background file:border-0 file:bg-transparent file:text-sm file:font-medium placeholder:text-muted-foreground focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-ring focus-visible:ring-offset-2 disabled:cursor-not-allowed disabled:opacity-50"
                      {...field}
                    >
                      {BusinessCategories.map(cat => (
                        <option key={cat} value={cat} className="bg-background text-foreground">
                          {cat}
                        </option>
                      ))}
                    </select>
                  </FormControl>
                  <FormMessage />
                </FormItem>
              )}
            />

            <FormField
              control={form.control}
              name="description"
              render={({ field }) => (
                <FormItem>
                  <FormLabel>{t.description || "Description"} *</FormLabel>
                  <FormControl>
                    <Textarea 
                      placeholder={t.descriptionPlaceholder || "Briefly describe your business operations"} 
                      {...field} 
                    />
                  </FormControl>
                  <FormMessage />
                </FormItem>
              )}
            />
            
            <FormField
              control={form.control}
              name="gstNumber"
              render={({ field }) => (
                <FormItem>
                  <FormLabel>{t.gstNumber || "GST Number (Optional)"}</FormLabel>
                  <FormControl>
                    <Input placeholder="e.g. 27AADCB2230M1Z2" {...field} />
                  </FormControl>
                  <FormMessage />
                </FormItem>
              )}
            />

            <FormField
              control={form.control}
              name="msmeNumber"
              render={({ field }) => (
                <FormItem>
                  <FormLabel>{t.msmeNumber || "MSME Number (Optional)"}</FormLabel>
                  <FormControl>
                    <Input placeholder="e.g. UDYAM-MH-12-3456789" {...field} />
                  </FormControl>
                  <FormMessage />
                </FormItem>
              )}
            />
          </div>

          <div className="space-y-4">
            <h3 className="font-semibold text-lg">{t.locationInfo || "Location Information"}</h3>
            
            <FormField
              control={form.control}
              name="location.state"
              render={({ field }) => (
                <FormItem>
                  <FormLabel>{t.state || "State"} *</FormLabel>
                  <FormControl>
                    <Input placeholder={t.statePlaceholder || "e.g. Maharashtra"} {...field} />
                  </FormControl>
                  <FormMessage />
                </FormItem>
              )}
            />

            <FormField
              control={form.control}
              name="location.district"
              render={({ field }) => (
                <FormItem>
                  <FormLabel>{t.district || "District"} *</FormLabel>
                  <FormControl>
                    <Input placeholder={t.districtPlaceholder || "e.g. Pune"} {...field} />
                  </FormControl>
                  <FormMessage />
                </FormItem>
              )}
            />

            <FormField
              control={form.control}
              name="location.pincode"
              render={({ field }) => (
                <FormItem>
                  <FormLabel>{t.pincode || "Pincode"} *</FormLabel>
                  <FormControl>
                    <Input placeholder={t.pincodePlaceholder || "e.g. 411001"} maxLength={6} {...field} />
                  </FormControl>
                  <FormMessage />
                </FormItem>
              )}
            />
          </div>
          <div className="space-y-4 pt-6 md:pt-0">
            <h3 className="font-semibold text-lg">{t.additionalDetails || "Additional Details"}</h3>

            <FormField
              control={form.control}
              name="stage"
              render={({ field }) => (
                <FormItem>
                  <FormLabel>{t.businessStage || "Business Stage"}</FormLabel>
                  <FormControl>
                    <select
                      className="flex h-10 w-full rounded-md border border-input bg-transparent px-3 py-2 text-sm ring-offset-background disabled:opacity-50"
                      {...field}
                    >
                      <option value="">{t.selectStage || "Select Stage"}</option>
                      <option value="idea">Idea / Planning</option>
                      <option value="early">Early Stage</option>
                      <option value="growth">Growth Stage</option>
                      <option value="mature">Mature / Established</option>
                    </select>
                  </FormControl>
                  <FormMessage />
                </FormItem>
              )}
            />

            <FormField
              control={form.control}
              name="employees"
              render={({ field }) => (
                <FormItem>
                  <FormLabel>{t.employeesCount || "Number of Employees"}</FormLabel>
                  <FormControl>
                    <Input type="number" min="0" placeholder="e.g. 5" {...field} />
                  </FormControl>
                  <FormMessage />
                </FormItem>
              )}
            />

            <FormField
              control={form.control}
              name="website"
              render={({ field }) => (
                <FormItem>
                  <FormLabel>{t.website || "Website"}</FormLabel>
                  <FormControl>
                    <Input placeholder="e.g. https://mybusiness.com" {...field} />
                  </FormControl>
                  <FormMessage />
                </FormItem>
              )}
            />

            <FormField
              control={form.control}
              name="languages"
              render={({ field }) => (
                <FormItem>
                  <FormLabel>{t.languages || "Languages Spoken"}</FormLabel>
                  <FormControl>
                    <Input placeholder="e.g. English, Hindi, Marathi" {...field} />
                  </FormControl>
                  <FormDescription>Comma separated list of languages</FormDescription>
                  <FormMessage />
                </FormItem>
              )}
            />

            <div className="grid grid-cols-2 gap-4">
              <FormField
                control={form.control}
                name="womenOwned"
                render={({ field }) => (
                  <FormItem>
                    <FormLabel>{t.womenOwned || "Women Owned?"}</FormLabel>
                    <FormControl>
                      <select
                        className="flex h-10 w-full rounded-md border border-input bg-transparent px-3 py-2 text-sm ring-offset-background disabled:opacity-50"
                        value={field.value ? "yes" : "no"}
                        onChange={(e) => field.onChange(e.target.value === "yes")}
                      >
                        <option value="no">No</option>
                        <option value="yes">Yes</option>
                      </select>
                    </FormControl>
                    <FormMessage />
                  </FormItem>
                )}
              />

              <FormField
                control={form.control}
                name="farmerProducerOrganization"
                render={({ field }) => (
                  <FormItem>
                    <FormLabel>{t.fpo || "FPO?"}</FormLabel>
                    <FormControl>
                      <select
                        className="flex h-10 w-full rounded-md border border-input bg-transparent px-3 py-2 text-sm ring-offset-background disabled:opacity-50"
                        value={field.value ? "yes" : "no"}
                        onChange={(e) => field.onChange(e.target.value === "yes")}
                      >
                        <option value="no">No</option>
                        <option value="yes">Yes</option>
                      </select>
                    </FormControl>
                    <FormMessage />
                  </FormItem>
                )}
              />
            </div>
          </div>
        </div>

        <div className="flex justify-end gap-4 border-t border-white/10 pt-6">
          <Button 
            type="button" 
            variant="outline" 
            onClick={() => router.push(`/${lang}/dashboard/businesses`)}
            disabled={isSubmitting}
          >
            {t.cancel || "Cancel"}
          </Button>
          <Button type="submit" disabled={isSubmitting}>
            {isSubmitting 
              ? (t.submitting || "Submitting...") 
              : initialData 
                ? (t.saveChanges || "Save Changes") 
                : (t.submit || "Register Business")}
          </Button>
        </div>
      </form>
    </Form>
  )
}
