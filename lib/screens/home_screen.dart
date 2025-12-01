import 'package:fit_kitchen_demo/widgets/feature_card.dart';
import 'package:flutter/material.dart';
import '../core/app_strings.dart';
import '../models/ingredient.dart';
import '../models/recipe.dart';
import '../models/health_profile.dart';
import '../widgets/stat_card.dart';
import 'pantry_screen.dart';
import 'health_profile_screen.dart';
import 'meal_suggestions_screen.dart';
import 'all_recipes_screen.dart';

class HomePage extends StatelessWidget {
  final AppLang lang;
  final VoidCallback onToggleLang;
  final List<Ingredient> ingredients;
  final List<Recipe> recipes;
  final HealthProfile healthProfile;
  final ValueChanged<HealthProfile> onHealthProfileChanged;
  final VoidCallback onIngredientsChanged;

  const HomePage({
    super.key,
    required this.lang,
    required this.onToggleLang,
    required this.ingredients,
    required this.recipes,
    required this.healthProfile,
    required this.onHealthProfileChanged,
    required this.onIngredientsChanged,
  });

  @override
  Widget build(BuildContext context) {
    final strings = AppStrings(lang);

    return Scaffold(
      body: Stack(
        children: [
          Container(
            height: 260,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF3BB89C), Color(0xFF1C8D9E)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
          ),
          SafeArea(
            child: Column(
              children: [
                _buildHeader(context, strings),
                Expanded(
                  child: Container(
                    decoration: const BoxDecoration(
                      color: Color(0xFFF2F4F7),
                      borderRadius:
                          BorderRadius.vertical(top: Radius.circular(28)),
                    ),
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.fromLTRB(18, 20, 18, 20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildStatsRow(context, strings),
                          const SizedBox(height: 24),
                          Text(strings.mainFeatures,
                              style: Theme.of(context).textTheme.titleMedium),
                          const SizedBox(height: 12),
                          _buildFeatureList(context, strings),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context, AppStrings strings) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      child: Column(
        children: [
          Row(
            children: [
              const Icon(Icons.kitchen_rounded,
                  color: Colors.white, size: 28),
              const SizedBox(width: 8),
              Text(
                strings.appTitle,
                style: Theme.of(context)
                    .textTheme
                    .headlineLarge!
                    .copyWith(color: Colors.white),
              ),
              const Spacer(),
              OutlinedButton(
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.white,
                  side: const BorderSide(color: Colors.white),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
                onPressed: onToggleLang,
                child: Text(strings.languageButton),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Align(
            alignment: AlignmentDirectional.centerStart,
            child: Text(
              strings.tagline,
              style: Theme.of(context)
                  .textTheme
                  .bodyMedium!
                  .copyWith(color: Colors.white.withOpacity(0.9)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsRow(BuildContext context, AppStrings strings) {
    return Row(
      children: [
        Expanded(
          child: StatCard(
            title: strings.ingredients,
            value: ingredients.length.toString(),
            icon: Icons.inventory_2_rounded,
            color: const Color(0xFF3BB89C),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: StatCard(
            title: strings.recipes,
            value: recipes.length.toString(),
            icon: Icons.restaurant_menu_rounded,
            color: const Color(0xFFf08c3a),
          ),
        ),
      ],
    );
  }

  Widget _buildFeatureList(BuildContext context, AppStrings strings) {
    return Column(
      children: [
        FeatureTile(
          icon: Icons.inventory_rounded,
          title: strings.pantry,
          subtitle: strings.pantryDesc,
          color: const Color(0xFF3BB89C),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => PantryScreen(
                  lang: lang,
                  ingredients: ingredients,
                  onIngredientsChanged: onIngredientsChanged,
                ),
              ),
            );
          },
        ),
        const SizedBox(height: 10),
        FeatureTile(
          icon: Icons.favorite_rounded,
          title: strings.healthProfile,
          subtitle: strings.healthProfileDesc,
          color: Colors.pinkAccent,
          onTap: () async {
            final updated = await Navigator.push<HealthProfile>(
              context,
              MaterialPageRoute(
                builder: (_) =>
                    HealthProfileScreen(lang: lang, profile: healthProfile),
              ),
            );
            if (updated != null) {
              onHealthProfileChanged(updated);
            }
          },
        ),
        const SizedBox(height: 10),
        FeatureTile(
          icon: Icons.lightbulb_rounded,
          title: strings.mealSuggestions,
          subtitle: strings.mealSuggestionsDesc,
          color: const Color(0xFFf08c3a),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => MealSuggestionsScreen(
                  lang: lang,
                  ingredients: ingredients,
                  recipes: recipes,
                  profile: healthProfile,
                ),
              ),
            );
          },
        ),
        const SizedBox(height: 10),
        FeatureTile(
          icon: Icons.menu_book_rounded,
          title: strings.allRecipes,
          subtitle: strings.allRecipesDesc,
          color: Colors.indigo,
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) =>
                    AllRecipesScreen(lang: lang, recipes: recipes),
              ),
            );
          },
        ),
      ],
    );
  }
}
