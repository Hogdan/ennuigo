import 'dart:convert';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DBHelper {
  static const _databaseName = "ennuigo.db";
  static const _databaseVersion = 1;

  static const tableMoods = 'moods';
  static const tableEntries = 'entries';

  static const columnId = 'id';
  static const columnColor = 'color';
  static const columnPathData = 'path_data';
  
  static const columnDate = 'date';
  static const columnMoodId = 'mood_id';

  // Make this a singleton class
  DBHelper._privateConstructor();
  static final DBHelper instance = DBHelper._privateConstructor();

  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    String path = join(await getDatabasesPath(), _databaseName);
    return await openDatabase(path,
        version: _databaseVersion, onCreate: _onCreate);
  }

  Future _onCreate(Database db, int version) async {
    await db.execute('''
          CREATE TABLE $tableMoods (
            $columnId INTEGER PRIMARY KEY AUTOINCREMENT,
            $columnColor INTEGER NOT NULL,
            $columnPathData TEXT NOT NULL
          )
          ''');

    await db.execute('''
          CREATE TABLE $tableEntries (
            $columnDate TEXT PRIMARY KEY,
            $columnMoodId INTEGER NOT NULL,
            FOREIGN KEY ($columnMoodId) REFERENCES $tableMoods ($columnId)
          )
          ''');

    // Insert default moods
    await _insertDefaultMoods(db);
  }

  Future<void> _insertDefaultMoods(Database db) async {
    // Happy (Green)
    await db.insert(tableMoods, {
      columnColor: 0xFF4CAF50, // Green
      columnPathData: jsonEncode([
        {'x': 30, 'y': 40, 'type': 'move'},
        {'x': 40, 'y': 40, 'type': 'line'},
        {'x': 60, 'y': 40, 'type': 'move'},
        {'x': 70, 'y': 40, 'type': 'line'},
        {'x': 20, 'y': 60, 'type': 'move'},
        {'x': 50, 'y': 80, 'type': 'line'},
        {'x': 80, 'y': 60, 'type': 'line'},
      ])
    });

    // Neutral (Yellow)
    await db.insert(tableMoods, {
      columnColor: 0xFFFFEB3B, // Yellow
      columnPathData: jsonEncode([
        {'x': 30, 'y': 40, 'type': 'move'},
        {'x': 40, 'y': 40, 'type': 'line'},
        {'x': 60, 'y': 40, 'type': 'move'},
        {'x': 70, 'y': 40, 'type': 'line'},
        {'x': 30, 'y': 70, 'type': 'move'},
        {'x': 70, 'y': 70, 'type': 'line'},
      ])
    });

    // Sad (Blue)
    await db.insert(tableMoods, {
      columnColor: 0xFF2196F3, // Blue
      columnPathData: jsonEncode([
        {'x': 30, 'y': 40, 'type': 'move'},
        {'x': 40, 'y': 40, 'type': 'line'},
        {'x': 60, 'y': 40, 'type': 'move'},
        {'x': 70, 'y': 40, 'type': 'line'},
        {'x': 20, 'y': 80, 'type': 'move'},
        {'x': 50, 'y': 60, 'type': 'line'},
        {'x': 80, 'y': 80, 'type': 'line'},
      ])
    });
  }

  Future<int> insertMood(Map<String, dynamic> row) async {
    Database db = await instance.database;
    return await db.insert(tableMoods, row);
  }

  Future<void> deleteMood(int id) async {
    Database db = await instance.database;
    // Delete entries referencing this mood first
    await db.delete(tableEntries, where: '$columnMoodId = ?', whereArgs: [id]);
    // Then delete the mood
    await db.delete(tableMoods, where: '$columnId = ?', whereArgs: [id]);
  }

  Future<List<Map<String, dynamic>>> queryAllMoods() async {
    Database db = await instance.database;
    return await db.query(tableMoods);
  }

  Future<int> insertOrUpdateEntry(String date, int moodId) async {
    Database db = await instance.database;
    return await db.insert(
      tableEntries,
      {columnDate: date, columnMoodId: moodId},
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<Map<String, dynamic>?> queryEntry(String date) async {
    Database db = await instance.database;
    List<Map<String, dynamic>> results = await db.query(
      tableEntries,
      where: '$columnDate = ?',
      whereArgs: [date],
    );
    if (results.isNotEmpty) return results.first;
    return null;
  }

  Future<List<Map<String, dynamic>>> queryAllEntries() async {
    Database db = await instance.database;
    return await db.query(tableEntries);
  }
}
