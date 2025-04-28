import 'package:flutter/material.dart';
import 'package:todo/widgets/todo_tile.dart';
import 'package:todo/widgets/add_task_bar.dart';
import 'package:catppuccin_flutter/catppuccin_flutter.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'dart:convert';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  Flavor flavor = catppuccin.macchiato;
  final _controller = TextEditingController();
  final _storage = const FlutterSecureStorage();
  List toDoList = [];

  @override
  void initState() {
    super.initState();
    _loadToDoList();
  }

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

  Future<void> _saveToDoList() async {
    await _storage.write(key: 'todo_list', value: jsonEncode(toDoList));
  }

  void checkBoxChanged(int index) {
    setState(() {
      toDoList[index][1] = !toDoList[index][1];
    });
    _saveToDoList();
  }

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

  void deleteTask(int index) {
    setState(() {
      toDoList.removeAt(index);
    });
    _saveToDoList();
  }

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
