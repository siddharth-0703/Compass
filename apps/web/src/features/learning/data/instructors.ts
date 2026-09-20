import { Instructor } from "../types/learning.types";

export const instructors: Instructor[] = [
  {
    id: "inst-organic-01",
    name: "Dr. Ramesh Patil",
    title: "Chief Agronomist",
    organization: "National Organic Farming Institute",
    bio: "Dr. Patil has over 20 years of experience in sustainable and organic farming across India.",
    languages: ["en", "hi", "mr"],
    experience: "20+ years",
    avatar: "https://images.unsplash.com/photo-1595841696677-6489b4b0ff72?q=80&w=200&auto=format&fit=crop"
  },
  {
    id: "inst-business-02",
    name: "Sunita Sharma",
    title: "MSME Consultant",
    organization: "Rural Enterprise Council",
    bio: "Sunita helps rural entrepreneurs register and scale their micro-businesses effectively.",
    languages: ["en", "hi"],
    experience: "15 years",
    avatar: "https://images.unsplash.com/photo-1573496359142-b8d87734a5a2?q=80&w=200&auto=format&fit=crop"
  },
  {
    id: "inst-digital-03",
    name: "Vikram Desai",
    title: "Digital Growth Specialist",
    organization: "Tech For Bharat",
    bio: "Vikram specializes in teaching digital literacy and social media marketing to rural businesses.",
    languages: ["en", "mr"],
    experience: "10 years",
    avatar: "https://images.unsplash.com/photo-1560250097-0b93528c311a?q=80&w=200&auto=format&fit=crop"
  }
];
