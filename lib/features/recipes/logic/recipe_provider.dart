import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../models/recipe.dart';
import '../../history/logic/cooking_history_provider.dart';
import '../../health/logic/health_provider.dart';
import '../../pantry/logic/pantry_provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'ai_recipe_service.dart';

class RecipeProvider extends ChangeNotifier {
  RecipeProvider() {
    _loadFavorites();
  }

  final List<Recipe> _recipes = [
    Recipe(
      id: 'r1',
      title: 'Grilled Chicken with Rice',
      description: 'A protein-packed fitness classic with fluffy rice and fresh tomatoes.',
      ingredients: ['Chicken Breast', 'Rice', 'Tomatoes', 'Olive Oil'],
      steps: '1. Season the chicken with salt, pepper, and herbs.\n2. Grill on medium heat until fully cooked (about 6-7 min per side).\n3. Cook the rice according to package instructions.\n4. Dice tomatoes and drizzle with olive oil.\n5. Serve chicken over rice with fresh tomatoes on the side.',
      calories: 550,
      protein: 42.0,
      carbs: 65.0,
      fat: 12.0,
      prepTime: 35,
      category: 'Lunch',
      servings: 2,
      isFeatured: true,
      imageUrl: 'https://images.unsplash.com/photo-1532550907401-a500c9a57435?w=600&q=80',
    ),
    Recipe(
      id: 'r2',
      title: 'Simple Tomato Rice',
      description: 'A light and healthy vegetarian rice dish bursting with tomato flavor.',
      ingredients: ['Rice', 'Tomatoes', 'Onion', 'Olive Oil'],
      steps: '1. Dice onion and sauté in olive oil until translucent.\n2. Add chopped tomatoes and cook for 5 minutes.\n3. Add rice and water, bring to a boil.\n4. Reduce heat and simmer until rice is tender.\n5. Season with salt and pepper. Serve warm.',
      calories: 420,
      protein: 8.0,
      carbs: 85.0,
      fat: 6.0,
      prepTime: 25,
      category: 'Lunch',
      servings: 3,
      imageUrl: 'https://images.unsplash.com/photo-1536304929831-ee1ca9d44906?w=600&q=80',
    ),
    Recipe(
      id: 'r3',
      title: 'Vegetable Omelette',
      description: 'The perfect breakfast choice, high in protein and loaded with fresh veggies.',
      ingredients: ['Eggs', 'Bell Pepper', 'Onion', 'Tomatoes', 'Olive Oil'],
      steps: '1. Dice bell pepper, onion, and tomatoes.\n2. Beat eggs in a bowl with a pinch of salt.\n3. Heat olive oil in a non-stick pan.\n4. Sauté vegetables for 2-3 minutes.\n5. Pour eggs over vegetables, cook on low heat.\n6. Fold and serve hot.',
      calories: 280,
      protein: 18.0,
      carbs: 10.0,
      fat: 20.0,
      prepTime: 15,
      category: 'Breakfast',
      servings: 1,
      isFeatured: true,
      imageUrl: 'https://images.unsplash.com/photo-1565299507177-b0ac66763828?w=600&q=80',
    ),
    Recipe(
      id: 'r4',
      title: 'Garlic Lemon Chicken',
      description: 'Zesty and savory chicken breast, ideal for a light but satisfying dinner.',
      ingredients: ['Chicken Breast', 'Garlic', 'Lemon', 'Olive Oil'],
      steps: '1. Mince garlic and mix with lemon juice and olive oil.\n2. Marinate chicken breasts for 15 minutes.\n3. Grill or pan-sear chicken for 6-7 minutes per side.\n4. Squeeze extra lemon on top before serving.\n5. Serve with a side salad or rice.',
      calories: 380,
      protein: 38.0,
      carbs: 5.0,
      fat: 14.0,
      prepTime: 30,
      category: 'Dinner',
      servings: 2,
      isFeatured: true,
      imageUrl: 'https://images.unsplash.com/photo-1598515214211-89fd3a3e66c9?w=600&q=80',
    ),
    Recipe(
      id: 'r5',
      title: 'Avocado Toast with Egg',
      description: 'The ultimate healthy breakfast with healthy fats and high protein.',
      ingredients: ['Bread', 'Avocado', 'Eggs', 'Salt', 'Black Pepper'],
      steps: '1. Toast the bread until golden brown.\n2. Mash avocado with salt and pepper in a bowl.\n3. Fry or poach the egg to your preference.\n4. Spread avocado on toast and top with the egg.\n5. Enjoy your nutritious start!',
      calories: 320,
      protein: 14.0,
      carbs: 28.0,
      fat: 18.0,
      prepTime: 10,
      category: 'Breakfast',
      servings: 1,
      imageUrl: 'https://images.unsplash.com/photo-1525351484163-7529414344d8?w=600&q=80',
    ),
    Recipe(
      id: 'r6',
      title: 'Beef & Broccoli Stir-Fry',
      description: 'A savory, nutrient-dense Asian-inspired dish for a powerful lunch.',
      ingredients: ['Beef', 'Broccoli', 'Garlic', 'Olive Oil', 'Rice'],
      steps: '1. Slice beef into thin strips.\n2. Sauté garlic and beef in olive oil until browned.\n3. Add broccoli and a splash of water, cover for 3 minutes.\n4. Serve over steamed rice.\n5. Season with salt or light soy sauce.',
      calories: 620,
      protein: 45.0,
      carbs: 55.0,
      fat: 22.0,
      prepTime: 20,
      category: 'Lunch',
      servings: 2,
      imageUrl: 'https://images.unsplash.com/photo-1512058556646-c4da40fba323?w=600&q=80',
    ),
    Recipe(
      id: 'r7',
      title: 'Greek Yogurt Parfait',
      description: 'A quick, healthy snack packed with protein and probiotics.',
      ingredients: ['Greek Yogurt', 'Honey', 'Banana', 'Oats'],
      steps: '1. Spoon Greek yogurt into a glass or bowl.\n2. Slice banana and layer on top.\n3. Add a handful of oats.\n4. Drizzle with honey.\n5. Serve chilled.',
      calories: 250,
      protein: 15.0,
      carbs: 38.0,
      fat: 4.0,
      prepTime: 5,
      category: 'Breakfast',
      servings: 1,
      imageUrl: 'https://images.unsplash.com/photo-1488477181946-6428a0291777?w=600&q=80',
    ),
    Recipe(
      id: 'r8',
      title: 'Lentil Soup',
      description: 'A hearty, warming soup loaded with fiber and plant-based protein.',
      ingredients: ['Lentils', 'Onion', 'Garlic', 'Tomatoes', 'Cumin'],
      steps: '1. Sauté onion and garlic until golden.\n2. Add lentils, tomatoes, and cumin.\n3. Pour in 4 cups of water or broth.\n4. Simmer for 25 minutes until lentils are soft.\n5. Blend half the soup for a creamy texture.\n6. Season and serve with bread.',
      calories: 310,
      protein: 20.0,
      carbs: 52.0,
      fat: 3.0,
      prepTime: 35,
      category: 'Dinner',
      servings: 4,
      imageUrl: 'https://images.unsplash.com/photo-1547592166-23ac45744acd?w=600&q=80',
    ),
    Recipe(
      id: 'r9',
      title: 'Salmon with Asparagus',
      description: 'A premium, omega-3 rich dinner that is simple yet elegant.',
      ingredients: ['Salmon', 'Asparagus', 'Lemon', 'Olive Oil', 'Garlic'],
      steps: '1. Preheat oven to 200°C.\n2. Place salmon and asparagus on a baking tray.\n3. Drizzle with olive oil and squeeze lemon juice over everything.\n4. Sprinkle minced garlic on top.\n5. Bake for 15-18 minutes until salmon flakes easily.\n6. Serve immediately.',
      calories: 450,
      protein: 40.0,
      carbs: 8.0,
      fat: 28.0,
      prepTime: 25,
      category: 'Dinner',
      servings: 2,
      isFeatured: true,
      imageUrl: 'https://images.unsplash.com/photo-1467003909585-2f8a72700288?w=600&q=80',
    ),
    Recipe(
      id: 'r10',
      title: 'Chickpea & Spinach Curry',
      description: 'A vibrant, plant-based curry bursting with spice and nutrition.',
      ingredients: ['Chickpeas', 'Spinach', 'Tomatoes', 'Onion', 'Garlic', 'Ginger'],
      steps: '1. Sauté onion, garlic, and ginger until fragrant.\n2. Add tomatoes and cook until soft.\n3. Stir in chickpeas and your favourite curry spices.\n4. Add a splash of water and simmer 10 minutes.\n5. Fold in fresh spinach until wilted.\n6. Serve with rice or flatbread.',
      calories: 380,
      protein: 18.0,
      carbs: 58.0,
      fat: 8.0,
      prepTime: 30,
      category: 'Dinner',
      servings: 3,
      imageUrl: 'https://images.unsplash.com/photo-1585937421612-70a008356fbe?w=600&q=80',
    ),
  ];

