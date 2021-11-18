import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:money_budget_frontend/providers/metadata.dart';
import 'package:provider/provider.dart';

import '../providers/category.dart';
import '../app_constant.dart';
import '../models/http_exception.dart';
import './budget.dart';
import 'auth.dart';

class Budgets with ChangeNotifier {
  List<Budget> _items = [];
  final String authToken;
  final String userId;

  Budgets(this.authToken, this.userId, this._items);

  List<Budget> get items {
    return [..._items];
  }

  Budget findById(String id) {
    if(id == '' || id == null || id == 'undefined' || _items.length == 0)
      return null;

    return _items.firstWhere((bud) => bud.id == id, orElse: () => null);
  }

  DateTime findFirstDateOfTheMonth() {
    var now = DateTime.now();
    return new DateTime(now.year, now.month + 1, 0);
  }

  DateTime findLastDateOfTheMonth() {
    var now = DateTime.now();
    return new DateTime(now.year, now.month, 0);
  }

  Future<bool> testDelay() {
    return Future<bool>.delayed(
      const Duration(seconds: 2),
          () => true,
    );
  }

  clearData() {
    _items = [];
    notifyListeners();
  }

  Future<bool> fetchAndSetBudgets() async {

    if(_items.length > 0) {
      print('MONEY >> already fetch budgets');
      return true;
    }

    var url = '${AppConst.BASE_URL}/budgets?userId=$userId';
    try {
      final response = await http.get(Uri.parse(url),
        headers: {
          HttpHeaders.authorizationHeader: authToken,
        },
      );

      if(response.body == null) {
        return false;
      }

      final extractedData = json.decode(response.body);
      if (extractedData == null) {
        return false;
      }


      final List<Budget> loadedBudgets = [];
      extractedData['budgets'].forEach((budData) {
        List<Category> loadedCategories = [];
        budData['categories'].forEach((cate) {
          print(cate['iconData']);
          IconData data = Icons.category;
          if (cate['iconData'] != null && cate['iconData'] != "") {
            data = IconData(int.parse(cate['iconData']), fontFamily: 'MaterialIcons');
          }
          loadedCategories.add(Category(
            id: cate['id'],
            budgetId: cate['budgetId'],
            type: cate['type'],
            volume: cate['volume'].toDouble(),
            description: cate['description'],
            totalSpent: cate['totalSpent'].toDouble(),
            iconData: data
          ));
        });

        loadedBudgets.add(Budget(
          id: budData['id'],
          title: budData['title'],
          startDate: DateTime.parse(budData['startDate']),
          endDate: DateTime.parse(budData['endDate']),
          categories: loadedCategories,
        ));
      });

      _items = loadedBudgets;
      return true;
    } catch (error) {
      print(error);
      return false;
    }
  }

  Future<Budget> addBudget(Budget budget) async {
    final url ='${AppConst.BASE_URL}/budget';
    try {
      final response = await http.post(
        Uri.parse(url),
        headers: { HttpHeaders.authorizationHeader: authToken, },
        body: json.encode(
          {
            'userId': userId,
            'startDate': budget.startDate.toUtc().toIso8601String(),
            'endDate': budget.endDate.toUtc().toIso8601String(),
            'title': budget.title,
          },
        ),
      );

      List<Category> newCategories = [];
      if (budget.categories.length > 0) {
        for (var cate in budget.categories) {
          final response2 = await http.post(
              Uri.parse('${AppConst.BASE_URL}/category'),
            headers: {
              HttpHeaders.authorizationHeader: authToken,
            },
            body: json.encode(
              {
                'userId': userId,
                'budgetId': json.decode(response.body)['id'],
                'type': cate.type,
                'description': cate.description,
                'volume': cate.volume,
                'iconData': cate.iconData.codePoint.toString(),
                'totalSpent': 0.0
              },
            ),
          );

          var data = json.decode(response2.body);
          newCategories.add(Category(
            budgetId: json.decode(response.body)['id'],
            totalSpent: data['totalSpent'].toDouble(),
            volume: data['volume'].toDouble(),
            type: data['type'],
            description: data['description'],
            iconData: cate.iconData,
            id: data['id'],
          ));
        }
      }

      final newBudget = Budget(
        title: budget.title != null
            ? budget.title
            : '${DateFormat.MMMd().format(budget.startDate)} - ${DateFormat.MMMd().format(budget.endDate)}',
        startDate: budget.startDate,
        endDate: budget.endDate,
        id: json.decode(response.body)['id'],
        categories: newCategories,
      );
      _items.add(newBudget);
      // _items.insert(0, newBudget); // at the start of the list
      notifyListeners();

      return newBudget;
    } catch (error) {
      print(error);
      throw error;
    }
  }

  Future<void> updateBudget(String id, Budget newBudget) async {
    final budIndex = _items.indexWhere((bud) => bud.id == id);
    if (budIndex >= 0) {
      final url ='${AppConst.BASE_URL}/budget/$id';
      await http.patch(Uri.parse(url),
          headers: { HttpHeaders.authorizationHeader: authToken, },
          body: json.encode({
            'title': newBudget.title,
            'startDate': newBudget.startDate,
            'endDate': newBudget.endDate,
          }));
      _items[budIndex] = newBudget;
      notifyListeners();
    } else {
    }
  }

  Future<bool> deleteBudget(String id) async {
    final url = '${AppConst.BASE_URL}/budget/$id';
    final existingBudgetIndex = _items.indexWhere((bud) => bud.id == id);
    var existingBudget = _items[existingBudgetIndex];
    _items.removeAt(existingBudgetIndex);
    notifyListeners();
    try {
      final response = await http.delete(
        Uri.parse(url), headers: { HttpHeaders.authorizationHeader: authToken,},);

      if (response.statusCode >= 400) {
        _items.insert(existingBudgetIndex, existingBudget);
        notifyListeners();
        return false;
      }

      existingBudget = null;
      return true;
    } catch (e) {
      _items.insert(existingBudgetIndex, existingBudget);
      notifyListeners();
      return false;
    }


  }
}
