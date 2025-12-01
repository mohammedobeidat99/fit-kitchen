class Recipe {
  final String title;
  final List<String> ingredients;
  final String steps;
  final int calories;
  final bool isForDiabetes;
  final bool isLowSalt;
  final bool isVegetarian;

  Recipe({
    required this.title,
    required this.ingredients,
    required this.steps,
    required this.calories,
    required this.isForDiabetes,
    required this.isLowSalt,
    required this.isVegetarian,
  });
}
