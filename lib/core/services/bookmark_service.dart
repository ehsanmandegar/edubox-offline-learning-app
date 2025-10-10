import 'package:flutter/foundation.dart';
import '../models/lesson.dart';
import '../database/database_helper.dart';
import 'course_service.dart';

class BookmarkService {
  final DatabaseHelper _databaseHelper;
  final CourseService _courseService;
  final String _defaultUserId = 'default_user';

  BookmarkService({
    DatabaseHelper? databaseHelper,
    CourseService? courseService,
  }) : _databaseHelper = databaseHelper ?? DatabaseHelper(),
       _courseService = courseService ?? CourseService();

  /// Toggle bookmark status for a lesson
  Future<bool> toggleBookmark(String lessonId) async {
    try {
      final isCurrentlyBookmarked = await isBookmarked(lessonId);
      
      if (isCurrentlyBookmarked) {
        await removeBookmark(lessonId);
        return false;
      } else {
        await addBookmark(lessonId);
        return true;
      }
    } catch (e) {
      debugPrint('Error toggling bookmark: $e');
      rethrow;
    }
  }

  /// Add a lesson to bookmarks
  Future<void> addBookmark(String lessonId) async {
    try {
      final lesson = await _courseService.getLessonById(lessonId);
      if (lesson == null) {
        throw ArgumentError('Lesson not found: $lessonId');
      }

      await _databaseHelper.addBookmark(_defaultUserId, lessonId, lesson.courseId);
      debugPrint('Bookmark added for lesson: $lessonId');
    } catch (e) {
      debugPrint('Error adding bookmark: $e');
      rethrow;
    }
  } 
 /// Remove a lesson from bookmarks
  Future<void> removeBookmark(String lessonId) async {
    try {
      await _databaseHelper.removeBookmark(_defaultUserId, lessonId);
      debugPrint('Bookmark removed for lesson: $lessonId');
    } catch (e) {
      debugPrint('Error removing bookmark: $e');
      rethrow;
    }
  }

  /// Check if a lesson is bookmarked
  Future<bool> isBookmarked(String lessonId) async {
    try {
      return await _databaseHelper.isBookmarked(_defaultUserId, lessonId);
    } catch (e) {
      debugPrint('Error checking bookmark status: $e');
      return false;
    }
  }

  /// Get all bookmarked lessons
  Future<List<Lesson>> getBookmarkedLessons() async {
    try {
      final bookmarkedLessonIds = await _databaseHelper.getBookmarkedLessons(_defaultUserId);
      final lessons = <Lesson>[];

      for (final lessonId in bookmarkedLessonIds) {
        final lesson = await _courseService.getLessonById(lessonId);
        if (lesson != null) {
          lessons.add(lesson);
        }
      }

      debugPrint('Retrieved ${lessons.length} bookmarked lessons');
      return lessons;
    } catch (e) {
      debugPrint('Error getting bookmarked lessons: $e');
      return [];
    }
  }

  /// Get bookmarked lessons organized by category
  Future<Map<String, List<Lesson>>> getBookmarkedLessonsByCategory() async {
    try {
      final bookmarkedLessons = await getBookmarkedLessons();
      final Map<String, List<Lesson>> lessonsByCategory = {};

      for (final lesson in bookmarkedLessons) {
        final course = await _courseService.getCourseById(lesson.courseId);
        if (course != null) {
          final categoryId = course.categoryId;
          lessonsByCategory.putIfAbsent(categoryId, () => []);
          lessonsByCategory[categoryId]!.add(lesson);
        }
      }

      // Sort lessons within each category by course and order
      for (final lessons in lessonsByCategory.values) {
        lessons.sort((a, b) {
          final courseComparison = a.courseId.compareTo(b.courseId);
          if (courseComparison != 0) return courseComparison;
          return a.order.compareTo(b.order);
        });
      }

      debugPrint('Organized bookmarks into ${lessonsByCategory.length} categories');
      return lessonsByCategory;
    } catch (e) {
      debugPrint('Error organizing bookmarks by category: $e');
      return {};
    }
  }

  /// Get bookmarked lessons for a specific course
  Future<List<Lesson>> getBookmarkedLessonsForCourse(String courseId) async {
    try {
      final allBookmarkedLessons = await getBookmarkedLessons();
      final courseLessons = allBookmarkedLessons
          .where((lesson) => lesson.courseId == courseId)
          .toList();

      // Sort by lesson order
      courseLessons.sort((a, b) => a.order.compareTo(b.order));

      debugPrint('Found ${courseLessons.length} bookmarked lessons for course: $courseId');
      return courseLessons;
    } catch (e) {
      debugPrint('Error getting bookmarked lessons for course: $e');
      return [];
    }
  }

