import 'package:flutter/material.dart';

enum AppLang { en, ar }

class AppStrings {
  final AppLang lang;
  AppStrings(this.lang);

  bool get isAr => lang == AppLang.ar;
  TextDirection get direction =>
      isAr ? TextDirection.rtl : TextDirection.ltr;

  // General
  String get appTitle => isAr ? ' فيت كيتشين' : 'FitKitchen';
  String get tagline => isAr
      ? 'خطط لوجباتك بذكاء باستخدام المكونات الموجودة في مطبخك.'
      : 'Plan smarter meals using what you already have in your kitchen.';

  // Stats
  String get ingredients => isAr ? 'المكونات' : 'Ingredients';
  String get recipes => isAr ? 'الوصفات' : 'Recipes';
  String get mealsPlanned => isAr ? 'وجبات مخططة' : 'Planned';

  // Main features
  String get mainFeatures => isAr ? 'الخصائص الرئيسية' : 'Main Features';
  String get pantry => isAr ? 'مخزون المطبخ' : 'Pantry';
  String get pantryDesc =>
      isAr ? 'إدارة وتتبع مكونات مطبخك.' : 'Manage and track your ingredients.';
  String get healthProfile => isAr ? 'الملف الصحي' : 'Health Profile';
  String get healthProfileDesc => isAr
      ? 'تحديد حالتك الصحية وتفضيلاتك الغذائية.'
      : 'Set your health needs and preferences.';
  String get mealSuggestions => isAr ? 'اقتراح الوجبات' : 'Meal Suggestions';
  String get mealSuggestionsDesc => isAr
      ? 'عرض وجبات تناسب مخزونك وحالتك الصحية.'
      : 'See meals that fit your kitchen and health.';
  String get allRecipes => isAr ? 'كل الوصفات' : 'All Recipes';
  String get allRecipesDesc =>
      isAr ? 'تصفح جميع الوصفات المتاحة.' : 'Browse all available recipes.';

  // Pantry
  String get pantryTitle => pantry;
  String get add => isAr ? 'إضافة' : 'Add';
  String get name => isAr ? 'الاسم' : 'Name';
  String get quantity => isAr ? 'الكمية' : 'Quantity';
  String get unit => isAr ? 'الوحدة (جم، حبة..)' : 'Unit (g, pcs, etc.)';
  String get save => isAr ? 'حفظ' : 'Save';
  String get cancel => isAr ? 'إلغاء' : 'Cancel';
  String get category => isAr ? 'الفئة' : 'Category';
  String get expirationDate => isAr ? 'تاريخ الانتهاء' : 'Expiration Date';
  String get expired => isAr ? 'منتهي الصلاحية' : 'Expired';
  String get expiringSoon => isAr ? 'ينتهي قريباً' : 'Expiring Soon';
  String get lowStock => isAr ? 'مخزون منخفض' : 'Low Stock';

  // Health Profile
  String get healthTitle => healthProfile;
  String get diabetes =>
      isAr ? 'وجبات مناسبة لمرضى السكري' : 'Diabetes-friendly meals';
  String get pressure => isAr
      ? 'وجبات قليلة الملح (ضغط دم مرتفع)'
      : 'Low-salt meals (High blood pressure)';
  String get vegetarian =>
      isAr ? 'وجبات نباتية فقط' : 'Vegetarian meals only';
  String get allergies => isAr ? 'الحساسيات' : 'Allergies';
  String get addAllergyHint =>
      isAr ? 'أضف حساسية (مثلاً: مكسرات)' : 'Add allergy (e.g., peanuts)';

  // Meal Suggestions
  String get suggestionsTitle => mealSuggestions;
  String get noMeals => isAr
      ? 'لا توجد وجبات مناسبة.\nحاول إضافة مكونات أكثر أو تعديل ملفك الصحي.'
      : 'No suitable meals found.\nTry adding more ingredients or adjusting your health profile.';

  // Recipe Details
  String get kcal => isAr ? 'سعر حراري' : 'kcal';
  String get ingredientsTitle => isAr ? 'المكونات' : 'Ingredients';
  String get stepsTitle => isAr ? 'الخطوات' : 'Steps';
  String get prepTime => isAr ? 'وقت التحضير' : 'Prep Time';
  String get minutes => isAr ? 'دقيقة' : 'min';
  String get servings => isAr ? 'حصص' : 'Servings';
  String get markAsCooked => isAr ? 'تم الطهي' : 'Mark as Cooked';
  String get addToMealPlan => isAr ? 'أضف للخطة' : 'Add to Plan';
  String get cookThis => isAr ? 'اطبخ هذا' : 'Cook This';
  String get cookedSuccess => isAr ? 'تمت إضافة الوجبة لسجل الطبخ!' : 'Added to cooking history!';
  String get addedToPlan => isAr ? 'تمت إضافة الوجبة للخطة!' : 'Added to meal plan!';
  String get selectDay => isAr ? 'اختر اليوم' : 'Select Day';

