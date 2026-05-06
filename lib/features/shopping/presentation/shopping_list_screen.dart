import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/theme/app_theme.dart';
import '../../../shared/widgets/app_scaffold.dart';
import '../../../shared/widgets/empty_state.dart';
import '../../../shared/widgets/section_header.dart';
import '../../../shared/widgets/custom_text_field.dart';
import '../logic/shopping_provider.dart';
import '../../../models/shopping_item.dart';
import '../../pantry/logic/pantry_provider.dart';

class ShoppingListScreen extends StatelessWidget {
  final AppLang lang;

  const ShoppingListScreen({super.key, required this.lang});

  @override
  Widget build(BuildContext context) {
    final strings = AppStrings(lang);
    final isAr = lang == AppLang.ar;
    final shopping = context.watch<ShoppingListProvider>();
    final pantry = context.read<PantryProvider>();
    final grouped = shopping.groupedByCategory;

    return AppScaffold(
      title: strings.shopping,
      actions: [
        if (shopping.checkedCount > 0) ...[
          IconButton(
            onPressed: () {
              shopping.moveCheckedToPantry(pantry);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(isAr ? 'تم نقل المشتريات إلى المخزن ✅' : 'Items moved to Pantry ✅'),
                  backgroundColor: AppTheme.primary,
                  behavior: SnackBarBehavior.floating,
                ),
              );
            },
            icon: const Icon(Icons.kitchen_rounded, color: AppTheme.primary),
            tooltip: isAr ? 'نقل إلى المخزن' : 'Move to Pantry',
          ),
          IconButton(
            onPressed: () => shopping.clearChecked(),
            icon: const Icon(Icons.cleaning_services_outlined, color: Colors.redAccent),
            tooltip: isAr ? 'مسح المشتريات' : 'Clear Checked',
          ),
        ],
      ],
      body: shopping.items.isEmpty
          ? EmptyStateWidget(
              icon: Icons.shopping_cart_outlined,
              title: isAr ? 'قائمة التسوق فارغة' : 'Shopping List Empty',
              message: isAr ? 'أضف أغراضاً لقائمتك هنا.' : 'Add items to your list here.',
              actionLabel: isAr ? 'أضف غرضاً' : 'Add Item',
              onActionPressed: () => _showAddItemDialog(context, strings, shopping),
            )
          : Column(
              children: [
                // Summary bar
                Padding(
                  padding: const EdgeInsets.fromLTRB(AppTheme.spacingM, AppTheme.spacingM, AppTheme.spacingM, 0),
                  child: Container(
                    padding: const EdgeInsets.all(AppTheme.spacingM),
                    decoration: BoxDecoration(
                      color: AppTheme.primary.withAlpha(15),
                      borderRadius: BorderRadius.circular(AppTheme.radiusM),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          isAr ? 'العناصر: ${shopping.count}' : 'Total: ${shopping.count}',
                          style: const TextStyle(fontWeight: FontWeight.bold, color: AppTheme.primary),
                        ),
                        if (shopping.checkedCount > 0)
                          GestureDetector(
                            onTap: () {
                              shopping.moveCheckedToPantry(pantry);
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(isAr ? '✅ تم نقل ${shopping.count} عناصر إلى المخزن' : '✅ Items moved to Pantry!'),
                                  backgroundColor: AppTheme.primary,
                                  behavior: SnackBarBehavior.floating,
                                ),
                              );
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                              decoration: BoxDecoration(
                                color: AppTheme.primary,
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(Icons.kitchen_rounded, color: Colors.white, size: 14),
                                  const SizedBox(width: 4),
                                  Text(
                                    isAr ? 'نقل إلى المخزن (${shopping.checkedCount})' : 'Add to Pantry (${shopping.checkedCount})',
                                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12),
                                  ),
                                ],
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
                // Grouped items
                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.symmetric(vertical: AppTheme.spacingM),
                    children: [
                      ...grouped.entries.map((group) {
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SectionHeader(title: group.key),
                            ...group.value.map((item) => _ShoppingItemTile(item: item, shopping: shopping, strings: strings)),
                            const SizedBox(height: AppTheme.spacingM),
                          ],
                        );
                      }),
                    ],
                  ),
                ),
              ],
            ),
      floatingActionButton: FloatingActionButton(
        heroTag: 'shopping_fab',
        onPressed: () => _showAddItemDialog(context, strings, shopping),
        backgroundColor: AppTheme.primary,
        foregroundColor: Colors.white,
        child: const Icon(Icons.add_shopping_cart_rounded),
      ),
    );
  }

  void _showAddItemDialog(BuildContext context, AppStrings strings, ShoppingListProvider provider) {
    final nameCtrl = TextEditingController();
    final qtyCtrl = TextEditingController();
    final unitCtrl = TextEditingController(text: strings.isAr ? 'قطعة' : 'pcs');
    DateTime? selectedExpiry;
    
    showDialog(
      context: context,
      builder: (dialogCtx) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: Text(strings.isAr ? 'غرض جديد' : 'New Item'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CustomTextField(controller: nameCtrl, label: strings.name),
                const SizedBox(height: AppTheme.spacingM),
                Row(
                  children: [
                    Expanded(
                      child: CustomTextField(
                        controller: qtyCtrl, 
                        label: strings.quantity, 
                        keyboardType: TextInputType.number,
                      ),
                    ),
                    const SizedBox(width: AppTheme.spacingM),
                    Expanded(
                      child: CustomTextField(
                        controller: unitCtrl, 
                        label: strings.isAr ? 'الوحدة' : 'Unit',
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppTheme.spacingM),
                // Expiry Date Picker (Optional)
                InkWell(
                  onTap: () async {
                    final picked = await showDatePicker(
                      context: context,
                      initialDate: DateTime.now().add(const Duration(days: 7)),
                      firstDate: DateTime.now(),
                      lastDate: DateTime.now().add(const Duration(days: 365 * 2)),
                    );
                    if (picked != null) {
                      setState(() => selectedExpiry = picked);
                    }
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey.withAlpha(100)),
                      borderRadius: BorderRadius.circular(AppTheme.radiusM),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.calendar_today_outlined, size: 18, color: AppTheme.primary),
                        const SizedBox(width: 10),
                        Text(
                          selectedExpiry == null
                              ? (strings.isAr ? 'تاريخ الانتهاء (اختياري)' : 'Expiry Date (Optional)')
                              : '${selectedExpiry!.day}/${selectedExpiry!.month}/${selectedExpiry!.year}',
                          style: TextStyle(
                            color: selectedExpiry == null ? Colors.grey : AppTheme.primary,
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(dialogCtx), child: Text(strings.cancel)),
            TextButton(
              onPressed: () {
                if (nameCtrl.text.isNotEmpty) {
                  provider.addItem(
                    nameCtrl.text, 
                    double.tryParse(qtyCtrl.text) ?? 1.0, 
                    unitCtrl.text.isEmpty ? 'pcs' : unitCtrl.text, 
                    'Other',
                    expiryDate: selectedExpiry,
                  );
                  Navigator.pop(dialogCtx);
                }
              },
              child: Text(strings.add),
            ),
          ],
        ),
      ),
    );
  }
}

class _ShoppingItemTile extends StatelessWidget {
  final ShoppingItem item;
  final ShoppingListProvider shopping;
  final AppStrings strings;

  const _ShoppingItemTile({required this.item, required this.shopping, required this.strings});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: AppTheme.spacingM, vertical: 4),
      decoration: BoxDecoration(
        color: AppTheme.getCardColor(context),
        borderRadius: BorderRadius.circular(AppTheme.radiusM),
        border: Border.all(color: item.isChecked ? Colors.transparent : Colors.grey.withAlpha(20)),
      ),
      child: ListTile(
        leading: Checkbox(
          value: item.isChecked,
          onChanged: (_) => shopping.toggleChecked(item.id),
          activeColor: AppTheme.primary,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
        ),
        title: Text(
          item.name,
          style: TextStyle(
            fontWeight: FontWeight.w600,
            decoration: item.isChecked ? TextDecoration.lineThrough : null,
            color: item.isChecked ? Colors.grey : null,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('${item.quantity} ${item.unit}', style: const TextStyle(fontSize: 12)),
            if (item.expirationDate != null)
              Text(
                '${strings.isAr ? "ينتهي:" : "Expires:"} ${item.expirationDate!.day}/${item.expirationDate!.month}/${item.expirationDate!.year}',
                style: const TextStyle(fontSize: 10, color: Colors.orangeAccent, fontWeight: FontWeight.bold),
              ),
          ],
        ),
        trailing: IconButton(
          onPressed: () => shopping.removeItem(item.id),
          icon: const Icon(Icons.delete_outline, color: Colors.grey, size: 20),
        ),
      ),
    );
  }
}
