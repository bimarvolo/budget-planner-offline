import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import './category.dart';

class Budget with ChangeNotifier {
  final String id;
  final String title;
  final DateTime startDate;
  final DateTime endDate;
  List<Category> categories;

  Budget(
      {@required this.id,
      @required this.title,
      @required this.startDate,
      @required this.endDate,
      @required this.categories});
  
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