  List<Recipe> get allRecipes => List.unmodifiable(_recipes);
  List<Recipe> get featuredRecipes => _recipes.where((r) => r.isFeatured).toList();
  List<Recipe> get favoriteRecipes => [
    ..._recipes.where((r) => r.isFavorite),
    ..._aiSuggestions.where((r) => r.isFavorite) // Also grab the saved AI magic recipes!
  ];

  // --- SMART RECOMMENDATION ENGINE ---
  Recipe getSmartTimeBasedRecommendation() {
    final hour = DateTime.now().hour;
    String targetCategory = 'Lunch';
    if (hour >= 5 && hour < 11) targetCategory = 'Breakfast';
    else if (hour >= 11 && hour < 16) targetCategory = 'Lunch';
    else targetCategory = 'Dinner';

    final options = _recipes.where((r) => r.category == targetCategory).toList();
    if (options.isEmpty) return _recipes.first;
    return options[math.Random().nextInt(options.length)];
  }

  // --- INGREDIENT SUBSTITUTIONS ---
  String getSubstitutions(String ingredient) {
    final Map<String, String> subs = {
      'Chicken Breast': 'Tofu or Turkey Breast',
      'Olive Oil': 'Applesauce (in baking) or Greek Yogurt',
      'Rice': 'Quinoa or Cauliflower Rice',
      'Eggs': 'Flax seeds (for baking) or Chickpea flour',
      'Bread': 'Lettuce wraps or Whole-grain crackers',
      'Beef': 'Lentils or Mushrooms',
      'Butter': 'Avocado or Coconut oil',
      'Sugar': 'Honey or Stevia',
    };
    return subs[ingredient] ?? 'No common healthy substitute found.';
  }

