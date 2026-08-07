import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:aretina/core/constants/constants.dart';

class DatabaseHelper {
  DatabaseHelper._internal();
  static final DatabaseHelper instance = DatabaseHelper._internal();

  static Database? _database;

  Future<Database> get database async {
    _database ??= await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, AppConstants.dbName);

    return await openDatabase(
      path,
      version: AppConstants.dbVersion,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    // Users table
    await db.execute('''
      CREATE TABLE ${AppConstants.tableUsers} (
        id            INTEGER PRIMARY KEY AUTOINCREMENT,
        name          TEXT    NOT NULL,
        email         TEXT    NOT NULL UNIQUE,
        password_hash TEXT    NOT NULL,
        avatar_path   TEXT,
        created_at    TEXT    NOT NULL
      )
    ''');

    // Detections table
    await db.execute('''
      CREATE TABLE ${AppConstants.tableDetections} (
        id          INTEGER PRIMARY KEY AUTOINCREMENT,
        user_id     INTEGER NOT NULL,
        image_path  TEXT    NOT NULL,
        diagnosis   TEXT    NOT NULL,
        confidence  REAL    NOT NULL,
        all_scores  TEXT    NOT NULL,
        detected_at TEXT    NOT NULL,
        notes       TEXT,
        FOREIGN KEY (user_id) REFERENCES ${AppConstants.tableUsers}(id)
          ON DELETE CASCADE
      )
    ''');

    // Index for faster user-based queries
    await db.execute(
      'CREATE INDEX idx_detections_user_id ON ${AppConstants.tableDetections}(user_id)',
    );
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    // Handle future migrations here
  }

  Future<void> close() async {
    final db = await database;
    await db.close();
    _database = null;
  }
}
