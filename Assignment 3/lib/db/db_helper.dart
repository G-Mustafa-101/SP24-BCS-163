import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/bmi_model.dart';

class DBHelper {
  static Database? _db;

  Future<Database> get db async {
    if (_db != null) return _db!;
    _db = await initDB();
    return _db!;
  }

  Future<Database> initDB() async {
    String path = join(await getDatabasesPath(), 'bmi.db');

    return await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
        CREATE TABLE bmi(
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          bmi REAL,
          category TEXT,
          height REAL,
          weight REAL
        )
        ''');
      },
    );
  }

  Future insert(BMIModel model) async {
    final dbClient = await db;
    return await dbClient.insert('bmi', model.toMap());
  }

  Future<List<BMIModel>> getAll() async {
    final dbClient = await db;
    final data = await dbClient.query('bmi');
    return data.map((e) => BMIModel.fromMap(e)).toList();
  }

  Future delete(int id) async {
    final dbClient = await db;
    return await dbClient.delete('bmi', where: 'id=?', whereArgs: [id]);
  }

  Future deleteAll() async {
    final dbClient = await db;
    return await dbClient.delete('bmi');
  }

  Future update(BMIModel model) async {
    final dbClient = await db;
    return await dbClient.update(
      'bmi',
      model.toMap(),
      where: 'id=?',
      whereArgs: [model.id],
    );
  }
}