  // --- HEALTH GRADING ---
  String getHealthGrade(Recipe recipe) {
    final proteinRatio = recipe.protein / (recipe.calories / 100);
    if (proteinRatio > 8) return 'A+';
    if (proteinRatio > 6) return 'A';
    if (proteinRatio > 4) return 'B';
    return 'C';
  }

  String _searchQuery = '';
  String get searchQuery => _searchQuery;

  String _selectedCategory = 'All';
  String get selectedCategory => _selectedCategory;

  void setSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  void setCategory(String category) {
    _selectedCategory = category;
    notifyListeners();
  }

  List<Recipe> get filteredRecipes {
    var items = _recipes.toList();
    if (_searchQuery.isNotEmpty) {
      items = items.where((r) => r.title.toLowerCase().contains(_searchQuery.toLowerCase())).toList();
    }
    if (_selectedCategory != 'All') {
      items = items.where((r) => r.category == _selectedCategory).toList();
    }
    return items;
  }

  Recipe? getById(String id) {
    try {
      return _recipes.firstWhere((r) => r.id == id);
    } catch (_) {
      try {
        return _aiSuggestions.firstWhere((r) => r.id == id);
      } catch (_) {
        return null;
      }
    }
  }

  String? _uid;

  void bindUser(String uid) {
    if (_uid == uid) return;
    _uid = uid;
    _loadFavorites();
  }

  void unbindUser() {
    _uid = null;
    for (var r in _recipes) {
      r.isFavorite = false;
    }
    notifyListeners();
  }

  void toggleFavorite(String id) {
    int index = _recipes.indexWhere((r) => r.id == id);
    if (index != -1) {
      _recipes[index].isFavorite = !_recipes[index].isFavorite;
      _saveFavorites();
      notifyListeners();
      return;
    }
    
    // Check AI suggestions if not found in normal recipes
    index = _aiSuggestions.indexWhere((r) => r.id == id);
    if (index != -1) {
      _aiSuggestions[index].isFavorite = !_aiSuggestions[index].isFavorite;
      _saveFavorites();
      notifyListeners();
      return;
    }
  }

