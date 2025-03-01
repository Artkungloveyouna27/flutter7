import 'package:flutter/foundation.dart';
import 'package:sqflite/sqflite.dart' as sql; 

class SqlHelper {
  static Future<void> createTable(sql.Database database) async {
    await database.execute("CREATE TABLE tasks("
        "id INTEGER PRIMARY KEY AUTOINCREMENT,"
        "title TEXT,"
        "description TEXT)");
  }

  static Future<sql.Database> db() async {
    return sql.openDatabase(
      'dbtasks.db',
      version: 1,
      onCreate: (sql.Database database, int version) async {
        await createTable(database);
      },
    );
  }

  static Future<int> insertTask(String title, String description) async {
    final db = await SqlHelper.db();
    final data = {
      'title': title,
      'description': description,
    };
    final id = await db.insert('tasks', data,conflictAlgorithm: sql.ConflictAlgorithm.replace);
    return id;
    }

    static Future<List<Map<String,dynamic>>> getTasks() async{
      final db = await SqlHelper.db();
      return db.query('tasks', orderBy: "id DESC",);
    }

    static Future<List<Map<String,dynamic>>> getTask(int id) async {
      final db = await SqlHelper.db();
      return db.query ('tasks', 
      where: "id = ?",
      whereArgs:[id],
      limit:1);
    }

    static Future<int> updateTask(
      int id,String title, String description) async {
        final db= await SqlHelper.db();

        final data = {
          'title' :title,
          'description' : description
        };
        final result = await db.update('tasks', data,
        where: "id = ?",
        whereArgs: [id]);
        return result;
      }

    static Future<void> deleteTask(int id) async {
      final db = await SqlHelper.db();
      try{
        await db.delete("table", where: "id=?", whereArgs: [id]);
      }catch(err) {
        debugPrint("เกิดข้อผิดพลาดบางประการในขณะลบข้อมูล....: $err");
      }
    }
    
}