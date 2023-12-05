import 'dart:convert';
import 'package:crud_flutter/screens/tododatabase.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:camera/camera.dart';
import 'camera_screen.dart';
import 'package:path/path.dart' as path;

import 'package:sqflite/sqflite.dart';

class AddTodoPage extends StatefulWidget {
  final Map? todo;
  final void Function()? onTodoUpdated;

  const AddTodoPage({
    Key? key,
    this.todo,
    this.onTodoUpdated,
  }) : super(key: key);

  @override
  State<AddTodoPage> createState() => _AddTodoPageState();
}

class _AddTodoPageState extends State<AddTodoPage> {
  TextEditingController titleController = TextEditingController();
  TextEditingController descriptionController = TextEditingController();
  bool isEdit = false;
  late CameraController _cameraController;
  late Future<void> _initializeCameraFuture;
  XFile? _imageFile;
  late Database _database;

  @override
  void initState() {
    super.initState();
    _initializeCamera();
    _initDatabase();
    final todo = widget.todo;
    if (widget.todo != null) {
      isEdit = true;
      final title = widget.todo!['title'];
      final description = widget.todo!['description'];
      titleController.text = title;
      descriptionController.text = description;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(isEdit ? 'Edit Todo' : 'Add Todo'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          TextField(
            controller: titleController,
            decoration: const InputDecoration(hintText: 'Title'),
            onChanged: (text) {
              setState(() {}); // Atualiza a UI quando o texto muda
            },
          ),
          const SizedBox(height: 20),
          TextField(
            controller: descriptionController,
            decoration: const InputDecoration(hintText: 'Description'),
            onChanged: (text) {
              setState(() {}); // Atualiza a UI quando o texto muda
            },
            keyboardType: TextInputType.multiline,
            minLines: 5,
            maxLines: 8,
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: isEdit ? updateData : submitData,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Text(isEdit ? 'Update' : 'Submit'),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              _initializeCamera().then((_) {
                if (_cameraController != null) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          CameraScreen(cameraController: _cameraController),
                    ),
                  );
                }
              });
            },
            child: Text('Acessar Câmera'),
          ),
        ],
      ),
    );
  }

  Future<void> updateData() async {
    final todo = widget.todo;
    if (todo == null) {
      print('You cannot call updated without todo data');
      return;
    }

    final title = titleController.text;
    final description = descriptionController.text;
    final id = todo['_id'];
    final body = {
      "title": title,
      "description": description,
      "is_completed": todo['is_completed'],
    };

    final url = 'http://api.nstack.in/v1/todos/$id';
    final uri = Uri.parse(url);

    try {
      final response = await http.put(
        uri,
        body: jsonEncode(body),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        titleController.text = '';
        descriptionController.text = '';
        showSuccessMessage('Dados salvos na API!');

        // Se a função onTodoUpdated for passada como parâmetro, chame-a após a atualização
        widget.onTodoUpdated?.call();

        // Fecha a tela de edição após a atualização
        Navigator.pop(context, true);

        // Atualiza o banco de dados local
        await TodoDatabase.update({
          'id': id,
          'title': title,
          'description': description,
          'isCompleted': todo['is_completed'] ? 1 : 0,
        });
        showSuccessMessage('Dados salvos localmente!');
      } else {
        showErrorMessage('Update Failed: ${response.statusCode}');
      }
    } catch (error) {
      showErrorMessage('Error: $error');
    }
  }

  Future<void> submitData() async {
    final title = titleController.text;
    final description = descriptionController.text;

    final body = {
      "title": title,
      "description": description,
      "is_completed": false,
    };

    const url = 'http://api.nstack.in/v1/todos/';
    final uri = Uri.parse(url);

    try {
      final response = await http.post(
        uri,
        body: jsonEncode(body),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 201) {
        titleController.text = '';
        descriptionController.text = '';
        showSuccessMessage('Created successfully');
        final Map<String, dynamic> responseData = jsonDecode(response.body);
        await TodoDatabase.insert({
          'id': responseData['_id'],
          'title': title,
          'description': description,
          'isCompleted': false,
        });
      } else {
        showErrorMessage('Creation Failed: ${response.statusCode}');
      }
    } catch (error) {
      showErrorMessage('Error: $error');
    }
  }

  void showSuccessMessage(String message) {
    final snackBar = SnackBar(
      content: Text(
        message,
        style: const TextStyle(color: Colors.white),
      ),
      backgroundColor: const Color.fromARGB(255, 5, 236, 74),
    );
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

  void showErrorMessage(String message) {
    final snackBar = SnackBar(
      content: Text(
        message,
        style: const TextStyle(color: Colors.white),
      ),
      backgroundColor: Colors.red,
    );
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

  Future<void> _initializeCamera() async {
    final cameras = await availableCameras();
    final firstCamera = cameras.first;

    setState(() {
      _cameraController =
          CameraController(firstCamera, ResolutionPreset.medium);
      _initializeCameraFuture = _cameraController.initialize();
    });
  }

  Future<void> _initDatabase() async {
    final databasesPath = await getDatabasesPath();
    final dbPath =
        path.join(databasesPath!, 'todos.db'); // Corrigindo o uso do join
    _database = await openDatabase(
      dbPath,
      version: 1,
      onCreate: (db, version) {
        return db.execute(
          'CREATE TABLE todos(id INTEGER PRIMARY KEY, title TEXT, description TEXT, image TEXT)',
        );
      },
    );
  }
  Future<String> getDatabasePath() async {
  // Obtém o diretório de armazenamento local do aplicativo
  final appDocumentDir = await getDatabasesPath();
  return appDocumentDir;
}
  void showDatabasePath() async {
  final dbPath = await getDatabasePath();
  print('O banco de dados SQLite está salvo em: $dbPath');
}
  @override
  void dispose() {
    _cameraController.dispose();
    _database.close();
    super.dispose();
  }
}
