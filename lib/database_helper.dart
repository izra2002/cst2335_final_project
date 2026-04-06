import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

// This class handles all database operations for the Pet Owner section
class DatabaseHelper {

  // Only one instance of the database is created (singleton pattern)
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  // Returns the database, creates it if it doesn't exist yet
  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('pet_owners.db');
    return _database!;
  }

  // Creates the database file on the device 4
  Future<Database> _initDB(String filePath) async {
    // Get the path where the database will be saved on the device
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(
      path,
      version: 1,
      onCreate: _createDB,
    );
  }

  // Creates the pet_owners table with all required columns
  Future _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE pet_owners (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        firstName TEXT NOT NULL,
        lastName TEXT NOT NULL,
        address TEXT NOT NULL,
        dateOfBirth TEXT NOT NULL,
        insuranceNumber TEXT
      )
    ''');
  }

  // Inserts a new pet owner into the database
  Future<int> insertOwner(Map<String, dynamic> owner) async {
    final db = await database;
    return await db.insert('pet_owners', owner);
  }

  // Returns all pet owners from the database
  Future<List<Map<String, dynamic>>> getAllOwners() async {
    final db = await database;
    return await db.query('pet_owners');
  }

  // Updates an existing pet owner's information
  Future<int> updateOwner(Map<String, dynamic> owner) async {
    final db = await database;
    return await db.update(
      'pet_owners',
      owner,
      where: 'id = ?',
      whereArgs: [owner['id']],
    );
  }

  // Deletes a pet owner from the database by their id
  Future<int> deleteOwner(int id) async {
    final db = await database;
    return await db.delete(
      'pet_owners',
      where: 'id = ?',
      whereArgs: [id],
    );
  }
}