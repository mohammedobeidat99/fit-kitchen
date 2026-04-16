import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../core/services/firestore_service.dart';
import '../../../models/shopping_item.dart';
import '../../../models/ingredient.dart';
import '../../pantry/logic/pantry_provider.dart';

class ShoppingListProvider extends ChangeNotifier {
  final List<ShoppingItem> _items = [];
  String? _uid;

  List<ShoppingItem> get items => List.unmodifiable(_items);
  int get count => _items.length;
  int get checkedCount => _items.where((i) => i.isChecked).length;
  int get uncheckedCount => _items.where((i) => !i.isChecked).length;

  void bindUser(String uid) {
    if (_uid == uid) return;
    _uid = uid;
    _items.clear();
    _listenToFirestore();
  }

  void unbindUser() {
    _uid = null;
    _items.clear();
    notifyListeners();
  }

  void _listenToFirestore() {
    if (_uid == null) return;
    if (_uid == 'guest') {
      _items.addAll([
        ShoppingItem(id: 's1', name: 'Fresh Salmon', quantity: 2, unit: 'fillets', isChecked: false),
        ShoppingItem(id: 's2', name: 'Avocado', quantity: 3, unit: 'pcs', isChecked: true),
        ShoppingItem(id: 's3', name: 'Almond Milk', quantity: 1, unit: 'liter', isChecked: false),
      ]);
      notifyListeners();
      return;
    }

    FirestoreService.shoppingCollection(_uid!).snapshots().listen((snapshot) {
      _items.clear();
      for (final doc in snapshot.docs) {
        final data = doc.data() as Map<String, dynamic>;
        _items.add(ShoppingItem(
          id: doc.id,
          name: data['name'] ?? '',
          quantity: (data['quantity'] ?? 1).toDouble(),
          unit: data['unit'] ?? 'pcs',
          category: data['category'] ?? 'Other',
          isChecked: data['isChecked'] ?? false,
        ));
      }
      notifyListeners();
    });
  }

  Map<String, List<ShoppingItem>> get groupedByCategory {
    final Map<String, List<ShoppingItem>> map = {};
    for (final item in _items) {
      map.putIfAbsent(item.category, () => []).add(item);
    }
    return map;
  }

  Future<void> addItem(String name, double qty, String unit, String category) async {
    final id = DateTime.now().millisecondsSinceEpoch.toString();
    final item = ShoppingItem(
      id: id,
      name: name,
      quantity: qty,
      unit: unit,
      category: category,
    );
    _items.add(item);
    notifyListeners();

    if (_uid != null && _uid != 'guest') {
      await FirestoreService.shoppingCollection(_uid!).doc(id).set({
        'name': name,
        'quantity': qty,
        'unit': unit,
        'category': category,
        'isChecked': false,
      });
    }
  }

  Future<void> removeItem(String id) async {
    _items.removeWhere((i) => i.id == id);
    notifyListeners();

    if (_uid != null && _uid != 'guest') {
      await FirestoreService.shoppingCollection(_uid!).doc(id).delete();
    }
  }

  Future<void> toggleChecked(String id) async {
    final index = _items.indexWhere((i) => i.id == id);
    if (index != -1) {
      _items[index].isChecked = !_items[index].isChecked;
      notifyListeners();

      if (_uid != null && _uid != 'guest') {
        await FirestoreService.shoppingCollection(_uid!).doc(id).update({
          'isChecked': _items[index].isChecked,
        });
      }
    }
  }

  Future<void> moveCheckedToPantry(PantryProvider pantry) async {
    final checked = _items.where((i) => i.isChecked).toList();
    for (final item in checked) {
      await pantry.addIngredient(Ingredient(
        id: 'shop_${item.id}',
        name: item.name,
        quantity: item.quantity,
        unit: item.unit,
        category: item.category,
        expirationDate: DateTime.now().add(const Duration(days: 14)),
      ));
    }

    final checkedIds = checked.map((i) => i.id).toList();
    _items.removeWhere((i) => i.isChecked);
    notifyListeners();

    if (_uid != null && _uid != 'guest') {
      for (final id in checkedIds) {
        await FirestoreService.shoppingCollection(_uid!).doc(id).delete();
      }
    }
  }

  Future<void> clearChecked() async {
    final checkedIds = _items.where((i) => i.isChecked).map((i) => i.id).toList();
    _items.removeWhere((i) => i.isChecked);
    notifyListeners();

    if (_uid != null && _uid != 'guest') {
      for (final id in checkedIds) {
        await FirestoreService.shoppingCollection(_uid!).doc(id).delete();
      }
    }
  }

  Future<void> clearAll() async {
    final allIds = _items.map((i) => i.id).toList();
    _items.clear();
    notifyListeners();

    if (_uid != null && _uid != 'guest') {
      for (final id in allIds) {
        await FirestoreService.shoppingCollection(_uid!).doc(id).delete();
      }
    }
  }
}
