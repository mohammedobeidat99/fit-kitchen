import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:fit_kitchen_demo/main.dart';
import 'package:fit_kitchen_demo/features/pantry/logic/pantry_provider.dart';
import 'package:fit_kitchen_demo/features/recipes/logic/recipe_provider.dart';
import 'package:fit_kitchen_demo/features/health/logic/health_provider.dart';
import 'package:fit_kitchen_demo/features/meal_planner/logic/meal_plan_provider.dart';
import 'package:fit_kitchen_demo/features/shopping/logic/shopping_provider.dart';
import 'package:fit_kitchen_demo/features/history/logic/cooking_history_provider.dart';

void main() {
  testWidgets('App launches without crashing', (WidgetTester tester) async {
    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => PantryProvider()),
          ChangeNotifierProvider(create: (_) => RecipeProvider()),
          ChangeNotifierProvider(create: (_) => HealthProvider()),
          ChangeNotifierProvider(create: (_) => MealPlanProvider()),
          ChangeNotifierProvider(create: (_) => ShoppingListProvider()),
          ChangeNotifierProvider(create: (_) => CookingHistoryProvider()),
        ],
        child: const FitKitchenApp(),
      ),
    );

    expect(find.text('FitKitchen'), findsOneWidget);
  });
}
