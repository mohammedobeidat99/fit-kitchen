import 'package:flutter/material.dart';
import '../core/app_strings.dart';
import '../models/recipe.dart';

class RecipeDetailsScreen extends StatelessWidget {
  final AppLang lang;
  final Recipe recipe;

  const RecipeDetailsScreen({
    super.key,
    required this.lang,
    required this.recipe,
  });

  @override
  Widget build(BuildContext context) {
    final strings = AppStrings(lang);

    return Scaffold(
      appBar: AppBar(
        title: Text(recipe.title),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: ListView(
          children: [
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: const Color(0xFFFFF1E7),
                borderRadius: BorderRadius.circular(18),
              ),
              child: Row(
                children: [
                  const Icon(Icons.local_fire_department_rounded,
                      color: Colors.deepOrange),
                  const SizedBox(width: 8),
                  Text(
                    '${recipe.calories} ${strings.kcal}',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 18),
            Text(strings.ingredientsTitle,
                style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            ...recipe.ingredients.map(
              (ing) => ListTile(
                dense: true,
                contentPadding: EdgeInsets.zero,
                leading: const Icon(Icons.check_circle_outline,
                    color: Colors.green),
                title: Text(ing),
              ),
            ),
            const SizedBox(height: 16),
            Text(strings.stepsTitle,
                style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            Text(
              recipe.steps,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ],
        ),
      ),
    );
  }
}
