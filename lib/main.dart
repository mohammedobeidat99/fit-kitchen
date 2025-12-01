import 'package:fit_kitchen_demo/screens/home_screen.dart';
import 'package:flutter/material.dart';
import 'core/app_strings.dart';
import 'models/ingredient.dart';
import 'models/recipe.dart';
import 'models/health_profile.dart';

void main() {
  runApp(const FitKitchenApp());
}

class FitKitchenApp extends StatefulWidget {
  const FitKitchenApp({super.key});

  @override
  State<FitKitchenApp> createState() => _FitKitchenAppState();
}

class _FitKitchenAppState extends State<FitKitchenApp> {
  AppLang _lang = AppLang.en;

  final List<Ingredient> _ingredients = [
    Ingredient(name: 'Chicken Breast', quantity: 500, unit: 'g'),
    Ingredient(name: 'Rice', quantity: 1000, unit: 'g'),
    Ingredient(name: 'Tomatoes', quantity: 4, unit: 'pcs'),
  ];

  final List<Recipe> _recipes = [
    Recipe(
      title: 'Grilled Chicken with Rice',
      ingredients: ['Chicken Breast', 'Rice', 'Tomatoes'],
      steps:
          '1. Season the chicken.\n2. Grill until cooked.\n3. Cook the rice.\n4. Serve with chopped tomatoes.',
      calories: 550,
      isForDiabetes: true,
      isLowSalt: false,
      isVegetarian: false,
    ),
    Recipe(
      title: 'Simple Tomato Rice',
      ingredients: ['Rice', 'Tomatoes'],
      steps:
          '1. Cook rice.\n2. Prepare tomato sauce.\n3. Mix together and serve warm.',
      calories: 420,
      isForDiabetes: false,
      isLowSalt: true,
      isVegetarian: true,
    ),
  ];

  HealthProfile _healthProfile = HealthProfile();

  void _toggleLanguage() {
    setState(() {
      _lang = _lang == AppLang.en ? AppLang.ar : AppLang.en;
    });
  }

  @override
  Widget build(BuildContext context) {
    final strings = AppStrings(_lang);

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: strings.appTitle,
      theme: ThemeData(
        useMaterial3: true,
        scaffoldBackgroundColor: const Color(0xFFF2F4F7),
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF3BB89C),
        ),
        textTheme: const TextTheme(
          headlineLarge: TextStyle(
            fontSize: 26,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
          titleMedium: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
          bodyMedium: TextStyle(
            fontSize: 14,
            color: Colors.black54,
          ),
        ),
      ),
      home: Directionality(
        textDirection: strings.direction,
        child: HomePage(
          lang: _lang,
          onToggleLang: _toggleLanguage,
          ingredients: _ingredients,
          recipes: _recipes,
          healthProfile: _healthProfile,
          onHealthProfileChanged: (p) => setState(() {
            _healthProfile = p;
          }),
          onIngredientsChanged: () => setState(() {}),
        ),
      ),
    );
  }
}
