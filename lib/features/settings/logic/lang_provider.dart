import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../core/constants/app_strings.dart';

/// A proper ChangeNotifier for language so all screens
/// rebuild reactively when the user switches language.
class LangProvider extends ChangeNotifier {
  AppLang _lang = AppLang.en;
  AppLang get lang => _lang;
  bool get isAr => _lang == AppLang.ar;

  LangProvider() {
    _load();
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    final code = prefs.getString('app_lang') ?? 'en';
    _lang = code == 'ar' ? AppLang.ar : AppLang.en;
    notifyListeners();
  }

  Future<void> toggle() async {
    _lang = _lang == AppLang.en ? AppLang.ar : AppLang.en;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('app_lang', _lang == AppLang.ar ? 'ar' : 'en');
  }
}
