import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:todo/pages/home_page.dart';
import 'pages/auth_screen.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'db/todo_database.dart';

/// Entry point for the Todo app.
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();
  Hive.registerAdapter(TodoItemAdapter());
  await openTodoBox();
  runApp(const MyApp());
}

/// The root widget of the Todo app.
///
/// Sets up the MaterialApp and initial authentication screen.
///
/// @attribute key Optional widget key.
class MyApp extends StatelessWidget {
  /// Creates a [MyApp] widget.
  ///
  /// @param key Optional widget key.
  const MyApp({super.key});

  /// Builds the root MaterialApp.
  ///
  /// @param context The build context.
  /// @return Widget
  @override
  Widget build(BuildContext context) {
    return MaterialApp(debugShowCheckedModeBanner: false, home: AuthScreen());
  }
}
