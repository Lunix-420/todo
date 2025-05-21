import 'package:flutter/material.dart';
import 'package:todo/widgets/todo_tile.dart';
import 'package:todo/widgets/add_task_bar.dart';
import 'package:catppuccin_flutter/catppuccin_flutter.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:convert';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'dart:html' as html; // ignore: avoid_web_libraries_in_flutter
import 'package:hive_flutter/hive_flutter.dart';
import '../db/todo_database.dart';

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

  late Future<Box<TodoItem>> _todoBoxFuture;

  /// Initializes the state and loads the todo list from secure storage.
  @override
  void initState() {
    super.initState();
    _todoBoxFuture =
        Hive.isBoxOpen(todoBoxName)
            ? Future.value(Hive.box<TodoItem>(todoBoxName))
            : openTodoBox();
  }

  /// Loads todo items from a JSON file and adds them to the current list and storage.
  Future<void> _loadFromJsonFile(Box<TodoItem> todoBox) async {
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
          if (result.files.single.path == null) {
            throw Exception("Dateipfad fehlt.");
          }
          File file = File(result.files.single.path!);
          content = await file.readAsString();
        }
        List<dynamic> jsonList = jsonDecode(content);

        // Build set of existing IDs
        Set existingIds = todoBox.values.map((item) => item.id).toSet();

        List<TodoItem> newTodos = [];
        for (var item in jsonList) {
          if (item is Map<String, dynamic>) {
            String name = item['todoName'] ?? '';
            bool done = (item['status'] == 'done');
            var id = item['todoId'];
            if (id == null) continue;
            if (existingIds.contains(id)) continue; // skip duplicates
            newTodos.add(TodoItem(name: name, done: done, id: id));
          }
        }
        for (var todo in newTodos) {
          todoBox.add(todo);
        }
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('JSON-Todos geladen!'),
            backgroundColor: flavor.green,
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Fehler beim Laden der JSON-Datei'),
          backgroundColor: flavor.red,
        ),
      );
    }
  }

  /// Exports the current todo list as a JSON file.
  Future<void> _exportToJsonFile(Box<TodoItem> todoBox) async {
    try {
      // Prepare the JSON list with the required fields
      List<Map<String, dynamic>> exportList = [];
      for (var item in todoBox.values) {
        exportList.add({
          "todoName": item.name,
          "todoId": item.id,
          "status": item.done ? "done" : "pending",
          "deadline": "", // No deadline in current model, left empty
        });
      }
      String jsonString = jsonEncode(exportList);

      if (kIsWeb) {
        // Web: trigger browser download
        final bytes = utf8.encode(jsonString);
        final blob = html.Blob([bytes], 'application/json');
        final url = html.Url.createObjectUrlFromBlob(blob);
        html.AnchorElement(href: url)
          ..setAttribute('download', 'exported_todos.json')
          ..click();
        html.Url.revokeObjectUrl(url);

        if (!mounted) return;
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

        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Todos exportiert: $filePath'),
            backgroundColor: flavor.green,
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;
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
    return FutureBuilder<Box<TodoItem>>(
      future: _todoBoxFuture,
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return Scaffold(
            backgroundColor: flavor.base,
            body: Center(child: CircularProgressIndicator()),
          );
        }
        final todoBox = snapshot.data!;
        return Scaffold(
          backgroundColor: flavor.base,
          appBar: AppBar(
            title: const Text(
              'Todo Liste',
              style: TextStyle(
                fontSize: 32, // Bigger font size
                fontWeight: FontWeight.bold, // Bolder
              ),
            ),
            centerTitle: true,
            backgroundColor: flavor.surface0,
            foregroundColor: flavor.text,
            elevation: 2,
            toolbarHeight: 80, // Make AppBar taller
            actions: [
              // Import Button with hover effect
              Padding(
                padding: const EdgeInsets.symmetric(
                  vertical: 16,
                  horizontal: 8,
                ),
                child: StatefulBuilder(
                  builder: (context, setState) {
                    final hover = ValueNotifier(false);
                    return ValueListenableBuilder<bool>(
                      valueListenable: hover,
                      builder:
                          (context, isHovered, child) => MouseRegion(
                            onEnter: (_) => hover.value = true,
                            onExit: (_) => hover.value = false,
                            child: AnimatedScale(
                              scale: isHovered ? 1.08 : 1.0,
                              duration: const Duration(milliseconds: 120),
                              child: GestureDetector(
                                onTap: () => _loadFromJsonFile(todoBox),
                                child: AnimatedContainer(
                                  duration: const Duration(milliseconds: 120),
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 18,
                                    vertical: 8,
                                  ),
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      colors: [flavor.peach, flavor.red],
                                      begin: Alignment.topLeft,
                                      end: Alignment.bottomRight,
                                    ),
                                    borderRadius: BorderRadius.circular(18),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withAlpha(51),
                                        blurRadius: isHovered ? 14 : 6,
                                        offset: const Offset(0, 3),
                                      ),
                                    ],
                                  ),
                                  child: Row(
                                    children: [
                                      const Icon(
                                        Icons.file_upload,
                                        color: Colors.black,
                                        size: 22,
                                      ),
                                      const SizedBox(width: 8),
                                      Text(
                                        'Import',
                                        style: TextStyle(
                                          color: Colors.black,
                                          fontWeight: FontWeight.w900,
                                          fontSize: 16,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                    );
                  },
                ),
              ),
              // Export Button with hover effect
              Padding(
                padding: const EdgeInsets.symmetric(
                  vertical: 16,
                  horizontal: 8,
                ),
                child: StatefulBuilder(
                  builder: (context, setState) {
                    final hover = ValueNotifier(false);
                    return ValueListenableBuilder<bool>(
                      valueListenable: hover,
                      builder:
                          (context, isHovered, child) => MouseRegion(
                            onEnter: (_) => hover.value = true,
                            onExit: (_) => hover.value = false,
                            child: AnimatedScale(
                              scale: isHovered ? 1.08 : 1.0,
                              duration: const Duration(milliseconds: 120),
                              child: GestureDetector(
                                onTap: () => _exportToJsonFile(todoBox),
                                child: AnimatedContainer(
                                  duration: const Duration(milliseconds: 120),
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 18,
                                    vertical: 8,
                                  ),
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      colors: [flavor.peach, flavor.red],
                                      begin: Alignment.topLeft,
                                      end: Alignment.bottomRight,
                                    ),
                                    borderRadius: BorderRadius.circular(18),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withAlpha(51),
                                        blurRadius: isHovered ? 14 : 6,
                                        offset: const Offset(0, 3),
                                      ),
                                    ],
                                  ),
                                  child: Row(
                                    children: [
                                      const Icon(
                                        Icons.file_download,
                                        color: Colors.black,
                                        size: 22,
                                      ),
                                      const SizedBox(width: 8),
                                      Text(
                                        'Export',
                                        style: TextStyle(
                                          color: Colors.black,
                                          fontWeight: FontWeight.w900,
                                          fontSize: 16,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                    );
                  },
                ),
              ),
            ],
          ),
          body: ValueListenableBuilder(
            valueListenable: todoBox.listenable(),
            builder: (context, Box<TodoItem> box, _) {
              return ListView.builder(
                itemCount: box.length,
                itemBuilder: (BuildContext context, index) {
                  final todo = box.getAt(index);
                  if (todo == null) return SizedBox.shrink();
                  return TodoTile(
                    taskName: todo.name,
                    taskDone: todo.done,
                    onChanged: (value) {
                      todo.done = !todo.done;
                      todo.save();
                      setState(() {});
                    },
                    onDelete: () {
                      box.deleteAt(index);
                      setState(() {});
                    },
                  );
                },
              );
            },
          ),
          floatingActionButton: AddTaskBar(
            controller: _controller,
            onAddTask: () {
              if (_controller.text.trim().isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: const Text('Aufgabe darf nicht leer sein!'),
                    backgroundColor: flavor.red,
                  ),
                );
                return;
              }
              int newId = DateTime.now().millisecondsSinceEpoch;
              final todo = TodoItem(
                name: _controller.text,
                done: false,
                id: newId,
              );
              todoBox.add(todo);
              _controller.clear();
              setState(() {});
            },
            flavor: flavor,
          ),
        );
      },
    );
  }
}
