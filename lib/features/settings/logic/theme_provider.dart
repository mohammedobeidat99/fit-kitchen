import 'package:flutter/material.dart';
import '../../../core/services/local_storage_service.dart';

class ThemeProvider extends ChangeNotifier {
  bool _isDarkMode = false;
  bool get isDarkMode => _isDarkMode;

  ThemeProvider() {
    _loadTheme();
  }

  void _loadTheme() {
    _isDarkMode = LocalStorageService.getBool(LocalStorageService.keyDarkMode);
    notifyListeners();
  }

  void toggleTheme() async {
    _isDarkMode = !_isDarkMode;
    await LocalStorageService.setBool(LocalStorageService.keyDarkMode, _isDarkMode);
    notifyListeners();
  }

  ThemeMode get themeMode => _isDarkMode ? ThemeMode.dark : ThemeMode.light;
}
