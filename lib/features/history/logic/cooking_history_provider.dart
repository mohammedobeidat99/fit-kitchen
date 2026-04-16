import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../core/services/firestore_service.dart';
import '../../../models/recipe.dart';
import '../../../models/cooking_history_entry.dart';

class CookingHistoryProvider extends ChangeNotifier {
  final List<CookingHistoryEntry> _entries = [];
  String? _uid;

  List<CookingHistoryEntry> get entries {
    final list = List<CookingHistoryEntry>.from(_entries);
    list.sort((a, b) => b.timestamp.compareTo(a.timestamp));
    return List.unmodifiable(list);
  }

  void bindUser(String uid) {
    if (_uid == uid) return;
    _uid = uid;
    _entries.clear();
    _listenToFirestore();
  }

  void unbindUser() {
    _uid = null;
    _entries.clear();
    notifyListeners();
  }

  void _listenToFirestore() {
    if (_uid == null) return;
    if (_uid == 'guest') {
       _entries.addAll([
          CookingHistoryEntry(id: 'g1', recipeId: 'r1', recipeTitle: 'Grilled Chicken with Rice', timestamp: DateTime.now().subtract(const Duration(days: 1)), calories: 550),
          CookingHistoryEntry(id: 'g2', recipeId: 'r3', recipeTitle: 'Vegetable Omelette', timestamp: DateTime.now().subtract(const Duration(hours: 4)), calories: 280),
       ]);
       notifyListeners();
       return;
    }
    FirestoreService.cookingHistoryCollection(_uid!)
        .orderBy('timestamp', descending: true)
        .limit(100)
        .snapshots()
        .listen((snapshot) {
      _entries.clear();
      for (final doc in snapshot.docs) {
        final data = doc.data() as Map<String, dynamic>;
        _entries.add(CookingHistoryEntry(
          id: doc.id,
          recipeId: data['recipeId'] ?? '',
          recipeTitle: data['recipeTitle'] ?? '',
          timestamp: data['timestamp'] != null
              ? (data['timestamp'] as Timestamp).toDate()
              : DateTime.now(),
          calories: data['calories'] ?? 0,
        ));
      }
      notifyListeners();
    });
  }

  Future<void> addEntry(Recipe recipe) async {
    final id = DateTime.now().millisecondsSinceEpoch.toString();
    final entry = CookingHistoryEntry(
      id: id,
      recipeId: recipe.id,
      recipeTitle: recipe.title,
      timestamp: DateTime.now(),
      calories: recipe.calories,
    );
    _entries.add(entry);
    notifyListeners();

    if (_uid != null && _uid != 'guest') {
      await FirestoreService.cookingHistoryCollection(_uid!).doc(id).set({
        'recipeId': recipe.id,
        'recipeTitle': recipe.title,
        'timestamp': Timestamp.fromDate(entry.timestamp),
        'calories': recipe.calories,
      });
    }
  }

  Future<void> clearHistory() async {
    final allIds = _entries.map((e) => e.id).toList();
    _entries.clear();
    notifyListeners();

    if (_uid != null && _uid != 'guest') {
      for (final id in allIds) {
        await FirestoreService.cookingHistoryCollection(_uid!).doc(id).delete();
      }
    }
  }
}
