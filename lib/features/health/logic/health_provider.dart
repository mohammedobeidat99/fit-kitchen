import 'dart:async';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../core/services/firestore_service.dart';
import '../../../models/health_profile.dart';

class HealthProvider extends ChangeNotifier {
  HealthProfile _profile = HealthProfile();
  HealthProfile get profile => _profile;

  Timer? _midnightTimer;
  String? _uid;

  HealthProvider() {
    _checkDailyReset();
    _scheduleMidnightReset();
  }

  @override
  void dispose() {
    _midnightTimer?.cancel();
    super.dispose();
  }

  void bindUser(String uid) {
    if (_uid == uid) return;
    _uid = uid;
    _loadFromFirestore();
  }

  void unbindUser() {
    _uid = null;
  }

  Future<void> _loadFromFirestore() async {
    if (_uid == null || _uid == 'guest') return;
    try {
      final doc = await FirestoreService.healthDoc(_uid!).get();
      if (doc.exists) {
        final data = doc.data() as Map<String, dynamic>?;
        if (data != null) {
          _calorieTarget = data['calorieTarget'] ?? 2000;
          _proteinTarget = (data['proteinTarget'] ?? 150).toDouble();
          _carbsTarget = (data['carbsTarget'] ?? 250).toDouble();
          _waterGoal = data['waterGoal'] ?? 8;

          _profile.hasDiabetes = data['hasDiabetes'] ?? false;
          _profile.hasHighBloodPressure = data['hasHighBloodPressure'] ?? false;
          _profile.isVegetarian = data['isVegetarian'] ?? false;

          if (data['allergies'] != null) {
            _profile.allergies = List<String>.from(data['allergies']);
          }

          if (data['activeConditionIds'] != null) {
            final ids = List<String>.from(data['activeConditionIds']);
            _profile.activeConditions = HealthProfile.presetConditions
                .where((c) => ids.contains(c.id))
                .toList();
          }

          notifyListeners();
        }
      }
    } catch (e) {
      debugPrint('Error loading health profile: $e');
    }
  }

  Future<void> _saveToFirestore() async {
    if (_uid == null || _uid == 'guest') return;
    try {
      await FirestoreService.healthDoc(_uid!).set({
        'calorieTarget': _calorieTarget,
        'proteinTarget': _proteinTarget,
        'carbsTarget': _carbsTarget,
        'waterGoal': _waterGoal,
        'hasDiabetes': _profile.hasDiabetes,
        'hasHighBloodPressure': _profile.hasHighBloodPressure,
        'isVegetarian': _profile.isVegetarian,
        'allergies': _profile.allergies,
        'activeConditionIds': _profile.activeConditions.map((c) => c.id).toList(),
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
    } catch (e) {
      debugPrint('Error saving health profile: $e');
    }
  }

  Future<void> _checkDailyReset() async {
    final prefs = await SharedPreferences.getInstance();
    final lastReset = prefs.getString('last_daily_reset');
    final today = DateTime.now().toIso8601String().substring(0, 10);
    if (lastReset != today) {
      _waterGlasses = 0;
      _dailyCaloriesConsumed = 0;
      _dailyProteinConsumed = 0;
      _dailyCarbsConsumed = 0;
      await prefs.setString('last_daily_reset', today);
      notifyListeners();
    }
  }

  void _scheduleMidnightReset() {
    final now = DateTime.now();
    final midnight = DateTime(now.year, now.month, now.day + 1);
    final duration = midnight.difference(now);
    _midnightTimer = Timer(duration, () {
      _waterGlasses = 0;
      _dailyCaloriesConsumed = 0;
      _dailyProteinConsumed = 0;
      _dailyCarbsConsumed = 0;
      SharedPreferences.getInstance().then((prefs) {
        prefs.setString('last_daily_reset', DateTime.now().toIso8601String().substring(0, 10));
      });
      notifyListeners();
      _scheduleMidnightReset();
    });
  }

  int _dailyCaloriesConsumed = 0;
  int get dailyCaloriesConsumed => _dailyCaloriesConsumed;

  double _dailyProteinConsumed = 0;
  double get dailyProteinConsumed => _dailyProteinConsumed;

  double _dailyCarbsConsumed = 0;
  double get dailyCarbsConsumed => _dailyCarbsConsumed;

  int _waterGlasses = 0;
  int get waterGlasses => _waterGlasses;

  int _calorieTarget = 2000;
  int get calorieTarget => _calorieTarget;

  double _proteinTarget = 150;
  double get proteinTarget => _proteinTarget;

  double _carbsTarget = 250;
  double get carbsTarget => _carbsTarget;

  int _waterGoal = 8;
  int get waterGoal => _waterGoal;

  double get calorieProgress => (_dailyCaloriesConsumed / _calorieTarget).clamp(0.0, 1.0);

  int get healthScore {
    int score = 75;
    if (_dailyCaloriesConsumed > _calorieTarget) score -= 10;
    if (_dailyCaloriesConsumed > 0 && _dailyCaloriesConsumed <= _calorieTarget) score += 10;
    if (_waterGlasses >= _waterGoal) score += 5;
    return score.clamp(0, 100);
  }

  void addCalories(int calories, double protein, double carbs) {
    _dailyCaloriesConsumed += calories;
    _dailyProteinConsumed += protein;
    _dailyCarbsConsumed += carbs;
    notifyListeners();
  }

  void updateWater(int glasses) {
    _waterGlasses = glasses.clamp(0, 20);
    notifyListeners();
  }

  void resetDailyStats() {
    _dailyCaloriesConsumed = 0;
    _dailyProteinConsumed = 0;
    _dailyCarbsConsumed = 0;
    _waterGlasses = 0;
    notifyListeners();
  }

  void toggleDiabetes(bool value) {
    _profile.hasDiabetes = value;
    notifyListeners();
    _saveToFirestore();
  }

  void toggleLowSalt(bool value) {
    _profile.hasHighBloodPressure = value;
    notifyListeners();
    _saveToFirestore();
  }

  void toggleVegetarian(bool value) {
    _profile.isVegetarian = value;
    notifyListeners();
    _saveToFirestore();
  }

  void addAllergy(String allergy) {
    if (allergy.isNotEmpty && !_profile.allergies.contains(allergy)) {
      _profile.allergies.add(allergy);
      notifyListeners();
      _saveToFirestore();
    }
  }

  void removeAllergy(int index) {
    _profile.allergies.removeAt(index);
    notifyListeners();
    _saveToFirestore();
  }

  bool hasCondition(String conditionId) {
    return _profile.activeConditions.any((c) => c.id == conditionId);
  }

  void toggleCondition(HealthCondition condition) {
    final existing = _profile.activeConditions.indexWhere((c) => c.id == condition.id);
    if (existing != -1) {
      _profile.activeConditions.removeAt(existing);
    } else {
      _profile.activeConditions.add(condition);
    }
    notifyListeners();
    _saveToFirestore();
  }

  bool isRecipeSafe(List<String> ingredients) {
    final avoided = _profile.avoidedIngredientKeywords;
    if (avoided.isEmpty) return true;
    for (final ing in ingredients) {
      for (final keyword in avoided) {
        if (ing.toLowerCase().contains(keyword.toLowerCase())) return false;
      }
    }
    return true;
  }
}