  // Language
  String get languageButton => isAr ? 'EN' : 'عربي';

  // Bottom Navigation
  String get navHome => isAr ? 'الرئيسية' : 'Home';
  String get navPlanner => isAr ? 'الخطة' : 'Planner';
  String get navShopping => isAr ? 'التسوق' : 'Shopping';
  String get navHistory => isAr ? 'السجل' : 'History';

  // Weekly Planner
  String get weeklyPlanner => isAr ? 'الخطة الأسبوعية' : 'Weekly Planner';
  String get weeklyPlannerDesc => isAr
      ? 'خطط وجباتك لكل يوم من الأسبوع.'
      : 'Plan your meals for each day of the week.';
  String get noMealsPlanned => isAr ? 'لا توجد وجبات مخططة' : 'No meals planned';
  String get addMeal => isAr ? 'إضافة وجبة' : 'Add Meal';
  String get clearDay => isAr ? 'مسح اليوم' : 'Clear Day';
  String get clearAll => isAr ? 'مسح الكل' : 'Clear All';
  String get selectRecipe => isAr ? 'اختر وصفة' : 'Select Recipe';

  // Day names
  String dayName(String day) {
    if (!isAr) return day;
    const map = {
      'Monday': 'الإثنين',
      'Tuesday': 'الثلاثاء',
      'Wednesday': 'الأربعاء',
      'Thursday': 'الخميس',
      'Friday': 'الجمعة',
      'Saturday': 'السبت',
      'Sunday': 'الأحد',
    };
    return map[day] ?? day;
  }

  // Shopping List
  String get shoppingList => isAr ? 'قائمة التسوق' : 'Shopping List';
  String get shoppingListDesc => isAr
      ? 'أنشئ قائمة المكونات الناقصة.'
      : 'Generate list of missing ingredients.';
  String get generateFromPlan => isAr ? 'إنشاء من الخطة' : 'Generate from Plan';
  String get addItem => isAr ? 'إضافة عنصر' : 'Add Item';
  String get clearChecked => isAr ? 'حذف المحدد' : 'Clear Checked';
  String get emptyShoppingList => isAr ? 'قائمة التسوق فارغة' : 'Shopping list is empty';
  String get itemName => isAr ? 'اسم العنصر' : 'Item name';

  // Notifications
  String get notifications => isAr ? 'التنبيهات' : 'Notifications';
  String get notificationsDesc => isAr
      ? 'تنبيهات انتهاء الصلاحية والمخزون.'
      : 'Expiration and stock alerts.';
  String get noNotifications => isAr ? 'لا توجد تنبيهات' : 'No notifications';
  String get expirationAlert => isAr ? 'تنبيه انتهاء صلاحية' : 'Expiration Alert';
  String get lowStockAlert => isAr ? 'تنبيه مخزون منخفض' : 'Low Stock Alert';
  String get mealReminder => isAr ? 'تذكير وجبة' : 'Meal Reminder';

  // Cooking History
  String get cookingHistory => isAr ? 'سجل الطبخ' : 'Cooking History';
  String get cookingHistoryDesc => isAr
      ? 'عرض سجل الوجبات المطبوخة.'
      : 'View your cooked meals activity log.';
  String get noCookingHistory => isAr ? 'لا يوجد سجل طبخ بعد' : 'No cooking history yet';
  String get clearHistory => isAr ? 'مسح السجل' : 'Clear History';
  String get cookedOn => isAr ? 'تم الطبخ في' : 'Cooked on';

  // ====== AUTH ======
  String get login => isAr ? 'تسجيل الدخول' : 'Login';
  String get register => isAr ? 'إنشاء حساب' : 'Register';
  String get createAccount => isAr ? 'إنشاء حساب جديد' : 'Create Account';
  String get fullName => isAr ? 'الاسم الكامل' : 'Full Name';
  String get email => isAr ? 'البريد الإلكتروني' : 'Email';
  String get password => isAr ? 'كلمة المرور' : 'Password';
  String get confirmPassword => isAr ? 'تأكيد كلمة المرور' : 'Confirm Password';
  String get rememberMe => isAr ? 'تذكرني' : 'Remember Me';
  String get forgotPassword => isAr ? 'نسيت كلمة المرور؟' : 'Forgot Password?';
  String get noAccount => isAr ? 'ليس لديك حساب؟' : "Don't have an account?";
  String get haveAccount => isAr ? 'لديك حساب بالفعل؟' : 'Already have an account?';
  String get biometricLogin => isAr ? 'تسجيل بالبصمة' : 'Biometric Login';
  String get biometricNotAvailable => isAr ? 'غير متاح على هذا الجهاز' : 'Not available on this device';

