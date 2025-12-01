import 'package:flutter/material.dart';
import '../core/app_strings.dart';
import '../models/recipe.dart';
import 'recipe_details_screen.dart';

class AllRecipesScreen extends StatelessWidget {
  final AppLang lang;
  final List<Recipe> recipes;

  const AllRecipesScreen({
    super.key,
    required this.lang,
    required this.recipes,
  });

  @override
  Widget build(BuildContext context) {
    final strings = AppStrings(lang);

    return Scaffold(
      appBar: AppBar(
        title: Text(strings.allRecipes),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: recipes.length,
        itemBuilder: (context, index) {
          final recipe = recipes[index];
          return Card(
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            margin: const EdgeInsets.only(bottom: 12),
            child: ListTile(
              leading: const Icon(Icons.menu_book_rounded),
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
