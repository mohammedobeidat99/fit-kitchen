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
  ];

  Future<List<Recipe>> generateRecipes(List<String> pantryIngredients) async {
    // Simulate a tiny delay for UX
    await Future.delayed(const Duration(milliseconds: 900));

    if (pantryIngredients.isEmpty) return [];

    final suggestions = <Recipe>[];
    final shuffled = List<Map<String, dynamic>>.from(_templates)..shuffle(_rng);

    // Generate up to 7 recipes
    for (int i = 0; i < 7 && i < shuffled.length; i++) {
      final template = shuffled[i];
      final mainIngredient = pantryIngredients[_rng.nextInt(pantryIngredients.length)];
      final secondaryIngredients = pantryIngredients
          .where((ing) => ing != mainIngredient)
          .take(3)
          .toList();

      final title = '${template['titlePrefix']} ${template['method']} $mainIngredient';
      final method = template['method'] as String;
      final category = template['category'] as String;
      final calories = (template['baseCalories'] as int) + _rng.nextInt(100) - 50;
      final prepTime = (template['basePrepTime'] as int) + _rng.nextInt(10);

      final allIngredients = [mainIngredient, ...secondaryIngredients];
      final steps = _buildSteps(mainIngredient, secondaryIngredients, method);
      
      final imageUrl = 'https://image.pollinations.ai/prompt/${Uri.encodeComponent('Delicious appetizing $title high quality restaurant food photography plating')}';

      suggestions.add(Recipe(
        id: 'ai_${DateTime.now().millisecondsSinceEpoch}_$i',
        title: title,
        description: 'A smart suggestion using your $mainIngredient — ready in $prepTime minutes!',
        imageUrl: imageUrl,
        ingredients: allIngredients,
        steps: steps,
        category: category,
        prepTime: prepTime,
        calories: calories,
        servings: 2,
        protein: 25.0 + _rng.nextInt(20).toDouble(),
        carbs: 30.0 + _rng.nextInt(30).toDouble(),
        fat: 10.0 + _rng.nextInt(15).toDouble(),
        isFeatured: false,
      ));
    }

    return suggestions;
  }

  String _buildSteps(String main, List<String> secondary, String method) {
    final sides = secondary.isEmpty ? 'and season to taste' : secondary.join(', ');
    return '1. Prepare $main by washing and cutting into even pieces.\n'
        '2. Gather $sides and arrange them ready for cooking.\n'
        '3. Heat your pan or oven and add a drizzle of oil.\n'
        '4. ${method.contains('Baked') ? "Place in preheated oven at 180°C." : "${method} $main for 5-7 minutes on each side."}\n'
        '5. Add the remaining ingredients ($sides) and cook together for 3-5 more minutes.\n'
        '6. Season with salt, pepper, and your favourite spices.\n'
        '7. Plate beautifully and serve hot!';
  }
}
