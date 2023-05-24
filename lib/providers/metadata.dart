import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'dart:io';

import '../app_constant.dart';

class Metadata with ChangeNotifier {
  int? currentBudget;
  String? language;
  String? currency = 'en';
  String? themeMode;

  Metadata({this.currentBudget, this.language, this.currency, this.themeMode});

  Map<String, String?> toJson() {
    return {
      'currentBudget': this.currentBudget.toString(),
      'language': this.language,
      'currency': this.currency,
      'themeMode': this.themeMode,
    };
  }

  syncMetadata(lang, cu, curentB, theme) {
    this.language = lang;
    this.currency = cu;
    this.currentBudget = curentB;
    this.themeMode = theme;
    notifyListeners();
  }

  setLanguage(lang, {isSave = true}) async {
    this.language = lang;
    if (isSave) await saveMetadata();
    notifyListeners();
  }

  setCurrentBudget(budget, {isSave = true}) async {
    this.currentBudget = budget;
    if (isSave) await saveMetadata();
    notifyListeners();
  }

  setCurrency(cu, {isSave = true}) async {
    this.currency = cu;
    if (isSave) await saveMetadata();
    notifyListeners();
  }

  Future<void> setThemeMode(mode, {isSave = true}) async {
    this.themeMode = mode;
    if (isSave) await saveMetadata();
    notifyListeners();
  }

  @override
  String toString() {
    return 'currentBudget: ${this.currentBudget} language: ${this.language} currency: ${this.currency} themeMode: ${this.themeMode}';
  }

  Future<void> saveMetadata() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userData = json.encode(
        {
          'metadata': new Metadata(
            currentBudget: this.currentBudget,
            language: this.language,
            currency: this.currency,
            themeMode: this.themeMode,
          ),
        },
      );
      prefs.setString('userData', userData);
    } catch (err) {
      print(err);
    }
  }
}
