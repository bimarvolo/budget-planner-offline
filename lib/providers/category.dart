import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import './transaction.dart';

part 'category.g.dart';

enum CategoryType { expensive, income }

@HiveType(typeId: 2)
class Category with ChangeNotifier {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String description;

  @HiveField(2)
  final String type;

  @HiveField(3)
  final double volume;

  @HiveField(4)
  double totalSpent;

  List<Transaction>? transactions;

  IconData? iconData;

  @HiveField(5)
  String? iconDataString;

  @override
  String toString() {
    return "Id: $id - type: $type - volume: $volume - totalSpend: $totalSpent";
  }

  Category(
      {required this.id,
      required this.description,
      required this.type,
      required this.volume,
      required this.totalSpent,
      this.transactions,
      this.iconData,
      this.iconDataString});
}
