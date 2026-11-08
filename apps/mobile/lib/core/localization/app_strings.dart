class AppStrings {
  final String lang;

  const AppStrings(this.lang);

  bool get isHindi => lang == 'hi';
  bool get isMarathi => lang == 'mr';
  bool get isEnglish => lang == 'en';

  // Navigation & Core Tabs
  String get dashboard => isHindi ? 'डैशबोर्ड' : (isMarathi ? 'डॅशबोर्ड' : 'Dashboard');
  String get businesses => isHindi ? 'व्यवसाय' : (isMarathi ? 'व्यवसाय' : 'Businesses');
  String get learning => isHindi ? 'शिक्षा' : (isMarathi ? 'शिक्षण' : 'Learning');
  String get schemes => isHindi ? 'सरकारी योजनाएं' : (isMarathi ? 'सरकारी योजना' : 'Schemes');
  String get marketPrices => isHindi ? 'मंडी भाव' : (isMarathi ? 'बाजार भाव' : 'Market Prices');
  String get mentorship => isHindi ? 'मार्गदर्शन' : (isMarathi ? 'मार्गदर्शन' : 'Mentorship');
  String get analytics => isHindi ? 'एनालिटिक्स' : (isMarathi ? 'विश्लेषण' : 'Analytics');
  String get users => isHindi ? 'उपयोगकर्ता' : (isMarathi ? 'वापरकर्ते' : 'Users');
  String get settings => isHindi ? 'सेटिंग्स' : (isMarathi ? 'सेटिंग्ज' : 'Settings');
  String get logout => isHindi ? 'लॉग आउट' : (isMarathi ? 'बाहेर पडा' : 'Logout');

  // Groups
  String get overview => isHindi ? 'अवलोकन' : (isMarathi ? 'आढावा' : 'OVERVIEW');
  String get management => isHindi ? 'प्रबंधन' : (isMarathi ? 'व्यवस्थापन' : 'MANAGEMENT');
  String get system => isHindi ? 'सिस्टम' : (isMarathi ? 'प्रणाली' : 'SYSTEM');
  String get aiContent => isHindi ? 'एआई और सामग्री' : (isMarathi ? 'एआय आणि सामग्री' : 'AI & CONTENT');

  // Dashboard & Hero Banner
  String get aiCommandCenter => isHindi ? 'एआई बिजनेस कमांड सेंटर' : (isMarathi ? 'एआय व्यवसाय कमांड केंद्र' : 'AI BUSINESS COMMAND CENTER');
  String get welcomeBack => isHindi ? 'वापसी पर स्वागत है' : (isMarathi ? 'पुन्हा स्वागत आहे' : 'Welcome back');
  String get todayAiRecommendation => isHindi ? 'आज की एआई सिफारिश' : (isMarathi ? 'आजची एआय शिफारस' : "Today's AI Recommendation");
  String get aiRecommendationText => isHindi
      ? 'महाराष्ट्र में जैविक बाजरा की मांग बढ़ रही है। आपकी प्रोफ़ाइल के आधार पर, अपनी इन्वेंट्री बढ़ाने पर विचार करें। 3 नई सरकारी योजनाएं भी आपके व्यवसाय से मेल खाती हैं।'
      : (isMarathi
          ? 'महाराष्ट्रात सेंद्रिय बाजरीची मागणी वाढत आहे. आपल्या प्रोफाइलच्या आधारे, आपली उत्पादने वाढवण्याचा विचार करा. 3 नवीन सरकारी योजना आपल्या व्यवसायाशी जुळतात.'
          : '"Organic millet demand is increasing in Maharashtra. Based on your profile, consider increasing your inventory. 3 new Government Schemes also match your business."');

  String get businessScore => isHindi ? 'बिजनेस स्कोर' : (isMarathi ? 'व्यवसाय गुण' : 'Business Score');
  String get marketDemand => isHindi ? 'बाजार मांग' : (isMarathi ? 'बाजार मागणी' : 'Market Demand');
  String get highDemand => isHindi ? 'उच्च' : (isMarathi ? 'उच्च' : 'High');
  String get weather => isHindi ? 'मौसम' : (isMarathi ? 'हवामान' : 'Weather');
  String get schemeMatches => isHindi ? 'योजना मैच' : (isMarathi ? 'योजना जुळण्या' : 'Scheme Matches');

  // Weather Condition Localization
  String weatherCondition(String raw) {
    final lower = raw.trim().toLowerCase();
    if (lower.contains('clear')) {
      return isHindi ? 'साफ़ आसमान' : (isMarathi ? 'निरभ्र आकाश' : 'Clear Sky');
    } else if (lower.contains('cloud')) {
      return isHindi ? 'बादल' : (isMarathi ? 'ढगाळ' : 'Cloudy');
    } else if (lower.contains('rain')) {
      return isHindi ? 'बारिश' : (isMarathi ? 'पाऊस' : 'Rain');
    } else if (lower.contains('drizzle')) {
      return isHindi ? 'बूंदाबांदी' : (isMarathi ? 'रिमझिम' : 'Drizzle');
    } else if (lower.contains('thunder')) {
      return isHindi ? 'गरज के साथ बारिश' : (isMarathi ? 'वादळी पाऊस' : 'Thunderstorm');
    } else if (lower.contains('mist') || lower.contains('fog') || lower.contains('haze')) {
      return isHindi ? 'धुंध / कोहरा' : (isMarathi ? 'धुकं' : 'Mist / Fog');
    }
    return raw;
  }

  // Quick Actions
  String get quickActions => isHindi ? 'त्वरित कार्रवाई' : (isMarathi ? 'त्वरित कृती' : 'Quick Actions');
  String get registerNewBusiness => isHindi ? 'नया व्यवसाय पंजीकृत करें' : (isMarathi ? 'नवीन व्यवसाय नोंदणी करा' : 'Register New Business');
  String get exploreSchemes => isHindi ? 'योजनाएं खोजें' : (isMarathi ? 'योजना शोधा' : 'Explore Schemes');
  String get checkMandiRates => isHindi ? 'मंडी भाव देखें' : (isMarathi ? 'मंडी भाव तपासा' : 'Check APMC Rates');
  String get startLearning => isHindi ? 'सीखना शुरू करें' : (isMarathi ? 'शिकणे सुरू करा' : 'Start Learning');
  String get talkToAi => isHindi ? 'एआई से बात करें' : (isMarathi ? 'एआयशी बोला' : 'Talk to AI');

  // Business Health & Metrics
  String get businessHealth => isHindi ? 'व्यवसाय स्वास्थ्य' : (isMarathi ? 'व्यवसाय आरोग्य' : 'Business Health');
  String get activeBusinesses => isHindi ? 'सक्रिय व्यवसाय' : (isMarathi ? 'सक्रिय व्यवसाय' : 'Active Businesses');
  String get communityMembers => isHindi ? 'समुदाय सदस्य' : (isMarathi ? 'समुदाय सदस्य' : 'Community Members');
  String get learningHours => isHindi ? 'सीखने के घंटे' : (isMarathi ? 'शिकण्याचे तास' : 'Learning Hours');
  String get vsLastMonth => isHindi ? 'पिछले महीने की तुलना में' : (isMarathi ? 'मागील महिन्याच्या तुलनेत' : 'vs last month');
  String get vsLastWeek => isHindi ? 'पिछले सप्ताह की तुलना में' : (isMarathi ? 'मागील आठवड्याच्या तुलनेत' : 'vs last week');
  String get recentActivity => isHindi ? 'हाल की गतिविधि' : (isMarathi ? 'अलीकडील क्रियाकलाप' : 'Recent Activity');
  String get viewAll => isHindi ? 'सभी देखें' : (isMarathi ? 'सर्व पहा' : 'View all');

  // Platform Analytics
  String get platformAnalytics => isHindi ? 'प्लेटफ़ॉर्म एनालिटिक्स' : (isMarathi ? 'प्लॅटफॉर्म विश्लेषण' : 'Platform Analytics');
  String get range30Days => isHindi ? '30 दिन' : (isMarathi ? '30 दिवस' : '30 Days');
  String get range3Months => isHindi ? '3 महीने' : (isMarathi ? '3 महिने' : '3 Months');
  String get range6Months => isHindi ? '6 महीने' : (isMarathi ? '6 महिने' : '6 Months');
  String get range1Year => isHindi ? '1 वर्ष' : (isMarathi ? '1 वर्ष' : '1 Year');
  String get ecosystemMetrics => isHindi ? 'पारिस्थितिकी तंत्र मेट्रिक्स' : (isMarathi ? 'इकोसिस्टम मेट्रिक्स' : 'Ecosystem Metrics');
  String get ecosystemSubtitle => isHindi
      ? 'ग्रामीण उद्यमी अपनाने और सब्सिडी का वास्तविक समय अवलोकन।'
      : (isMarathi
          ? 'ग्रामीण उद्योजक स्वीकार आणि अनुदानाचे रिअल-टाइम विहंगावलोकन.'
          : 'Real-time overview of rural entrepreneur adoption & subsidies.');
  String get marketplaceVolume => isHindi ? 'मार्केटप्लेस वॉल्यूम' : (isMarathi ? 'बाजारपेठ उलाढाल' : 'Marketplace Volume');
  String get activeEntrepreneurs => isHindi ? 'सक्रिय उद्यमी' : (isMarathi ? 'सक्रिय उद्योजक' : 'Active Entrepreneurs');
  String get schemeSuccessRate => isHindi ? 'योजना सफलता दर' : (isMarathi ? 'योजना यश दर' : 'Scheme Success Rate');
  String get mandiPricePremium => isHindi ? 'मंडी मूल्य प्रीमियम' : (isMarathi ? 'बाजार भाव प्रीमियम' : 'Mandi Price Premium');
  String get yoyGrowth => isHindi ? '+18.4% वार्षिक' : (isMarathi ? '+18.4% वार्षिक' : '+18.4% YoY');
  String get newEntrepreneurs => isHindi ? '+124 नए' : (isMarathi ? '+124 नवीन' : '+124 new');
  String get sanctionedCount => isHindi ? '567 स्वीकृत' : (isMarathi ? '567 मंजूर' : '567 sanctioned');
  String get aboveMsp => isHindi ? 'एमएसपी से ऊपर' : (isMarathi ? 'हमीभावापेक्षा जास्त' : 'Above MSP');
  String get enterprisesBySector => isHindi ? 'उद्योग क्षेत्र के अनुसार उद्यम' : (isMarathi ? 'उद्योग क्षेत्रानुसार उद्योग' : 'Enterprises by Industry Sector');
  String get agriProcessing => isHindi ? 'कृषि प्रसंस्करण' : (isMarathi ? 'कृषी प्रक्रिया' : 'Agri-Processing');
  String get dairyLivestock => isHindi ? 'डेयरी और पशुधन' : (isMarathi ? 'दुग्ध आणि पशुधन' : 'Dairy & Livestock');
  String get handicrafts => isHindi ? 'हस्तशिल्प और हथकरघा' : (isMarathi ? 'हस्तकला आणि हातमाग' : 'Handicrafts & Handlooms');
  String get foodSpices => isHindi ? 'खाद्य और मसाले' : (isMarathi ? 'अन्न आणि मसाले' : 'Food & Spices');
  String get renewableTech => isHindi ? 'ग्रामीण नवीकरणीय तकनीक' : (isMarathi ? 'ग्रामीण नूतनीकरणक्षम तंत्रज्ञान' : 'Rural Renewable Tech');
  String get topPerformingStates => isHindi ? 'शीर्ष प्रदर्शन करने वाले राज्य' : (isMarathi ? 'अव्वल कामगिरी करणारी राज्ये' : 'Top Performing States');
  String get topStatesSubtitle => isHindi
      ? 'क्षेत्रीय सब्सिडी प्रवाह और सूक्ष्म व्यवसाय घनत्व'
      : (isMarathi ? 'प्रादेशिक अनुदान प्रवाह आणि सूक्ष्म व्यवसाय घनता' : 'Regional subsidy flow & micro-business density');
  String get activeUnits => isHindi ? 'सक्रिय इकाइयां' : (isMarathi ? 'सक्रिय युनिट्स' : 'active units');

  // Settings
  String get account => isHindi ? 'खाता' : (isMarathi ? 'खाते' : 'Account');
  String get preferences => isHindi ? 'प्राथमिकताएं' : (isMarathi ? 'पसंती' : 'Preferences');
  String get language => isHindi ? 'भाषा' : (isMarathi ? 'भाषा' : 'Language');
  String get appearance => isHindi ? 'दिखावट' : (isMarathi ? 'स्वरूप' : 'Appearance');
  String get syncSettings => isHindi ? 'सिंक सेटिंग्स' : (isMarathi ? 'सिंक सेटिंग्ज' : 'Sync Settings');
  String get profile => isHindi ? 'प्रोफ़ाइल' : (isMarathi ? 'प्रोफाइल' : 'Profile');
  String get selectLanguage => isHindi ? 'भाषा चुनें' : (isMarathi ? 'भाषा निवडा' : 'Select Language');
  String get systemDefault => isHindi ? 'सिस्टम डिफ़ॉल्ट' : (isMarathi ? 'सिस्टम डीफॉल्ट' : 'System default');
  String get lightTheme => isHindi ? 'हल्का मोड (लाइट)' : (isMarathi ? 'हलका मोड' : 'Light theme');
  String get darkTheme => isHindi ? 'गहरा मोड (डार्क)' : (isMarathi ? 'गडद मोड' : 'Dark theme');
  String get profileManagementComingSoon => isHindi ? 'प्रोफ़ाइल प्रबंधन जल्द आ रहा है' : (isMarathi ? 'प्रोफाइल व्यवस्थापन लवकरच येत आहे' : 'Profile management coming soon');

  // Learning
  String get learningHub => isHindi ? 'शिक्षा केंद्र' : (isMarathi ? 'शिक्षण केंद्र' : 'Learning Hub');
  String get searchOfflineCourses => isHindi ? 'ऑफ़लाइन पाठ्यक्रम खोजें...' : (isMarathi ? 'ऑफलाइन अभ्यासक्रम शोधा...' : 'Search offline courses...');
  String get all => isHindi ? 'सभी' : (isMarathi ? 'सर्व' : 'All');
  String get agriculture => isHindi ? 'कृषि' : (isMarathi ? 'शेती / कृषी' : 'Agriculture');
  String get digitalSkills => isHindi ? 'डिजिटल कौशल' : (isMarathi ? 'डिजिटल कौशल्ये' : 'Digital Skills');
  String get financialLiteracy => isHindi ? 'वित्तीय साक्षरता' : (isMarathi ? 'आर्थिक साक्षरता' : 'Financial Literacy');
  String get entrepreneurship => isHindi ? 'उद्यमिता' : (isMarathi ? 'उद्योजकता' : 'Entrepreneurship');
  String get economy => isHindi ? 'अर्थव्यवस्था' : (isMarathi ? 'अर्थव्यवस्था' : 'Economy');
  String get womenEntrepreneurs => isHindi ? 'महिला उद्यमी' : (isMarathi ? 'महिला उद्योजक' : 'Women Entrepreneurs');
  String get noCoursesFound => isHindi ? 'कोई पाठ्यक्रम नहीं मिला।' : (isMarathi ? 'कोणताही अभ्यासक्रम आढळला नाही.' : 'No courses found.');
  String get courseLessons => isHindi ? 'कोर्स के पाठ' : (isMarathi ? 'अभ्यासक्रमाचे धडे' : 'Course Lessons');
  String get completed => isHindi ? 'पूर्ण हुआ' : (isMarathi ? 'पूर्ण झाले' : 'Completed');
  String get markAsCompleted => isHindi ? 'पूर्ण के रूप में चिह्नित करें' : (isMarathi ? 'पूर्ण म्हणून चिन्हांकित करा' : 'Mark as Completed');
  String get downloadOffline => isHindi ? 'ऑफ़लाइन डाउनलोड करें' : (isMarathi ? 'ऑफलाइन डाउनलोड करा' : 'Download Lesson (Offline)');
  String get downloadedOfflineReady => isHindi ? 'डाउनलोड किया गया (ऑफ़लाइन तैयार ✓)' : (isMarathi ? 'डाउनलोड केले (ऑफलाइन तयार ✓)' : 'Downloaded (Offline Ready ✓)');
  String get playbackSpeed => isHindi ? 'प्लेबैक गति' : (isMarathi ? 'प्लेबॅक गती' : 'Playback Speed');
  String get offlineZeroData => isHindi ? 'ऑफ़लाइन ज़ीरो-डेटा' : (isMarathi ? 'ऑफलाइन शून्य-डेटा' : 'OFFLINE ZERO-DATA');
  String get inAppHd => isHindi ? 'इन-ऐप एचडी' : (isMarathi ? 'अ‍ॅपमध्ये एचडी' : 'IN-APP HD');

  // Schemes
  String get governmentSchemes => isHindi ? 'सरकारी योजनाएं' : (isMarathi ? 'सरकारी योजना' : 'Government Schemes');
  String get schemesFoundForYou => isHindi ? 'योजनाएं आपके लिए मिलीं' : (isMarathi ? 'योजना आपल्यासाठी सापडल्या' : 'Schemes Found For You');
  String get basedOnYourProfile => isHindi ? 'आपकी प्रोफ़ाइल के आधार पर' : (isMarathi ? 'आपल्या प्रोफाइलच्या आधारे' : 'Based on your profile');
  String get findYourSchemes => isHindi ? 'अपनी योजनाएं खोजें' : (isMarathi ? 'आपल्या योजना शोधा' : 'Find Your Schemes');
  String get refineProfile => isHindi ? 'प्रोफ़ाइल सुधारें' : (isMarathi ? 'प्रोफाइल सुधारा' : 'Refine Profile');
  String get noMatchingSchemes => isHindi ? 'कोई मेल खाती योजना नहीं मिली' : (isMarathi ? 'कोणतीही जुळणारी योजना आढळली नाही' : 'No matching schemes found');
  String get tryAdjustingProfile => isHindi ? 'अपनी प्रोफ़ाइल समायोजित करें या बाद में जांचें।' : (isMarathi ? 'आपली प्रोफाइल समायोजित करा किंवा नंतर तपासा.' : 'Try adjusting your profile or check back later.');
  String get verifiedSchemes => isHindi ? 'सत्यापित योजनाएं' : (isMarathi ? 'सत्यापित योजना' : 'Verified Schemes');
  String get aiDiscovered => isHindi ? 'एआई द्वारा खोजी गई' : (isMarathi ? 'एआय शोधलेले' : 'AI Discovered');
  String get verifiedPill => isHindi ? '✓ सत्यापित — आधिकारिक रूप से पुष्ट योजनाएं' : (isMarathi ? '✓ सत्यापित — अधिकृतपणे पुष्टी केलेल्या योजना' : '✓ Verified — officially confirmed schemes');
  String get aiDiscoveredPill => isHindi ? 'एआई द्वारा खोजी गई — सत्यापन लंबित' : (isMarathi ? 'एआय शोधलेले — पडताळणी प्रलंबित' : 'AI Discovered — pending verification');
  String get benefit => isHindi ? 'लाभ' : (isMarathi ? 'फायदा' : 'Benefit');
  String get eligibility => isHindi ? 'पात्रता' : (isMarathi ? 'पात्रता' : 'Eligibility');
  String get howToApply => isHindi ? 'आवेदन कैसे करें' : (isMarathi ? 'अर्ज कसा करावा' : 'How to Apply');
  String get applyOnline => isHindi ? 'ऑनलाइन आवेदन करें' : (isMarathi ? 'ऑनलाइन अर्ज करा' : 'Apply Online');
  String get bookmark => isHindi ? 'बुकमार्क' : (isMarathi ? 'बुकमार्क' : 'Bookmark');

  // Scheme Questionnaire
  String get primaryActivity => isHindi ? 'प्राथमिक गतिविधि' : (isMarathi ? 'प्राथमिक क्रियाकलाप' : 'Primary Activity');
  String get annualIncome => isHindi ? 'वार्षिक आय' : (isMarathi ? 'वार्षिक उत्पन्न' : 'Annual Income');
  String get ageGroup => isHindi ? 'आयु वर्ग' : (isMarathi ? 'वयोगट' : 'Age Group');
  String get gender => isHindi ? 'लिंग' : (isMarathi ? 'लिंग' : 'Gender');
  String get socialCategory => isHindi ? 'सामाजिक श्रेणी' : (isMarathi ? 'सामाजिक वर्ग' : 'Social Category');
  String get farmer => isHindi ? 'किसान' : (isMarathi ? 'शेतकरी' : 'Farmer');
  String get entrepreneur => isHindi ? 'उद्यमी / व्यापारी' : (isMarathi ? 'उद्योजक / व्यापारी' : 'Business / Entrepreneur');
  String get student => isHindi ? 'छात्र' : (isMarathi ? 'विद्यार्थी' : 'Student');
  String get unemployed => isHindi ? 'बेरोजगार' : (isMarathi ? 'बेरोजगार' : 'Unemployed');
  String get artisan => isHindi ? 'कारीगर / स्वरोजगार' : (isMarathi ? 'कारागीर / स्वयंरोजगार' : 'Artisan / Self Employed');
  String get male => isHindi ? 'पुरुष' : (isMarathi ? 'पुरुष' : 'Male');
  String get female => isHindi ? 'महिला' : (isMarathi ? 'स्त्री' : 'Female');
  String get other => isHindi ? 'अन्य' : (isMarathi ? 'इतर' : 'Other');
  String get previous => isHindi ? 'पिछला' : (isMarathi ? 'मागे' : 'Previous');
  String get next => isHindi ? 'अगला' : (isMarathi ? 'पुढे' : 'Next');
  String get findMySchemes => isHindi ? 'मेरी योजनाएं खोजें' : (isMarathi ? 'माझ्या योजना शोधा' : 'Find My Schemes');
  String get stepOf => isHindi ? 'चरण' : (isMarathi ? 'टप्पा' : 'Step');

  // Market Prices
  String get marketPricesSubtitle => isHindi
      ? 'भारत भर में दैनिक थोक कृषि भाव देखें।'
      : (isMarathi ? 'संपूर्ण भारतातील दैनिक घाऊक कृषी भाव तपासा.' : 'Check daily wholesale agricultural prices across India.');
  String get checkApmcRates => isHindi ? 'एपीएमसी मंडी भाव देखें' : (isMarathi ? 'एपीएमसी बाजार भाव तपासा' : 'Check APMC Mandi Rates');
  String get filterRatesSubtitle => isHindi
      ? 'राज्य, मंडी या विशिष्ट फसल के अनुसार फ़िल्टर करें'
      : (isMarathi ? 'राज्य, बाजार किंवा विशिष्ट पिकांनुसार फिल्टर करा' : 'Filter by state, market, or specific crop');
  String get state => isHindi ? 'राज्य' : (isMarathi ? 'राज्य' : 'State');
  String get marketMandi => isHindi ? 'मंडी / बाजार' : (isMarathi ? 'बाजार / मंडी' : 'Market / Mandi');
  String get commodityCrop => isHindi ? 'फसल / जिन्नस' : (isMarathi ? 'पीक / जिन्नस' : 'Commodity / Crop');
  String get allMarkets => isHindi ? 'सभी मंडियां' : (isMarathi ? 'सर्व बाजार' : 'All Markets');
  String get allCommodities => isHindi ? 'सभी फसलें' : (isMarathi ? 'सर्व पिके' : 'All Commodities');
  String get crop => isHindi ? 'फसल' : (isMarathi ? 'पीक' : 'Crop');
  String get market => isHindi ? 'मंडी' : (isMarathi ? 'बाजार' : 'Market');
  String get minPrice => isHindi ? 'न्यूनतम भाव' : (isMarathi ? 'किमान भाव' : 'Min Price');
  String get maxPrice => isHindi ? 'अधिकतम भाव' : (isMarathi ? 'कमाल भाव' : 'Max Price');
  String get modalPrice => isHindi ? 'मॉडल भाव' : (isMarathi ? 'सरासरी भाव' : 'Modal Price');
  String get arrivalDate => isHindi ? 'आवक तिथि' : (isMarathi ? 'आवक तारीख' : 'Arrival Date');
  String get noMarketData => isHindi ? 'कोई मंडी डेटा नहीं मिला' : (isMarathi ? 'कोणताही बाजार डेटा आढळला नाही' : 'No market data found');

  // Businesses
  String get myBusinesses => isHindi ? 'मेरे व्यवसाय' : (isMarathi ? 'माझे व्यवसाय' : 'My Businesses');
  String get noBusinessesFound => isHindi ? 'कोई व्यवसाय नहीं मिला' : (isMarathi ? 'कोणताही व्यवसाय आढळला नाही' : 'No businesses found');
  String get startByRegistering => isHindi
      ? 'अपना पहला व्यवसाय पंजीकृत करके शुरुआत करें।'
      : (isMarathi ? 'आपल्या पहिल्या व्यवसायाची नोंदणी करून सुरुवात करा.' : 'Get started by registering your first business.');
  String get registerBusiness => isHindi ? 'व्यवसाय पंजीकृत करें' : (isMarathi ? 'व्यवसाय नोंदणी करा' : 'Register Business');

  // General
  String get search => isHindi ? 'खोजें...' : (isMarathi ? 'शोधा...' : 'Search...');
  String get cancel => isHindi ? 'रद्द करें' : (isMarathi ? 'रद्द करा' : 'Cancel');
  String get save => isHindi ? 'सहेजें' : (isMarathi ? 'जतन करा' : 'Save');
  String get apply => isHindi ? 'लागू करें' : (isMarathi ? 'लागू करा' : 'Apply');
  String get retry => isHindi ? 'पुनः प्रयास करें' : (isMarathi ? 'पुन्हा प्रयत्न करा' : 'Retry');

  // Dynamic Lookup
  String get(String key) {
    switch (key.toLowerCase()) {
      case 'dashboard':
        return dashboard;
      case 'businesses':
        return businesses;
      case 'learning':
        return learning;
      case 'schemes':
        return schemes;
      case 'weather':
        return weather;
      case 'settings':
        return settings;
      case 'language':
        return language;
      case 'profile':
        return profile;
      case 'logout':
        return logout;
      default:
        return key;
    }
  }
}
