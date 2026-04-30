import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/game_model.dart';

class DBHelper {
  static Database? _db;

  Future<Database> get database async {
    if (_db != null) return _db!;
    _db = await initDB();
    return _db!;
  }

  initDB() async {
    String path = join(await getDatabasesPath(), 'game.db');

    return await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
CREATE TABLE games(
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  attemptsList TEXT,
  totalAttempts INTEGER,
  result TEXT,
  score INTEGER,
  time TEXT
)
''');
      },
    );
  }

  insertGame(GameModel game) async {
    final db = await database;
    return await db.insert('games', game.toMap());
  }

  getGames() async {
    final db = await database;
    final data = await db.query('games', orderBy: 'id DESC');
    return data.map((e) => GameModel.fromMap(e)).toList();
  }

  deleteAll() async {
    final db = await database;
    await db.delete('games');
  }
}