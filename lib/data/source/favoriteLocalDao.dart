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

  Future<void> save(Favorite favorite) async {
    final dbClient = await db;
    await dbClient.insert(
      'favorites',
      favorite.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<Favorite> get(String favoriteId) async {
    final dbClient = await db;
    final List<Map<String, dynamic>> maps = await dbClient.query('favorites', where: "id = ?", whereArgs: [favoriteId], limit: 1);

    if (maps.length == 0) {
      return null;
    }

    return Favorite.fromJson(maps[0]);
  }

  Future<bool> isExist(String favoriteId) async {
    final dbClient = await db;
    final List<Map<String, dynamic>> maps = await dbClient.query('favorites', where: "id = ?", whereArgs: [favoriteId], limit: 1);
    return maps.length == 1;
  }

  Future<List<Favorite>> getAll() async {
    final dbClient = await db;
    final List<Map<String, dynamic>> maps = await dbClient.query('favorites');
    return List.generate(maps.length, (i) => Favorite.fromJson(maps[i]));
  }

  Future<void> delete(String id) async {
    final dbClient = await db;
    await dbClient.delete(
      'favorites',
      where: "id = ?",
      whereArgs: [id],
    );
  }
}
