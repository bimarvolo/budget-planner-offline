import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import './category.dart';

import 'package:hive/hive.dart';

part 'budget.g.dart';

@HiveType(typeId: 3)
class Budget with ChangeNotifier {
  
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String title;

  @HiveField(2)
  final DateTime startDate;

  @HiveField(3)
  final DateTime endDate;

  @HiveField(4)
  List<Category> categories;

  Budget(
      {required this.id,
      required this.title,
      required this.startDate,
      required this.endDate,
      required this.categories});

  @override
  String toString() {
    return "Id: $id - title: $title - startDate: $startDate - endDate: $endDate - categories: $categories";
  }
  
  String get titleDisplay {
      String _title = DateFormat.d().format(startDate) == DateFormat.d().format(endDate)
      ?
      DateFormat.d().format(startDate) == DateFormat.d().format(endDate)
          ? '${DateFormat.d().format(startDate)}, ${DateFormat.yMMM().format(endDate)}'
          : '${DateFormat.d().format(startDate)} - ${DateFormat.d().format(endDate)}, ${DateFormat.yMMM().format(endDate)}'
      : '${DateFormat.d().format(startDate)}, ${DateFormat.yMMM().format(startDate)} - ${DateFormat.d().format(endDate)}, ${DateFormat.yMMM().format(endDate)}';
      return title != '' ? title : _title;
  }

}
