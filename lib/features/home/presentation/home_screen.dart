import 'package:fit_kitchen_demo/features/health/presentation/widgets/circular_health_dashboard.dart';
import 'package:fit_kitchen_demo/features/health/presentation/widgets/hydration_tracker_widget.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/theme/app_theme.dart';
import '../../../shared/widgets/app_scaffold.dart';
import '../../../shared/widgets/info_card.dart';
import '../../../shared/widgets/section_header.dart';
import '../../auth/logic/auth_provider.dart';
import '../../pantry/logic/pantry_provider.dart';
import '../../meal_planner/logic/meal_plan_provider.dart';
import '../../recipes/logic/recipe_provider.dart';
import '../../settings/presentation/settings_screen.dart';
import '../../health/logic/health_provider.dart';
import '../../../shared/widgets/glass_container.dart';
import '../../recipes/presentation/favorite_recipes_screen.dart';

class HomeScreen extends StatelessWidget {
  final AppLang lang;
  final Function(int)? onNavigate;

  const HomeScreen({super.key, required this.lang, this.onNavigate});

  @override
  Widget build(BuildContext context) {
    final strings = AppStrings(lang);
    final auth = context.watch<AuthProvider>();
    final pantry = context.watch<PantryProvider>();
    final planner = context.watch<MealPlanProvider>();
    final recipes = context.watch<RecipeProvider>();

    final userName = auth.currentUser?.name ?? strings.guest;
    final health = context.watch<HealthProvider>();

    return AppScaffold(
      useSafeArea: false,
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // AI Header with Gradient
            Container(
              padding: const EdgeInsets.only(top: 64, bottom: 24, left: 24, right: 24),
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: AppTheme.primaryGradient,
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.vertical(bottom: Radius.circular(AppTheme.radiusXL)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            strings.greeting(userName),
                            style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
                          ),
                          Text(
                            isAr(lang) ? 'جاهز للطبخ اليوم؟' : 'Ready for a smart meal today?',
                            style: TextStyle(color: Colors.white.withAlpha(200), fontSize: 13),
                          ),
                        ],
                      ),
                      GestureDetector(
                        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => SettingsScreen(lang: lang))),
                        child: const CircleAvatar(
                          backgroundColor: Colors.white24,
                          child: Icon(Icons.person_rounded, color: Colors.white),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  
                  // --- PREMIUM CIRCULAR DASHBOARD ---
                  CircularHealthDashboard(
                    calories: health.dailyCaloriesConsumed,
                    targetCalories: health.calorieTarget,
                    protein: health.dailyProteinConsumed,
                    targetProtein: health.proteinTarget,
                    carbs: health.dailyCarbsConsumed,
                    targetCarbs: health.carbsTarget,
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 24),

            // Smart Recommendation Logic
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppTheme.spacingM),
              child: _SmartMealSuggestionCard(
                lang: lang, 
                recipe: recipes.getSmartTimeBasedRecommendation(),
              ),
            ),
            const SizedBox(height: 24),
            
            // Hydration Tracker
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppTheme.spacingM),
              child: HydrationTrackerWidget(
                currentGlasses: health.waterGlasses,
                targetGlasses: health.waterGoal,
                onUpdate: (val) => health.updateWater(val),
              ),
            ),

            // AI Smart Insights (Practical Data)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppTheme.spacingM),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(isAr(lang) ? 'رؤى الذكاء الاصطناعي' : 'AI Smart Insights', style: Theme.of(context).textTheme.titleLarge),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      _InsightCard(
                         label: strings.healthScore,
                         value: '${health.healthScore}',
                         color: AppTheme.primary,
                         icon: Icons.favorite_rounded,
                      ),
                      const SizedBox(width: 12),
                      _InsightCard(
                         label: strings.caloriesToday,
                         value: '${health.dailyCaloriesConsumed}',
                         color: AppTheme.secondary,
                         icon: Icons.local_fire_department_rounded,
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppTheme.spacingXL),


            // Summary Cards Grid
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppTheme.spacingM),
              child: GridView.count(
                crossAxisCount: 2,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                mainAxisSpacing: AppTheme.spacingM,
                crossAxisSpacing: AppTheme.spacingM,
                childAspectRatio: 1.15, // Perfect squarish shape, no empty vertical space
                children: [
                  InfoCard(
                    title: strings.ingredients,
                    value: '${pantry.count}',
                    icon: Icons.inventory_2_outlined,
                    color: AppTheme.primary,
                  ),
                  InfoCard(
                    title: strings.expiringSoon,
                    value: '${pantry.expiringSoonItems.length}',
                    icon: Icons.timer_outlined,
                    color: Colors.redAccent,
                    subtitle: pantry.expiringSoonItems.isNotEmpty ? 'Check now' : 'All good',
                    onTap: () => onNavigate?.call(1),
                  ),
                  InfoCard(
                    title: strings.mealsPlanned,
                    value: '${planner.totalMealsPlanned}',
                    icon: Icons.restaurant_menu_outlined,
                    color: AppTheme.secondary,
                  ),
                  InfoCard(
                    title: isAr(lang) ? 'المفضلة' : 'Saved',
                    value: '${recipes.favoriteRecipes.length}',
                    icon: Icons.favorite_outline,
                    color: Colors.pinkAccent,
                    onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => FavoriteRecipesScreen(lang: lang))),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppTheme.spacingXL),

            // Quick Actions
            SectionHeader(title: strings.quickActions),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: AppTheme.spacingM),
              child: Row(
                children: [
                   _QuickAction(
                    label: isAr(lang) ? 'تخطيط ذكي' : 'Smart Plan',
                    icon: Icons.calendar_today_rounded,
                    color: AppTheme.primary,
                    onTap: () => onNavigate?.call(3),
                  ),
                  _QuickAction(
                    label: isAr(lang) ? 'مخزني' : 'Pantry',
                    icon: Icons.kitchen_rounded,
                    color: AppTheme.secondary,
                    onTap: () => onNavigate?.call(1),
                  ),
                  _QuickAction(
                    label: isAr(lang) ? 'اقتراحات الذكاء الاصطناعي' : 'AI Ideas',
                    icon: Icons.auto_awesome,
                    color: Colors.deepPurple,
                    onTap: () => onNavigate?.call(2),
                  ),
                  _QuickAction(
                    label: strings.shopping,
                    icon: Icons.shopping_basket_outlined,
                    color: AppTheme.accent,
                    onTap: () => onNavigate?.call(4),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppTheme.spacingXL),

            // Featured Recipes
            SectionHeader(
              title: strings.featuredRecipes,
              actionLabel: isAr(lang) ? 'عرض الكل' : 'See All',
              onActionPressed: () {},
            ),
            SizedBox(
              height: 220,
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: AppTheme.spacingM),
                scrollDirection: Axis.horizontal,
                itemCount: recipes.featuredRecipes.length,
                itemBuilder: (context, index) {
                  final recipe = recipes.featuredRecipes[index];
                  return Container(
                    width: 280,
                    margin: const EdgeInsets.only(right: AppTheme.spacingM),
                    decoration: BoxDecoration(
                      color: AppTheme.getCardColor(context),
                      borderRadius: BorderRadius.circular(AppTheme.radiusL),
                      image: DecorationImage(
                      image: NetworkImage('https://images.unsplash.com/photo-1546069901-ba9599a7e63c?w=500&q=80'),
                      fit: BoxFit.cover,
                      colorFilter: ColorFilter.mode(
                        Colors.black.withAlpha(80),
                        BlendMode.darken,
                      ),
                      onError: (exception, stackTrace) {
                        debugPrint('Network image failed: $exception');
                      },
                    ),
                  ),
                    child: Padding(
                      padding: const EdgeInsets.all(AppTheme.spacingL),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.end,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            recipe.title,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              const Icon(Icons.timer_outlined, color: Colors.white70, size: 14),
                              const SizedBox(width: 4),
                              Text(
                                '${recipe.prepTime} min',
                                style: const TextStyle(color: Colors.white70, fontSize: 12),
                              ),
                              const SizedBox(width: 12),
                              const Icon(Icons.local_fire_department_outlined, color: Colors.white70, size: 14),
                              const SizedBox(width: 4),
                              Text(
                                '${recipe.calories} kcal',
                                style: const TextStyle(color: Colors.white70, fontSize: 12),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: AppTheme.spacingL),
          ],
        ),
      ),
    );
  }

  bool isAr(AppLang lang) => lang == AppLang.ar;
}

