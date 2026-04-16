import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/theme/app_theme.dart';
import '../../../shared/widgets/app_scaffold.dart';
import '../../../shared/widgets/empty_state.dart';
import '../../../shared/widgets/section_header.dart';
import '../logic/cooking_history_provider.dart';

class CookingHistoryScreen extends StatelessWidget {
  final AppLang lang;

  const CookingHistoryScreen({super.key, required this.lang});

  @override
  Widget build(BuildContext context) {
    final strings = AppStrings(lang);
    final isAr = lang == AppLang.ar;
    final history = context.watch<CookingHistoryProvider>();
    final entries = history.entries;

    return AppScaffold(
      title: isAr ? 'سجل الطبخ' : 'Cooking History',
      actions: [
        if (entries.isNotEmpty)
          IconButton(
            onPressed: () => history.clearHistory(),
            icon: const Icon(Icons.delete_sweep_outlined, color: Colors.redAccent),
          ),
      ],
      body: entries.isEmpty
          ? EmptyStateWidget(
              icon: Icons.history_rounded,
              title: isAr ? 'لا يوجد سجل' : 'No History Yet',
              message: isAr ? 'الوجبات التي تطبخها ستظهر هنا.' : 'Meals you cook will appear here.',
            )
          : ListView.builder(
              padding: const EdgeInsets.all(AppTheme.spacingM),
              itemCount: entries.length + 1,
              itemBuilder: (context, index) {
                if (index == 0) return SectionHeader(title: isAr ? 'الوجبات السابقة' : 'Recent Meals');
                final entry = entries[index - 1];
                return Container(
                  margin: const EdgeInsets.only(bottom: AppTheme.spacingM),
                  decoration: BoxDecoration(
                    color: AppTheme.getCardColor(context),
                    borderRadius: BorderRadius.circular(AppTheme.radiusM),
                  ),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: AppTheme.primary.withAlpha(20),
                      child: const Icon(Icons.check_circle_rounded, color: AppTheme.primary),
                    ),
                    title: Text(entry.recipeTitle, style: const TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Text(
                      '${entry.timestamp.day}/${entry.timestamp.month}/${entry.timestamp.year} · ${entry.calories} kcal',
                      style: const TextStyle(fontSize: 12),
                    ),
                  ),
                );
              },
            ),
    );
  }
}
