import 'package:flutter/material.dart';
import 'package:catppuccin_flutter/catppuccin_flutter.dart';

class TodoTile extends StatelessWidget {
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
