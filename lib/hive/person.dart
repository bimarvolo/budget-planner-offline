import 'package:hive/hive.dart';

part 'person.g.dart';

@HiveType(typeId: 1)
class Person {
  @HiveField(0)
  String name;

  @HiveField(1)
  int age;

  @HiveField(2)
  List<String> friends;

  Person({
    required this.name,
    required this.age,
    required this.friends,
  });

  @override
  String toString() {
    return "Name: $name - age: $age friends: $friends";
  }
}
