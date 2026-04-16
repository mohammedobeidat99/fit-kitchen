class HealthCondition {
  final String id;
  final String name;
  final String nameAr;
  final List<String> avoidIngredients; // ingredient keywords to filter out

  const HealthCondition({
    required this.id,
    required this.name,
    required this.nameAr,
    this.avoidIngredients = const [],
  });
}

class HealthProfile {
  bool hasDiabetes;
  bool hasHighBloodPressure;
  bool isVegetarian;
  List<String> allergies;

  /// Custom conditions the user can add (e.g. 'Celiac', 'Lactose Intolerant')
  List<HealthCondition> activeConditions;

  HealthProfile({
    this.hasDiabetes = false,
    this.hasHighBloodPressure = false,
    this.isVegetarian = false,
    List<String>? allergies,
    List<HealthCondition>? activeConditions,
  })  : allergies = allergies ?? [],
        activeConditions = activeConditions ?? [];

  /// All ingredient keywords that should be avoided based on active conditions
  Set<String> get avoidedIngredientKeywords {
    final keywords = <String>{};
    if (hasDiabetes) keywords.addAll(['Sugar', 'Honey', 'Corn Syrup', 'White Bread', 'White Rice']);
    if (hasHighBloodPressure) keywords.addAll(['Salt', 'Sodium', 'Soy Sauce', 'Processed']);
    if (isVegetarian) keywords.addAll(['Chicken', 'Beef', 'Pork', 'Fish', 'Salmon', 'Meat', 'Tuna']);
    for (final c in activeConditions) {
      keywords.addAll(c.avoidIngredients);
    }
    // Allergies are also avoided keywords
    keywords.addAll(allergies);
    return keywords;
  }

  /// Predefined conditions a user can pick from
  static const List<HealthCondition> presetConditions = [
    HealthCondition(
      id: 'celiac',
      name: 'Celiac / Gluten-Free',
      nameAr: 'الداء الزلاقي / خالي من الغلوتين',
      avoidIngredients: ['Bread', 'Flour', 'Wheat', 'Pasta', 'Oats'],
    ),
    HealthCondition(
      id: 'lactose',
      name: 'Lactose Intolerant',
      nameAr: 'عدم تحمل اللاكتوز',
      avoidIngredients: ['Milk', 'Cheese', 'Butter', 'Cream', 'Yogurt', 'Greek Yogurt'],
    ),
    HealthCondition(
      id: 'kidney',
      name: 'Kidney Disease',
      nameAr: 'مرض الكلى',
      avoidIngredients: ['Potassium', 'Phosphorus', 'Beans', 'Lentils'],
    ),
    HealthCondition(
      id: 'heartdisease',
      name: 'Heart Disease',
      nameAr: 'أمراض القلب',
      avoidIngredients: ['Butter', 'Lard', 'Fried', 'Cream', 'Bacon'],
    ),
    HealthCondition(
      id: 'gout',
      name: 'Gout',
      nameAr: 'النقرس',
      avoidIngredients: ['Beef', 'Seafood', 'Alcohol', 'Organ Meat', 'Sardines'],
    ),
    HealthCondition(
      id: 'keto',
      name: 'Keto / Low Carb',
      nameAr: 'كيتو / منخفض الكربوهيدرات',
      avoidIngredients: ['Rice', 'Bread', 'Pasta', 'Sugar', 'Potato', 'Oats', 'Banana'],
    ),
    HealthCondition(
      id: 'vegan',
      name: 'Vegan',
      nameAr: 'نباتي صارم',
      avoidIngredients: ['Chicken', 'Beef', 'Pork', 'Fish', 'Salmon', 'Eggs', 'Milk', 'Cheese', 'Honey', 'Butter', 'Cream', 'Yogurt'],
    ),
    HealthCondition(
      id: 'ibs',
      name: 'IBS / Gut Sensitivity',
      nameAr: 'متلازمة القولون العصبي',
      avoidIngredients: ['Garlic', 'Onion', 'Beans', 'Broccoli', 'Cauliflower'],
    ),
  ];
}
