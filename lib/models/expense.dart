import 'package:hive/hive.dart';
import 'package:uuid/uuid.dart';

part 'expense.g.dart';

@HiveType(typeId: 0)
enum Category {
  @HiveField(0)
  food,
  @HiveField(1)
  transport,
  @HiveField(2)
  entertainment,
  @HiveField(3)
  bills,
  @HiveField(4)
  other
}

@HiveType(typeId: 1)
class Expense extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  String name;

  @HiveField(2)
  double amount;

  @HiveField(3)
  Category category;

  @HiveField(4)
  DateTime date;

  Expense({
    String? id,
    required this.name,
    required this.amount,
    required this.category,
    required this.date,
  }) : id = id ?? const Uuid().v4();
}
