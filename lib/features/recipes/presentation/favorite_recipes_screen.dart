import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/theme/app_theme.dart';
import '../../../shared/widgets/app_scaffold.dart';
import '../../../shared/widgets/empty_state.dart';
import '../../recipes/logic/recipe_provider.dart';
import 'recipe_details_screen.dart';

class FavoriteRecipesScreen extends StatelessWidget {
  final AppLang lang;

  const FavoriteRecipesScreen({super.key, required this.lang});

  @override
  Widget build(BuildContext context) {
    final isAr = lang == AppLang.ar;
    final recipesProv = context.watch<RecipeProvider>();
    final favorites = recipesProv.favoriteRecipes;

    return AppScaffold(
      title: isAr ? 'وصفاتي المفضلة ❤️' : 'My Favorites ❤️',
      body: favorites.isEmpty
          ? EmptyStateWidget(
              icon: Icons.heart_broken_rounded,
              title: isAr ? 'لا توجد وصفات مفضلة' : 'No Favorites Yet',
              message: isAr
                  ? 'لم تقم بحفظ أي وصفة. انقر على القلب بجوار الوصفة لإضافتها هنا!'
                  : 'You haven\'t pinned any recipes yet. Tap the heart icon to save one here!',
            )
          : ListView.builder(
              padding: const EdgeInsets.only(top: AppTheme.spacingM, bottom: 40),
              itemCount: favorites.length,
              itemBuilder: (context, index) {
                final recipe = favorites[index];
                final isDynamicImage = recipe.id.startsWith('ai_');
                
                return GestureDetector(
                  onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => RecipeDetailsScreen(recipe: recipe, lang: lang))),
                  child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: AppTheme.spacingM, vertical: AppTheme.spacingS),
                    height: 120, // Clean horizontal card
                    decoration: BoxDecoration(
                      color: Theme.of(context).cardColor,
                      borderRadius: BorderRadius.circular(AppTheme.radiusL),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withAlpha(isDark(context) ? 40 : 10),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        // Left Image
                        ClipRRect(
                          borderRadius: BorderRadius.horizontal(
                              left: isAr ? Radius.zero : const Radius.circular(AppTheme.radiusL),
                              right: isAr ? const Radius.circular(AppTheme.radiusL) : Radius.zero),
                          child: Stack(
                            children: [
                              Image.network(
                                recipe.imageUrl ?? 'https://image.pollinations.ai/prompt/${Uri.encodeComponent('Delicious appetizing ${recipe.title} high quality restaurant food photography plating')}?width=300&height=300',
                                width: 120,
                                height: 120,
                                fit: BoxFit.cover,
                                errorBuilder: (_, __, ___) => Container(
                                  width: 120,
                                  height: 120,
                                  color: AppTheme.primary.withAlpha(20),
                                  child: const Icon(Icons.fastfood, color: AppTheme.primary),
                                ),
                              ),
                              if (isDynamicImage)
                                Positioned(
                                  top: 4,
                                  left: 4,
                                  child: Container(
                                    padding: const EdgeInsets.all(4),
                                    decoration: BoxDecoration(
                                      color: Colors.black.withAlpha(150),
                                      shape: BoxShape.circle,
                                    ),
                                    child: const Icon(Icons.auto_awesome, color: Colors.amber, size: 12),
                                  ),
                                ),
                            ],
                          ),
                        ),
                        
                        // Right Content
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.all(AppTheme.spacingM),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  recipe.title,
                                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 6),
                                Row(
                                  children: [
                                    const Icon(Icons.local_fire_department, size: 14, color: AppTheme.secondary),
                                    const SizedBox(width: 4),
                                    Text('${recipe.calories} kcal', style: const TextStyle(fontSize: 12, color: Colors.grey)),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),

                        // Action Button
                        IconButton(
                          icon: const Icon(Icons.favorite_rounded, color: Colors.redAccent),
                          onPressed: () => recipesProv.toggleFavorite(recipe.id),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }

  bool isDark(BuildContext context) => Theme.of(context).brightness == Brightness.dark;
}
