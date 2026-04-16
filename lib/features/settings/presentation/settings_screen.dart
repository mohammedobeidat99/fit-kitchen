import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/theme/app_theme.dart';
import '../../../shared/widgets/app_scaffold.dart';
import '../../../shared/widgets/section_header.dart';
import '../../auth/logic/auth_provider.dart';
import '../../pantry/logic/pantry_provider.dart';
import '../../shopping/logic/shopping_provider.dart';
import '../../history/logic/cooking_history_provider.dart';
import '../../health/logic/health_provider.dart';
import '../../recipes/logic/recipe_provider.dart';
import '../../meal_planner/logic/meal_plan_provider.dart';
import '../logic/theme_provider.dart';
import '../logic/lang_provider.dart';
import '../../health/presentation/health_profile_screen.dart';
import '../../history/presentation/cooking_history_screen.dart';

class SettingsScreen extends StatelessWidget {
  final AppLang lang;

  const SettingsScreen({
    super.key,
    required this.lang,
  });

  @override
  Widget build(BuildContext context) {
    final langProvider = context.watch<LangProvider>();
    final lang = langProvider.lang;
    final strings = AppStrings(lang);
    final auth = context.watch<AuthProvider>();
    final theme = context.watch<ThemeProvider>();
    final isAr = lang == AppLang.ar;

    return AppScaffold(
      title: strings.settings,
      body: ListView(
        padding: const EdgeInsets.symmetric(vertical: AppTheme.spacingL),
        children: [
          // Profile Section
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppTheme.spacingM),
            child: Container(
              padding: const EdgeInsets.all(AppTheme.spacingL),
              decoration: BoxDecoration(
                color: AppTheme.primary.withAlpha(20),
                borderRadius: BorderRadius.circular(AppTheme.radiusXL),
              ),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 35,
                    backgroundColor: AppTheme.primary.withAlpha(40),
                    child: const Icon(Icons.person_rounded, size: 40, color: AppTheme.primary),
                  ),
                  const SizedBox(width: AppTheme.spacingL),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          auth.currentUser?.name ?? strings.guest,
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                        Text(
                          auth.currentUser?.email ?? 'guest@fitkitchen.app',
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: AppTheme.spacingXL),

          // Appearance Section
          SectionHeader(title: strings.appearance),
          _SettingsTile(
            title: strings.darkMode,
            icon: Icons.dark_mode_outlined,
            trailing: Switch(
              value: theme.isDarkMode,
              onChanged: (_) => theme.toggleTheme(),
              activeColor: AppTheme.primary,
            ),
          ),
          _SettingsTile(
            title: strings.isAr ? 'اللغة العربية' : 'English Language',
            subtitle: strings.isAr ? 'تغيير للإنجليزية' : 'Switch to Arabic',
            icon: Icons.translate_rounded,
            onTap: () => langProvider.toggle(),
          ),
          const SizedBox(height: AppTheme.spacingL),

          // Security Section
          SectionHeader(title: isAr ? 'الأمان والملف الشخصي' : 'Security & Profile'),
          _SettingsTile(
            title: isAr ? 'الملف الصحي' : 'Health Profile',
            icon: Icons.health_and_safety_outlined,
            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => HealthProfileScreen(lang: lang))),
          ),
          _SettingsTile(
            title: isAr ? 'سجل الطبخ' : 'Cooking History',
            icon: Icons.history_rounded,
            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => CookingHistoryScreen(lang: lang))),
          ),
          if (auth.biometricAvailable)
            _SettingsTile(
              title: isAr ? 'الدخول بالبصمة' : 'Biometric Login',
              icon: Icons.fingerprint_rounded,
              trailing: Switch(
                value: auth.biometricEnabled,
                onChanged: (v) => auth.setBiometricEnabled(v),
                activeColor: AppTheme.primary,
              ),
            ),
          const SizedBox(height: AppTheme.spacingL),

          // About Section
          SectionHeader(title: isAr ? 'حول' : 'About'),
          _SettingsTile(
            title: isAr ? 'إصدار التطبيق' : 'App Version',
            subtitle: 'v2.0.0-premium',
            icon: Icons.info_outline_rounded,
          ),
          const SizedBox(height: 40),

          // Logout
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppTheme.spacingXL),
            child: ElevatedButton(
              onPressed: () => _confirmLogout(context, strings, auth),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.redAccent.withAlpha(20),
                foregroundColor: Colors.redAccent,
                elevation: 0,
                side: const BorderSide(color: Colors.redAccent, width: 1),
              ),
              child: Text(strings.logout, style: const TextStyle(fontWeight: FontWeight.bold)),
            ),
          ),
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  void _confirmLogout(BuildContext context, AppStrings strings, AuthProvider auth) {
    showDialog(
      context: context,
      builder: (dialogCtx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppTheme.radiusL)),
        title: Text(strings.logout),
        content: Text(strings.isAr ? 'هل أنت متأكد من تسجيل الخروج؟' : 'Are you sure you want to logout?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(dialogCtx), child: Text(strings.cancel)),
          TextButton(
            onPressed: () async {
              Navigator.pop(dialogCtx); // pop dialog
              Navigator.of(context).popUntil((route) => route.isFirst); // pop all screens
              // Unbind all Firestore providers
              context.read<PantryProvider>().unbindUser();
              context.read<ShoppingListProvider>().unbindUser();
              context.read<CookingHistoryProvider>().unbindUser();
              context.read<HealthProvider>().unbindUser();
              context.read<RecipeProvider>().unbindUser();
              context.read<MealPlanProvider>().unbindUser();
              await auth.logout(); // sign out from Firebase
            },
            child: Text(strings.logout, style: const TextStyle(color: Colors.redAccent)),
          ),
        ],
      ),
    );
  }
}

class _SettingsTile extends StatelessWidget {
  final String title;
  final String? subtitle;
  final IconData icon;
  final Widget? trailing;
  final VoidCallback? onTap;

  const _SettingsTile({
    required this.title,
    this.subtitle,
    required this.icon,
    this.trailing,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(horizontal: AppTheme.spacingL, vertical: 4),
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: AppTheme.primary.withAlpha(15),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, color: AppTheme.primary, size: 22),
      ),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15)),
      subtitle: subtitle != null ? Text(subtitle!, style: const TextStyle(fontSize: 12)) : null,
      trailing: trailing ?? (onTap != null ? const Icon(Icons.chevron_right, size: 20) : null),
    );
  }
}
