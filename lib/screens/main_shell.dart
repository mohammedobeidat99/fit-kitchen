import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/constants/app_strings.dart';
import '../core/theme/app_theme.dart';
import '../features/settings/logic/lang_provider.dart';
import '../features/home/presentation/home_screen.dart';
import '../features/pantry/presentation/pantry_screen.dart';
import '../features/recipes/presentation/meal_suggestions_screen.dart';
import '../features/meal_planner/presentation/weekly_planner_screen.dart';
import '../features/shopping/presentation/shopping_list_screen.dart';
import '../features/settings/presentation/settings_screen.dart';
import '../features/community/presentation/feed_screen.dart';


class MainShell extends StatefulWidget {
  final AppLang lang;

  const MainShell({super.key, required this.lang});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    // Always read from LangProvider so any toggle instantly rebuilds
    final lang = context.watch<LangProvider>().lang;
    final strings = AppStrings(lang);
    final isAr = lang == AppLang.ar;

    final List<Widget> screens = [
      HomeScreen(lang: lang, onNavigate: (index) => setState(() => _currentIndex = index)),
      PantryScreen(lang: lang),
      MealSuggestionsScreen(lang: lang),
      const FeedScreen(),
      WeeklyPlannerScreen(lang: lang),
      ShoppingListScreen(lang: lang),
    ];

    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: screens,
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: Colors.black.withAlpha(20),
              blurRadius: 20,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: (index) => setState(() => _currentIndex = index),
          type: BottomNavigationBarType.fixed,
          backgroundColor: AppTheme.getCardColor(context),
          selectedItemColor: AppTheme.primary,
          unselectedItemColor: Colors.grey,
          selectedFontSize: 12,
          unselectedFontSize: 12,
          items: [
            BottomNavigationBarItem(
              icon: const Icon(Icons.dashboard_rounded),
              label: isAr ? 'الرئيسية' : 'Home',
            ),
            BottomNavigationBarItem(
              icon: const Icon(Icons.kitchen_rounded),
              label: strings.pantry,
            ),
            BottomNavigationBarItem(
              icon: const Icon(Icons.lightbulb_outline_rounded),
              label: isAr ? 'اقتراحات' : 'Ideas',
            ),
            BottomNavigationBarItem(
              icon: const Icon(Icons.people_rounded),
              label: isAr ? 'المجتمع' : 'Community',
            ),
            BottomNavigationBarItem(
              icon: const Icon(Icons.calendar_today_rounded),
              label: strings.planner,
            ),
            BottomNavigationBarItem(
              icon: const Icon(Icons.shopping_cart_rounded),
              label: strings.shopping,
            ),
          ],
        ),
      ),
    );
  }
}
