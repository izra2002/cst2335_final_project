import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

/// This class handles all database operations related to vaccines.
///
/// It is responsible for:
/// - Creating the database
/// - Creating the vaccines table
/// - Performing CRUD operations (Insert, Read, Update, Delete)
class VaccineDatabaseHelper {

  /// Singleton instance of the database helper
  static final VaccineDatabaseHelper instance = VaccineDatabaseHelper._init();

  /// Holds the database instance
  static Database? _database;

  /// Private constructor to prevent multiple instances (Singleton pattern)
  VaccineDatabaseHelper._init();

  /// Getter that returns the database instance.
  /// If the database does not exist yet, it initializes it.
  Future<Database> get database async {
    if (_database != null) return _database!;

    /// Initialize database if not already created
    _database = await _initDB('vaccine.db');
    return _database!;
  }

  /// Initializes the database by creating the file and opening connection
  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();

    /// Combine database path with file name
    final path = join(dbPath, filePath);

    /// Open database and create table if it does not exist
    return await openDatabase(
      path,
      version: 1,
      onCreate: _createDB,
    );
  }

  /// Creates the vaccines table inside the database
  ///
  /// The table contains:
  /// - id (primary key)
  /// - name
  /// - dosage
  /// - lotNumber
  /// - expirationDate
  Future _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE vaccines (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        dosage TEXT NOT NULL,
        lotNumber TEXT NOT NULL,
        expirationDate TEXT NOT NULL
      )
    ''');
  }

  /// Inserts a new vaccine record into the database
  ///
  /// [row] is a Map containing vaccine data
  Future<int> insertVaccine(Map<String, dynamic> row) async {
    final db = await instance.database;

    /// Insert data into vaccines table
    return await db.insert('vaccines', row);
  }

  /// Retrieves all vaccine records from the database
  ///
  /// Returns a list of maps representing each row
  Future<List<Map<String, dynamic>>> getAllVaccines() async {
    final db = await instance.database;

    /// Query all rows from vaccines table
    return await db.query('vaccines');
  }

  /// Updates an existing vaccine record
  ///
  /// [row] must contain the id of the vaccine to update
  Future<int> updateVaccine(Map<String, dynamic> row) async {
    final db = await instance.database;

    /// Extract id from the row
    int id = row['id'];

    /// Update the row where id matches
    return await db.update(
      'vaccines',
      row,
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  /// Deletes a vaccine record from the database
  ///
  /// [id] is the identifier of the vaccine to delete
  Future<int> deleteVaccine(int id) async {
    final db = await instance.database;

    /// Delete row where id matches
    return await db.delete(
      'vaccines',
      where: 'id = ?',
      whereArgs: [id],
    );
  }
}