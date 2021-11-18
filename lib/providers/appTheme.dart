import 'package:flutter/material.dart';

class AppTheme with ChangeNotifier {
  String themeMode;
  String language;

  AppTheme({
    this.themeMode,
    this.language
  });

  Future<void> setThemeMode(mode) async {
    this.themeMode = mode;
    notifyListeners();
  }

  Future<void> setLanguage(lang) async {
    this.language = lang;
    notifyListeners();
  }

}