import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._privateConstructor();

  factory DatabaseHelper() => _instance;

  DatabaseHelper._privateConstructor();

  Future<Database> getDatabase() async {
    return openDatabase(
      join(await getDatabasesPath(), 'weather_database.db'),
      onCreate: (db, version) {
        db.execute("CREATE TABLE favorites("
            "id TEXT PRIMARY KEY, "
            "name TEXT, "
            "lon REAL, "
            "lat REAL)");
        db.execute("CREATE TABLE recents("
            "id TEXT PRIMARY KEY, "
            "name TEXT, "
            "lon REAL, "
            "lat REAL, "
            "time INTEGER)");
      },
      version: 1,
    );
  }
}
