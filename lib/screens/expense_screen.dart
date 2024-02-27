import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'package:money_budget_frontend_offile/screens/expense_screen_data.dart';
import 'package:money_budget_frontend_offile/screens/expense_screen_empty.dart';
import '../hive/metadata_storage.dart';

class Expense extends StatefulWidget {
  static const routeName = '/expense';

  @override
  _ExpenseState createState() => _ExpenseState();
}

class _ExpenseState extends State<Expense> {
  @override
  Widget build(BuildContext context) {
    var metadata = MetadataStorage.getMetadata()!;
    var budgetIndex = metadata.currentBudget;

    if (budgetIndex == -1) return ExpenseEmpty();

    return ExpenseData();
  }
}
