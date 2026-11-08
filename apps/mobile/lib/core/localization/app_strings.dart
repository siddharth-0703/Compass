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
  String get welcomeBack => isHindi ? 'वापसी पर स्वागत है' : (isMarathi ? 'पुन्हा स्वागत आहे' : 'Welcome back');
  String get businessScore => isHindi ? 'बिजनेस स्कोर' : (isMarathi ? 'व्यवसाय गुण' : 'Business Score');
  String get marketDemand => isHindi ? 'बाजार मांग' : (isMarathi ? 'बाजार मागणी' : 'Market Demand');
  String get highDemand => isHindi ? 'उच्च' : (isMarathi ? 'उच्च' : 'High');
  String get weather => isHindi ? 'मौसम' : (isMarathi ? 'हवामान' : 'Weather');
  String get schemeMatches => isHindi ? 'योजना मैच' : (isMarathi ? 'योजना जुळण्या' : 'Scheme Matches');
  String get quickActions => isHindi ? 'त्वरित कार्रवाई' : (isMarathi ? 'त्वरित कृती' : 'Quick Actions');
  String get registerNewBusiness => isHindi ? 'नया व्यवसाय पंजीकृत करें' : (isMarathi ? 'नवीन व्यवसाय नोंदणी करा' : 'Register New Business');
  String get exploreSchemes => isHindi ? 'योजनाएं खोजें' : (isMarathi ? 'योजना शोधा' : 'Explore Schemes');
  String get checkMandiRates => isHindi ? 'मंडी भाव देखें' : (isMarathi ? 'मंडी भाव तपासा' : 'Check APMC Rates');
  String get startLearning => isHindi ? 'सीखना शुरू करें' : (isMarathi ? 'शिकणे सुरू करा' : 'Start Learning');
  String get recentActivity => isHindi ? 'हाल की गतिविधि' : (isMarathi ? 'अलीकडील क्रियाकलाप' : 'Recent Activity');
  String get viewAll => isHindi ? 'सभी देखें' : (isMarathi ? 'सर्व पहा' : 'View all');

  // Settings
  String get account => isHindi ? 'खाता' : (isMarathi ? 'खाते' : 'Account');
  String get preferences => isHindi ? 'प्राथमिकताएं' : (isMarathi ? 'पसंती' : 'Preferences');
  String get language => isHindi ? 'भाषा' : (isMarathi ? 'भाषा' : 'Language');
  String get appearance => isHindi ? 'दिखावट' : (isMarathi ? 'स्वरूप' : 'Appearance');
  String get syncSettings => isHindi ? 'सिंक सेटिंग्स' : (isMarathi ? 'सिंक सेटिंग्ज' : 'Sync Settings');
  String get profile => isHindi ? 'प्रोफ़ाइल' : (isMarathi ? 'प्रोफाइल' : 'Profile');
  String get selectLanguage => isHindi ? 'भाषा चुनें' : (isMarathi ? 'भाषा निवडा' : 'Select Language');
  String get systemDefault => isHindi ? 'सिस्टम डिफ़ॉल्ट' : (isMarathi ? 'सिस्टम डीफॉल्ट' : 'System default');

  // Learning
  String get courseLessons => isHindi ? 'कोर्स के पाठ' : (isMarathi ? 'अभ्यासक्रमाचे धडे' : 'Course Lessons');
  String get completed => isHindi ? 'पूर्ण हुआ' : (isMarathi ? 'पूर्ण झाले' : 'Completed');
  String get markAsCompleted => isHindi ? 'पूर्ण के रूप में चिह्नित करें' : (isMarathi ? 'पूर्ण म्हणून चिन्हांकित करा' : 'Mark as Completed');
  String get downloadOffline => isHindi ? 'ऑफ़लाइन डाउनलोड करें' : (isMarathi ? 'ऑफलाइन डाउनलोड करा' : 'Download Lesson (Offline)');
  String get downloadedOfflineReady => isHindi ? 'डाउनलोड किया गया (ऑफ़लाइन तैयार ✓)' : (isMarathi ? 'डाउनलोड केले (ऑफलाइन तयार ✓)' : 'Downloaded (Offline Ready ✓)');
  String get playbackSpeed => isHindi ? 'प्लेबैक गति' : (isMarathi ? 'प्लेबॅक गती' : 'Playback Speed');
  String get offlineZeroData => isHindi ? 'ऑफ़लाइन ज़ीरो-डेटा' : (isMarathi ? 'ऑफलाइन शून्य-डेटा' : 'OFFLINE ZERO-DATA');
  String get inAppHd => isHindi ? 'इन-ऐप एचडी' : (isMarathi ? 'अ‍ॅपमध्ये एचडी' : 'IN-APP HD');

  // Schemes
  String get findYourSchemes => isHindi ? 'अपनी योजनाएं खोजें' : (isMarathi ? 'आपल्या योजना शोधा' : 'Find Your Schemes');
  String get refineProfile => isHindi ? 'प्रोफ़ाइल सुधारें' : (isMarathi ? 'प्रोफाइल सुधारा' : 'Refine Profile');
  String get noMatchingSchemes => isHindi ? 'कोई मेल खाती योजना नहीं मिली' : (isMarathi ? 'कोणतीही जुळणारी योजना आढळली नाही' : 'No matching schemes found');
  String get verifiedSchemes => isHindi ? 'सत्यापित योजनाएं' : (isMarathi ? 'सत्यापित योजना' : 'Verified Schemes');
  String get aiDiscovered => isHindi ? 'एआई द्वारा खोजी गई' : (isMarathi ? 'एआय शोधलेले' : 'AI Discovered');

  // General
  String get search => isHindi ? 'खोजें...' : (isMarathi ? 'शोधा...' : 'Search...');
  String get talkToAi => isHindi ? 'एआई से बात करें' : (isMarathi ? 'एआयशी बोला' : 'Talk to AI');
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