  // Validation
  String get emailRequired => isAr ? 'البريد الإلكتروني مطلوب' : 'Email is required';
  String get emailInvalid => isAr ? 'بريد إلكتروني غير صالح' : 'Invalid email address';
  String get passwordRequired => isAr ? 'كلمة المرور مطلوبة' : 'Password is required';
  String get passwordTooShort => isAr ? 'كلمة المرور قصيرة جداً (6 أحرف على الأقل)' : 'Password too short (min 6 characters)';
  String get nameRequired => isAr ? 'الاسم مطلوب' : 'Name is required';
  String get nameTooShort => isAr ? 'الاسم قصير جداً' : 'Name too short';
  String get confirmPasswordRequired => isAr ? 'تأكيد كلمة المرور مطلوب' : 'Confirm password is required';
  String get passwordsDoNotMatch => isAr ? 'كلمات المرور غير متطابقة' : 'Passwords do not match';

  // Forgot Password
  String get resetPassword => isAr ? 'إعادة تعيين كلمة المرور' : 'Reset Password';
  String get resetPasswordDesc => isAr
      ? 'أدخل بريدك الإلكتروني وسنرسل لك رابط إعادة التعيين.'
      : 'Enter your email and we\'ll send you a reset link.';
  String get sendResetLink => isAr ? 'إرسال رابط التعيين' : 'Send Reset Link';
  String get resetEmailSent => isAr ? 'تم إرسال رابط التعيين!' : 'Reset Link Sent!';
  String get resetEmailSentDesc => isAr
      ? 'تحقق من بريدك الإلكتروني لإعادة تعيين كلمة المرور.'
      : 'Check your email to reset your password.';
  String get backToLogin => isAr ? 'العودة لتسجيل الدخول' : 'Back to Login';
  String get emailNotFound => isAr ? 'البريد الإلكتروني غير مسجل' : 'Email not found';

  // Settings
  String get settings => isAr ? 'الإعدادات' : 'Settings';
  String get appearance => isAr ? 'المظهر' : 'Appearance';
  String get darkMode => isAr ? 'الوضع الليلي' : 'Dark Mode';
  String get language => isAr ? 'اللغة' : 'Language';
  String get security => isAr ? 'الأمان' : 'Security';
  String get about => isAr ? 'حول التطبيق' : 'About';
  String get appVersion => isAr ? 'إصدار التطبيق' : 'App Version';
  String get logout => isAr ? 'تسجيل الخروج' : 'Logout';
  String get logoutConfirm => isAr ? 'هل أنت متأكد من تسجيل الخروج؟' : 'Are you sure you want to logout?';
  String get guest => isAr ? 'زائر' : 'Guest';

  // Search & Filter
  String get search => isAr ? 'بحث...' : 'Search...';
  String get searchIngredients => isAr ? 'البحث في المكونات...' : 'Search ingredients...';
  String get searchRecipes => isAr ? 'البحث في الوصفات...' : 'Search recipes...';
  String get filterByCategory => isAr ? 'تصفية حسب الفئة' : 'Filter by category';
  String get allCategories => isAr ? 'الكل' : 'All';
  String get sortByExpiration => isAr ? 'ترتيب حسب الانتهاء' : 'Sort by expiration';

  // Smart Meal Suggestions
  String get readyToCook => isAr ? 'جاهز للطبخ ✓' : 'Ready to cook ✓';
  String missingIngredients(int count) => isAr ? 'ينقصك $count مكونات' : 'Missing $count ingredients';

  // Greeting
  String greeting(String name) => isAr ? 'مرحباً، $name 👋' : 'Hello, $name 👋';

  // Misc
  String get noItems => isAr ? 'لا توجد عناصر' : 'No items';
  String get confirm => isAr ? 'تأكيد' : 'Confirm';
  String get delete => isAr ? 'حذف' : 'Delete';
  String get edit => isAr ? 'تعديل' : 'Edit';
  String get done => isAr ? 'تم' : 'Done';
}
