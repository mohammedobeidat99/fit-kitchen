import 'package:fit_kitchen_demo/features/recipes/logic/recipe_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'cooking_mode_screen.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/theme/app_theme.dart';
import '../../../shared/widgets/app_scaffold.dart';
import '../../../shared/widgets/custom_button.dart';
import '../../../shared/widgets/section_header.dart';
import '../../../models/recipe.dart';
import '../../history/logic/cooking_history_provider.dart';
import '../../../shared/widgets/glass_container.dart';

class RecipeDetailsScreen extends StatelessWidget {
  final Recipe recipe;
  final AppLang lang;

  const RecipeDetailsScreen({
    super.key,
    required this.recipe,
    required this.lang,
  });

  @override
  Widget build(BuildContext context) {
    final isAr = lang == AppLang.ar;
    final servingsNotifier = ValueNotifier<int>(recipe.servings);
    
    final safeImageUrl = recipe.imageUrl ?? 'https://image.pollinations.ai/prompt/${Uri.encodeComponent('Delicious appetizing ${recipe.title} high quality restaurant food photography plating')}?width=1000&height=800';

    return AppScaffold(
      useSafeArea: false,
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => CookingModeScreen(recipe: recipe, lang: lang),
            ),
          );
        },
        label: Text(isAr ? 'بدء الطبخ' : 'Start Cooking'),
        icon: const Icon(Icons.play_arrow_rounded),
        backgroundColor: AppTheme.primary,
        foregroundColor: Colors.white,
      ),
      body: CustomScrollView(
        slivers: [
          // Premium Sliver AppBar with Image
          SliverAppBar(
            expandedHeight: 300,
            pinned: true,
            actions: [
              Container(
                margin: const EdgeInsets.only(right: 16, left: 16, top: 4, bottom: 4),
                decoration: BoxDecoration(
                  color: Colors.black.withAlpha(100),
                  shape: BoxShape.circle,
                ),
                child: IconButton(
                  icon: Icon(
                    context.watch<RecipeProvider>().getById(recipe.id)?.isFavorite == true 
                        ? Icons.favorite_rounded 
                        : Icons.favorite_outline_rounded,
                    color: context.watch<RecipeProvider>().getById(recipe.id)?.isFavorite == true 
                        ? Colors.redAccent 
                        : Colors.white,
                  ),
                  onPressed: () {
                    context.read<RecipeProvider>().toggleFavorite(recipe.id);
                  },
                ),
              ),
            ],
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                fit: StackFit.expand,
                children: [
                  Image.network(
                    safeImageUrl,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => Container(
                      color: AppTheme.primary.withAlpha(30),
                      child: const Center(
                        child: Icon(Icons.restaurant_rounded, size: 80, color: AppTheme.primary),
                      ),
                    ),
                  ),
                  const DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [Colors.black54, Colors.transparent, Colors.black87],
                      ),
                    ),
                  ),
                ],
              ),
              title: Row(
                children: [
                   Expanded(
                    child: Text(
                      recipe.title,
                      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18),
                    ),
                  ),
                  _HealthGradeBadge(grade: context.read<RecipeProvider>().getHealthGrade(recipe)),
                ],
              ),
            ),
          ),

          // Content
          SliverToBoxAdapter(
            child: Container(
              padding: const EdgeInsets.all(AppTheme.spacingL),
              decoration: BoxDecoration(
                color: Theme.of(context).scaffoldBackgroundColor,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(AppTheme.radiusXL)),
              ),
              child: ValueListenableBuilder<int>(
                valueListenable: servingsNotifier,
                builder: (context, currentServings, child) {
                  final scale = currentServings / recipe.servings;
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                       // Stats Bar
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          _StatItem(icon: Icons.timer_outlined, label: '${recipe.prepTime} min', color: AppTheme.primary),
                          _StatItem(icon: Icons.local_fire_department_outlined, label: '${(recipe.calories * scale).toInt()} kcal', color: AppTheme.secondary),
                          _StatItem(icon: Icons.fitness_center_rounded, label: '${(recipe.protein * scale).toStringAsFixed(1)}g P', color: AppTheme.accent),
                        ],
                      ),
                      const SizedBox(height: AppTheme.spacingXL),

                      // Practical Portion Control
                      _PortionControl(
                        servings: currentServings,
                        onChanged: (newVal) => servingsNotifier.value = newVal.clamp(1, 10),
                      ),
                      const SizedBox(height: AppTheme.spacingXL),

                      // Detailed Nutrition Card
                      _NutritionCard(recipe: recipe, scale: scale),
                      const SizedBox(height: AppTheme.spacingXL),

                      // Ingredients
                      SectionHeader(title: isAr ? 'المكونات' : 'Ingredients'),
                      const SizedBox(height: AppTheme.spacingS),
                      ...recipe.ingredients.map((ing) => Padding(
                        padding: const EdgeInsets.symmetric(horizontal: AppTheme.spacingM, vertical: 6),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                const Icon(Icons.check_circle_outline_rounded, color: AppTheme.primary, size: 18),
                                const SizedBox(width: 12),
                                Text(ing, style: Theme.of(context).textTheme.bodyLarge),
                              ],
                            ),
                            Padding(
                              padding: const EdgeInsets.only(left: 30, top: 2),
                              child: Text(
                                'Tip: ${context.read<RecipeProvider>().getSubstitutions(ing)}',
                                style: TextStyle(color: Colors.grey[500], fontSize: 11, fontStyle: FontStyle.italic),
                              ),
                            ),
                          ],
                        ),
                      )),
                      const SizedBox(height: AppTheme.spacingXL),

                      // Steps
                      SectionHeader(title: isAr ? 'خطوات التحضير' : 'Instructions'),
                      const SizedBox(height: AppTheme.spacingS),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: AppTheme.spacingM),
                        child: Text(
                          recipe.steps,
                          style: Theme.of(context).textTheme.bodyLarge?.copyWith(height: 1.6),
                        ),
                      ),
                      const SizedBox(height: 100), // Space for FAB
                    ],
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _PortionControl extends StatelessWidget {
  final int servings;
  final ValueChanged<int> onChanged;
  const _PortionControl({required this.servings, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return GlassContainer(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      opacity: 0.05,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text('Adjust Portion Size', style: TextStyle(fontWeight: FontWeight.bold)),
          Row(
            children: [
              IconButton(
                icon: const Icon(Icons.remove_circle_outline, size: 24),
                onPressed: () => onChanged(servings - 1),
                color: AppTheme.primary,
              ),
              const SizedBox(width: 8),
              Text('$servings', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
              const SizedBox(width: 8),
              IconButton(
                icon: const Icon(Icons.add_circle_outline, size: 24),
                onPressed: () => onChanged(servings + 1),
                color: AppTheme.primary,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _NutritionCard extends StatelessWidget {
  final Recipe recipe;
  final double scale;
  const _NutritionCard({required this.recipe, required this.scale});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Dynamic Nutrition Breakdown', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        const SizedBox(height: 14),
        Row(
          children: [
            _NutrientProgress(label: 'Protein', value: '${(recipe.protein * scale).toStringAsFixed(1)}g', color: AppTheme.primary, percent: 0.7),
            const SizedBox(width: 12),
            _NutrientProgress(label: 'Carbs', value: '${(recipe.carbs * scale).toStringAsFixed(1)}g', color: AppTheme.secondary, percent: 0.5),
            const SizedBox(width: 12),
            _NutrientProgress(label: 'Fat', value: '${(recipe.fat * scale).toStringAsFixed(1)}g', color: Colors.orange, percent: 0.3),
          ],
        ),
      ],
    );
  }
}

class _NutrientProgress extends StatelessWidget {
  final String label;
  final String value;
  final Color color;
  final double percent;

  const _NutrientProgress({required this.label, required this.value, required this.color, required this.percent});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: color.withAlpha(15),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: const TextStyle(fontSize: 11, color: Colors.grey)),
            const SizedBox(height: 4),
            Text(value, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
            const SizedBox(height: 8),
            LinearProgressIndicator(value: percent, color: color, backgroundColor: color.withAlpha(30), minHeight: 4),
          ],
        ),
      ),
    );
  }
}

class _StatItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;

  const _StatItem({required this.icon, required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, color: color, size: 24),
        const SizedBox(height: 8),
        Text(label, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
      ],
    );
  }
}

class _HealthGradeBadge extends StatelessWidget {
  final String grade;
  const _HealthGradeBadge({required this.grade});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: AppTheme.primary,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(color: AppTheme.primary.withAlpha(100), blurRadius: 8, offset: const Offset(0, 2)),
        ],
      ),
      child: Text(
        grade,
        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
      ),
    );
  }
}
