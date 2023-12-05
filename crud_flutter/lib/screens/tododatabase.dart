import 'dart:io';

import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path_provider/path_provider.dart';

class TodoDatabase {
  static Database? _database;

  static Future<Database> get database async {
    if (_database != null) return _database!;

    // Se o banco de dados não existir ainda, crie um
    _database = await initDB();
    return _database!;
  }

  static Future<Database> initDB() async {
    final path = await getDatabasesPath();
    final databasePath = join(path, 'todo_database.db');

    return await openDatabase(databasePath, version: 1,
        onCreate: (Database db, int version) async {
      await db.execute('''
        CREATE TABLE todos(
          id INTEGER PRIMARY KEY,
          title TEXT,
          description TEXT,
          isCompleted INTEGER
        )
      ''');
    });
  }

  static Future<List<Map<String, dynamic>>> getTodos() async {
    final Database db = await database;
    return await db.query('todos');
  }

  static Future<int> insert(Map<String, dynamic> todo) async {
    final Database db = await database;
    return await db.insert('todos', todo);
  }

  static Future<int> update(Map<String, dynamic> todo) async {
    final Database db = await database;
    return await db
        .update('todos', todo, where: 'id = ?', whereArgs: [todo['id']]);
  }

  static Future<int> delete(int id) async {
    final Database db = await database;
    return await db.delete('todos', where: 'id = ?', whereArgs: [id]);
  }
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

Future<void> copyDatabaseToExternalStorage() async {
  // Obter o caminho do banco de dados atual
  var databasesPath = await getDatabasesPath();
  var sourcePath = join(databasesPath, 'todo_database.db');

  // Verificar se o arquivo do banco de dados existe
  if (await File(sourcePath).exists()) {
    // Obter o diretório do armazenamento externo
    var externalStorageDir = await getExternalStorageDirectory();
    var destinationPath =
        join(externalStorageDir!.path, 'backup_todo_database.db');

    try {
      // Copiar o banco de dados para o armazenamento externo
      await File(sourcePath).copy(destinationPath);
      print(
          'Banco de dados copiado para o armazenamento externo em: $destinationPath');
    } catch (e) {
      print('Erro ao copiar o banco de dados: $e');
    }
  } else {
    print('Arquivo do banco de dados não encontrado em $sourcePath');
  }
}
