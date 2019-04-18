import 'package:solocoding2019_base/data/model/favorite.dart';
import 'package:solocoding2019_base/data/database.dart';
import 'package:sqflite/sqflite.dart';

class FavoriteLocalDataSource {
  var _db;

  FavoriteLocalDataSource() {
    _db = DatabaseHelper().getDatabase();
  }

  Future<Database> get db async {
    if (_db != null) return _db;
    _db = await DatabaseHelper().getDatabase();
    return _db;
  }

  Future<void> insert(Favorite favorite) async {
    final Database dbClient = await db;
    await dbClient.insert(
      'favorites',
      favorite.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<Favorite>> getAll() async {
    final Database dbClient = await db;
    final List<Map<String, dynamic>> maps = await dbClient.query('favorites');
    return List.generate(maps.length, (i) => Favorite.fromJson(maps[i]));
  }

  Future<void> update(Favorite favorite) async {
    final dbClient = await db;
    await dbClient.update(
      'favorites',
      favorite.toMap(),
      where: "id = ?",
      whereArgs: [favorite.id],
    );
  }

  Future<void> delete(int id) async {
    final dbClient = await db;
    await dbClient.delete(
      'favorites',
      where: "id = ?",
      whereArgs: [id],
    );
  }
}
