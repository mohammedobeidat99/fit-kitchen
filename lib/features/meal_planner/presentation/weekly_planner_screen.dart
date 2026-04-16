import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/theme/app_theme.dart';
import '../../../shared/widgets/app_scaffold.dart';
import '../../../shared/widgets/empty_state.dart';
import '../../../shared/widgets/section_header.dart';
import '../logic/meal_plan_provider.dart';
import '../../../features/recipes/logic/recipe_provider.dart';
import '../../../features/pantry/logic/pantry_provider.dart';
import '../../../features/health/logic/health_provider.dart';
import '../../../features/settings/logic/lang_provider.dart';
import '../../../models/recipe.dart';
import '../../../models/planned_meal.dart';
import '../../../features/recipes/presentation/recipe_details_screen.dart';

class WeeklyPlannerScreen extends StatelessWidget {
  final AppLang lang;

  const WeeklyPlannerScreen({super.key, required this.lang});

  @override
  Widget build(BuildContext context) {
    final strings = AppStrings(lang);
    final isAr = lang == AppLang.ar;
    final mealPlan = context.watch<MealPlanProvider>();
    final todayIndex = DateTime.now().weekday - 1;

    return DefaultTabController(
      length: 7,
      initialIndex: todayIndex,
      child: AppScaffold(
        title: strings.planner,
        actions: [
          IconButton(
            onPressed: () {
              final recipesProv = context.read<RecipeProvider>();
              final pantryProv = context.read<PantryProvider>();
              final healthProv = context.read<HealthProvider>();
              
              final pantryNames = pantryProv.ingredients.map((i) => i.name).toList();
              final avoidedKw = healthProv.profile.avoidedIngredientKeywords;
              final suggestions = recipesProv.getSuggestions(pantryNames, avoidedKeywords: avoidedKw);
              
              final availableRecipes = suggestions.map((s) => s['recipe'] as Recipe).toList();
              
              if (availableRecipes.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(isAr 
                      ? 'لا يوجد مكونات كافية في المخزن لتوليد خطة بناءً على وصفاتك!' 
                      : 'Not enough pantry items to generate a smart plan!'),
                    backgroundColor: Colors.orangeAccent,
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              } else {
                mealPlan.generateSmartWeeklyPlan(availableRecipes);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(isAr 
                      ? '✨ تم التخطيط بناءً على المخزن والملف الصحي!' 
                      : '✨ Smart Plan generated based on pantry & health!'),
                    backgroundColor: AppTheme.primary,
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              }
            },
            icon: const Icon(Icons.auto_awesome, color: AppTheme.primary),
            tooltip: isAr ? 'توليد بناءً على المخزن' : 'Generate from Pantry',
          ),
          if (mealPlan.totalMealsPlanned > 0)
            IconButton(
              onPressed: () => mealPlan.clearAll(),
              icon: const Icon(Icons.delete_sweep_outlined, color: Colors.redAccent),
              tooltip: strings.clearAll,
            ),
        ],
        body: Column(
          children: [
            // Modern Days TabBar
            Container(
              color: AppTheme.getCardColor(context),
              child: TabBar(
                isScrollable: true,
                indicatorColor: AppTheme.primary,
                labelColor: AppTheme.primary,
                unselectedLabelColor: Colors.grey,
                indicatorWeight: 3,
                tabAlignment: TabAlignment.start,
                tabs: MealPlanProvider.days.map((day) {
                  final count = mealPlan.getMealsForDay(day).length;
                  return Tab(
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(strings.dayName(day).substring(0, 3), style: const TextStyle(fontWeight: FontWeight.bold)),
                        if (count > 0) ...[
                          const SizedBox(width: 6),
                          Container(
                            padding: const EdgeInsets.all(4),
                            decoration: const BoxDecoration(color: AppTheme.primary, shape: BoxShape.circle),
                            child: Text(count.toString(), style: const TextStyle(color: Colors.white, fontSize: 8, fontWeight: FontWeight.bold)),
                          ),
                        ],
                      ],
                    ),
                  );
                }).toList(),
              ),
            ),

            // Tab Content
            Expanded(
              child: TabBarView(
                children: MealPlanProvider.days.map((day) {
                  final meals = mealPlan.getMealsForDay(day);
                  if (meals.isEmpty) {
                    return EmptyStateWidget(
                      icon: Icons.calendar_today_outlined,
                      title: isAr ? 'لا توجد وجبات' : 'No Meals Planned',
                      message: isAr ? 'خطط لوجباتك لهذا اليوم.' : 'Plan your meals for this day.',
                      actionLabel: strings.addMeal,
                      onActionPressed: () => _showRecipePicker(context, strings, day),
                    );
                  }
                  return ListView.builder(
                    padding: const EdgeInsets.all(AppTheme.spacingM),
                    itemCount: meals.length + 1, // +1 for the header
                    itemBuilder: (context, index) {
                      if (index == 0) return SectionHeader(title: strings.dayName(day));
                      final plannedMeal = meals[index - 1];
                      return _MealCard(day: day, plannedMeal: plannedMeal, index: index - 1, strings: strings);
                    },
                  );
                }).toList(),
              ),
            ),
          ],
        ),
        floatingActionButton: FloatingActionButton.extended(
          heroTag: 'planner_fab',
          onPressed: () {
            // In a better architecture, we'd have a currentTabProvider, 
            // but DefaultTabController handles it internally.
            // For simplicity in a Stateless setup, we just open for Monday 
            // or we could use Builder to get TabController.
            final tabIndex = DefaultTabController.of(context).index;
            final day = MealPlanProvider.days[tabIndex];
             _showRecipePicker(context, strings, day);
          },
          backgroundColor: AppTheme.primary,
          foregroundColor: Colors.white,
          icon: const Icon(Icons.add),
          label: Text(strings.addMeal),
        ),
      ),
    );
  }

  void _showRecipePicker(BuildContext context, AppStrings strings, String day) {
    final recipes = context.read<RecipeProvider>().allRecipes;
    final mealPlan = context.read<MealPlanProvider>();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => Container(
        decoration: BoxDecoration(
          color: Theme.of(context).scaffoldBackgroundColor,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(AppTheme.radiusL)),
        ),
        height: MediaQuery.of(context).size.height * 0.7,
        child: Column(
          children: [
            Container(
              margin: const EdgeInsets.symmetric(vertical: 12),
              width: 40, height: 4, decoration: BoxDecoration(color: Colors.grey.withAlpha(50), borderRadius: BorderRadius.circular(10)),
            ),
            Padding(
              padding: const EdgeInsets.all(AppTheme.spacingM),
              child: Text('${strings.selectRecipe} — ${strings.dayName(day)}', style: Theme.of(context).textTheme.titleLarge),
            ),
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: AppTheme.spacingM),
                itemCount: recipes.length,
                itemBuilder: (context, index) {
                  final recipe = recipes[index];
                  return ListTile(
                    leading: CircleAvatar(backgroundColor: AppTheme.primary.withAlpha(20), child: const Icon(Icons.restaurant, color: AppTheme.primary, size: 18)),
                    title: Text(recipe.title, style: const TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Text('${recipe.calories} kcal · ${recipe.prepTime} min'),
                    trailing: const Icon(Icons.add_circle_outline, color: AppTheme.primary),
                    onTap: () {
                      mealPlan.addMealToDay(day, recipe);
                      Navigator.pop(context);
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MealCard extends StatelessWidget {
  final String day;
  final PlannedMeal plannedMeal;
  final int index;
  final AppStrings strings;

  const _MealCard({required this.day, required this.plannedMeal, required this.index, required this.strings});

  @override
  Widget build(BuildContext context) {
    final recipe = plannedMeal.recipe;
    final isCooked = plannedMeal.isCooked;

    return Container(
      margin: const EdgeInsets.only(bottom: AppTheme.spacingM),
      decoration: BoxDecoration(
        color: isCooked ? Colors.green.withAlpha(20) : AppTheme.getCardColor(context),
        borderRadius: BorderRadius.circular(AppTheme.radiusM),
        border: isCooked ? Border.all(color: Colors.green.withAlpha(50), width: 1.5) : null,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(5),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(AppTheme.radiusM),
        onTap: () async {
          final l = context.read<LangProvider>().lang;
          final cooked = await Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => RecipeDetailsScreen(recipe: recipe, lang: l)),
          );
          if (cooked == true) {
            context.read<MealPlanProvider>().markMealAsCooked(day, index);
          }
        },
        child: ListTile(
          leading: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: isCooked ? Colors.green.withAlpha(30) : AppTheme.primary.withAlpha(15), 
              borderRadius: BorderRadius.circular(10)
            ),
            child: Icon(
              isCooked ? Icons.check_circle_rounded : Icons.restaurant_menu_rounded, 
              color: isCooked ? Colors.green : AppTheme.primary, 
              size: 20
            ),
          ),
          title: Text(recipe.title, style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14, decoration: isCooked ? TextDecoration.lineThrough : null)),
          subtitle: Text(isCooked ? (strings.isAr ? 'تم الطهو' : 'Cooked') : '${recipe.category} · ${recipe.calories} kcal', style: TextStyle(fontSize: 12, color: isCooked ? Colors.green : Colors.grey)),
          trailing: IconButton(
            onPressed: () => context.read<MealPlanProvider>().removeMealFromDay(day, index),
            icon: const Icon(Icons.remove_circle_outline, color: Colors.redAccent, size: 20),
          ),
        ),
      ),
    );
  }
}
