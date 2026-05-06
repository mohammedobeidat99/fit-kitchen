import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/theme/app_theme.dart';
import '../../../shared/widgets/app_scaffold.dart';
import '../../../shared/widgets/section_header.dart';
import '../../../shared/widgets/custom_text_field.dart';
import '../logic/health_provider.dart';
import '../../../models/health_profile.dart';

class HealthProfileScreen extends StatelessWidget {
  final AppLang lang;

  const HealthProfileScreen({super.key, required this.lang});

  @override
  Widget build(BuildContext context) {
    final isAr = lang == AppLang.ar;
    final health = context.watch<HealthProvider>();
    final allergyCtrl = TextEditingController();

    return AppScaffold(
      title: isAr ? 'الملف الصحي' : 'Health Profile',
      body: ListView(
        padding: const EdgeInsets.symmetric(vertical: AppTheme.spacingL),
        children: [
          // ── Basic Dietary Preferences ──────────────────────────
          SectionHeader(title: isAr ? 'القيود الغذائية الأساسية' : 'Basic Dietary Preferences'),

          _HealthToggle(
            title: isAr ? 'نباتي' : 'Vegetarian',
            subtitle: isAr ? 'بدون لحوم أو دواجن' : 'No meat or poultry',
            icon: Icons.eco_rounded,
            value: health.profile.isVegetarian,
            onChanged: (v) => health.toggleVegetarian(v),
          ),
          _HealthToggle(
            title: isAr ? 'مرض السكري' : 'Diabetic Friendly',
            subtitle: isAr ? 'منخفض السكر والكربوهيدرات' : 'Low sugar & carbs',
            icon: Icons.water_drop_rounded,
            value: health.profile.hasDiabetes,
            onChanged: (v) => health.toggleDiabetes(v),
          ),
          _HealthToggle(
            title: isAr ? 'ضغط الدم / قليل الملح' : 'Low Salt / Sodium',
            subtitle: isAr ? 'للمصابين بضغط الدم المرتفع' : 'For high blood pressure',
            icon: Icons.favorite_rounded,
            value: health.profile.hasHighBloodPressure,
            onChanged: (v) => health.toggleLowSalt(v),
          ),

          const SizedBox(height: AppTheme.spacingXL),

          // ── Water Reminders ────────────────────────────────────
          SectionHeader(title: isAr ? 'تنبيهات شرب الماء' : 'Water Reminders'),
          _HealthToggle(
            title: isAr ? 'تفعيل التنبيهات' : 'Enable Reminders',
            subtitle: isAr ? 'للحفاظ على رطوبة جسمك' : 'Stay hydrated throughout the day',
            icon: Icons.notifications_active_rounded,
            value: health.waterReminderEnabled,
            onChanged: (v) => health.updateWaterReminder(v, health.waterReminderInterval),
          ),
          if (health.waterReminderEnabled)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppTheme.spacingM),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    isAr 
                      ? 'تكرار التنبيه: كل ${health.waterReminderInterval} دقيقة' 
                      : 'Reminder Interval: Every ${health.waterReminderInterval} mins',
                    style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
                  ),
                  Slider(
                    value: health.waterReminderInterval.toDouble(),
                    min: 15,
                    max: 120,
                    divisions: 7,
                    label: '${health.waterReminderInterval} min',
                    activeColor: AppTheme.primary,
                    onChanged: (v) => health.updateWaterReminder(true, v.toInt()),
                  ),
                ],
              ),
            ),

          const SizedBox(height: AppTheme.spacingXL),

          // ── Conditions & Preferences ───────────────────────────
          SectionHeader(title: isAr ? 'حالات خاصة' : 'Conditions & Preferences'),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppTheme.spacingM),
            child: Text(
              isAr ? 'اختر ما يناسب حالتك الصحية:' : 'Select any that apply to you:',
              style: TextStyle(color: AppTheme.getSubtitleColor(context), fontSize: 13),
            ),
          ),
          const SizedBox(height: AppTheme.spacingM),

          ...HealthProfile.presetConditions.map((condition) {
            final isActive = health.hasCondition(condition.id);
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppTheme.spacingM, vertical: 4),
              child: GestureDetector(
                onTap: () => health.toggleCondition(condition),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.all(AppTheme.spacingM),
                  decoration: BoxDecoration(
                    color: isActive ? AppTheme.primary.withAlpha(20) : AppTheme.getCardColor(context),
                    borderRadius: BorderRadius.circular(AppTheme.radiusM),
                    border: Border.all(
                      color: isActive ? AppTheme.primary : Colors.grey.withAlpha(40),
                      width: isActive ? 2 : 1,
                    ),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: isActive ? AppTheme.primary : Colors.grey.withAlpha(30),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          isActive ? Icons.check_rounded : Icons.add_rounded,
                          color: Colors.white,
                          size: 16,
                        ),
                      ),
                      const SizedBox(width: AppTheme.spacingM),
                      Expanded(
                        child: Text(
                          isAr ? condition.nameAr : condition.name,
                          style: TextStyle(
                            fontWeight: isActive ? FontWeight.bold : FontWeight.w500,
                            fontSize: 14,
                            color: isActive ? AppTheme.primary : null,
                          ),
                        ),
                      ),
                      if (isActive && condition.avoidIngredients.isNotEmpty)
                        Text(
                          isAr ? '${condition.avoidIngredients.length} قيود' : '${condition.avoidIngredients.length} limits',
                          style: const TextStyle(fontSize: 11, color: AppTheme.primary),
                        ),
                    ],
                  ),
                ),
              ),
            );
          }),

          const SizedBox(height: AppTheme.spacingXL),

          // ── Allergies ──────────────────────────────────────────
          SectionHeader(title: isAr ? 'الحساسية الغذائية' : 'Food Allergies'),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppTheme.spacingM),
            child: Row(
              children: [
                Expanded(
                  child: CustomTextField(
                    controller: allergyCtrl,
                    label: isAr ? 'أضف حساسية' : 'Add allergy',
                    hint: isAr ? 'مثال: جوز، بيض...' : 'e.g. Nuts, Eggs...',
                  ),
                ),
                const SizedBox(width: AppTheme.spacingM),
                IconButton(
                  onPressed: () {
                    if (allergyCtrl.text.isNotEmpty) {
                      health.addAllergy(allergyCtrl.text.trim());
                      allergyCtrl.clear();
                    }
                  },
                  icon: const Icon(Icons.add_circle_rounded, color: AppTheme.primary, size: 32),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppTheme.spacingL),

          if (health.profile.allergies.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppTheme.spacingM),
              child: Text(
                isAr ? 'لم تضف أي حساسية بعد.' : 'No allergies added yet.',
                style: TextStyle(color: AppTheme.getSubtitleColor(context), fontSize: 13),
              ),
            )
          else
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppTheme.spacingM),
              child: Wrap(
                spacing: 8,
                runSpacing: 8,
                children: health.profile.allergies.asMap().entries.map((entry) => Chip(
                  label: Text(entry.value, style: const TextStyle(fontSize: 12)),
                  onDeleted: () => health.removeAllergy(entry.key),
                  deleteIconColor: Colors.redAccent,
                  backgroundColor: Colors.redAccent.withAlpha(15),
                  side: const BorderSide(color: Colors.redAccent, width: 1),
                )).toList(),
              ),
            ),

          const SizedBox(height: AppTheme.spacingXL),

          // ── Active Summary ─────────────────────────────────────
          if (health.profile.avoidedIngredientKeywords.isNotEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppTheme.spacingM),
              child: Container(
                padding: const EdgeInsets.all(AppTheme.spacingM),
                decoration: BoxDecoration(
                  color: Colors.orangeAccent.withAlpha(20),
                  borderRadius: BorderRadius.circular(AppTheme.radiusM),
                  border: Border.all(color: Colors.orangeAccent.withAlpha(80)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.info_outline_rounded, color: Colors.orangeAccent, size: 18),
                        const SizedBox(width: 8),
                        Text(
                          isAr ? 'مكونات يتم تجنبها في الاقتراحات:' : 'Avoided in meal suggestions:',
                          style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.orangeAccent, fontSize: 13),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      health.profile.avoidedIngredientKeywords.join(' · '),
                      style: const TextStyle(fontSize: 12),
                    ),
                  ],
                ),
              ),
            ),

          const SizedBox(height: 80),
        ],
      ),
    );
  }
}

class _HealthToggle extends StatelessWidget {
  final String title;
  final String? subtitle;
  final IconData icon;
  final bool value;
  final ValueChanged<bool> onChanged;

  const _HealthToggle({
    required this.title,
    this.subtitle,
    required this.icon,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppTheme.spacingM, vertical: 4),
      child: Container(
        decoration: BoxDecoration(
          color: value ? AppTheme.primary.withAlpha(10) : null,
          borderRadius: BorderRadius.circular(AppTheme.radiusM),
        ),
        child: SwitchListTile(
          value: value,
          onChanged: onChanged,
          secondary: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: value ? AppTheme.primary.withAlpha(20) : Colors.grey.withAlpha(15),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: value ? AppTheme.primary : Colors.grey, size: 20),
          ),
          title: Text(title, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: value ? AppTheme.primary : null)),
          subtitle: subtitle != null ? Text(subtitle!, style: const TextStyle(fontSize: 12)) : null,
          activeColor: AppTheme.primary,
          contentPadding: const EdgeInsets.symmetric(horizontal: AppTheme.spacingM),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppTheme.radiusM)),
        ),
      ),
    );
  }
}
