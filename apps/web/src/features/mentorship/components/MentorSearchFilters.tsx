"use client"

import { Input } from "@/components/ui/input"
import { Search, SlidersHorizontal } from "lucide-react"
import { useDictionary } from "@/components/providers/DictionaryProvider"
import { 
  Select,
  SelectContent,
  SelectItem,
  SelectTrigger,
  SelectValue,
} from "@/components/ui/select"
import { Button } from "@/components/ui/button"

interface MentorSearchFiltersProps {
  searchTerm: string;
  setSearchTerm: (value: string) => void;
  expertiseFilter: string;
  setExpertiseFilter: (value: string) => void;
  availabilityFilter: string;
  setAvailabilityFilter: (value: string) => void;
  locationFilter: string;
  setLocationFilter: (value: string) => void;
  languageFilter: string;
  setLanguageFilter: (value: string) => void;
}

export function MentorSearchFilters({
  searchTerm,
  setSearchTerm,
  expertiseFilter,
  setExpertiseFilter,
  availabilityFilter,
  setAvailabilityFilter,
  locationFilter,
  setLocationFilter,
  languageFilter,
  setLanguageFilter,
}: MentorSearchFiltersProps) {
  const { dict } = useDictionary()
  const mDict = dict.mentorship || {}

  const clearFilters = () => {
    setSearchTerm("")
    setExpertiseFilter("all")
    setAvailabilityFilter("all")
    setLocationFilter("all")
    setLanguageFilter("all")
  }

  return (
    <div className="flex flex-col space-y-4 md:flex-row md:space-y-0 md:gap-4 mb-6 bg-card p-4 rounded-lg border flex-wrap">
      <div className="relative flex-1 min-w-[200px]">
        <Search className="absolute left-2.5 top-2.5 h-4 w-4 text-muted-foreground" />
        <Input
          type="search"
          placeholder={mDict.searchMentors || "Search mentors..."}
          className="pl-8 bg-background"
          value={searchTerm}
          onChange={(e) => setSearchTerm(e.target.value)}
        />
      </div>
      
      <div className="flex flex-wrap gap-2">
        <Select value={expertiseFilter} onValueChange={(val) => val && setExpertiseFilter(val)}>
          <SelectTrigger className="w-[160px] bg-background">
            <SelectValue placeholder={mDict.filterExpertise || "Expertise"} />
          </SelectTrigger>
          <SelectContent>
            <SelectItem value="all">{mDict.all || "All"}</SelectItem>
            <SelectItem value="food_processing">{mDict.expertise?.food_processing || "Food Processing"}</SelectItem>
            <SelectItem value="manufacturing">{mDict.expertise?.manufacturing || "Manufacturing"}</SelectItem>
            <SelectItem value="handicrafts">{mDict.expertise?.handicrafts || "Handicrafts"}</SelectItem>
            <SelectItem value="digital_marketing">{mDict.expertise?.digital_marketing || "Digital Marketing"}</SelectItem>
            <SelectItem value="finance">{mDict.expertise?.finance || "Finance"}</SelectItem>
            <SelectItem value="agriculture">{mDict.expertise?.agriculture || "Agriculture"}</SelectItem>
          </SelectContent>
        </Select>

        <Select value={languageFilter} onValueChange={(val) => val && setLanguageFilter(val)}>
          <SelectTrigger className="w-[140px] bg-background">
            <SelectValue placeholder={mDict.filterLanguage || "Language"} />
          </SelectTrigger>
          <SelectContent>
            <SelectItem value="all">{mDict.all || "All"}</SelectItem>
            <SelectItem value="hindi">{mDict.languages?.hindi || "Hindi"}</SelectItem>
            <SelectItem value="marathi">{mDict.languages?.marathi || "Marathi"}</SelectItem>
            <SelectItem value="english">{mDict.languages?.english || "English"}</SelectItem>
          </SelectContent>
        </Select>

        <Select value={locationFilter} onValueChange={(val) => val && setLocationFilter(val)}>
          <SelectTrigger className="w-[140px] bg-background">
            <SelectValue placeholder={mDict.filterLocation || "Location"} />
          </SelectTrigger>
          <SelectContent>
            <SelectItem value="all">{mDict.all || "All"}</SelectItem>
            <SelectItem value="maharashtra">{mDict.locations?.maharashtra || "Maharashtra"}</SelectItem>
            <SelectItem value="rajasthan">{mDict.locations?.rajasthan || "Rajasthan"}</SelectItem>
            <SelectItem value="karnataka">{mDict.locations?.karnataka || "Karnataka"}</SelectItem>
            <SelectItem value="uttar_pradesh">{mDict.locations?.uttar_pradesh || "Uttar Pradesh"}</SelectItem>
          </SelectContent>
        </Select>

        <Select value={availabilityFilter} onValueChange={(val) => val && setAvailabilityFilter(val)}>
          <SelectTrigger className="w-[140px] bg-background">
            <SelectValue placeholder={mDict.filterAvailability || "Availability"} />
          </SelectTrigger>
          <SelectContent>
            <SelectItem value="all">{mDict.all || "All"}</SelectItem>
            <SelectItem value="available">{mDict.available || "Available"}</SelectItem>
            <SelectItem value="limited">{mDict.unavailable || "Limited"}</SelectItem>
          </SelectContent>
        </Select>

        {(searchTerm || expertiseFilter !== "all" || availabilityFilter !== "all" || locationFilter !== "all" || languageFilter !== "all") && (
          <Button variant="ghost" size="icon" onClick={clearFilters} title={mDict.clearFilters || "Clear Filters"}>
            <SlidersHorizontal className="h-4 w-4" />
          </Button>
        )}
      </div>
    </div>
  )
}
