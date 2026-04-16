class ShoppingItem {
  final String id;
  final String name;
  double quantity;
  String unit;
  String category;
  bool isChecked;

  ShoppingItem({
    String? id,
    required this.name,
    this.quantity = 1,
    this.unit = 'pcs',
    this.category = 'Other',
    this.isChecked = false,
  }) : id = id ?? DateTime.now().millisecondsSinceEpoch.toString();
}
