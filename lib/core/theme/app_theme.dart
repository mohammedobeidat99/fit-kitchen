import 'package:flutter/material.dart';

class AppTheme {
  static const Color primary = Color(0xFF3BB89C);
  static const Color secondary = Color(0xFF5C6BC0);
  static const Color accent = Color(0xFFFF7043);
  
  static const double spacingXS = 4.0;
  static const double spacingS = 8.0;
  static const double spacingM = 16.0;
  static const double spacingL = 24.0;
  static const double spacingXL = 32.0;
  
  static const double radiusM = 12.0;
  static const double radiusL = 24.0;
  static const double radiusXL = 32.0;

  // AI Design Tokens
  static const List<Color> primaryGradient = [Color(0xFF3BB89C), Color(0xFF2E7D32)];
  static const List<Color> accentGradient = [Color(0xFFFF7043), Color(0xFFD84315)];
  static const List<Color> glassGradient = [Colors.white12, Colors.white10];
  
  static BoxDecoration glassDecoration(BuildContext context) => BoxDecoration(
    color: Theme.of(context).brightness == Brightness.light 
        ? Colors.white.withAlpha(150) 
        : const Color(0xFF1E293B).withAlpha(150), // Premium Slate Glass
    borderRadius: BorderRadius.circular(radiusL),
    border: Border.all(color: Colors.white.withAlpha(50)),
  );

  static Color getCardColor(BuildContext context) => Theme.of(context).cardColor;
  static Color getSubtitleColor(BuildContext context) => Theme.of(context).textTheme.bodySmall?.color ?? Colors.grey;

  static ThemeData get lightTheme => ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    colorScheme: ColorScheme.fromSeed(seedColor: primary, brightness: Brightness.light),
    scaffoldBackgroundColor: const Color(0xFFF8F9FA),
    cardTheme: CardThemeData(
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(radiusL)),
    ),
  );

  static ThemeData get darkTheme => ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    colorScheme: ColorScheme.fromSeed(seedColor: primary, brightness: Brightness.dark),
    scaffoldBackgroundColor: const Color(0xFF0F172A), // Premium Deep Slate/Navy Background
    cardColor: const Color(0xFF1E293B), // Premium Slate Card
    cardTheme: CardThemeData(
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(radiusL)), // Better uniformity
    ),
  );
}
