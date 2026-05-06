import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'core/services/local_storage_service.dart';
import 'core/theme/app_theme.dart';
import 'core/constants/app_strings.dart';

import 'core/utils/snackbar_helper.dart';

// Providers
import 'features/auth/logic/auth_provider.dart';
import 'features/settings/logic/theme_provider.dart';
import 'features/settings/logic/lang_provider.dart';
import 'features/pantry/logic/pantry_provider.dart';
import 'features/recipes/logic/recipe_provider.dart';
import 'features/meal_planner/logic/meal_plan_provider.dart';
import 'features/shopping/logic/shopping_provider.dart';
import 'features/history/logic/cooking_history_provider.dart';
import 'features/health/logic/health_provider.dart';
import 'features/community/logic/feed_provider.dart';


// Screens
import 'features/auth/presentation/login_screen.dart';
import 'features/splash/presentation/splash_screen.dart';
import 'screens/main_shell.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  await LocalStorageService.init();
  runApp(const FitKitchenApp());
}

class FitKitchenApp extends StatelessWidget {
  const FitKitchenApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider(create: (_) => LangProvider()),
        ChangeNotifierProvider(create: (_) => PantryProvider()),
        ChangeNotifierProvider(create: (_) => RecipeProvider()),
        ChangeNotifierProvider(create: (_) => MealPlanProvider()),
        ChangeNotifierProvider(create: (_) => ShoppingListProvider()),
        ChangeNotifierProvider(create: (_) => CookingHistoryProvider()),
        ChangeNotifierProvider(create: (_) => HealthProvider()),
        ChangeNotifierProvider(create: (_) => FeedProvider()),
      ],
      child: Consumer3<AuthProvider, ThemeProvider, LangProvider>(
        builder: (context, auth, theme, langProvider, child) {
          final lang = langProvider.lang;

          // Bind all data providers to the current user when logged in
          if (auth.isLoggedIn && auth.uid != null) {
            final uid = auth.uid!;
            context.read<PantryProvider>().bindUser(uid);
            context.read<ShoppingListProvider>().bindUser(uid);
            context.read<CookingHistoryProvider>().bindUser(uid);
            context.read<HealthProvider>().bindUser(uid);
            context.read<RecipeProvider>().bindUser(uid);
            context.read<FeedProvider>().bindUser(uid, auth.userName ?? 'User', auth.userImageUrl);
            context.read<MealPlanProvider>().bindUser(uid, context.read<RecipeProvider>().allRecipes);
          }

          return MaterialApp(
            scaffoldMessengerKey: SnackbarHelper.key,
            title: 'FitKitchen',
            debugShowCheckedModeBanner: false,
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            themeMode: theme.themeMode,
            builder: (context, child) {
              return Directionality(
                textDirection: lang == AppLang.ar ? TextDirection.rtl : TextDirection.ltr,
                child: child!,
              );
            },
            home: auth.isInitializing
                ? const SplashScreen()
                : auth.isLoggedIn
                    ? MainShell(lang: lang)
                    : LoginScreen(lang: lang, onToggleLang: () => langProvider.toggle()),
          );
        },
      ),
    );
  }
}
