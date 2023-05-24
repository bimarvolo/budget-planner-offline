import 'package:hive/hive.dart';

part 'transaction.g.dart';

@HiveType(typeId: 1)
class Transaction {
  @HiveField(0)
  final String id;

  @HiveField(1)
  String? description;

  @HiveField(2)
  final double volume;

  @HiveField(3)
  final DateTime date;

  Transaction({
    required this.id,
    this.description,
    required this.volume,
    required this.date,
  });

  @override
  String toString() {
    return "Id: $id - des: $description - volume: $volume - date: $date";
  }
}
