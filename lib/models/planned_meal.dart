import 'recipe.dart';

class PlannedMeal {
  final String? id;
  final Recipe recipe;
  bool isCooked;

  PlannedMeal({
    this.id,
    required this.recipe,
    this.isCooked = false,
  });
}
