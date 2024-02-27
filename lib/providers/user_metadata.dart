import 'package:hive/hive.dart';

part 'user_metadata.g.dart';

@HiveType(typeId: 4)
class UserMetadata {
  @HiveField(0)
  String currency = '\$'; // User currency preference

  @HiveField(1)
  String lang = 'en'; // User language preference

  @HiveField(2)
  String theme = 'DART'; // User theme preference

  @HiveField(3)
  int currentBudget = -1;
}
