import 'package:flutter/material.dart';
import 'package:todo/widgets/todo_tile.dart';
import 'package:catppuccin_flutter/catppuccin_flutter.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  Flavor flavor = catppuccin.macchiato;

  final _controller = TextEditingController();
  List toDoList = [
    ['Flutter Lernen', false],
    ['Kaffee trinken', false],
    ['Buch lesen', false],
    ['Film schauen', false],
  ];

  void checkBoxChanged(int index) {
    setState(() {
      toDoList[index][1] = !toDoList[index][1];
    });
  }

  void addTask() {
    setState(() {
      toDoList.add([_controller.text, false]);
      _controller.clear();
    });
  }

  void deleteTask(int index) {
    setState(() {
      toDoList.removeAt(index);
    });
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
      floatingActionButton: Row(
        children: [
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(left: 30, right: 10),
              child: TextField(
                controller: _controller,
                cursorColor: flavor.text,
                style: TextStyle(color: flavor.text),
                decoration: InputDecoration(
                  hintText: "Neue Aufgabe hinzufügen",
                  hintStyle: TextStyle(color: flavor.subtext0),
                  filled: true,
                  fillColor: flavor.crust,
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: flavor.surface0),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: flavor.surface0),
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
            ),
          ),
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [flavor.peach, flavor.red],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              shape: BoxShape.circle,
            ),
            child: FloatingActionButton(
              onPressed: addTask,
              backgroundColor: Colors.transparent,
              elevation: 0,
              child: Icon(Icons.add),
            ),
          ),
        ],
      ),
    );
  }
}
