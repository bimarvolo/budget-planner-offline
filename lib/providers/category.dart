import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

enum CategoryType { expensive, income }

class Category with ChangeNotifier {
  final String id;
  final String budgetId;
  final String description;
  final String type;
  final double volume;
  double totalSpent;
  IconData iconData;

  Category({
    @required this.id,
    @required this.budgetId,
    @required this.description,
    @required this.type,
    @required this.volume,
    @required this.totalSpent,
    this.iconData
  });

}
