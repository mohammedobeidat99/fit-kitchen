import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/theme/app_theme.dart';
import '../../../shared/widgets/app_scaffold.dart';
import '../../../shared/widgets/empty_state.dart';
import '../logic/recipe_provider.dart';
import '../../pantry/logic/pantry_provider.dart';
import '../../health/logic/health_provider.dart';
import '../../shopping/logic/shopping_provider.dart';
import '../../../models/recipe.dart';
import 'recipe_details_screen.dart';

class MealSuggestionsScreen extends StatelessWidget {
  final AppLang lang;

  const MealSuggestionsScreen({super.key, required this.lang});

  @override
  Widget build(BuildContext context) {
    final strings = AppStrings(lang);
    final isAr = lang == AppLang.ar;
    final recipes = context.watch<RecipeProvider>();
    final pantry = context.watch<PantryProvider>();
    final health = context.watch<HealthProvider>();
    
    final pantryNames = pantry.ingredients.map((i) => i.name).toList();
    final avoidedKeywords = health.profile.avoidedIngredientKeywords;
    final suggestions = recipes.getSuggestions(pantryNames, avoidedKeywords: avoidedKeywords);
    final hasActiveFilters = avoidedKeywords.isNotEmpty;

    return AppScaffold(
      title: isAr ? 'اقتراحات الوجبات' : 'Smart Suggestions',
      body: CustomScrollView(
        slivers: [
          // Health Filter Banner
          if (hasActiveFilters)
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(AppTheme.spacingM, AppTheme.spacingM, AppTheme.spacingM, 0),
                child: Container(
                  padding: const EdgeInsets.all(AppTheme.spacingM),
                  decoration: BoxDecoration(
                    color: Colors.green.withAlpha(20),
                    borderRadius: BorderRadius.circular(AppTheme.radiusM),
                    border: Border.all(color: Colors.green.withAlpha(60)),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.health_and_safety_rounded, color: Colors.green, size: 20),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          isAr
                              ? 'فلتر صحي نشط: ${avoidedKeywords.length} مكون مستبعد'
                              : 'Health filter active: ${avoidedKeywords.length} ingredients excluded',
                          style: const TextStyle(color: Colors.green, fontWeight: FontWeight.bold, fontSize: 12),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

          // AI Generate Button Box
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(AppTheme.spacingM),
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primary,
                  foregroundColor: Colors.white,
                  minimumSize: const Size(double.infinity, 54),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppTheme.radiusL)),
                  elevation: 8,
                  shadowColor: AppTheme.primary.withAlpha(100),
                ),
                onPressed: recipes.isGeneratingAiRecipes 
                  ? null 
                  : () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(isAr ? 'جاري ابتكار وصفات سحرية خصيصاً لك... يرجى الانتظار 🪄' : 'Crafting magical recipes just for you... Please wait 🪄'),
                          backgroundColor: AppTheme.primary,
                          behavior: SnackBarBehavior.floating,
                        ),
                      );
                      recipes.generateAiSuggestions(
                        pantryNames,
                        avoidedKeywords: health.profile.avoidedIngredientKeywords,
                        isDiabetic: health.profile.hasDiabetes,
                        isHypertensive: health.profile.hasHighBloodPressure,
                      );
                    },
                icon: recipes.isGeneratingAiRecipes
                  ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                  : const Icon(Icons.auto_awesome),
                label: Text(
                  isAr ? 'توليد وصفات ذكية 🪄' : 'Generate Smart Recipes 🪄',
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ),
          
          // AI Suggestions Banner (Main Meals)
          if (recipes.aiSuggestions.any((r) => r.category != 'Dessert')) ...[
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppTheme.spacingM, vertical: AppTheme.spacingS),
                child: Row(
                  children: [
                    const Icon(Icons.psychology, color: Colors.deepPurple, size: 24),
                    const SizedBox(width: 8),
                    Text(
                      isAr ? 'اقتراحات ذكية (وجبات)' : 'AI Smart Suggestions (Meals)',
                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.deepPurple),
                    ),
                  ],
                ),
              ),
            ),
            SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  final meals = recipes.aiSuggestions.where((r) => r.category != 'Dessert').toList();
                  final recipe = meals[index];
                  final matched = recipe.ingredients.where((ing) => pantryNames.any((p) => p.toLowerCase().contains(ing.toLowerCase()) || ing.toLowerCase().contains(p.toLowerCase()))).toList();
                  final missing = recipe.ingredients.where((ing) => !pantryNames.any((p) => p.toLowerCase().contains(ing.toLowerCase()) || ing.toLowerCase().contains(p.toLowerCase()))).toList();
                  final ratio = recipe.ingredients.isEmpty ? 0.0 : matched.length / recipe.ingredients.length;
                  return _buildMatchCard(recipe, matched, missing, ratio, context, lang, isAr, strings, isAiSuggestion: true);
                },
                childCount: recipes.aiSuggestions.where((r) => r.category != 'Dessert').length,
              ),
            ),
            const SliverToBoxAdapter(child: SizedBox(height: AppTheme.spacingM)),
          ],

          // AI Desserts Section
          if (recipes.aiSuggestions.any((r) => r.category == 'Dessert')) ...[
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppTheme.spacingM, vertical: AppTheme.spacingS),
                child: Row(
                  children: [
                    const Icon(Icons.icecream_rounded, color: Colors.pinkAccent, size: 24),
                    const SizedBox(width: 8),
                    Text(
                      isAr ? 'حلويات صحية ذكية' : 'Smart Healthy Desserts',
                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.pinkAccent),
                    ),
                  ],
                ),
              ),
            ),
            SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  final desserts = recipes.aiSuggestions.where((r) => r.category == 'Dessert').toList();
                  final recipe = desserts[index];
                  final matched = recipe.ingredients.where((ing) => pantryNames.any((p) => p.toLowerCase().contains(ing.toLowerCase()) || ing.toLowerCase().contains(p.toLowerCase()))).toList();
                  final missing = recipe.ingredients.where((ing) => !pantryNames.any((p) => p.toLowerCase().contains(ing.toLowerCase()) || ing.toLowerCase().contains(p.toLowerCase()))).toList();
                  final ratio = recipe.ingredients.isEmpty ? 0.0 : matched.length / recipe.ingredients.length;
                  return _buildMatchCard(recipe, matched, missing, ratio, context, lang, isAr, strings, isAiSuggestion: true);
                },
                childCount: recipes.aiSuggestions.where((r) => r.category == 'Dessert').length,
              ),
            ),
            const SliverToBoxAdapter(child: SizedBox(height: AppTheme.spacingM)),
          ],

          // Pantry Matches
          if (suggestions.isNotEmpty) ...[
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppTheme.spacingM, vertical: AppTheme.spacingS),
                child: Text(
                  isAr ? 'تطابقات المخزن' : 'Pantry Matches',
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
            ),
            SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  final entry = suggestions[index];
                  final recipe = entry['recipe'];
                  final matched = entry['matched'] as List<String>;
                  final missing = entry['missing'] as List<String>;
                  final ratio = entry['ratio'] as double;
                  
                  return _buildMatchCard(recipe, matched, missing, ratio, context, lang, isAr, strings);
                },
                childCount: suggestions.length,
              ),
            ),
          ] else if (recipes.aiSuggestions.isEmpty) ...[
            SliverFillRemaining(
              child: EmptyStateWidget(
                icon: Icons.lightbulb_outline_rounded,
                title: isAr ? 'لا توجد تطابقات' : 'No Suggestions',
                message: isAr 
                  ? 'أضف مكونات لمخزنك أو استخدم الزر أعلاه لتوليد وجبة'
                  : 'Add more ingredients to your pantry or tap above to generate recipes.',
              ),
            ),
          ],
          
          const SliverToBoxAdapter(child: SizedBox(height: 100)), // Bottom padding
        ],
      ),
    );
  }


  Widget _buildMatchCard(Recipe recipe, List<String> matched, List<String> missing, double ratio, BuildContext context, AppLang lang, bool isAr, AppStrings strings, {bool isAiSuggestion = false}) {
    final isPerfect = ratio == 1.0;
    
    // Dynamic fallback image for ANY recipe missing a photo
    final safeImageUrl = recipe.imageUrl ?? 'https://image.pollinations.ai/prompt/${Uri.encodeComponent('Delicious appetizing ${recipe.title} high quality restaurant food photography plating')}?width=800&height=500';
    
    return GestureDetector(
      onTap: () => Navigator.push(
        context, 
        MaterialPageRoute(builder: (_) => RecipeDetailsScreen(recipe: recipe, lang: lang))
      ),
      child: Container(
        margin: const EdgeInsets.only(left: AppTheme.spacingM, right: AppTheme.spacingM, bottom: AppTheme.spacingL),
        decoration: BoxDecoration(
          color: isDark(context) ? Theme.of(context).cardColor : Colors.white,
          borderRadius: BorderRadius.circular(AppTheme.radiusL),
          boxShadow: [
            BoxShadow(
              color: isAiSuggestion ? AppTheme.primary.withAlpha(isDark(context) ? 40 : 20) : (isDark(context) ? Colors.black.withAlpha(40) : Colors.black12),
              blurRadius: 20,
              spreadRadius: 2,
              offset: const Offset(0, 8),
            )
          ],
          border: isAiSuggestion 
            ? Border.all(color: Colors.amber.withAlpha(100), width: 1.5)
            : Border.all(color: isPerfect ? AppTheme.primary.withAlpha(150) : Colors.transparent, width: isPerfect ? 2 : 0),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image header
            Stack(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.vertical(top: Radius.circular(AppTheme.radiusL - (isAiSuggestion || isPerfect ? 2 : 0))),
                  child: Image.network(
                    safeImageUrl,
                    height: 160,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Container(
                      height: 160,
                      color: AppTheme.primary.withAlpha(20),
                      child: const Center(child: Icon(Icons.restaurant_rounded, size: 40, color: AppTheme.primary)),
                    ),
                  ),
                ),
                if (isAiSuggestion)
                  Positioned(
                    top: 12,
                    right: isAr ? 12 : null,
                    left: isAr ? null : 12,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.white.withAlpha(220),
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [BoxShadow(color: Colors.black.withAlpha(20), blurRadius: 4)],
                        border: Border.all(color: Colors.amber.shade300, width: 1),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.auto_awesome, color: Colors.amber, size: 14),
                          const SizedBox(width: 4),
                          Text(isAr ? 'مدعوم بالذكاء' : 'AI Powered', style: TextStyle(color: Colors.amber.shade800, fontSize: 10, fontWeight: FontWeight.bold)),
                        ],
                      ),
                    ),
                  ),
                  
                Positioned(
                  top: 12,
                  left: isAr ? 12 : null,
                  right: isAr ? null : 12,
                  child: Container(
                    decoration: BoxDecoration(
                      color: isDark(context) ? Colors.black.withAlpha(150) : Colors.white.withAlpha(220),
                      shape: BoxShape.circle,
                      boxShadow: [BoxShadow(color: Colors.black.withAlpha(20), blurRadius: 4)],
                    ),
                    child: IconButton(
                      icon: Icon(
                        recipe.isFavorite ? Icons.favorite_rounded : Icons.favorite_outline_rounded,
                        color: recipe.isFavorite ? Colors.redAccent : Colors.grey.shade500,
                        size: 22,
                      ),
                      onPressed: () {
                        context.read<RecipeProvider>().toggleFavorite(recipe.id);
                      },
                      constraints: const BoxConstraints(minWidth: 40, minHeight: 40),
                      padding: EdgeInsets.zero,
                    ),
                  ),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.all(AppTheme.spacingM),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(recipe.title, style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w800,
                          color: isDark(context) ? Colors.white : Colors.black87,
                        )),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                        decoration: BoxDecoration(
                          color: isAiSuggestion ? Colors.amber.withAlpha(30) : getStatusColor(ratio).withAlpha(30),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          '${(ratio * 100).toInt()}%',
                          style: TextStyle(color: isAiSuggestion ? Colors.amber.shade700 : getStatusColor(ratio), fontWeight: FontWeight.bold, fontSize: 14),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppTheme.spacingS),
                  LinearProgressIndicator(
                    value: ratio,
                    backgroundColor: isDark(context) ? Colors.white10 : Colors.black.withAlpha(10),
                    valueColor: AlwaysStoppedAnimation<Color>(isAiSuggestion ? Colors.amber : getStatusColor(ratio)),
                    borderRadius: BorderRadius.circular(10),
                    minHeight: 6,
                  ),
                  const SizedBox(height: AppTheme.spacingM),
                  
                  Text(
                    isAr ? 'المكونات المتوفرة:' : 'Matched Ingredients:',
                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: isDark(context) ? Colors.white70 : Colors.black54),
                  ),
                  const SizedBox(height: AppTheme.spacingXS),
                  Wrap(
                    spacing: 6,
                    runSpacing: 6,
                    children: matched.map((ing) => Chip(
                      label: Text(ing, style: TextStyle(fontSize: 11, color: isDark(context) ? Colors.white : Colors.black87, fontWeight: FontWeight.w600)),
                      backgroundColor: isAiSuggestion ? Colors.amber.withAlpha(20) : AppTheme.primary.withAlpha(20),
                      padding: EdgeInsets.zero,
                      visualDensity: VisualDensity.compact,
                      side: BorderSide.none,
                    )).toList(),
                  ),
                  
                  if (missing.isNotEmpty) ...[
                    const SizedBox(height: AppTheme.spacingM),
                    Text(
                      strings.missingIngredients(missing.length),
                      style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.redAccent.shade200),
                    ),
                    const SizedBox(height: AppTheme.spacingXS),
                    Wrap(
                      spacing: 6,
                      runSpacing: 4,
                      children: missing.map((ing) => Chip(
                        label: Text(ing, style: const TextStyle(fontSize: 11, color: Colors.redAccent)),
                        backgroundColor: Colors.redAccent.withAlpha(15),
                        padding: EdgeInsets.zero,
                        visualDensity: VisualDensity.compact,
                        side: BorderSide.none,
                      )).toList(),
                    ),
                    const SizedBox(height: AppTheme.spacingM),
                    Align(
                      alignment: isAr ? Alignment.centerLeft : Alignment.centerRight,
                      child: TextButton.icon(
                        icon: const Icon(Icons.add_shopping_cart, size: 16),
                        label: Text(
                          isAr ? 'إضافة النواقص للقائمة' : 'Add to Shopping List',
                          style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold),
                        ),
                        style: TextButton.styleFrom(
                          foregroundColor: AppTheme.accent,
                          backgroundColor: AppTheme.accent.withAlpha(20),
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                          minimumSize: Size.zero,
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        ),
                        onPressed: () {
                          final shopping = context.read<ShoppingListProvider>();
                          for (final ing in missing) {
                            shopping.addItem(ing, 1, 'pcs', 'Missing from ${recipe.title}');
                          }
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(isAr ? 'تم إضافة ${missing.length} مكونات للقائمة 🛒' : 'Added ${missing.length} items to shopping list 🛒'),
                              backgroundColor: AppTheme.primary,
                              behavior: SnackBarBehavior.floating,
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  bool isDark(BuildContext context) => Theme.of(context).brightness == Brightness.dark;
  
  Color getStatusColor(double ratio) {
    if (ratio >= 0.8) return AppTheme.primary;
    if (ratio >= 0.5) return AppTheme.secondary;
    return Colors.orangeAccent;
  }
}
