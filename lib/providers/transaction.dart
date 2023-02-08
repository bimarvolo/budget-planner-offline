import 'package:flutter/foundation.dart';

class Transaction {
  final String id;
  final String categoryId;
  String description;
  final double volume;
  final DateTime date;

  Transaction({
    @required this.id,
    @required this.categoryId,
    this.description,
    @required this.volume,
    @required this.date,
  });
}
