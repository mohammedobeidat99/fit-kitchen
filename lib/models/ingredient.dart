class Ingredient {
  final String id;
  final String name;
  double quantity;
  String unit;
  final String category;
  final DateTime? expirationDate;

  Ingredient({
    String? id,
    required this.name,
    required this.quantity,
    required this.unit,
    this.category = 'Other',
    this.expirationDate,
  }) : id = id ?? DateTime.now().millisecondsSinceEpoch.toString();

  bool get isExpired =>
      expirationDate != null && expirationDate!.isBefore(DateTime.now());

  bool get isExpiringSoon =>
      expirationDate != null &&
      !isExpired &&
      expirationDate!.difference(DateTime.now()).inDays <= 3;

  bool get isLowStock => quantity <= 1;

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'quantity': quantity,
      'unit': unit,
      'category': category,
      'expirationDate': expirationDate, // Firebase handles DateTime automatically
    };
  }
}
