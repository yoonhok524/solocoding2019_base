import 'package:solocoding2019_base/data/model/recent.dart';
import 'package:solocoding2019_base/data/database.dart';
import 'package:sqflite/sqflite.dart';

class RecentLocalDao {
  var _db;

  RecentLocalDao() {
    _db = DatabaseHelper().getDatabase();
  }

  Future<Database> get db async {
    if (_db != null) return _db;
    _db = await DatabaseHelper().getDatabase();
    return _db;
  }

  Future<List<Recent>> getAll() async {
    final dbClient = await db;
    final List<Map<String, dynamic>> maps = await dbClient.query('recents', orderBy: "time");
    return List.generate(maps.length, (i) => Recent.fromJson(maps[i]));
  }

  Future<void> save(Recent recent) async {
    print("[RecentLocalDao][Weather] save - $recent");
    final dbClient = await db;
    await dbClient.insert(
      'recents',
      recent.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace
    );
  }

  Future<void> delete(int id) async {
    final dbClient = await db;
    await dbClient.delete(
      'recents',
      where: "id = ?",
      whereArgs: [id],
    );
  }
}
