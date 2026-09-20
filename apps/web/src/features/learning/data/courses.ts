import { Course } from "../types/learning.types";

export const courses: Course[] = [
  {
    id: "organic-farming",
    title: "Modern Organic Farming Techniques",
    category: "Agriculture",
    difficulty: "Intermediate",
    duration: "45m",
    image: "https://images.unsplash.com/photo-1615811361523-6bd03d7748e7?q=80&w=800&auto=format&fit=crop",
    instructorId: "inst-organic-01",
    rating: 4.8,
    students: 12500,
    lastUpdated: "2024-05-10T00:00:00Z",
    estimatedHours: 1,
    tags: ["organic", "compost", "sustainability"],
    prerequisites: ["Basic understanding of agriculture"],
    learningOutcomes: [
      "Understand soil chemistry for organic crops",
      "Produce natural fertilizers and pesticides",
      "Acquire organic certification for your farm"
    ],
    certificateAvailable: true,
    offlineSupported: true,
    aiRecommendationScore: 94,
    languages: {
      en: {
        title: "Modern Organic Farming (English)",
        description: "Learn organic farming best practices in English.",
        lessons: [
          {
            id: "of-en-1",
            title: "Masterclass: Organic Soil & Composting",
            description: "A complete guide to natural soil health and organic matter preparation.",
            duration: "45m",
            videoId: "pDPWTRA2nPM", // TEDx Organic Mandya
            downloadable: true,
            resources: [{ name: "Organic Farming Guide PDF", url: "#", size: "4.2 MB" }]
          }
        ]
      },
      hi: {
        title: "आधुनिक जैविक खेती (Hindi)",
        description: "हिंदी में जैविक खेती के सर्वोत्तम अभ्यास सीखें।",
        lessons: [
          {
            id: "of-hi-1",
            title: "जैविक खेती का महत्व और शुरुआत",
            description: "जैविक खेती की मूल बातें और इसे शुरू करने का तरीका।",
            duration: "20m",
            videoId: "XUwptP0_v00",
            downloadable: true,
            resources: [{ name: "जैविक खेती गाइड", url: "#", size: "3.1 MB" }]
          },
          {
            id: "of-hi-2",
            title: "जैविक खेती के फायदे और तकनीक",
            description: "जैविक खेती के लाभ और खेतों में इसका उपयोग।",
            duration: "25m",
            videoId: "2qiNKen-rm0",
            downloadable: true,
          },
          {
            id: "of-hi-3",
            title: "मास्टरक्लास: जैविक मिट्टी और खाद",
            description: "प्राकृतिक मिट्टी के स्वास्थ्य और जैविक खाद तैयार करने के लिए एक पूरी गाइड।",
            duration: "45m",
            videoId: "Kouij55MvzE", // TEDx Dantewada
            downloadable: true,
          }
        ]
      },
      mr: {
        title: "आधुनिक सेंद्रिय शेती (Marathi)",
        description: "मराठीत सेंद्रिय शेतीचे सर्वोत्तम सराव शिका.",
        lessons: [
          {
            id: "of-mr-1",
            title: "सेंद्रिय शेतीची ओळख आणि फायदे",
            description: "सेंद्रिय शेतीचे मूलभूत तत्त्वे आणि फायदे.",
            duration: "20m",
            videoId: "yu2MMDwVDR0",
            downloadable: true,
            resources: [{ name: "सेंद्रिय शेती मार्गदर्शक", url: "#", size: "3.5 MB" }]
          },
          {
            id: "of-mr-2",
            title: "सेंद्रिय खत आणि कीटकनाशके",
            description: "नैसर्गिक खते आणि कीटकनाशके कशी बनवायची.",
            duration: "22m",
            videoId: "TwnPqUBSAEQ",
            downloadable: true,
          }
        ]
      }
    }
  },
  {
    id: "digital-marketing",
    title: "Digital Marketing for Local Products",
    category: "Digital Skills",
    difficulty: "Beginner",
    duration: "1h 10m",
    image: "https://images.unsplash.com/photo-1611162617213-7d7a39e9b1d7?q=80&w=800&auto=format&fit=crop",
    instructorId: "inst-digital-03",
    rating: 4.6,
    students: 8300,
    lastUpdated: "2024-06-15T00:00:00Z",
    estimatedHours: 1,
    tags: ["marketing", "whatsapp", "social media"],
    prerequisites: ["Smartphone and basic internet knowledge"],
    learningOutcomes: [
      "Set up a WhatsApp Business account",
      "Create attractive social media posts",
      "Reach customers beyond your local village"
    ],
    certificateAvailable: true,
    offlineSupported: true,
    aiRecommendationScore: 88,
    languages: {
      en: {
        title: "Digital Marketing (English)",
        description: "Grow your business using digital tools.",
        lessons: [
          {
            id: "dm-en-1",
            title: "Complete Digital Marketing Guide",
            description: "Learn how to use WhatsApp Business and Facebook to attract local customers.",
            duration: "1h 10m",
            videoId: "kGARu1dgLl4", // Simplilearn Digital Marketing
            downloadable: true,
            resources: [{ name: "Marketing Checklist", url: "#", size: "1.2 MB" }]
          }
        ]
      },
      hi: {
        title: "डिजिटल मार्केटिंग (Hindi)",
        description: "डिजिटल टूल्स का उपयोग करके अपना व्यवसाय बढ़ाएं।",
        lessons: [
          {
            id: "dm-hi-1",
            title: "संपूर्ण डिजिटल मार्केटिंग गाइड",
            description: "स्थानीय ग्राहकों को आकर्षित करने के लिए व्हाट्सएप बिजनेस और फेसबुक का उपयोग करना सीखें।",
            duration: "1h 10m",
            videoId: "5Nm5raGEo0E", // Hindi Business (Placeholder)
            downloadable: true,
          }
        ]
      },
      mr: {
        title: "डिजिटल मार्केटिंग (Marathi)",
        description: "डिजिटल टूल्स वापरून आपला व्यवसाय वाढवा.",
        lessons: [
          {
            id: "dm-mr-1",
            title: "संपूर्ण डिजिटल मार्केटिंग मार्गदर्शक",
            description: "स्थानिक ग्राहकांना आकर्षित करण्यासाठी व्हॉट्सॲप बिझनेस आणि फेसबुक कसे वापरावे ते शिका.",
            duration: "1h 10m",
            videoId: "_ZRkfA6GmGU", // Marathi Business (Placeholder)
            downloadable: true,
          }
        ]
      }
    }
  },
  {
    id: "financial-literacy-gst",
    title: "Understanding GST & Business Taxation",
    category: "Financial Literacy",
    difficulty: "Intermediate",
    duration: "55m",
    image: "https://images.unsplash.com/photo-1554224155-8d04cb21cd6c?q=80&w=800&auto=format&fit=crop",
    instructorId: "inst-business-02",
    rating: 4.9,
    students: 15400,
    lastUpdated: "2024-07-01T00:00:00Z",
    estimatedHours: 1,
    tags: ["finance", "gst", "taxes", "msme"],
    prerequisites: ["Running a small business or shop"],
    learningOutcomes: [
      "Understand when GST registration is required",
      "Learn the basics of tax filing for small shops",
      "Avoid common financial penalties"
    ],
    certificateAvailable: true,
    offlineSupported: true,
    aiRecommendationScore: 97,
    languages: {
      en: {
        title: "Understanding GST (English)",
        description: "A jargon-free guide to Indian business taxes.",
        lessons: [
          {
            id: "gst-en-1",
            title: "GST Masterclass for MSMEs",
            description: "Everything a small business owner needs to know about GST and basic accounting.",
            duration: "55m",
            videoId: "mT3P0YSNonE", // TED-Ed Economy
            downloadable: true,
            resources: [{ name: "Tax Calendar", url: "#", size: "500 KB" }]
          }
        ]
      },
      hi: {
        title: "GST और कराधान (Hindi)",
        description: "भारतीय व्यापार करों के लिए एक सरल गाइड।",
        lessons: [
          {
            id: "gst-hi-1",
            title: "छोटे व्यवसायों के लिए GST मास्टरक्लास",
            description: "छोटे व्यवसाय के मालिक को GST और बुनियादी लेखांकन के बारे में जानने की जरूरत है।",
            duration: "55m",
            videoId: "qIcA38MYsdk", // StudyIQ GST
            downloadable: true,
          }
        ]
      },
      mr: {
        title: "GST आणि व्यवसाय कर (Marathi)",
        description: "भारतीय व्यवसाय करांसाठी एक सोपा मार्गदर्शक.",
        lessons: [
          {
            id: "gst-mr-1",
            title: "लघुउद्योगांसाठी GST मास्टरक्लास",
            description: "लहान व्यवसाय मालकाला जीएसटी आणि मूलभूत लेखांकनाबद्दल काय माहित असणे आवश्यक आहे.",
            duration: "55m",
            videoId: "pDPWTRA2nPM", // Marathi Finance (Placeholder)
            downloadable: true,
          }
        ]
      }
    }
  },
  {
    id: "gov-schemes-guide",
    title: "Navigating Government Schemes & Subsidies",
    category: "Government Schemes",
    difficulty: "Beginner",
    duration: "40m",
    image: "https://images.unsplash.com/photo-1577717903315-1691ae25ab3f?q=80&w=800&auto=format&fit=crop",
    instructorId: "inst-business-02",
    rating: 4.7,
    students: 9200,
    lastUpdated: "2024-06-20T00:00:00Z",
    estimatedHours: 1,
    tags: ["government", "subsidies", "loans", "mudra"],
    prerequisites: ["None"],
    learningOutcomes: [
      "Identify subsidies available for your sector",
      "Learn how to apply for Mudra loans",
      "Prepare required documentation efficiently"
    ],
    certificateAvailable: false,
    offlineSupported: true,
    aiRecommendationScore: 91,
    languages: {
      en: {
        title: "Government Schemes (English)",
        description: "Learn how to access government support and subsidies.",
        lessons: [
          {
            id: "gov-en-1",
            title: "Complete Guide to Business Subsidies",
            description: "An overview of Mudra loans, PMFME, and state-level subsidy applications.",
            duration: "40m",
            videoId: "_ZRkfA6GmGU", // English Schemes (Placeholder)
            downloadable: true,
          }
        ]
      },
      hi: {
        title: "सरकारी योजनाएं (Hindi)",
        description: "सरकारी सहायता और सब्सिडी तक पहुंचना सीखें।",
        lessons: [
          {
            id: "gov-hi-1",
            title: "व्यवसाय सब्सिडी के लिए संपूर्ण गाइड",
            description: "मुद्रा ऋण, पीएमएफएमई और राज्य स्तरीय सब्सिडी आवेदनों का अवलोकन।",
            duration: "40m",
            videoId: "5Nm5raGEo0E", // DD Kisan Schemes
            downloadable: true,
          }
        ]
      },
      mr: {
        title: "सरकारी योजना (Marathi)",
        description: "सरकारी मदत आणि सबसिडी कशी मिळवायची ते शिका.",
        lessons: [
          {
            id: "gov-mr-1",
            title: "व्यवसाय सबसिडीसाठी संपूर्ण मार्गदर्शक",
            description: "मुद्रा कर्ज, पीएमएफएमई आणि राज्य-स्तरीय अनुदान अर्जांचे विहंगावलोकन.",
            duration: "40m",
            videoId: "5blQaNL1qO4", // Marathi Schemes (Placeholder)
            downloadable: true,
          }
        ]
      }
    }
  }
];
