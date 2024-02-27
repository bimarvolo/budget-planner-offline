import 'package:flutter/material.dart';

import './category.dart';

class Categories with ChangeNotifier {
  List<Category> _items = [];

  Categories(this._items);

  List<Category> get items {
    return [..._items];
  }

  void setItems(List<Category> list, {bool notify = false}) {
    _items = list.map((element) {
      if (element.iconDataString != null) {
        element.iconData = IconData(int.parse(element.iconDataString!),
            fontFamily: 'MaterialIcons');
      }
      return element;
    }).toList();

    _items = list;

    if (notify) notifyListeners();
  }

  clearData() {
    _items = [];
    notifyListeners();
  }

  List<Category> get expensiveCategories {
    print("get expensive categories ...");
    return _items.where((cate) => cate.type == 'expensive').toList();
  }

  List<Category> get incomeCategories {
    print("get income categories ...");

    return _items.where((cate) => cate.type == 'income').toList();
  }

  Category findById(String id) {
    return _items.firstWhere((cate) => cate.id == id);
  }

  Future<void> addCategory(Category category) async {
    _items.add(category);
    notifyListeners();
  }

  Future<bool> deleteCategory(Category cate) async {
    _items.remove(cate);
    notifyListeners();
    return true;
  }

  void localIncreaseTotalSpent(String categoryId, double volume) {
    var existed = findById(categoryId);
    existed.totalSpent = existed.totalSpent + volume;

    notifyListeners();
  }

  void decreaseTotalSpent(String categoryId, double volume) {
    var existed = findById(categoryId);
    existed.totalSpent = existed.totalSpent - volume;
    notifyListeners();
  }

  void notifyDataChange() {
    notifyListeners();
  }
}
