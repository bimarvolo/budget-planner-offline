import 'package:flutter/material.dart';
import 'package:hive/hive.dart';

import './transaction.dart';

/// A class that represents a collection of transactions.
///
/// This class provides functionality for managing and manipulating transactions.
/// It also implements the [ChangeNotifier] mixin to notify listeners when the
/// list of transactions is modified.
class Transactions with ChangeNotifier {
  List<Transaction> _items = [];
  String? categoryId;

  Transactions(this._items);

  List<Transaction> get items {
    return [..._items];
  }

  /// Sets the items in the transaction list.
  ///
  /// The [list] parameter is a list of [Transaction] objects that will be set as the new items in the transaction list.
  void setItems(List<Transaction> list) {
    _items = list;
    _items.sort((a, b) => b.date.compareTo(a.date));
    notifyListeners();
  }

  /// Finds a transaction by its ID.
  ///
  /// Returns the transaction with the specified ID, or null if no transaction is found.
  Transaction findById(String id) {
    return _items.firstWhere((cate) => cate.id == id);
  }

  ///
  /// This method retrieves expensive transactions from a data source and sets them in the provider.
  /// The [categoryId] parameter specifies the category for which the transactions should be fetched.
  /// This method is asynchronous and returns a [Future] that completes when the transactions are fetched and set.
  Future<void> fetchAndSetExpensive(String categoryId) async {
    Box<Transaction> transBox = Hive.box<Transaction>('transactions');

    final List<Transaction> loadedTransactions = [];
    transBox.values.forEach((element) {
      if (element.categoryId == categoryId) loadedTransactions.add(element);
    });

    _items = loadedTransactions;
    _items.sort((a, b) => b.date.compareTo(a.date));
    // notifyListeners();
    // } catch (error) {
    //   throw (error);
    // }
  }

  /// Adds a transaction to the list of transactions.
  ///
  /// The [transaction] parameter represents the transaction to be added.
  /// This method is asynchronous and returns a [Future] that completes when the transaction is added.
  /// Throws an error if the transaction is null.
  Future<void> addTransaction(Transaction transaction) async {
    Box<Transaction> transBox = Hive.box<Transaction>('transactions');

    // clear transactionId
    await transBox.put(transaction.id, transaction);
    _items.add(transaction);
    notifyListeners();
  }

  /// Updates the given [transaction].
  ///
  /// This method is used to update a transaction in the database.
  /// It takes a [Transaction] object as a parameter and updates the corresponding record in the database.
  /// The method returns a [Future] that completes when the transaction is successfully updated.
  Future<void> updateTransaction(Transaction transaction) async {
    Box<Transaction> transBox = Hive.box<Transaction>('transactions');
    // final transIndex = transBox.values
    //     .toList()
    //     .indexWhere((trans) => trans.id == transaction.id);

    await transBox.put(transaction.id, transaction);
    _items =
        _items.map((e) => e.id == transaction.id ? transaction : e).toList();
    notifyListeners();
  }

  /// Deletes a transaction with the specified [id].
  ///
  /// This method is used to remove a transaction from the list of transactions.
  ///
  /// Parameters:
  ///   - id: The unique identifier of the transaction to be deleted.
  ///
  /// Returns:
  ///   - Future<void>: A future that completes when the transaction is successfully deleted.
  ///
  /// Throws:
  ///   - Exception: If the transaction with the specified [id] does not exist.
  Future<void> deleteTransaction(String id) async {
    Box<Transaction> transBox = Hive.box<Transaction>('transactions');
    await transBox.delete(id);
    final transIndex = _items.indexWhere((trans) => trans.id == id);
    _items.removeAt(transIndex);

    notifyListeners();
  }

  void localDeleteTransaction(String id) {
    final existingTransIndex = _items.indexWhere((ex) => ex.id == id);
    _items.removeAt(existingTransIndex);
    notifyListeners();
  }
}
