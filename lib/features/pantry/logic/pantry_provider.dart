import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../core/services/firestore_service.dart';
import '../../../models/ingredient.dart';

import 'package:shared_preferences/shared_preferences.dart';

class PantryProvider extends ChangeNotifier {
  final List<Ingredient> _ingredients = [];
  String? _uid;

  List<Ingredient> get ingredients => List.unmodifiable(_ingredients);
  int get count => _ingredients.length;

  // Search & Filter state
  String _searchQuery = '';
  String get searchQuery => _searchQuery;

  bool _sortByExpiration = false;
  bool get sortByExpiration => _sortByExpiration;

  /// Call this after login to bind the provider to the user's Firestore data.
  void bindUser(String uid) {
    if (_uid == uid) return;
    _uid = uid;
    _ingredients.clear();
    _listenToFirestore();
  }

  void unbindUser() {
    _uid = null;
    _ingredients.clear();
    notifyListeners();
  }

  Future<void> _listenToFirestore() async {
    if (_uid == null) return;
    if (_uid == 'guest') {
      _ingredients.addAll([
        Ingredient(id: 'g1', name: 'Chicken Breast', quantity: 500, unit: 'g', category: 'Meat', expirationDate: DateTime.now().add(const Duration(days: 4))),
        Ingredient(id: 'g2', name: 'Brown Rice', quantity: 1000, unit: 'g', category: 'Grains', expirationDate: DateTime.now().add(const Duration(days: 120))),
        Ingredient(id: 'g3', name: 'Broccoli', quantity: 2, unit: 'pcs', category: 'Vegetables', expirationDate: DateTime.now().add(const Duration(days: 2))),
        Ingredient(id: 'g4', name: 'Olive Oil', quantity: 500, unit: 'ml', category: 'Pantry', expirationDate: null),
      ]);
      notifyListeners();
      return;
    }
    
    final prefs = await SharedPreferences.getInstance();
    final kitAddedKey = 'starter_kit_added_${_uid!}';
    final hasAddedKit = prefs.getBool(kitAddedKey) ?? false;

    FirestoreService.pantryCollection(_uid!).snapshots().listen((snapshot) {
      _ingredients.clear();
      
      // Auto-populate starter kit ONLYONCE per user if pantry is empty
      if (snapshot.docs.isEmpty && !hasAddedKit) {
        prefs.setBool(kitAddedKey, true);
        _addStarterKit(_uid!);
        // Do not return here, let the optimistic UI flow through!
      }

      for (final doc in snapshot.docs) {
        final data = doc.data() as Map<String, dynamic>;
        _ingredients.add(Ingredient(
          id: doc.id,
          name: data['name'] ?? '',
          quantity: (data['quantity'] ?? 0).toDouble(),
          unit: data['unit'] ?? 'g',
          category: data['category'] ?? 'Other',
          expirationDate: data['expirationDate'] != null
              ? (data['expirationDate'] as Timestamp).toDate()
              : null,
        ));
      }
      notifyListeners();
    });
  }

  Future<void> _addStarterKit(String uid) async {
    final batch = FirebaseFirestore.instance.batch();
    final col = FirestoreService.pantryCollection(uid);

    final kit = [
      Ingredient(id: 'k1', name: 'Chicken Breast', quantity: 1000, unit: 'g', category: 'Meat', expirationDate: DateTime.now().add(const Duration(days: 4))),
      Ingredient(id: 'k2', name: 'Brown Rice', quantity: 2000, unit: 'g', category: 'Grains', expirationDate: DateTime.now().add(const Duration(days: 180))),
      Ingredient(id: 'k3', name: 'Olive Oil', quantity: 500, unit: 'ml', category: 'Pantry', expirationDate: null),
      Ingredient(id: 'k4', name: 'Broccoli', quantity: 3, unit: 'pcs', category: 'Vegetables', expirationDate: DateTime.now().add(const Duration(days: 3))),
      Ingredient(id: 'k5', name: 'Eggs', quantity: 12, unit: 'pcs', category: 'Fridge', expirationDate: DateTime.now().add(const Duration(days: 14))),
      Ingredient(id: 'k6', name: 'Spinach', quantity: 200, unit: 'g', category: 'Vegetables', expirationDate: DateTime.now().add(const Duration(days: 5))),
    ];

    // Optimistically update the UI so it doesn't wait for network:
    _ingredients.addAll(kit);
    notifyListeners();

    for (final item in kit) {
      batch.set(col.doc(item.id), item.toMap());
    }

    try {
      await batch.commit();
    } catch (e) {
      debugPrint('Error writing starter kit: $e');
    }
  }

