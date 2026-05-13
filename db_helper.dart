import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('travel_tracker.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(
      path,
      version: 1,
      onCreate: _createDB,
    );
  }

  Future _createDB(Database db, int version) async {
    const idType = 'INTEGER PRIMARY KEY AUTOINCREMENT';
    const textType = 'TEXT NOT NULL';

    await db.execute('''
CREATE TABLE locations (
  id $idType,
  name $textType,
  date $textType
)
''');

    await db.execute('''
CREATE TABLE sms_messages (
  id $idType,
  sender $textType,
  content $textType,
  date $textType
)
''');
  }

  Future<int> insertLocation(String name, String date) async {
    final db = await instance.database;
    return await db.insert('locations', {'name': name, 'date': date});
  }

  Future<List<Map<String, dynamic>>> getLocations() async {
    final db = await instance.database;
    return await db.query('locations', orderBy: 'id DESC');
  }

  Future<int> insertSms(String sender, String content, String date) async {
    final db = await instance.database;
    return await db.insert('sms_messages', {
      'sender': sender,
      'content': content,
      'date': date,
    });
  }

  Future<List<Map<String, dynamic>>> getSmsMessages() async {
    final db = await instance.database;
    return await db.query('sms_messages', orderBy: 'id DESC');
  }
}
