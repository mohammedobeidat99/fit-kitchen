import 'package:cloud_firestore/cloud_firestore.dart';

/// Central helper to get Firestore collection references scoped to a user.
class FirestoreService {
  static final FirebaseFirestore _db = FirebaseFirestore.instance;

  /// Root user document
  static DocumentReference userDoc(String uid) =>
      _db.collection('users').doc(uid);

  /// Sub-collections under each user
  static CollectionReference pantryCollection(String uid) =>
      userDoc(uid).collection('pantry');

  static CollectionReference shoppingCollection(String uid) =>
      userDoc(uid).collection('shopping_list');

  static CollectionReference mealPlanCollection(String uid) =>
      userDoc(uid).collection('meal_plan');

  static CollectionReference cookingHistoryCollection(String uid) =>
      userDoc(uid).collection('cooking_history');

  static DocumentReference healthDoc(String uid) =>
      userDoc(uid).collection('profile').doc('health');
}
