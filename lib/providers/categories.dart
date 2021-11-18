import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../app_constant.dart';
import '../models/http_exception.dart';
import './category.dart';

class Categories with ChangeNotifier {
  List<Category> _items = [
  ];
  // var _showFavoritesOnly = false;
  final String authToken;
  final String userId;

  Categories(this.authToken, this.userId, this._items);

  List<Category> get items {
    if(_items != null) {
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
    if(_items != null)
      return _items.where((cate) => cate.type == 'expensive').toList();

    return [];
  }

  List<Category> get incomeCategories {
    return _items.where((cate) => cate.type == 'income').toList();
  }

  Category findById(String id) {
    return _items.firstWhere((cate) => cate.id == id, orElse: () => null);
  }

  // Future<void> fetchAndSetCategories() async {
  //   var url = '${AppConst.BASE_URL}/category?userId=$userId';
  //   try {
  //     final response = await http.get(url,
  //       headers: { HttpHeaders.authorizationHeader: authToken, },
  //     );
  //     final extractedData = json.decode(response.body);
  //     if (extractedData == null) {
  //       return;
  //     }
  //
  //     final List<Category> loadedCategories = [];
  //     extractedData.forEach((cateData) {
  //       loadedCategories.add(Category(
  //         id: cateData['id'],
  //         budgetId: cateData['budgetId'],
  //         description : cateData['description'],
  //         type: cateData['type'],
  //         volume: cateData['volume'].toDouble(),
  //         totalSpent: cateData['totalSpent'].toDouble(),
  //         iconData: cateData['iconData'] != null ? cateData['iconData'] : Icons.category // test
  //       ));
  //     });
  //
  //     _items = loadedCategories;
  //     notifyListeners();
  //   } catch (error) {
  //     throw (error);
  //   }
  // }

  Future<void> addCategory(Category category) async {
    final url = '${AppConst.BASE_URL}/category';
    var response;
    try {
      response = await http.post(
        Uri.parse(url),
        headers: { HttpHeaders.authorizationHeader: authToken, },
        body: json.encode(
          {
            'userId': userId,
            'budgetId': category.budgetId,
            'type': category.type,
            'description': category.description,
            'volume': category.volume,
            'totalSpent': 0.0,
            'iconData': category.iconData.codePoint.toString()
          },
        ),
      );

      if(response!= null && response.statusCode < 400) {
        final newCategory = Category(
          type: category.type,
          description: category.description,
          volume: category.volume,
          totalSpent: 0.0,
          budgetId: category.budgetId,
          id: json.decode(response.body)['id'],
          iconData: category.iconData,
        );
        _items.add(newCategory);
        notifyListeners();
      } else {
        print(response.toString());
        throw 'An error occur';
      }

    } catch (error) {
      print(error);
      throw error;
    }
  }

  Future<void> updateCategory(String id, Category newCategory) async {
    final prodIndex = _items.indexWhere((prod) => prod.id == id);
    if (prodIndex >= 0) {
      final url = '${AppConst.BASE_URL}/category/$id';
      await http.patch(Uri.parse(url),
          headers: { HttpHeaders.authorizationHeader: authToken, },
          body: json.encode({
            'type': newCategory.type,
            'description': newCategory.description,
            'volume': newCategory.volume,
            'totalSpent': newCategory.totalSpent,
          }));
      _items[prodIndex] = newCategory;
      notifyListeners();
    } else {
    }
  }

  Future<bool> deleteCategory(String id) async {
    final url = '${AppConst.BASE_URL}/category/$id';
    final existingCategoryIndex = _items.indexWhere((prod) => prod.id == id);
    var existingCategory = _items[existingCategoryIndex];
    _items.removeAt(existingCategoryIndex);
    notifyListeners();

    try {
      final response = await http.delete(Uri.parse(url), headers: { HttpHeaders.authorizationHeader: authToken, },);
      if (response.statusCode >= 400) {
        _items.insert(existingCategoryIndex, existingCategory);
        notifyListeners();
        existingCategory = null;
        return false;
      } else {
        return true;
      }
    } catch (e) {
      _items.insert(existingCategoryIndex, existingCategory);
      notifyListeners();
      existingCategory = null;
      throw e;
    }
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
