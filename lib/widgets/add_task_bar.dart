import 'package:flutter/material.dart';
import 'package:catppuccin_flutter/catppuccin_flutter.dart';

class AddTaskBar extends StatelessWidget {
  const AddTaskBar({
    super.key,
    required this.controller,
    required this.onAddTask,
    required this.flavor,
  });

  final TextEditingController controller;
  final VoidCallback onAddTask;
  final Flavor flavor;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Padding(
            padding: const EdgeInsets.only(left: 30, right: 10),
            child: TextField(
              controller: controller,
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
            onPressed: onAddTask,
            backgroundColor: Colors.transparent,
            elevation: 0,
            child: const Icon(Icons.add),
          ),
        ),
      ],
    );
  }
}
