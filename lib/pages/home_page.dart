import 'package:flutter/material.dart';
import 'package:todo/widgets/todo_tile.dart';
import 'package:todo/widgets/add_task_bar.dart';
import 'package:catppuccin_flutter/catppuccin_flutter.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'dart:convert';

/// The main page of the Todo app.
///
/// Displays the list of tasks and allows users to add, check off, and delete tasks.
/// Uses secure storage to persist the todo list.
class HomePage extends StatefulWidget {
  /// Creates a [HomePage] widget.
  ///
  /// @param key Optional widget key.
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

/// State for [HomePage].
///
/// Handles loading, saving, and updating the todo list, as well as user interactions.
class _HomePageState extends State<HomePage> {
  /// @attribute flavor The color flavor used for theming the app.
  Flavor flavor = catppuccin.macchiato;

  /// @attribute _controller Controller for the text input field where users enter new tasks.
  final _controller = TextEditingController();

  /// @attribute _storage Secure storage instance for persisting the todo list.
  final _storage = const FlutterSecureStorage();

  /// @attribute toDoList The list of todo items.
  ///
  /// Each item is a list containing the task name (String) and its completion status (bool).
  List toDoList = [];

  /// Initializes the state and loads the todo list from secure storage.
  @override
  void initState() {
    super.initState();
    _loadToDoList();
  }

  /// Loads the todo list from secure storage.
  ///
  /// If no data is found, initializes the list with default tasks and saves them.
  /// @return Future<void>
  Future<void> _loadToDoList() async {
    String? data = await _storage.read(key: 'todo_list');
    if (data != null) {
      setState(() {
        toDoList = List<List<dynamic>>.from(jsonDecode(data));
      });
    } else {
      setState(() {
        toDoList = [
          ['Flutter Lernen', false],
          ['Kaffee trinken', false],
          ['Buch lesen', false],
          ['Film schauen', false],
        ];
      });
      _saveToDoList();
    }
  }

  /// Saves the current todo list to secure storage.
  /// @return Future<void>
  Future<void> _saveToDoList() async {
    await _storage.write(key: 'todo_list', value: jsonEncode(toDoList));
  }

  /// Toggles the completion status of the task at the given [index].
  ///
  /// Also saves the updated list to storage.
  /// @param index The index of the task to toggle.
  void checkBoxChanged(int index) {
    setState(() {
      toDoList[index][1] = !toDoList[index][1];
    });
    _saveToDoList();
  }

  /// Adds a new task to the todo list using the text from [_controller].
  ///
  /// If the input is empty, shows a snackbar with an error message.
  void addTask() {
    if (_controller.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Aufgabe darf nicht leer sein!'),
          backgroundColor: flavor.red,
        ),
      );
      return;
    }
    setState(() {
      toDoList.add([_controller.text, false]);
      _controller.clear();
    });
    _saveToDoList();
  }

  /// Deletes the task at the given [index] from the todo list.
  ///
  /// Also saves the updated list to storage.
  /// @param index The index of the task to delete.
  void deleteTask(int index) {
    setState(() {
      toDoList.removeAt(index);
    });
    _saveToDoList();
  }

  /// Builds the UI for the home page, including the app bar, todo list, and add task bar.
  /// @param context The build context.
  /// @return Widget
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: flavor.base,
      appBar: AppBar(
        title: const Text('Todo Liste'),
        centerTitle: true,
        backgroundColor: flavor.surface0,
        foregroundColor: flavor.text,
      ),
      body: ListView.builder(
        itemCount: toDoList.length,
        itemBuilder: (BuildContext context, index) {
          return TodoTile(
            taskName: toDoList[index][0],
            taskDone: toDoList[index][1],
            onChanged: (value) => checkBoxChanged(index),
            onDelete: () => deleteTask(index),
          );
        },
      ),
      floatingActionButton: AddTaskBar(
        controller: _controller,
        onAddTask: addTask,
        flavor: flavor,
      ),
    );
  }
}
