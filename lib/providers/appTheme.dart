import 'package:flutter/material.dart';

class AppTheme with ChangeNotifier {
  late String themeMode;
  late String language;

  AppTheme({required this.themeMode, required this.language});

  Future<void> setThemeMode(mode) async {
    this.themeMode = mode;
    notifyListeners();
  }

  Future<void> setLanguage(lang) async {
    this.language = lang;
    notifyListeners();
  }
}