  void setSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  void toggleSortByExpiration() {
    _sortByExpiration = !_sortByExpiration;
    notifyListeners();
  }

  List<Ingredient> get filteredIngredients {
    var items = _ingredients.toList();

    if (_searchQuery.isNotEmpty) {
      items = items.where((i) =>
          i.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          i.category.toLowerCase().contains(_searchQuery.toLowerCase())
      ).toList();
    }

    if (_sortByExpiration) {
      items.sort((a, b) {
        if (a.expirationDate == null && b.expirationDate == null) return 0;
        if (a.expirationDate == null) return 1;
        if (b.expirationDate == null) return -1;
        return a.expirationDate!.compareTo(b.expirationDate!);
      });
    }

    return items;
  }

  List<Ingredient> get expiredItems =>
      _ingredients.where((i) => i.isExpired).toList();

  List<Ingredient> get expiringSoonItems =>
      _ingredients.where((i) => i.isExpiringSoon).toList();

  Future<void> addIngredient(Ingredient ingredient) async {
    // Add locally for instant UI feedback
    _ingredients.add(ingredient);
    notifyListeners();

    if (_uid != null && _uid != 'guest') {
      await FirestoreService.pantryCollection(_uid!).doc(ingredient.id).set({
        'name': ingredient.name,
        'quantity': ingredient.quantity,
        'unit': ingredient.unit,
        'category': ingredient.category,
        'expirationDate': ingredient.expirationDate != null
            ? Timestamp.fromDate(ingredient.expirationDate!)
            : null,
      });
    }
  }

  Future<void> removeIngredientById(String id) async {
    _ingredients.removeWhere((i) => i.id == id);
    notifyListeners();

    if (_uid != null && _uid != 'guest') {
      await FirestoreService.pantryCollection(_uid!).doc(id).delete();
    }
  }

  Future<void> updateQuantity(String id, double newQty) async {
    final index = _ingredients.indexWhere((i) => i.id == id);
    if (index != -1) {
      _ingredients[index].quantity = newQty;
      notifyListeners();

      if (_uid != null && _uid != 'guest') {
        await FirestoreService.pantryCollection(_uid!).doc(id).update({
          'quantity': newQty,
        });
      }
    }
  }

  Future<void> useIngredients(List<String> recipeIngredients) async {
    for (var ingName in recipeIngredients) {
      final index = _ingredients.indexWhere((i) =>
        ingName.toLowerCase().contains(i.name.toLowerCase()) ||
        i.name.toLowerCase().contains(ingName.toLowerCase())
      );
      if (index != -1) {
        if (_ingredients[index].unit == 'pcs') {
          _ingredients[index].quantity = (_ingredients[index].quantity - 1).clamp(0, 9999);
        } else {
          _ingredients[index].quantity = (_ingredients[index].quantity - 100).clamp(0, 9999);
        }

        // Sync updated quantity to Firestore
        if (_uid != null && _uid != 'guest') {
          await FirestoreService.pantryCollection(_uid!).doc(_ingredients[index].id).update({
            'quantity': _ingredients[index].quantity,
          });
        }
      }
    }
    notifyListeners();
  }
}
