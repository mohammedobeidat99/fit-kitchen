import 'dart:math';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../core/services/firestore_service.dart';
import '../../../models/recipe.dart';
import '../../../models/planned_meal.dart';

class MealPlanProvider extends ChangeNotifier {
  static const List<String> days = [
    'Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'
  ];

  final Map<String, List<PlannedMeal>> _weeklyPlan = {
    for (var day in days) day: [],
  };

  String? _uid;

  int get totalMealsPlanned {
    int count = 0;
    _weeklyPlan.forEach((_, recipes) => count += recipes.length);
    return count;
  }

  void bindUser(String uid, List<Recipe> allRecipes) {
    if (_uid == uid) return;
    _uid = uid;
    _listenToFirestore(allRecipes);
  }

  void unbindUser() {
    _uid = null;
    clearAllLocally();
  }

  void clearAllLocally() {
    _weeklyPlan.forEach((day, _) => _weeklyPlan[day] = []);
    notifyListeners();
  }

  void _listenToFirestore(List<Recipe> allRecipes) {
    if (_uid == null) return;
    if (_uid == 'guest') {
       if (allRecipes.length >= 3) {
          _weeklyPlan['Monday'] = [PlannedMeal(id: 'g1', recipe: allRecipes[0], isCooked: true), PlannedMeal(id: 'g2', recipe: allRecipes[1], isCooked: false)];
          _weeklyPlan['Tuesday'] = [PlannedMeal(id: 'g3', recipe: allRecipes[2], isCooked: false)];
       }
       notifyListeners();
       return;
    }
    FirestoreService.mealPlanCollection(_uid!).snapshots().listen((snapshot) {
      clearAllLocally();
      for (final doc in snapshot.docs) {
        final data = doc.data() as Map<String, dynamic>;
        final day = data['day'] as String;
        final recipeId = data['recipeId'] as String;
        final isCooked = data['isCooked'] ?? false;
        
        // Find full recipe model
        final recipe = allRecipes.firstWhere(
          (r) => r.id == recipeId, 
          orElse: () => allRecipes.first
        );

        if (_weeklyPlan.containsKey(day)) {
          _weeklyPlan[day]!.add(PlannedMeal(
            id: doc.id,
            recipe: recipe,
            isCooked: isCooked,
          ));
        }
      }
      notifyListeners();
    });
  }

  List<PlannedMeal> getMealsForDay(String day) => _weeklyPlan[day] ?? [];

  Future<void> addMealToDay(String day, Recipe recipe) async {
    final id = DateTime.now().millisecondsSinceEpoch.toString();
    final meal = PlannedMeal(id: id, recipe: recipe, isCooked: false);
    
    // Optimistic update
    if (_weeklyPlan.containsKey(day)) {
      _weeklyPlan[day]!.add(meal);
      notifyListeners();
    }

    if (_uid != null && _uid != 'guest') {
      await FirestoreService.mealPlanCollection(_uid!).doc(id).set({
        'day': day,
        'recipeId': recipe.id,
        'isCooked': false,
        'timestamp': FieldValue.serverTimestamp(),
      });
    }
  }

  Future<void> removeMealFromDay(String day, int index) async {
    if (_weeklyPlan.containsKey(day) && _weeklyPlan[day]!.length > index) {
      final mealId = _weeklyPlan[day]![index].id;
      _weeklyPlan[day]!.removeAt(index);
      notifyListeners();

      if (_uid != null && _uid != 'guest' && mealId != null) {
        await FirestoreService.mealPlanCollection(_uid!).doc(mealId).delete();
      }
    }
  }

  Future<void> markMealAsCooked(String day, int index) async {
    if (_weeklyPlan.containsKey(day) && _weeklyPlan[day]!.length > index) {
      final meal = _weeklyPlan[day]![index];
      meal.isCooked = true;
      notifyListeners();

      if (_uid != null && _uid != 'guest' && meal.id != null) {
        await FirestoreService.mealPlanCollection(_uid!).doc(meal.id).update({
          'isCooked': true,
        });
      }
    }
  }

  /// Generates a smart weekly plan that changes every week.
  Future<void> generateSmartWeeklyPlan(List<Recipe> allRecipes) async {
    await clearAll();
    
    // Use week-of-year as seed so plan changes every week
    final now = DateTime.now();
    final weekOfYear = (now.difference(DateTime(now.year, 1, 1)).inDays / 7).floor();
    final rng = Random(weekOfYear);

    final breakfasts = allRecipes.where((r) => r.category == 'Breakfast').toList()..shuffle(rng);
    final lunches = allRecipes.where((r) => r.category == 'Lunch').toList()..shuffle(rng);
    final dinners = allRecipes.where((r) => r.category == 'Dinner').toList()..shuffle(rng);

    for (int i = 0; i < days.length; i++) {
      final day = days[i];
      if (breakfasts.isNotEmpty) {
        await addMealToDay(day, breakfasts[i % breakfasts.length]);
      }
      if (lunches.isNotEmpty) {
        await addMealToDay(day, lunches[i % lunches.length]);
      }
      if (dinners.isNotEmpty) {
        await addMealToDay(day, dinners[i % dinners.length]);
      }
    }
  }

  Future<void> clearAll() async {
    final List<String> allIdsToDel = [];
    _weeklyPlan.forEach((_, meals) {
      allIdsToDel.addAll(meals.where((m) => m.id != null).map((m) => m.id!));
    });

    clearAllLocally();

    if (_uid != null && _uid != 'guest') {
      final batch = FirebaseFirestore.instance.batch();
      for (final id in allIdsToDel) {
        batch.delete(FirestoreService.mealPlanCollection(_uid!).doc(id));
      }
      await batch.commit();
    }
  }
}
