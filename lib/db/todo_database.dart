import 'package:hive/hive.dart';

part 'todo_database.g.dart';

@HiveType(typeId: 0)
class TodoItem extends HiveObject {
  @HiveField(0)
  String name;

  @HiveField(1)
  bool done;

  @HiveField(2)
  int id;

  TodoItem({required this.name, required this.done, required this.id});
}

// Helper for box name
const String todoBoxName = 'todos';

// Open box (call this before using Hive)
Future<Box<TodoItem>> openTodoBox() async {
  return await Hive.openBox<TodoItem>(todoBoxName);
}
