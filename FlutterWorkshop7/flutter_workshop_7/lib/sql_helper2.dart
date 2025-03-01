import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class SqlHelper2 {
  static Database? _database;
  static const String tableName = 'contacts';

  static Future<Database> db() async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  static Future<Database> _initDatabase() async {
    final path = join(await getDatabasesPath(), 'contacts.db');
    return await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE $tableName (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            first_name TEXT,
            last_name TEXT,
            email TEXT,
            phone TEXT,
            group_type TEXT
          )
        ''');
      },
    );
  }

  static Future<int> insertContact(Map<String, dynamic> data) async {
    final db = await SqlHelper2.db();
    return await db.insert(tableName, data);
  }

  static Future<List<Map<String, dynamic>>> getContacts() async {
    final db = await SqlHelper2.db();
    return await db.query(tableName);
  }

  static Future<Map<String, dynamic>?> getContactById(int id) async {
    final db = await SqlHelper2.db();
    final List<Map<String, dynamic>> result = await db.query(
      tableName,
      where: "id = ?",
      whereArgs: [id],
      limit: 1,
    );
    return result.isNotEmpty ? result.first : null;
  }

  static Future<int> updateContact(int id, Map<String, dynamic> data) async {
    final db = await SqlHelper2.db();
    return await db.update(tableName, data, where: "id = ?", whereArgs: [id]);
  }

  static Future<int> deleteContact(int id) async {
    final db = await SqlHelper2.db();
    return await db.delete(tableName, where: "id = ?", whereArgs: [id]);
  }
}
