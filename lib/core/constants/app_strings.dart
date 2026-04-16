import 'package:flutter/material.dart';

enum AppLang { en, ar }

class AppStrings {
  final AppLang lang;
  AppStrings(this.lang);

  bool get isAr => lang == AppLang.ar;
  TextDirection get direction => isAr ? TextDirection.rtl : TextDirection.ltr;

  // Global Components
  String get appName => isAr ? 'فيت كيتشين' : 'FitKitchen';
  String get welcomeBack => isAr ? 'مرحباً بعودتك' : 'Welcome Back';
  String get guest => isAr ? 'زائر' : 'Guest';
  String get logout => isAr ? 'تسجيل الخروج' : 'Logout';
  String get cancel => isAr ? 'إلغاء' : 'Cancel';
  String get confirm => isAr ? 'تأكيد' : 'Confirm';
  String get save => isAr ? 'حفظ' : 'Save';
  String get search => isAr ? 'بحث...' : 'Search...';
  String get noData => isAr ? 'لا توجد بيانات' : 'No data available';
  String get retry => isAr ? 'إعادة المحاولة' : 'Retry';

  // Auth Specific
  String get login => isAr ? 'تسجيل الدخول' : 'Login';
  String get register => isAr ? 'تسجيل جديد' : 'Register';
  String get email => isAr ? 'البريد الإلكتروني' : 'Email';
  String get password => isAr ? 'كلمة المرور' : 'Password';
  String get fullName => isAr ? 'الاسم الكامل' : 'Full Name';
  String get createAccount => isAr ? 'إنشاء حساب' : 'Create Account';
  String get selectRecipe => isAr ? 'اختر وصفة' : 'Select Recipe';
  String get addMeal => isAr ? 'أضف وجبة' : 'Add Meal';
  String get clearAll => isAr ? 'مسح الكل' : 'Clear All';
  String get readyToCook => isAr ? 'جاهز للطبخ' : 'Ready to Cook';
  String get appearance => isAr ? 'المظهر' : 'Appearance';
  String get darkMode => isAr ? 'الوضع المظلم' : 'Dark Mode';
  String get name => isAr ? 'الاسم' : 'Name';
  String get quantity => isAr ? 'الكمية' : 'Quantity';
  String get add => isAr ? 'إضافة' : 'Add';
  String get noItems => isAr ? 'لا يوجد عناصر' : 'No Items';
  String get searchIngredients => isAr ? 'ابحث عن المكونات' : 'Search Ingredients';
  String get sortByExpiration => isAr ? 'ترتيب حسب الانتهاء' : 'Sort by Expiration';
  String get aiAssistant => isAr ? 'المساعد الذكي' : 'AI Assistant';
  String get foodScanner => isAr ? 'ماسح الطعام' : 'Food Scanner';
  String get smartSuggestions => isAr ? 'اقتراحات ذكية' : 'Smart Suggestions';
  String get healthScore => isAr ? 'مستوى الصحة' : 'Health Score';
  String get caloriesToday => isAr ? 'سعرات اليوم' : 'Daily Calories';
  String get scanFood => isAr ? 'امسح الوجبة' : 'Scan Food';
  String get askMe => isAr ? 'اسألني أي شيء...' : 'Ask me anything...';

  String dayName(String day) {
    if (!isAr) return day;
    switch (day) {
      case 'Monday': return 'الاثنين';
      case 'Tuesday': return 'الثلاثاء';
      case 'Wednesday': return 'الأربعاء';
      case 'Thursday': return 'الخميس';
      case 'Friday': return 'الجمعة';
      case 'Saturday': return 'السبت';
      case 'Sunday': return 'الأحد';
      default: return day;
    }
  }

  String missingIngredients(int count) => isAr ? 'ينقصك $count مكونات' : 'Missing $count ingredients';

  String get biometricAuth => isAr ? 'المصادقة بالبصمة' : 'Biometric Auth';

  // Home Screen
  String get homeSummary => isAr ? 'نظرة عامة' : 'At a glance';
  String get ingredients => isAr ? 'مكونات' : 'Ingredients';
  String get expiringSoon => isAr ? 'تنتهي قريباً' : 'Expiring soon';
  String get mealsPlanned => isAr ? 'وجبات مخططة' : 'Meals planned';
  String get quickActions => isAr ? 'إجراءات سريعة' : 'Quick Actions';
  String get featuredRecipes => isAr ? 'وصفات مميزة' : 'Featured Recipes';

  // Feature specific strings (to be expanded as needed)
  String get pantry => isAr ? 'المخزون' : 'Pantry';
  String get planner => isAr ? 'المخطط' : 'Planner';
  String get shopping => isAr ? 'التسوق' : 'Shopping';
  String get settings => isAr ? 'الإعدادات' : 'Settings';

  // Helper for greeting
  String greeting(String name) => isAr ? 'مرحباً، $name 👋' : 'Hello, $name 👋';
}
