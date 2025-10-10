import 'dart:async';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:flutter/foundation.dart';
import '../models/user_progress.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  factory DatabaseHelper() => _instance;
  DatabaseHelper._internal();

  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    try {
      final databasesPath = await getDatabasesPath();
      final path = join(databasesPath, 'edubox.db');

      debugPrint('Initializing database at: $path');

      return await openDatabase(
        path,
        version: 1,
        onCreate: _onCreate,
        onUpgrade: _onUpgrade,
      );
    } catch (e) {
      debugPrint('Error initializing database: $e');
      rethrow;
    }
  }

  Future<void> _onCreate(Database db, int version) async {
    try {
      debugPrint('Creating database tables...');

      // User Progress table
      await db.execute('''
        CREATE TABLE user_progress (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          user_id TEXT NOT NULL,
          lesson_id TEXT NOT NULL,
          progress REAL NOT NULL DEFAULT 0.0,
          last_accessed TEXT NOT NULL,
          is_completed INTEGER NOT NULL DEFAULT 0,
          created_at TEXT NOT NULL DEFAULT CURRENT_TIMESTAMP,
          updated_at TEXT NOT NULL DEFAULT CURRENT_TIMESTAMP,
          UNIQUE(user_id, lesson_id)
        )
      ''');

      // Bookmarks table
      await db.execute('''
        CREATE TABLE bookmarks (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          user_id TEXT NOT NULL,
          lesson_id TEXT NOT NULL,
          course_id TEXT NOT NULL,
          created_at TEXT NOT NULL DEFAULT CURRENT_TIMESTAMP,
          UNIQUE(user_id, lesson_id)
        )
      ''');

      // Purchases table
      await db.execute('''
        CREATE TABLE purchases (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          user_id TEXT NOT NULL,
          course_id TEXT,
          product_id TEXT NOT NULL,
          purchase_token TEXT,
          purchase_time TEXT NOT NULL,
          is_unlock_all INTEGER NOT NULL DEFAULT 0,
          created_at TEXT NOT NULL DEFAULT CURRENT_TIMESTAMP,
          UNIQUE(user_id, product_id)
        )
      ''');

      // Create indexes for better performance
      await db.execute('CREATE INDEX idx_user_progress_user_lesson ON user_progress(user_id, lesson_id)');
      await db.execute('CREATE INDEX idx_bookmarks_user ON bookmarks(user_id)');
      await db.execute('CREATE INDEX idx_purchases_user ON purchases(user_id)');

      debugPrint('Database tables created successfully');
    } catch (e) {
      debugPrint('Error creating database tables: $e');
      rethrow;
    }
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    debugPrint('Upgrading database from version $oldVersion to $newVersion');
    
    // Handle database migrations here
    if (oldVersion < 2) {
      // Example migration for version 2
      // await db.execute('ALTER TABLE user_progress ADD COLUMN new_column TEXT');
    }
  }

  // User Progress operations
  Future<int> insertOrUpdateProgress(UserProgress progress) async {
    try {
      final db = await database;
      
      final progressMap = {
        'user_id': progress.userId,
        'lesson_id': progress.lessonId,
        'progress': progress.progress,
        'last_accessed': progress.lastAccessed.toIso8601String(),
        'is_completed': progress.isCompleted ? 1 : 0,
        'updated_at': DateTime.now().toIso8601String(),
      };

      final result = await db.insert(
        'user_progress',
        progressMap,
        conflictAlgorithm: ConflictAlgorithm.replace,
      );

      debugPrint('Progress saved for lesson: ${progress.lessonId}');
      return result;
    } catch (e) {
      debugPrint('Error saving progress: $e');
      rethrow;
    }
  }

  Future<UserProgress?> getProgress(String userId, String lessonId) async {
    try {
      final db = await database;
      
      final List<Map<String, dynamic>> maps = await db.query(
        'user_progress',
        where: 'user_id = ? AND lesson_id = ?',
        whereArgs: [userId, lessonId],
      );

      if (maps.isNotEmpty) {
        final map = maps.first;
        return UserProgress(
          userId: map['user_id'],
          lessonId: map['lesson_id'],
          progress: map['progress'],
          lastAccessed: DateTime.parse(map['last_accessed']),
          isCompleted: map['is_completed'] == 1,
        );
      }

      return null;
    } catch (e) {
      debugPrint('Error getting progress: $e');
      return null;
    }
  }

  Future<Map<String, UserProgress>> getAllProgress(String userId) async {
    try {
      final db = await database;
      
      final List<Map<String, dynamic>> maps = await db.query(
        'user_progress',
        where: 'user_id = ?',
        whereArgs: [userId],
      );

      final Map<String, UserProgress> progressMap = {};
      
      for (final map in maps) {
        final progress = UserProgress(
          userId: map['user_id'],
          lessonId: map['lesson_id'],
          progress: map['progress'],
          lastAccessed: DateTime.parse(map['last_accessed']),
          isCompleted: map['is_completed'] == 1,
        );
        progressMap[progress.lessonId] = progress;
      }

      debugPrint('Loaded ${progressMap.length} progress records for user: $userId');
      return progressMap;
    } catch (e) {
      debugPrint('Error getting all progress: $e');
      return {};
    }
  }

  // Bookmark operations
  Future<int> addBookmark(String userId, String lessonId, String courseId) async {
    try {
      final db = await database;
      
      final result = await db.insert(
        'bookmarks',
        {
          'user_id': userId,
          'lesson_id': lessonId,
          'course_id': courseId,
          'created_at': DateTime.now().toIso8601String(),
        },
        conflictAlgorithm: ConflictAlgorithm.replace,
      );

      debugPrint('Bookmark added for lesson: $lessonId');
      return result;
    } catch (e) {
      debugPrint('Error adding bookmark: $e');
      rethrow;
    }
  }

  Future<int> removeBookmark(String userId, String lessonId) async {
    try {
      final db = await database;
      
      final result = await db.delete(
        'bookmarks',
        where: 'user_id = ? AND lesson_id = ?',
        whereArgs: [userId, lessonId],
      );

      debugPrint('Bookmark removed for lesson: $lessonId');
      return result;
    } catch (e) {
      debugPrint('Error removing bookmark: $e');
      rethrow;
    }
  }

  Future<List<String>> getBookmarkedLessons(String userId) async {
    try {
      final db = await database;
      
      final List<Map<String, dynamic>> maps = await db.query(
        'bookmarks',
        columns: ['lesson_id'],
        where: 'user_id = ?',
        whereArgs: [userId],
        orderBy: 'created_at DESC',
      );

      final bookmarks = maps.map((map) => map['lesson_id'] as String).toList();
      debugPrint('Loaded ${bookmarks.length} bookmarks for user: $userId');
      return bookmarks;
    } catch (e) {
      debugPrint('Error getting bookmarks: $e');
      return [];
    }
  }

  Future<bool> isBookmarked(String userId, String lessonId) async {
    try {
      final db = await database;
      
      final List<Map<String, dynamic>> maps = await db.query(
        'bookmarks',
        where: 'user_id = ? AND lesson_id = ?',
        whereArgs: [userId, lessonId],
        limit: 1,
      );

      return maps.isNotEmpty;
    } catch (e) {
      debugPrint('Error checking bookmark: $e');
      return false;
    }
  }

  // Purchase operations
  Future<int> recordPurchase({
    required String userId,
    String? courseId,
    required String productId,
    String? purchaseToken,
    required DateTime purchaseTime,
    bool isUnlockAll = false,
  }) async {
    try {
      final db = await database;
      
      final result = await db.insert(
        'purchases',
        {
          'user_id': userId,
          'course_id': courseId,
          'product_id': productId,
          'purchase_token': purchaseToken,
          'purchase_time': purchaseTime.toIso8601String(),
          'is_unlock_all': isUnlockAll ? 1 : 0,
          'created_at': DateTime.now().toIso8601String(),
        },
        conflictAlgorithm: ConflictAlgorithm.replace,
      );

      debugPrint('Purchase recorded: $productId');
      return result;
    } catch (e) {
      debugPrint('Error recording purchase: $e');
      rethrow;
    }
  }

  Future<List<String>> getPurchasedCourses(String userId) async {
    try {
      final db = await database;
      
      final List<Map<String, dynamic>> maps = await db.query(
        'purchases',
        columns: ['course_id'],
        where: 'user_id = ? AND course_id IS NOT NULL',
        whereArgs: [userId],
      );

      final purchases = maps
          .map((map) => map['course_id'] as String?)
          .where((courseId) => courseId != null)
          .cast<String>()
          .toList();

      debugPrint('Loaded ${purchases.length} purchased courses for user: $userId');
      return purchases;
    } catch (e) {
      debugPrint('Error getting purchased courses: $e');
      return [];
    }
  }

  Future<bool> hasUnlockAll(String userId) async {
    try {
      final db = await database;
      
      final List<Map<String, dynamic>> maps = await db.query(
        'purchases',
        where: 'user_id = ? AND is_unlock_all = 1',
        whereArgs: [userId],
        limit: 1,
      );

      return maps.isNotEmpty;
    } catch (e) {
      debugPrint('Error checking unlock all: $e');
      return false;
    }
  }

  // Utility methods
  Future<void> clearAllData() async {
    try {
      final db = await database;
      
      await db.delete('user_progress');
      await db.delete('bookmarks');
      await db.delete('purchases');
      
      debugPrint('All database data cleared');
    } catch (e) {
      debugPrint('Error clearing database: $e');
      rethrow;
    }
  }

  Future<void> close() async {
    final db = _database;
    if (db != null) {
      await db.close();
      _database = null;
      debugPrint('Database closed');
    }
  }
}