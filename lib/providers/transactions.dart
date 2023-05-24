import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:http/http.dart' as http;

import '../app_constant.dart';
import '../models/http_exception.dart';
import './transaction.dart';
import 'budget.dart';

class Transactions with ChangeNotifier {
  List<Transaction> _items = [];
  String? categoryId;

  Transactions(this._items);

  List<Transaction> get items {
    if (_items != null) {
      return [..._items];
    }

    return [];
  }

  void setItems(List<Transaction> list) {
    _items = list;
    _items.sort((a, b) => b.date.compareTo(a.date));
    notifyListeners();
  }

  Transaction findById(String id) {
    return _items.firstWhere((cate) => cate.id == id);
  }

  Future<void> fetchAndSetExpensive(String categoryId) async {
    Box<Transaction> transBox = Hive.box<Transaction>('transactions');

    final List<Transaction> loadedTransactions = [];
    transBox.values.forEach((element) {
      loadedTransactions.add(element);
    });

    _items = loadedTransactions;
    _items.sort((a, b) => b.date.compareTo(a.date));
    // notifyListeners();
    // } catch (error) {
    //   throw (error);
    // }
  }

  Future<void> addTransaction(Transaction transaction) async {
    Box<Transaction> transBox = Hive.box<Transaction>('transactions');

    transBox.put(transaction.id, transaction);
    _items.add(transaction);
    notifyListeners();

    // final url = '${AppConst.BASE_URL}/transactions';
    // try {
    //   final response = await http.post(
    //     Uri.parse(url),
    //     headers: {
    //       HttpHeaders.authorizationHeader: authToken,
    //     },
    //     body: json.encode(
    //       {
    //         'userId': userId,
    //         'categoryId': transaction.categoryId,
    //         'description': transaction.description,
    //         'volume': transaction.volume,
    //         'date': transaction.date.toUtc().toIso8601String()
    //       },
    //     ),
    //   );

    //   final newTransaction = Transaction(
    //     description: transaction.description,
    //     volume: transaction.volume,
    //     categoryId: transaction.categoryId,
    //     date: transaction.date,
    //     id: json.decode(response.body)['trans']['id'],
    //   );
    //   _items.add(newTransaction);
    //   notifyListeners();
    // } catch (error) {
    //   print(error);
    //   throw error;
    // }
  }

  Future<void> updateTransaction(Transaction newTransaction) async {
    // final transIndex =
    //     _items.indexWhere((trans) => trans.id == newTransaction.id);
    // try {
    //   if (transIndex >= 0) {
    //     final url = '${AppConst.BASE_URL}/transaction/${newTransaction.id}';

    //     await http.patch(Uri.parse(url),
    //         headers: {
    //           HttpHeaders.authorizationHeader: authToken,
    //         },
    //         body: json.encode({
    //           'description': newTransaction.description,
    //           'volume': newTransaction.volume,
    //           'date': newTransaction.date.toUtc().toIso8601String(),
    //           'categoryId': newTransaction.categoryId,
    //         }));
    //     _items[transIndex] = newTransaction;
    //     notifyListeners();
    //   } else {}
    // } catch (err) {
    //   print(err);
    //   throw err;
    // }
  }

  Future<bool> deleteTransaction(String id) async {
    return false;
    // final url = '${AppConst.BASE_URL}/transaction/$id';
    // final existingTransIndex = _items.indexWhere((ex) => ex.id == id);
    // Transaction? existingTransaction = _items[existingTransIndex];
    // _items.removeAt(existingTransIndex);
    // notifyListeners();

    // try {
    //   final response = await http.delete(
    //     Uri.parse(url),
    //     headers: {
    //       HttpHeaders.authorizationHeader: authToken,
    //     },
    //   );

    //   if (response.statusCode >= 400) {
    //     _items.insert(existingTransIndex, existingTransaction);
    //     notifyListeners();
    //     existingTransaction = null;
    //     return false;
    //   } else {
    //     existingTransaction = null;
    //     return true;
    //   }
    // } catch (e) {
    //   _items.insert(existingTransIndex, existingTransaction!);
    //   notifyListeners();
    //   existingTransaction = null;
    //   throw e;
    // }
  }

  void localDeleteTransaction(String id) {
    final existingTransIndex = _items.indexWhere((ex) => ex.id == id);
    _items.removeAt(existingTransIndex);
    notifyListeners();
  }
}