  Future<void> _loadFavorites() async {
    if (_uid == null || _uid == 'guest') {
      // Fallback to local
      final prefs = await SharedPreferences.getInstance();
      final favIds = prefs.getStringList('favorite_recipes') ?? [];
      for (var recipe in _recipes) {
        recipe.isFavorite = favIds.contains(recipe.id);
      }
    } else {
      // Load from Firestore
      try {
        final doc = await FirebaseFirestore.instance
            .collection('users')
            .doc(_uid!)
            .collection('profile')
            .doc('favorites')
            .get();
        if (doc.exists) {
          final favIds = List<String>.from(doc.data()!['recipeIds'] ?? []);
          for (var recipe in _recipes) {
            recipe.isFavorite = favIds.contains(recipe.id);
          }
        }
      } catch (e) {
        debugPrint('Error loading favorites: $e');
      }
    }
    notifyListeners();
  }

  Future<void> _saveFavorites() async {
    final favIds = _recipes.where((r) => r.isFavorite).map((r) => r.id).toList();

    if (_uid == null || _uid == 'guest') {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setStringList('favorite_recipes', favIds);
    } else {
      try {
        await FirebaseFirestore.instance
            .collection('users')
            .doc(_uid!)
            .collection('profile')
            .doc('favorites')
            .set({'recipeIds': favIds});
      } catch (e) {
        debugPrint('Error saving favorites: $e');
      }
    }
  }

  // Functional: Orchestrate the cooking process
  void markAsCooked(BuildContext context, Recipe recipe) {
    // 1. Add to History
    context.read<CookingHistoryProvider>().addEntry(recipe);
    
    // 2. Add Calories to Health
    context.read<HealthProvider>().addCalories(recipe.calories, recipe.protein, recipe.carbs);
    
    // 3. Subtract from Pantry
    context.read<PantryProvider>().useIngredients(recipe.ingredients);
    
    // 4. Practical feedback
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Marked "${recipe.title}" as cooked! Pantry and Health stats updated.'),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  // Smart suggestions logic — filters by pantry match AND health conditions
  List<Map<String, dynamic>> getSuggestions(
    List<String> pantryIngredients, {
    Set<String> avoidedKeywords = const {},
  }) {
    final List<Map<String, dynamic>> suggested = [];
    
    for (final recipe in _recipes) {
      // Skip recipe if it contains any avoided health keyword
      if (avoidedKeywords.isNotEmpty) {
        final containsAvoided = recipe.ingredients.any((ing) =>
          avoidedKeywords.any((kw) => ing.toLowerCase().contains(kw.toLowerCase()))
        );
        if (containsAvoided) continue;
      }

      final matched = recipe.ingredients.where((ing) => 
        pantryIngredients.any((p) => p.toLowerCase().contains(ing.toLowerCase()))
      ).toList();
      
      final missing = recipe.ingredients.where((ing) => 
        !pantryIngredients.any((p) => p.toLowerCase().contains(ing.toLowerCase()))
      ).toList();
      
      final matchRatio = pantryIngredients.isEmpty 
          ? 0.0 
          : matched.length / recipe.ingredients.length;
      
      if (matchRatio >= 0.3) { // Show if at least 30% match
        suggested.add({
          'recipe': recipe,
          'matched': matched,
          'missing': missing,
          'ratio': matchRatio,
        });
      }
    }
    
    suggested.sort((a, b) => (b['ratio'] as double).compareTo(a['ratio'] as double));
    return suggested;
  }

  // --- AI Smart Suggestions ---
  final AiRecipeService _aiRecipeService = AiRecipeService();
  bool _isGeneratingAiRecipes = false;
  bool get isGeneratingAiRecipes => _isGeneratingAiRecipes;

  List<Recipe> _aiSuggestions = [];
  List<Recipe> get aiSuggestions => _aiSuggestions;

  Future<void> generateAiSuggestions(List<String> pantryIngredients) async {
    _isGeneratingAiRecipes = true;
    notifyListeners();
    try {
      // Retain already pinned AI recipes so they are not deleted
      final pinnedAi = _aiSuggestions.where((r) => r.isFavorite).toList();
      
      final newAi = await _aiRecipeService.generateRecipes(pantryIngredients);
      
      _aiSuggestions = [...pinnedAi, ...newAi];
    } catch (e) {
      debugPrint('Error generating AI suggestions: $e');
    } finally {
      _isGeneratingAiRecipes = false;
      notifyListeners();
    }
  }
}