class _SmartMealSuggestionCard extends StatelessWidget {
  final AppLang lang;
  final dynamic recipe; // For now

  const _SmartMealSuggestionCard({required this.lang, required this.recipe});

  @override
  Widget build(BuildContext context) {
    final isAr = lang == AppLang.ar;
    return GlassContainer(
      padding: const EdgeInsets.all(16),
      opacity: 0.1,
      child: Row(
        children: [
          const Icon(Icons.auto_awesome_rounded, color: AppTheme.primary, size: 28),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isAr ? 'اقتراح ذكي حسب الوقت' : 'Smart Time-Based Suggestion',
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                ),
                Text(
                  isAr ? 'بناءً على التوقيت الحالي، ننصحك بـ ${recipe.title} 🍲' : 'Based on current time, we suggest ${recipe.title} 🍲',
                  style: TextStyle(color: Colors.grey[600], fontSize: 12),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _InsightCard extends StatelessWidget {
  final String label;
  final String value;
  final Color color;
  final IconData icon;

  const _InsightCard({required this.label, required this.value, required this.color, required this.icon});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [color.withAlpha(isDark ? 40 : 25), color.withAlpha(isDark ? 10 : 5)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(AppTheme.radiusL),
          border: Border.all(color: color.withAlpha(30)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: color, size: 22),
            const SizedBox(height: 10),
            Text(value, style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: isDark ? Colors.white : Colors.black87)),
            Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey, fontWeight: FontWeight.w600)),
          ],
        ),
      ),
    );
  }
}

class _QuickAction extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _QuickAction({
    required this.label,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(right: AppTheme.spacingM),
        padding: const EdgeInsets.symmetric(horizontal: AppTheme.spacingM, vertical: 14),
        decoration: BoxDecoration(
          color: color.withAlpha(isDark ? 35 : 20), // Soft filled button
          borderRadius: BorderRadius.circular(AppTheme.radiusXL), // Very rounded, calm shape
        ),
        child: Row(
          children: [
            Icon(icon, color: color, size: 20),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                color: color,
                fontWeight: FontWeight.bold,
                fontSize: 13,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
