import 'package:flutter/material.dart';
import 'package:catppuccin_flutter/catppuccin_flutter.dart';

/// A widget that provides a text field and a button to add new tasks.
///
/// Displays a styled input bar at the bottom of the screen for entering new todo items.
/// The button triggers the provided callback to add the task.
///
/// @attribute controller The [TextEditingController] for the input field.
/// @attribute onAddTask Callback function to be called when the add button is pressed.
/// @attribute flavor The [Flavor] used for theming colors.
class AddTaskBar extends StatelessWidget {
  /// Creates an [AddTaskBar] widget.
  ///
  /// @param key Optional widget key.
  /// @param controller Controller for the text input field.
  /// @param onAddTask Callback for when the add button is pressed.
  /// @param flavor The color flavor for theming.
  const AddTaskBar({
    super.key,
    required this.controller,
    required this.onAddTask,
    required this.flavor,
  });

  final TextEditingController controller;
  final VoidCallback onAddTask;
  final Flavor flavor;

  /// Builds the add task bar UI.
  ///
  /// @param context The build context.
  /// @return Widget
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
              onSubmitted: (_) => onAddTask(),
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
