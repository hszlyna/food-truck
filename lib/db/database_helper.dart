import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();

  static Database? _database;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;

    _database = await _initDB('foodtruck.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(
      path,
      version: 2,   // UPGRADED VERSION
      onCreate: _createDB,
      onUpgrade: _upgradeDB,
    );
  }

  //============================================================
  //                    DATABASE CREATION
  //============================================================
  Future _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE users (
        userid INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        email TEXT NOT NULL,
        phone TEXT NOT NULL,
        username TEXT NOT NULL,
        password TEXT NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE truckbook (
        bookid INTEGER PRIMARY KEY AUTOINCREMENT,
        userid INTEGER NOT NULL,
        book_date TEXT NOT NULL,
        booktime TEXT NOT NULL,
        eventdate TEXT NOT NULL,
        eventtime TEXT NOT NULL,
        foodtrucktype TEXT NOT NULL,
        numberofdays INTEGER NOT NULL,
        price REAL NOT NULL,
        FOREIGN KEY (userid) REFERENCES users (userid)
      )
    ''');

    await db.execute('''
      CREATE TABLE administrator (
        adminid INTEGER PRIMARY KEY AUTOINCREMENT,
        username TEXT NOT NULL UNIQUE,
        password TEXT NOT NULL
      )
    ''');

    // NEW: Food Truck Table
    await db.execute('''
      CREATE TABLE foodtrucks (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        image TEXT
      )
    ''');
  }

  //============================================================
  //                  DATABASE UPGRADE HANDLER
  //============================================================
  Future<void> _upgradeDB(Database db, int oldV, int newV) async {
    if (oldV < 2) {
      await db.execute('''
        CREATE TABLE foodtrucks (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          name TEXT NOT NULL,
          image TEXT
        )
      ''');
    }
  }

  //============================================================
  //                       USER SECTION
  //============================================================

  Future<int> registerUser(Map<String, dynamic> user) async {
    final db = await instance.database;

    final existingUsers = await db.query(
      'users',
      where: 'username = ?',
      whereArgs: [user['username']],
    );

    if (existingUsers.isNotEmpty) {
      return -1;
    }

    return await db.insert('users', user);
  }

  Future<Map<String, dynamic>?> loginUser(String username, String password) async {
    final db = await instance.database;

    final result = await db.query(
      'users',
      where: 'username = ? AND password = ?',
      whereArgs: [username, password],
    );

    return result.isNotEmpty ? result.first : null;
  }

  Future<Map<String, dynamic>?> getUserInfo(int userId) async {
    final db = await instance.database;
    final result = await db.query(
      'users',
      where: 'userid = ?',
      whereArgs: [userId],
    );
    return result.isNotEmpty ? result.first : null;
  }

  Future<int> updateUserInfo(int userId, Map<String, dynamic> updatedValues) async {
    final db = await instance.database;
    return await db.update(
      'users',
      updatedValues,
      where: 'userid = ?',
      whereArgs: [userId],
    );
  }

  Future<List<Map<String, dynamic>>> getUsers() async {
    final db = await instance.database;
    return await db.query('users');
  }

  Future<void> adminDeleteUser(int userId) async {
    final db = await instance.database;

    await db.delete(
      'truckbook',
      where: 'userid = ?',
      whereArgs: [userId],
    );

    await db.delete(
      'users',
      where: 'userid = ?',
      whereArgs: [userId],
    );
  }

  Future<int> adminUpdateUser(int userId, Map<String, dynamic> updatedValues) async {
    final db = await instance.database;

    return await db.update(
      'users',
      updatedValues,
      where: 'userid = ?',
      whereArgs: [userId],
    );
  }

  //============================================================
  //                     BOOKING SECTION
  //============================================================

  Future<int> addBooking(Map<String, dynamic> booking) async {
    final db = await instance.database;
    return await db.insert('truckbook', booking);
  }

  Future<List<Map<String, dynamic>>> getBookings(int userId) async {
    final db = await instance.database;
    return await db.query(
      'truckbook',
      where: 'userid = ?',
      whereArgs: [userId],
    );
  }

  Future<int> updateBooking(int bookingId, Map<String, dynamic> updatedBooking) async {
    final db = await instance.database;
    return await db.update(
      'truckbook',
      updatedBooking,
      where: 'bookid = ?',
      whereArgs: [bookingId],
    );
  }

  Future<int> deleteBooking(int bookingId) async {
    final db = await instance.database;
    return await db.delete(
      'truckbook',
      where: 'bookid = ?',
      whereArgs: [bookingId],
    );
  }

  Future<List<Map<String, dynamic>>> getAllBookings() async {
    final db = await instance.database;
    return await db.query('truckbook');
  }

  Future<void> adminDeleteBooking(int bookingId) async {
    final db = await instance.database;

    await db.delete(
      'truckbook',
      where: 'bookid = ?',
      whereArgs: [bookingId],
    );
  }

  //============================================================
  //                     ADMIN SECTION
  //============================================================

  Future<void> insertAdminData() async {
    final db = await instance.database;

    await db.insert(
      'administrator',
      {
        'username': 'admin',
        'password': 'admin123',
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<Map<String, dynamic>?> loginAdmin(String username, String password) async {
    final db = await instance.database;

    final results = await db.query(
      'administrator',
      where: 'username = ? AND password = ?',
      whereArgs: [username, password],
    );

    return results.isNotEmpty ? results.first : null;
  }

  //============================================================
  //                 FOOD TRUCK MANAGEMENT (NEW)
  //============================================================

  // Get all food trucks
  Future<List<Map<String, dynamic>>> getFoodTrucks() async {
    final db = await instance.database;
    return await db.query('foodtrucks');
  }

  // Add a new food truck
  Future<int> addFoodTruck(String name, String image) async {
    final db = await instance.database;
    return await db.insert('foodtrucks', {
      'name': name,
      'image': image,
    });
  }

  // Delete a food truck
  Future<int> deleteFoodTruck(int id) async {
    final db = await instance.database;
    return await db.delete(
      'foodtrucks',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  //============================================================
  Future<void> close() async {
    final db = await instance.database;
    db.close();
  }
}
