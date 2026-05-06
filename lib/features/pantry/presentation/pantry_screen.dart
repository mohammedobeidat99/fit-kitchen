import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/services/notification_service.dart';
import '../../../shared/widgets/app_scaffold.dart';
import '../../../shared/widgets/custom_button.dart';
import '../../../shared/widgets/custom_text_field.dart';
import '../../../shared/widgets/empty_state.dart';
import '../logic/pantry_provider.dart';
import '../../../models/ingredient.dart';

class PantryScreen extends StatelessWidget {
  final AppLang lang;

  const PantryScreen({super.key, required this.lang});

  @override
  Widget build(BuildContext context) {
    final strings = AppStrings(lang);
    final pantry = context.watch<PantryProvider>();
    final items = pantry.filteredIngredients;

    return AppScaffold(
      title: strings.pantry,
      actions: [
        IconButton(
          onPressed: () => pantry.toggleSortByExpiration(),
          icon: Icon(
            pantry.sortByExpiration ? Icons.timer_rounded : Icons.timer_outlined,
            color: pantry.sortByExpiration ? AppTheme.primary : null,
          ),
          tooltip: strings.sortByExpiration,
        ),
      ],
      floatingActionButton: FloatingActionButton(
        heroTag: 'pantry_fab',
        onPressed: () => _showAddDialog(context, strings, pantry),
        backgroundColor: AppTheme.primary,
        foregroundColor: Colors.white,
        child: const Icon(Icons.add),
      ),
      body: Column(
        children: [
          // Search Bar
          Padding(
            padding: const EdgeInsets.all(AppTheme.spacingM),
            child: CustomTextField(
              controller: TextEditingController(text: pantry.searchQuery)
                ..selection = TextSelection.fromPosition(
                  TextPosition(offset: pantry.searchQuery.length),
                ),
              label: '',
              hint: strings.searchIngredients,
              prefixIcon: Icons.search,
              suffixIcon: pantry.searchQuery.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.close, size: 18),
                      onPressed: () => pantry.setSearchQuery(''),
                    )
                  : null,
              validator: null, // Just a search field
            ),
          ),
          
          // List
          Expanded(
            child: items.isEmpty
                ? EmptyStateWidget(
                    icon: Icons.inventory_2_outlined,
                    title: strings.noItems,
                    message: isAr(lang) ? 'مخزنك فارغ حالياً.' : 'Your pantry is currently empty.',
                    actionLabel: strings.add,
                    onActionPressed: () => _showAddDialog(context, strings, pantry),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.only(bottom: 100, left: AppTheme.spacingM, right: AppTheme.spacingM),
                    itemCount: items.length,
                    itemBuilder: (context, index) {
                      final item = items[index];
                      return _IngredientCard(item: item, strings: strings);
                    },
                  ),
          ),
        ],
      ),
    );
  }

  bool isAr(AppLang lang) => lang == AppLang.ar;

  void _showAddDialog(BuildContext context, AppStrings strings, PantryProvider provider) {
    final nameCtrl = TextEditingController();
    final qtyCtrl = TextEditingController();
    final unitCtrl = TextEditingController(text: 'g');
    String category = 'Other';
    DateTime? selectedExpiry;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => StatefulBuilder(
        builder: (sheetCtx, setSheetState) => Container(
          decoration: BoxDecoration(
            color: Theme.of(context).scaffoldBackgroundColor,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(AppTheme.radiusL)),
          ),
          padding: EdgeInsets.only(
            left: AppTheme.spacingL,
            right: AppTheme.spacingL,
            top: AppTheme.spacingL,
            bottom: MediaQuery.of(context).viewInsets.bottom + AppTheme.spacingL,
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  strings.isAr ? 'إضافة مكون جديد' : 'Add New Ingredient',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: AppTheme.spacingL),
                CustomTextField(controller: nameCtrl, label: strings.isAr ? 'اسم المكون' : 'Ingredient Name'),
                const SizedBox(height: AppTheme.spacingM),
                Row(
                  children: [
                    Expanded(child: CustomTextField(controller: qtyCtrl, label: strings.isAr ? 'الكمية' : 'Qty', keyboardType: TextInputType.number)),
                    const SizedBox(width: AppTheme.spacingM),
                    Expanded(child: CustomTextField(controller: unitCtrl, label: strings.isAr ? 'الوحدة' : 'Unit')),
                  ],
                ),
                const SizedBox(height: AppTheme.spacingM),
                // Expiry Date Picker
                GestureDetector(
                  onTap: () async {
                    final picked = await showDatePicker(
                      context: context,
                      initialDate: selectedExpiry ?? DateTime.now().add(const Duration(days: 7)),
                      firstDate: DateTime.now(),
                      lastDate: DateTime.now().add(const Duration(days: 365 * 5)),
                      helpText: strings.isAr ? 'تاريخ انتهاء الصلاحية' : 'Select Expiry Date',
                    );
                    if (picked != null) {
                      setSheetState(() => selectedExpiry = picked);
                    }
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                    decoration: BoxDecoration(
                      border: Border.all(color: selectedExpiry != null ? AppTheme.primary : Colors.grey.withAlpha(80)),
                      borderRadius: BorderRadius.circular(AppTheme.radiusM),
                      color: selectedExpiry != null ? AppTheme.primary.withAlpha(15) : null,
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.calendar_today_rounded,
                            size: 18,
                            color: selectedExpiry != null ? AppTheme.primary : Colors.grey),
                        const SizedBox(width: 12),
                        Text(
                          selectedExpiry != null
                              ? '${strings.isAr ? "ينتهي:" : "Expires:"} ${selectedExpiry!.day}/${selectedExpiry!.month}/${selectedExpiry!.year}'
                              : (strings.isAr ? 'تحديد تاريخ الانتهاء (اختياري)' : 'Select Expiry Date (optional)'),
                          style: TextStyle(
                            color: selectedExpiry != null ? AppTheme.primary : Colors.grey,
                            fontWeight: selectedExpiry != null ? FontWeight.bold : FontWeight.normal,
                          ),
                        ),
                        if (selectedExpiry != null) ...[
                          const Spacer(),
                          GestureDetector(
                            onTap: () => setSheetState(() => selectedExpiry = null),
                            child: const Icon(Icons.close, size: 16, color: Colors.grey),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: AppTheme.spacingXL),
                CustomButton(
                  label: strings.save,
                  onPressed: () {
                    if (nameCtrl.text.isNotEmpty) {
                      provider.addIngredient(Ingredient(
                        id: DateTime.now().toString(),
                        name: nameCtrl.text,
                        quantity: double.tryParse(qtyCtrl.text) ?? 0,
                        unit: unitCtrl.text.isEmpty ? 'g' : unitCtrl.text,
                        category: category,
                        expirationDate: selectedExpiry,
                      ));
                      if (selectedExpiry != null) {
                        NotificationService().scheduleExpiryNotification(nameCtrl.text, selectedExpiry!);
                      }
                      Navigator.pop(context);
                    }
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _IngredientCard extends StatelessWidget {
  final Ingredient item;
  final AppStrings strings;

  const _IngredientCard({required this.item, required this.strings});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    Color getStatusColor() {
      if (item.isExpired) return Colors.redAccent;
      if (item.isExpiringSoon) return Colors.orangeAccent;
      return AppTheme.primary;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: AppTheme.spacingM),
      padding: const EdgeInsets.all(AppTheme.spacingM),
      decoration: BoxDecoration(
        color: AppTheme.getCardColor(context),
        borderRadius: BorderRadius.circular(AppTheme.radiusM),
        border: Border.all(color: getStatusColor().withAlpha(40), width: 1),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: getStatusColor().withAlpha(20),
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.shopping_bag_outlined, color: getStatusColor(), size: 20),
          ),
          const SizedBox(width: AppTheme.spacingM),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(item.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                const SizedBox(height: 2),
                Text(
                  '${item.quantity.toStringAsFixed(0)} ${item.unit} · ${item.category}',
                  style: TextStyle(color: AppTheme.getSubtitleColor(context), fontSize: 13),
                ),
                if (item.expirationDate != null)
                  Text(
                    '${strings.isAr ? "ينتهي:" : "Expires:"} ${item.expirationDate!.day}/${item.expirationDate!.month}/${item.expirationDate!.year}',
                    style: TextStyle(
                      color: item.isExpiringSoon ? Colors.orangeAccent : (item.isExpired ? Colors.redAccent : AppTheme.getSubtitleColor(context)),
                      fontSize: 11,
                      fontWeight: (item.isExpiringSoon || item.isExpired) ? FontWeight.bold : FontWeight.normal,
                    ),
                  ),
              ],
            ),
          ),
          if (item.isExpiringSoon || item.isExpired)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: getStatusColor().withAlpha(30),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                item.isExpired ? strings.isAr ? 'منتهي' : 'Expired' : strings.isAr ? 'ينتهي جزيئا' : 'Near Exp',
                style: TextStyle(color: getStatusColor(), fontSize: 10, fontWeight: FontWeight.bold),
              ),
            ),
          const SizedBox(width: AppTheme.spacingS),
          IconButton(
            onPressed: () => context.read<PantryProvider>().removeIngredientById(item.id),
            icon: const Icon(Icons.delete_outline, color: Colors.redAccent, size: 20),
          ),
        ],
      ),
    );
  }
}
