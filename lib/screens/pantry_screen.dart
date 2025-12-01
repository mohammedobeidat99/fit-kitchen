import 'package:flutter/material.dart';
import '../core/app_strings.dart';
import '../models/ingredient.dart';

class PantryScreen extends StatefulWidget {
  final AppLang lang;
  final List<Ingredient> ingredients;
  final VoidCallback onIngredientsChanged;

  const PantryScreen({
    super.key,
    required this.lang,
    required this.ingredients,
    required this.onIngredientsChanged,
  });

  @override
  State<PantryScreen> createState() => _PantryScreenState();
}

class _PantryScreenState extends State<PantryScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _qtyController = TextEditingController();
  final TextEditingController _unitController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _qtyController.dispose();
    _unitController.dispose();
    super.dispose();
  }

  void _openAddSheet() {
    final strings = AppStrings(widget.lang);

    _nameController.clear();
    _qtyController.clear();
    _unitController.clear();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) {
        return Directionality(
          textDirection: strings.direction,
          child: Padding(
            padding: EdgeInsets.only(
              left: 16,
              right: 16,
              top: 18,
              bottom: MediaQuery.of(context).viewInsets.bottom + 16,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  strings.add,
                  style: const TextStyle(
                      fontSize: 18, fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 14),
                TextField(
                  controller: _nameController,
                  decoration: InputDecoration(labelText: strings.name),
                ),
                TextField(
                  controller: _qtyController,
                  decoration: InputDecoration(labelText: strings.quantity),
                  keyboardType: TextInputType.number,
                ),
                TextField(
                  controller: _unitController,
                  decoration: InputDecoration(labelText: strings.unit),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: Text(strings.cancel),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: _saveIngredient,
                        child: Text(strings.save),
                      ),
                    ),
                  ],
                )
              ],
            ),
          ),
        );
      },
    );
  }

  void _saveIngredient() {
    final name = _nameController.text.trim();
    final qty = double.tryParse(_qtyController.text.trim()) ?? 0;
    final unit = _unitController.text.trim().isEmpty
        ? 'unit'
        : _unitController.text.trim();

    if (name.isNotEmpty && qty > 0) {
      setState(() {
        widget.ingredients.add(
          Ingredient(name: name, quantity: qty, unit: unit),
        );
      });
      widget.onIngredientsChanged();
      Navigator.pop(context);
    }
  }

  void _removeIngredient(int index) {
    setState(() {
      widget.ingredients.removeAt(index);
    });
    widget.onIngredientsChanged();
  }

  @override
  Widget build(BuildContext context) {
    final strings = AppStrings(widget.lang);

    return Scaffold(
      appBar: AppBar(
        title: Text(strings.pantryTitle),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _openAddSheet,
        icon: const Icon(Icons.add),
        label: Text(strings.add),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: widget.ingredients.length,
        itemBuilder: (context, index) {
          final item = widget.ingredients[index];
          return Container(
            margin: const EdgeInsets.only(bottom: 10),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(
                  color: const Color(0xFF3BB89C).withOpacity(0.2)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.03),
                  blurRadius: 10,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 20,
                  backgroundColor:
                      const Color(0xFF3BB89C).withOpacity(0.15),
                  child: const Icon(Icons.inventory_2_rounded,
                      color: Color(0xFF3BB89C)),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(item.name,
                          style: const TextStyle(
                              fontWeight: FontWeight.w600, fontSize: 15)),
                      const SizedBox(height: 2),
                      Text(
                        '${item.quantity.toStringAsFixed(0)} ${item.unit}',
                        style: TextStyle(
                          color: Colors.grey.shade600,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: () => _removeIngredient(index),
                  icon: const Icon(Icons.delete_outline,
                      color: Colors.redAccent),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
