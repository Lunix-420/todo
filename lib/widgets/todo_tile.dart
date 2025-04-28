import 'package:flutter/material.dart';
import 'package:catppuccin_flutter/catppuccin_flutter.dart';

/// A widget that displays a single todo item with a checkbox and delete button.
///
/// Shows the task name, its completion status, and allows toggling or deleting the task.
///
/// @attribute taskName The name of the todo task.
/// @attribute taskDone Whether the task is marked as completed.
/// @attribute onChanged Callback when the checkbox is toggled.
/// @attribute onDelete Callback when the delete button is pressed.
class TodoTile extends StatelessWidget {
  /// Creates a [TodoTile] widget.
  ///
  /// @param key Optional widget key.
  /// @param taskName The name of the todo task.
  /// @param taskDone Whether the task is marked as completed.
  /// @param onChanged Callback for checkbox toggle.
  /// @param onDelete Callback for delete button.
  const TodoTile({
    super.key,
    required this.taskName,
    required this.taskDone,
    this.onChanged,
    this.onDelete,
  });

  final String taskName;
  final bool taskDone;
  final Function(bool?)? onChanged;
  final VoidCallback? onDelete;

  /// Builds the todo tile UI.
  ///
  /// @param context The build context.
  /// @return Widget
  @override
  Widget build(BuildContext context) {
    Flavor flavor = catppuccin.macchiato;
    return Padding(
      padding: const EdgeInsets.only(top: 20, left: 20, right: 20, bottom: 0),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: flavor.surface0,
          borderRadius: BorderRadius.circular(15),
        ),
        child: Row(
          children: [
            Checkbox(
              value: taskDone,
              onChanged: onChanged,
              checkColor: flavor.crust,
              activeColor: flavor.text,
              side: BorderSide(color: flavor.text),
            ),
            Expanded(
              child: Text(
                taskName,
                style: TextStyle(
                  color: flavor.text,
                  fontSize: 18,
                  decoration:
                      taskDone
                          ? TextDecoration.lineThrough
                          : TextDecoration.none,
                  decorationColor: flavor.text,
                  decorationThickness: 2,
                ),
              ),
            ),
            IconButton(
              onPressed: onDelete,
              icon: Icon(Icons.delete, color: flavor.red),
            ),
          ],
        ),
      ),
    );
  }
}
