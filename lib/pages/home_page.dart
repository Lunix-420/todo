import 'package:flutter/material.dart';
import 'package:todo/widgets/todo_tile.dart';
import 'package:todo/widgets/add_task_bar.dart';
import 'package:catppuccin_flutter/catppuccin_flutter.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:convert';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
// Only import dart:html if on web
// ignore: avoid_web_libraries_in_flutter
import 'dart:html' as html;

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
  /// Each item is a list containing the task name (String), its completion status (bool), and a unique ID (int).
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
        // Support both old and new formats for backward compatibility
        List rawList = jsonDecode(data);
        toDoList =
            rawList.map((item) {
              if (item.length == 3) return item;
              // If old format, assign a unique id
              return [
                item[0],
                item[1],
                DateTime.now().millisecondsSinceEpoch + rawList.indexOf(item),
              ];
            }).toList();
      });
    } else {
      setState(() {
        toDoList = [
          ['Flutter Lernen', false, 1],
          ['Kaffee trinken', false, 2],
          ['Buch lesen', false, 3],
          ['Film schauen', false, 4],
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
      // Assign a unique id (timestamp-based)
      int newId = DateTime.now().millisecondsSinceEpoch;
      toDoList.add([_controller.text, false, newId]);
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

  /// Loads todo items from a JSON file and adds them to the current list and storage.
  Future<void> _loadFromJsonFile() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['json'],
      );
      if (result != null) {
        String content;
        if (kIsWeb) {
          // On web, read from bytes
          final bytes = result.files.single.bytes;
          if (bytes == null) throw Exception("Keine Datei-Inhalte gefunden.");
          content = utf8.decode(bytes);
        } else {
          // On mobile/desktop, read from file path
          if (result.files.single.path == null)
            throw Exception("Dateipfad fehlt.");
          File file = File(result.files.single.path!);
          content = await file.readAsString();
        }
        List<dynamic> jsonList = jsonDecode(content);

        // Build set of existing IDs
        Set existingIds =
            toDoList.map((item) => item.length > 2 ? item[2] : null).toSet();

        List<List<dynamic>> newTodos = [];
        for (var item in jsonList) {
          if (item is Map<String, dynamic>) {
            String name = item['todoName'] ?? '';
            bool done = (item['status'] == 'done');
            var id = item['todoId'];
            if (id == null) continue;
            if (existingIds.contains(id)) continue; // skip duplicates
            newTodos.add([name, done, id]);
          }
        }
        setState(() {
          toDoList.addAll(newTodos);
        });
        await _saveToDoList();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('JSON-Todos geladen!'),
            backgroundColor: flavor.green,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Fehler beim Laden der JSON-Datei'),
          backgroundColor: flavor.red,
        ),
      );
    }
  }

  /// Exports the current todo list as a JSON file.
  Future<void> _exportToJsonFile() async {
    try {
      // Prepare the JSON list with the required fields
      List<Map<String, dynamic>> exportList = [];
      for (var item in toDoList) {
        exportList.add({
          "todoName": item[0],
          "todoId": item.length > 2 ? item[2] : null,
          "status": item[1] == true ? "done" : "pending",
          "deadline": "", // No deadline in current model, left empty
        });
      }
      String jsonString = jsonEncode(exportList);

      if (kIsWeb) {
        // Web: trigger browser download
        final bytes = utf8.encode(jsonString);
        final blob = html.Blob([bytes], 'application/json');
        final url = html.Url.createObjectUrlFromBlob(blob);
        final anchor =
            html.AnchorElement(href: url)
              ..setAttribute('download', 'exported_todos.json')
              ..click();
        html.Url.revokeObjectUrl(url);

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Todos als JSON exportiert (Download gestartet)'),
            backgroundColor: flavor.green,
          ),
        );
      } else {
        // Mobile/Desktop: save to file system
        Directory? directory;
        if (Platform.isAndroid || Platform.isIOS) {
          directory = await getApplicationDocumentsDirectory();
        } else {
          directory = await getDownloadsDirectory();
        }
        String filePath = "${directory!.path}/exported_todos.json";
        File file = File(filePath);
        await file.writeAsString(jsonString);

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Todos exportiert: $filePath'),
            backgroundColor: flavor.green,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Fehler beim Exportieren der JSON-Datei'),
          backgroundColor: flavor.red,
        ),
      );
    }
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
        actions: [
          IconButton(
            icon: Icon(Icons.upload_file, color: flavor.text),
            tooltip: 'Load JSON',
            onPressed: _loadFromJsonFile,
          ),
          IconButton(
            icon: Icon(Icons.download, color: flavor.text),
            tooltip: 'Export as JSON',
            onPressed: _exportToJsonFile,
          ),
        ],
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
