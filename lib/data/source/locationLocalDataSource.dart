import 'package:path/path.dart';
import 'package:solocoding2019_base/data/model/location.dart';
import 'package:sqflite/sqflite.dart';

class LocationLocalDataSource {
  var _db;

  LocationLocalDataSource() {
    _db = _init();
  }

  Future<Database> get db async {
    if (_db != null) return _db;
    _db = await _init();
    return _db;
  }

  Future<Database> _init() async {
    return openDatabase(
      join(await getDatabasesPath(), 'weather_database.db'),
      onCreate: (db, version) => db.execute(
            "CREATE TABLE locations(id INTEGER PRIMARY KEY, name TEXT, lon REAL, lat REAL)",
          ),
      version: 1,
    );
  }

  Future<void> insert(Location location) async {
    final Database dbClient = await db;
    await dbClient.insert(
      'locations',
      location.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<Location>> locations() async {
    final Database dbClient = await db;
    final List<Map<String, dynamic>> maps = await dbClient.query('locations');
    return List.generate(maps.length, (i) => Location.fromJson(maps[i]));
  }

  Future<void> updateLocation(Location location) async {
    final dbClient = await db;
    await dbClient.update(
      'locations',
      location.toMap(),
      where: "id = ?",
      whereArgs: [location.id],
    );
  }

  Future<void> deleteLocation(int id) async {
    final dbClient = await db;
    await dbClient.delete(
      'locations',
      where: "id = ?",
      whereArgs: [id],
    );
  }
}