  /// Get bookmark statistics
  Future<BookmarkStats> getBookmarkStats() async {
    try {
      final bookmarkedLessons = await getBookmarkedLessons();
      final Map<String, int> courseBookmarkCounts = {};
      final Map<String, int> categoryBookmarkCounts = {};

      for (final lesson in bookmarkedLessons) {
        // Count by course
        courseBookmarkCounts[lesson.courseId] = 
            (courseBookmarkCounts[lesson.courseId] ?? 0) + 1;

        // Count by category
        final course = await _courseService.getCourseById(lesson.courseId);
        if (course != null) {
          categoryBookmarkCounts[course.categoryId] = 
              (categoryBookmarkCounts[course.categoryId] ?? 0) + 1;
        }
      }

      return BookmarkStats(
        totalBookmarks: bookmarkedLessons.length,
        bookmarksByCourse: courseBookmarkCounts,
        bookmarksByCategory: categoryBookmarkCounts,
      );
    } catch (e) {
      debugPrint('Error getting bookmark stats: $e');
      return BookmarkStats(
        totalBookmarks: 0,
        bookmarksByCourse: {},
        bookmarksByCategory: {},
      );
    }
  }

  /// Search within bookmarked lessons
  Future<List<Lesson>> searchBookmarkedLessons(String query) async {
    try {
      if (query.trim().isEmpty) return [];

      final bookmarkedLessons = await getBookmarkedLessons();
      final lowerQuery = query.toLowerCase();

      final matchingLessons = bookmarkedLessons.where((lesson) {
        return lesson.title.toLowerCase().contains(lowerQuery) ||
               lesson.content.toLowerCase().contains(lowerQuery) ||
               lesson.translatedContent.toLowerCase().contains(lowerQuery);
      }).toList();

      debugPrint('Found ${matchingLessons.length} bookmarked lessons matching "$query"');
      return matchingLessons;
    } catch (e) {
      debugPrint('Error searching bookmarked lessons: $e');
      return [];
    }
  }

  /// Get recently bookmarked lessons
  Future<List<Lesson>> getRecentlyBookmarkedLessons({int limit = 10}) async {
    try {
      final bookmarkedLessonIds = await _databaseHelper.getBookmarkedLessons(_defaultUserId);
      final recentLessonIds = bookmarkedLessonIds.take(limit).toList();
      final lessons = <Lesson>[];

      for (final lessonId in recentLessonIds) {
        final lesson = await _courseService.getLessonById(lessonId);
        if (lesson != null) {
          lessons.add(lesson);
        }
      }

      debugPrint('Retrieved ${lessons.length} recently bookmarked lessons');
      return lessons;
    } catch (e) {
      debugPrint('Error getting recently bookmarked lessons: $e');
      return [];
    }
  }

  /// Clear all bookmarks
  Future<void> clearAllBookmarks() async {
    try {
      final bookmarkedLessonIds = await _databaseHelper.getBookmarkedLessons(_defaultUserId);
      
      for (final lessonId in bookmarkedLessonIds) {
        await _databaseHelper.removeBookmark(_defaultUserId, lessonId);
      }

      debugPrint('All bookmarks cleared');
    } catch (e) {
      debugPrint('Error clearing bookmarks: $e');
      rethrow;
    }
  }

  /// Export bookmarks (returns lesson IDs)
  Future<List<String>> exportBookmarks() async {
    try {
      return await _databaseHelper.getBookmarkedLessons(_defaultUserId);
    } catch (e) {
      debugPrint('Error exporting bookmarks: $e');
      return [];
    }
  }

  /// Import bookmarks from lesson IDs
  Future<void> importBookmarks(List<String> lessonIds) async {
    try {
      for (final lessonId in lessonIds) {
        final lesson = await _courseService.getLessonById(lessonId);
        if (lesson != null) {
          await addBookmark(lessonId);
        }
      }

      debugPrint('Imported ${lessonIds.length} bookmarks');
    } catch (e) {
      debugPrint('Error importing bookmarks: $e');
      rethrow;
    }
  }
}

/// Bookmark statistics model
class BookmarkStats {
  final int totalBookmarks;
  final Map<String, int> bookmarksByCourse;
  final Map<String, int> bookmarksByCategory;

  BookmarkStats({
    required this.totalBookmarks,
    required this.bookmarksByCourse,
    required this.bookmarksByCategory,
  });

  String get mostBookmarkedCourse {
    if (bookmarksByCourse.isEmpty) return '';
    return bookmarksByCourse.entries
        .reduce((a, b) => a.value > b.value ? a : b)
        .key;
  }

  String get mostBookmarkedCategory {
    if (bookmarksByCategory.isEmpty) return '';
    return bookmarksByCategory.entries
        .reduce((a, b) => a.value > b.value ? a : b)
        .key;
  }

  @override
  String toString() {
    return 'BookmarkStats(total: $totalBookmarks, courses: ${bookmarksByCourse.length}, categories: ${bookmarksByCategory.length})';
  }
}