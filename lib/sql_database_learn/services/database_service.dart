import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

import '../models/task.dart';

class DatabaseService {
  static Database? _db;
  static final DatabaseService instance = DatabaseService._constructor();

  final String _tasksTableName = "tasks";
  final String _tasksidColumnName = "id";
  final String _tasksContentColumnName = "content";
  final String _tasksStatusColumnName = "status";

  DatabaseService._constructor();
  Future<Database> get database async {
    if (_db != null) return _db!;
    _db = await getDatabase();
    return _db!;
  }

  Future<Database> getDatabase() async {
    final databaseDirPath = await getDatabasesPath();
    final databasePath = join(databaseDirPath, "master_db.db");
    final database = await openDatabase(
      databasePath,
      version: 1,
      onCreate: (db, version) {
        db.execute('''
            CREATE TABLE $_tasksTableName (
              $_tasksidColumnName INTEGER PRIMARY KEY,
              $_tasksContentColumnName TEXT NOT NULL,
              $_tasksStatusColumnName INTEGER NOT NULL
            )

          ''');
      },
    );
    return database;
  }

  void addTask(
    String content,
  ) async {
    final db = await database;
    await db.insert(
      _tasksTableName,
      {
        _tasksContentColumnName: content,
        _tasksStatusColumnName: 0,
      },
    );
  }

  Future<List<Task>> getTasks() async {
    final db = await database;
    final data = await db.query(_tasksTableName);
    List<Task> tasks =
        data.map((e) => Task(status: e["status"] as int, id: e["id"] as int, content: e["content"] as String)).toList();
    return tasks;
  }

  void updateTaskStatus(int id, int status) async {
    final db = await database;
    await db.update(
      _tasksTableName,
      {
        _tasksStatusColumnName: status,
      },
      where: '$_tasksidColumnName = ?',
      whereArgs: [
        id,
      ],
    );
  }

  void deleteTask(int id) async {
    final db = await database;
    await db.delete(
      _tasksTableName,
      where: 'id = ?',
      whereArgs: [
        id,
      ],
    );
  }

  void updateTaskContent(int id, String newContent) async {
    final db = await database;
    await db.update(
      _tasksTableName,
      {
        _tasksContentColumnName: newContent,
      },
      where: '$_tasksidColumnName = ?',
      whereArgs: [
        id,
      ],
    );
  }

  Future<List<Task>> search(String search) async {
    final db = await database;
    final List<Map<String, dynamic>> maps =
        await db.rawQuery("SELECT * FROM tasks WHERE content LIKE ?", ['%$search%']);
    return List.generate(
      maps.length,
      (index) {
        var column = maps[index];
        return Task(
          status: column['status'] as int,
          id: column['id'] as int,
          content: column['content'] as String,
        );
      },
    );
  }
}
