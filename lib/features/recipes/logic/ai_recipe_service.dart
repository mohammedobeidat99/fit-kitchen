import 'dart:math';
import '../../../models/recipe.dart';
import 'package:flutter/foundation.dart';

/// Local smart recipe generator — no API key required.
/// Generates creative recipe suggestions from pantry ingredients.
class AiRecipeService {
  final _rng = Random();

  static const List<Map<String, dynamic>> _templates = [
    {
      'titlePrefix': 'Quick',
      'method': 'Stir-Fried',
      'category': 'Lunch',
      'baseCalories': 480,
      'basePrepTime': 20,
    },
    {
      'titlePrefix': 'Healthy',
      'method': 'Baked',
      'category': 'Dinner',
      'baseCalories': 420,
      'basePrepTime': 35,
    },
    {
      'titlePrefix': 'Light',
      'method': 'Grilled',
      'category': 'Lunch',
      'baseCalories': 350,
      'basePrepTime': 25,
    },
    {
      'titlePrefix': 'Morning',
      'method': 'Scrambled',
      'category': 'Breakfast',
      'baseCalories': 280,
      'basePrepTime': 12,
    },
    {
      'titlePrefix': 'Protein',
      'method': 'Pan-Seared',
      'category': 'Dinner',
      'baseCalories': 520,
      'basePrepTime': 30,
    },
    {
      'titlePrefix': 'Crispy',
      'method': 'Air-Fried',
      'category': 'Snack',
      'baseCalories': 220,
      'basePrepTime': 15,
    },
    {
      'titlePrefix': 'Spicy',
      'method': 'Roasted',
      'category': 'Dinner',
      'baseCalories': 380,
      'basePrepTime': 40,
    },
    {
      'titlePrefix': 'Fresh',
      'method': 'Salad Bowl',
      'category': 'Lunch',
      'baseCalories': 310,
      'basePrepTime': 10,
    },
    {
      'titlePrefix': 'Hearty',
      'method': 'Slow-Cooked',
      'category': 'Dinner',
      'baseCalories': 450,
      'basePrepTime': 120,
    },
    {
      'titlePrefix': 'Sweet',
      'method': 'Sugar-Free',
      'category': 'Dessert',
      'baseCalories': 180,
      'basePrepTime': 15,
    },
    {
      'titlePrefix': 'Creamy',
      'method': 'Frozen',
      'category': 'Dessert',
      'baseCalories': 210,
      'basePrepTime': 10,
    },
    {
      'titlePrefix': 'Rich',
      'method': 'No-Bake',
      'category': 'Dessert',
      'baseCalories': 250,
      'basePrepTime': 20,
    },
  ];

  Future<List<Recipe>> generateRecipes(
    List<String> pantryIngredients, {
    Set<String> avoidedKeywords = const {},
    bool isDiabetic = false,
    bool isHypertensive = false,
  }) async {
    // Simulate a tiny delay for UX
    await Future.delayed(const Duration(milliseconds: 1200));

    if (pantryIngredients.isEmpty) return [];

    // Filter pantry ingredients based on health profile
    final safePantry = pantryIngredients.where((ing) {
      return !avoidedKeywords.any((kw) => ing.toLowerCase().contains(kw.toLowerCase()));
    }).toList();

    if (safePantry.isEmpty) return [];

    final suggestions = <Recipe>[];
    final shuffled = List<Map<String, dynamic>>.from(_templates)..shuffle(_rng);

    // Generate up to 7 recipes
    for (int i = 0; i < 7 && i < shuffled.length; i++) {
      final template = shuffled[i];
      
      // Skip template if it's not suitable for conditions (e.g. sugary snacks for diabetics)
      if (isDiabetic && template['category'] == 'Snack' && template['titlePrefix'] == 'Crispy') continue;

      final mainIngredient = safePantry[_rng.nextInt(safePantry.length)];
      final secondaryIngredients = safePantry
          .where((ing) => ing != mainIngredient)
          .take(3)
          .toList();

      String titlePrefix = template['titlePrefix'];
      if (isDiabetic) titlePrefix = 'Low-Glycemic';
      if (isHypertensive) titlePrefix = 'Heart-Healthy';

      final title = '$titlePrefix ${template['method']} $mainIngredient';
      final method = template['method'] as String;
      final category = template['category'] as String;
      
      // Adjust macros for health conditions
      int calories = (template['baseCalories'] as int) + _rng.nextInt(100) - 50;
      double carbs = 30.0 + _rng.nextInt(30).toDouble();
      double protein = 25.0 + _rng.nextInt(20).toDouble();
      
      if (isDiabetic) {
        carbs = carbs * 0.6; // Lower carbs
        calories = (calories * 0.8).toInt();
      }

      final allIngredients = [mainIngredient, ...secondaryIngredients];
      final steps = _buildSteps(mainIngredient, secondaryIngredients, method, isHypertensive);
      
      final imageUrl = 'https://image.pollinations.ai/prompt/${Uri.encodeComponent('Delicious healthy ${isDiabetic ? "low sugar" : ""} ${isHypertensive ? "low sodium" : ""} $title high quality food photography plating')}';

      suggestions.add(Recipe(
        id: 'ai_${DateTime.now().millisecondsSinceEpoch}_$i',
        title: title,
        description: 'A health-optimized suggestion using your $mainIngredient.',
        imageUrl: imageUrl,
        ingredients: allIngredients,
        steps: steps,
        category: category,
        prepTime: template['basePrepTime'] as int,
        calories: calories,
        servings: 2,
        protein: protein,
        carbs: carbs,
        fat: 10.0 + _rng.nextInt(15).toDouble(),
        isFeatured: false,
      ));
    }

    return suggestions;
  }

  String _buildSteps(String main, List<String> secondary, String method, bool lowSalt) {
    final sides = secondary.isEmpty ? 'and season' : secondary.join(', ');
    final seasoning = lowSalt ? "herbs and lemon (low sodium)" : "salt, pepper, and spices";
    
    return '1. Prepare $main by washing and cutting into even pieces.\n'
        '2. Gather $sides and arrange them ready for cooking.\n'
        '3. Heat your pan or oven and add a healthy drizzle of olive oil.\n'
        '4. ${method.contains('Baked') ? "Place in preheated oven at 180°C." : "${method} $main for 5-7 minutes on each side."}\n'
        '5. Add the remaining ingredients ($sides) and cook together for 3-5 more minutes.\n'
        '6. Season with $seasoning.\n'
        '7. Plate beautifully and serve hot!';
  }
}
