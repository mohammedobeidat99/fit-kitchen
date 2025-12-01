import 'package:flutter/material.dart';

enum AppLang { en, ar }

class AppStrings {
  final AppLang lang;
  AppStrings(this.lang);

  bool get isAr => lang == AppLang.ar;
  TextDirection get direction =>
      isAr ? TextDirection.rtl : TextDirection.ltr;

  String get appTitle => isAr ? ' فيت كيتشين' : 'FitKitchen';
  String get tagline => isAr
      ? 'خطط لوجباتك بذكاء باستخدام المكونات الموجودة في مطبخك.'
      : 'Plan smarter meals using what you already have in your kitchen.';

  String get ingredients => isAr ? 'المكونات' : 'Ingredients';
  String get recipes => isAr ? 'الوصفات' : 'Recipes';

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

  String get pantryTitle => pantry;
  String get add => isAr ? 'إضافة' : 'Add';
  String get name => isAr ? 'الاسم' : 'Name';
  String get quantity => isAr ? 'الكمية' : 'Quantity';
  String get unit => isAr ? 'الوحدة (جم، حبة..)' : 'Unit (g, pcs, etc.)';
  String get save => isAr ? 'حفظ' : 'Save';
  String get cancel => isAr ? 'إلغاء' : 'Cancel';

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

  String get suggestionsTitle => mealSuggestions;
  String get noMeals => isAr
      ? 'لا توجد وجبات مناسبة.\nحاول إضافة مكونات أكثر أو تعديل ملفك الصحي.'
      : 'No suitable meals found.\nTry adding more ingredients or adjusting your health profile.';

  String get kcal => isAr ? 'سعر حراري' : 'kcal';
  String get ingredientsTitle => isAr ? 'المكونات' : 'Ingredients';
  String get stepsTitle => isAr ? 'الخطوات' : 'Steps';

  String get languageButton => isAr ? 'EN' : 'عربي';
}
