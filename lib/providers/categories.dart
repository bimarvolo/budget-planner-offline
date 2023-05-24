import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:http/http.dart' as http;
import 'package:money_budget_frontend_offile/providers/metadata.dart';
import 'package:provider/provider.dart';

import '../app_constant.dart';
import '../models/http_exception.dart';
import './category.dart';
import 'budget.dart';

class Categories with ChangeNotifier {
  List<Category> _items = [];

  Categories(this._items);

  List<Category> get items {
    if (_items != null) {
      return [..._items];
    }

    return [];
  }

  void setItems(List<Category> list) {
    _items = list;
    notifyListeners();
  }

  clearData() {
    _items = [];
    notifyListeners();
  }

  List<Category> get expensiveCategories {
    return _items.where((cate) => cate.type == 'expensive').toList();
  }

  List<Category> get incomeCategories {
    return _items.where((cate) => cate.type == 'income').toList();
  }

  Category findById(String id) {
    return _items.firstWhere((cate) => cate.id == id);
  }

  Future<void> addCategory(Category category) async {
    _items.add(category);
    notifyListeners();
  }

  Future<void> updateCategory(String id, Category newCategory) async {
    // final prodIndex = _items.indexWhere((prod) => prod.id == id);
    // if (prodIndex >= 0) {
    //   final url = '${AppConst.BASE_URL}/category/$id';
    //   await http.patch(Uri.parse(url),
    //       headers: {
    //         HttpHeaders.authorizationHeader: authToken,
    //       },
    //       body: json.encode({
    //         'type': newCategory.type,
    //         'description': newCategory.description,
    //         'volume': newCategory.volume,
    //         'totalSpent': newCategory.totalSpent,
    //       }));
    //   _items[prodIndex] = newCategory;
    //   notifyListeners();
    // } else {}
  }

  Future<bool> deleteCategory(Category cate) async {
    _items.remove(cate);
    notifyListeners();
    return true;
  }

  void increaseTotalSpent(String categoryId, double volume) {
    var existed = findById(categoryId);
    existed.totalSpent = existed.totalSpent + volume;
    notifyListeners();
  }

  void decreaseTotalSpent(String categoryId, double volume) {
    var existed = findById(categoryId);
    existed.totalSpent = existed.totalSpent - volume;
    notifyListeners();
  }
}
