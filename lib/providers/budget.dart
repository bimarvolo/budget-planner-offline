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
    String _title;
    if (DateFormat.yM().format(startDate) == DateFormat.yM().format(endDate)) {
      if (startDate.day == 1 &&
          endDate.day == DateTime(startDate.year, startDate.month + 1, 0).day) {
        _title = DateFormat.yMMMM().format(startDate);
      } else {
        _title = DateFormat.MMMM().format(startDate) +
            ' ' +
            DateFormat.d().format(startDate) +
            ' - ' +
            DateFormat.d().format(endDate) +
            ', ' +
            DateFormat.y().format(startDate);
      }
    } else if (startDate.difference(endDate).inDays == 1) {
      _title = DateFormat.MMMM().format(startDate) +
          ' ' +
          DateFormat.d().format(startDate) +
          ' - ' +
          DateFormat.MMMM().format(endDate) +
          ' ' +
          DateFormat.d().format(endDate) +
          ', ' +
          DateFormat.y().format(endDate);
    } else {
      _title = DateFormat.MMMM().format(startDate) +
          ' ' +
          DateFormat.d().format(startDate) +
          ' - ' +
          DateFormat.MMMM().format(endDate) +
          ' ' +
          DateFormat.d().format(endDate) +
          ', ' +
          DateFormat.y().format(endDate);
    }
    return title.isNotEmpty ? title : _title;
  }
}
