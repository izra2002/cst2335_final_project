import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

/// This class handles all database operations for the Pet section.
/// It is separate from DatabaseHelper — we use a different class name
/// and a different table name so there is no clash with the Pet Owner section.
class PetDatabaseHelper {

  // Only one instance of this helper is created and shared (singleton pattern)
  static final PetDatabaseHelper instance = PetDatabaseHelper._init();

  // The actual database object — it starts as null until we open it
  static Database? _database;

  // Private constructor so nobody can create another instance from outside
  PetDatabaseHelper._init();

  /// Returns the database, and creates it the first time it is needed
  Future<Database> get database async {
    // If the database is already open, just return it
    if (_database != null) return _database!;

    // Otherwise open (or create) the database file
    _database = await _initDB('pets.db');
    return _database!;
  }

  /// Opens the database file on the device storage
  Future<Database> _initDB(String filePath) async {
    // Get the folder path where databases are stored on this device
    final dbPath = await getDatabasesPath();

    // Join the folder path with our file name to get the full path
    final path = join(dbPath, filePath);

    // Open the database — if the file doesn't exist it will be created
    return await openDatabase(
      path,
      version: 1,
      onCreate: _createDB,
    );
  }

  /// Creates the pets table the first time the database is made
  Future _createDB(Database db, int version) async {
    // This SQL statement creates the table with all the columns we need
    await db.execute('''
      CREATE TABLE pets (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        birthday TEXT NOT NULL,
        species TEXT NOT NULL,
        colour TEXT NOT NULL,
        ownerId TEXT NOT NULL
      )
    ''');
  }

  /// Inserts a new pet into the database and returns the new row id
  Future<int> insertPet(Map<String, dynamic> pet) async {
    // Get the database
    final db = await database;

    // Insert the pet map into the pets table and return the new id
    return await db.insert('pets', pet);
  }

  /// Returns all pets stored in the database as a list of maps
  Future<List<Map<String, dynamic>>> getAllPets() async {
    // Get the database
    final db = await database;

    // Query every row in the pets table
    return await db.query('pets');
  }

  /// Updates an existing pet's information in the database
  Future<int> updatePet(Map<String, dynamic> pet) async {
    // Get the database
    final db = await database;

    // Update only the row that has the matching id
    return await db.update(
      'pets',
      pet,
      where: 'id = ?',
      whereArgs: [pet['id']],
    );
  }

  /// Deletes a pet from the database using its id
  Future<int> deletePet(int id) async {
    // Get the database
    final db = await database;

    // Delete only the row with the matching id.
    return await db.delete(
      'pets',
      where: 'id = ?',
      whereArgs: [id],
    );
  }
}