import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../app_constant.dart';
import '../models/http_exception.dart';
import './transaction.dart';

class Transactions with ChangeNotifier {
  List<Transaction> _items = [
  ];

  final String authToken;
  final String userId;
  String categoryId;

  Transactions(this.authToken, this.userId, this._items);

  List<Transaction> get items {
    if(_items != null) {
      return [..._items];
    }

    return [];

  }

  void setItems(List<Transaction> list) {
    _items = list;
    _items.sort((a,b)=> b.date.compareTo(a.date));
    notifyListeners();
  }

  Transaction findById(String id) {
    return _items.firstWhere((cate) => cate.id == id, orElse: () => null);
  }

  Future<void> fetchAndSetExpensive(String categoryId) async {

    var url = '${AppConst.BASE_URL}/transaction?userId=$userId&categoryId=$categoryId';
    try {
      final response = await http.get(Uri.parse(url),
        headers: { HttpHeaders.authorizationHeader: authToken, },
      );
      final extractedData = json.decode(response.body);
      if (extractedData == null) {
        return;
      }
      
      final List<Transaction> loadedTransactions = [];
      extractedData.forEach((transactionData) {
        loadedTransactions.add(Transaction(
          id: transactionData['id'],
          date: DateTime.parse(transactionData['date']),
          categoryId: transactionData['categoryId'],
          description : transactionData['description'],
          volume: transactionData['volume'].toDouble(),
        ));
      });

      _items = loadedTransactions;
      _items.sort((a,b)=> b.date.compareTo(a.date));
      notifyListeners();
    } catch (error) {
      throw (error);
    }
  }

  Future<void> addTransaction(Transaction transaction) async {
    final url = '${AppConst.BASE_URL}/transactions';
    try {
      final response = await http.post(
        Uri.parse(url),
        headers: { HttpHeaders.authorizationHeader: authToken, },
        body: json.encode(
          {
            'userId': userId,
            'categoryId': transaction.categoryId,
            'description': transaction.description,
            'volume': transaction.volume,
            'date': transaction.date.toUtc().toIso8601String()
          },
        ),
      );


      final newTransaction = Transaction(
        description: transaction.description,
        volume: transaction.volume,
        categoryId: transaction.categoryId,
        date: transaction.date,
        id: json.decode(response.body)['trans']['id'],
      );
      _items.add(newTransaction);
      notifyListeners();
    } catch (error) {
      print(error);
      throw error;
    }
  }

  Future<void> updateTransaction(Transaction newTransaction) async {
    final transIndex = _items.indexWhere((trans) => trans.id == newTransaction.id);
    try {
      if (transIndex >= 0) {
        final url = '${AppConst.BASE_URL}/transaction/${newTransaction.id}';

        await http.patch(Uri.parse(url),
            headers: { HttpHeaders.authorizationHeader: authToken,},
            body: json.encode({
              'description': newTransaction.description,
              'volume': newTransaction.volume,
              'date': newTransaction.date.toUtc().toIso8601String(),
              'categoryId': newTransaction.categoryId,
            }));
        _items[transIndex] = newTransaction;
        notifyListeners();
      } else {
      }
    } catch (err) {
      print(err);
      throw err;
    }
  }

  Future<bool> deleteTransaction(String id) async {
    final url = '${AppConst.BASE_URL}/transaction/$id';
    final existingTransIndex = _items.indexWhere((ex) => ex.id == id);
    var existingTransaction = _items[existingTransIndex];
    _items.removeAt(existingTransIndex);
    notifyListeners();

    try {
      final response = await http.delete(Uri.parse(url), headers: { HttpHeaders.authorizationHeader: authToken, },);

      if (response.statusCode >= 400) {
        _items.insert(existingTransIndex, existingTransaction);
        notifyListeners();
        existingTransaction = null;
        return false;
      } else {
        existingTransaction = null;
        return true;
      }
    } catch (e) {
      _items.insert(existingTransIndex, existingTransaction);
      notifyListeners();
      existingTransaction = null;
      throw e;
    }

  }

  void localDeleteTransaction(String id) {
    final existingTransIndex = _items.indexWhere((ex) => ex.id == id);
    _items.removeAt(existingTransIndex);
    notifyListeners();
  }


}
