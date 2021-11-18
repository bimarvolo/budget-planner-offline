import 'package:flutter/foundation.dart';

class Transaction {
  final String id;
  final String categoryId;
  final String description;
  final double volume;
  final DateTime date;

  Transaction({
    @required this.id,
    @required this.categoryId,
    @required this.description,
    @required this.volume,
    @required this.date,
  });
}
