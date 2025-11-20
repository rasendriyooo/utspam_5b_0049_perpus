import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/user.dart';
import '../models/book.dart';
import '../models/borrow_transaction.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('perpustakaan.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(path, version: 1, onCreate: _createDB);
  }

  Future<void> _createDB(Database db, int version) async {
    const idType = 'INTEGER PRIMARY KEY AUTOINCREMENT';
    const textType = 'TEXT NOT NULL';
    const integerType = 'INTEGER NOT NULL';
    const realType = 'REAL NOT NULL';

    await db.execute('''
      CREATE TABLE users (
        id $idType,
        full_name $textType,
        nik $textType UNIQUE,
        email $textType UNIQUE,
        address $textType,
        phone_number $textType,
        username $textType UNIQUE,
        password $textType,
        created_at $textType
      )
    ''');

    await db.execute('''
      CREATE TABLE books (
        id $idType,
        title $textType,
        genre $textType,
        price_per_day $realType,
        cover_url $textType,
        synopsis $textType,
        author $textType,
        publish_year $integerType
      )
    ''');

    await db.execute('''
      CREATE TABLE borrow_transactions (
        id $idType,
        user_id $integerType,
        book_id $integerType,
        borrower_name $textType,
        duration_days $integerType,
        start_date $textType,
        total_cost $realType,
        status $textType,
        created_at $textType,
        updated_at TEXT,
        FOREIGN KEY (user_id) REFERENCES users (id),
        FOREIGN KEY (book_id) REFERENCES books (id)
      )
    ''');

    await _insertDummyBooks(db);
  }

  Future<void> _insertDummyBooks(Database db) async {
    final dummyBooks = [
      {
        'title': 'Atomic Habits',
        'genre': 'Self-Help',
        'price_per_day': 12000.0,
        'cover_url': 'atomic_habits.jpg',
        'synopsis':
            'An easy and proven way to build good habits and break bad ones.',
        'author': 'James Clear',
        'publish_year': 2018,
      },
      {
        'title': 'The Psychology of Money',
        'genre': 'Finance',
        'price_per_day': 13000.0,
        'cover_url': 'the_psychology_of_money.jpg',
        'synopsis':
            'Timeless lessons on wealth, greed, and happiness doing well with money.',
        'author': 'Morgan Housel',
        'publish_year': 2020,
      },
      {
        'title': 'The Silent Patient',
        'genre': 'Thriller',
        'price_per_day': 12500.0,
        'cover_url': 'the_silent_patient.jpg',
        'synopsis':
            'A woman shoots her husband and then refuses to speak. A psychotherapist is determined to uncover why.',
        'author': 'Alex Michaelides',
        'publish_year': 2019,
      },
      {
        'title': 'The Art of War',
        'genre': 'Philosophy',
        'price_per_day': 10000.0,
        'cover_url': 'the_art_of_war.jpg',
        'synopsis':
            'Ancient Chinese military treatise on strategy and tactics in warfare and negotiation.',
        'author': 'Sun Tzu',
        'publish_year': -500,
      },
    ];

    for (final book in dummyBooks) {
      await db.insert('books', book);
    }
  }

  Future<User> createUser(User user) async {
    final db = await instance.database;
    final id = await db.insert('users', user.toMap());
    return user.copyWith(id: id);
  }

  Future<User?> getUser(int id) async {
    final db = await instance.database;
    final maps = await db.query('users', where: 'id = ?', whereArgs: [id]);

    if (maps.isNotEmpty) {
      return User.fromMap(maps.first);
    }
    return null;
  }

  Future<User?> getUserByEmailOrNik(String emailOrNik) async {
    final db = await instance.database;
    final maps = await db.query(
      'users',
      where: 'email = ? OR nik = ?',
      whereArgs: [emailOrNik, emailOrNik],
    );

    if (maps.isNotEmpty) {
      return User.fromMap(maps.first);
    }
    return null;
  }

  Future<bool> isEmailExists(String email) async {
    final db = await instance.database;
    final result = await db.query(
      'users',
      where: 'email = ?',
      whereArgs: [email],
    );
    return result.isNotEmpty;
  }

  Future<bool> isUsernameExists(String username) async {
    final db = await instance.database;
    final result = await db.query(
      'users',
      where: 'username = ?',
      whereArgs: [username],
    );
    return result.isNotEmpty;
  }

  Future<bool> isNikExists(String nik) async {
    final db = await instance.database;
    final result = await db.query('users', where: 'nik = ?', whereArgs: [nik]);
    return result.isNotEmpty;
  }

  Future<List<Book>> getAllBooks() async {
    final db = await instance.database;
    final result = await db.query('books', orderBy: 'title ASC');
    return result.map((map) => Book.fromMap(map)).toList();
  }

  Future<Book?> getBook(int id) async {
    final db = await instance.database;
    final maps = await db.query('books', where: 'id = ?', whereArgs: [id]);

    if (maps.isNotEmpty) {
      return Book.fromMap(maps.first);
    }
    return null;
  }

  Future<BorrowTransaction> createTransaction(
    BorrowTransaction transaction,
  ) async {
    final db = await instance.database;
    final id = await db.insert('borrow_transactions', transaction.toMap());
    return transaction.copyWith(id: id);
  }

  Future<int> updateTransaction(BorrowTransaction transaction) async {
    final db = await instance.database;
    return db.update(
      'borrow_transactions',
      transaction.copyWith(updatedAt: DateTime.now()).toMap(),
      where: 'id = ?',
      whereArgs: [transaction.id],
    );
  }

  Future<List<BorrowTransaction>> getUserTransactions(int userId) async {
    final db = await instance.database;
    final result = await db.rawQuery(
      '''
      SELECT 
        bt.*,
        b.title as book_title,
        b.cover_url as book_cover_url,
        b.genre as book_genre,
        b.author as book_author,
        b.price_per_day as book_price_per_day
      FROM borrow_transactions bt
      INNER JOIN books b ON bt.book_id = b.id
      WHERE bt.user_id = ?
      ORDER BY bt.created_at DESC
    ''',
      [userId],
    );

    return result.map((map) => BorrowTransaction.fromMap(map)).toList();
  }

  Future<BorrowTransaction?> getTransaction(int id) async {
    final db = await instance.database;
    final result = await db.rawQuery(
      '''
      SELECT 
        bt.*,
        b.title as book_title,
        b.cover_url as book_cover_url,
        b.genre as book_genre,
        b.author as book_author,
        b.price_per_day as book_price_per_day
      FROM borrow_transactions bt
      INNER JOIN books b ON bt.book_id = b.id
      WHERE bt.id = ?
    ''',
      [id],
    );

    if (result.isNotEmpty) {
      return BorrowTransaction.fromMap(result.first);
    }
    return null;
  }

  Future<void> close() async {
    final db = await instance.database;
    db.close();
  }
}
