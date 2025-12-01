import 'package:flutter/material.dart';
import '../core/app_strings.dart';
import '../models/ingredient.dart';
import '../models/recipe.dart';
import '../models/health_profile.dart';
import 'recipe_details_screen.dart';

class MealSuggestionsScreen extends StatelessWidget {
  final AppLang lang;
  final List<Ingredient> ingredients;
  final List<Recipe> recipes;
  final HealthProfile profile;

  const MealSuggestionsScreen({
    super.key,
    required this.lang,
    required this.ingredients,
    required this.recipes,
    required this.profile,
  });

  List<Recipe> _filterRecipes() {
    return recipes.where((recipe) {
      if (profile.hasDiabetes && !recipe.isForDiabetes) return false;
      if (profile.hasHighBloodPressure && !recipe.isLowSalt) return false;
      if (profile.isVegetarian && !recipe.isVegetarian) return false;

      for (final allergy in profile.allergies) {
        for (final ing in recipe.ingredients) {
          if (ing.toLowerCase().contains(allergy.toLowerCase())) {
            return false;
          }
        }
      }

      int matched = 0;
      for (final recIng in recipe.ingredients) {
        final found = ingredients.any(
          (userIng) =>
              userIng.name.toLowerCase() == recIng.toLowerCase() &&
              userIng.quantity > 0,
        );
        if (found) matched++;
      }

      if (recipe.ingredients.isEmpty) return false;
      final ratio = matched / recipe.ingredients.length;
      return ratio >= 0.5;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final strings = AppStrings(lang);
    final filtered = _filterRecipes();

    return Scaffold(
      appBar: AppBar(
        title: Text(strings.suggestionsTitle),
      ),
      body: filtered.isEmpty
          ? Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Text(
                  strings.noMeals,
                  textAlign: TextAlign.center,
                ),
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: filtered.length,
              itemBuilder: (context, index) {
                final recipe = filtered[index];
                return Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    color: Colors.white,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.04),
                        blurRadius: 12,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor:
                          const Color(0xFFf08c3a).withOpacity(0.18),
                      child: const Icon(Icons.restaurant_rounded,
                          color: Color(0xFFf08c3a)),
                    ),
                    title: Text(recipe.title),
                    subtitle: Text('${recipe.calories} ${strings.kcal}'),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) =>
                              RecipeDetailsScreen(lang: lang, recipe: recipe),
                        ),
                      );
                    },
                  ),
                );
              },
            ),
    );
  }
}
