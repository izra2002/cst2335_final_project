import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'veterinarian.dart';

/// Singleton database helper for managing [Veterinarian] records.
///
/// Uses SQLite via the sqflite package to persist data between app sessions.
class VetDatabase {
  /// The single instance of this class.
  static final VetDatabase instance = VetDatabase._init();

  static Database? _database;

  VetDatabase._init();

  /// Returns the database, creating it if it doesn't exist yet.
  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('veterinarians.db');
    return _database!;
  }

  /// Initialises the SQLite database at the given [filePath].
  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(
      path,
      version: 1,
      onCreate: _createDB,
    );
  }

  /// Creates the veterinarians table when the database is first created.
  Future _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE veterinarians (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        birthday TEXT NOT NULL,
        address TEXT NOT NULL,
        university TEXT NOT NULL
      )
    ''');
  }

  /// Inserts a new [vet] into the database and returns the saved object with its new ID.
  Future<Veterinarian> insertVet(Veterinarian vet) async {
    final db = await instance.database;
    final id = await db.insert('veterinarians', vet.toMap());
    return vet..id = id;
  }

  /// Returns all veterinarians stored in the database.
  Future<List<Veterinarian>> getAllVets() async {
    final db = await instance.database;
    final result = await db.query('veterinarians', orderBy: 'name ASC');
    return result.map((map) => Veterinarian.fromMap(map)).toList();
  }

  /// Updates an existing [vet]'s information in the database.
  Future<int> updateVet(Veterinarian vet) async {
    final db = await instance.database;
    return db.update(
      'veterinarians',
      vet.toMap(),
      where: 'id = ?',
      whereArgs: [vet.id],
    );
  }

  /// Deletes the veterinarian with the given [id] from the database.
  Future<int> deleteVet(int id) async {
    final db = await instance.database;
    return db.delete(
      'veterinarians',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  /// Closes the database connection.
  Future close() async {
    final db = await instance.database;
    db.close();
  }
}