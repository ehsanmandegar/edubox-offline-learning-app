import 'package:flutter/foundation.dart';
import '../models/user_progress.dart';
import '../database/database_helper.dart';
import 'course_service.dart';

class ProgressService {
  final DatabaseHelper _databaseHelper;
  final CourseService _courseService;
  final String _defaultUserId = 'default_user';

  ProgressService({
    DatabaseHelper? databaseHelper,
    CourseService? courseService,
  }) : _databaseHelper = databaseHelper ?? DatabaseHelper(),
       _courseService = courseService ?? CourseService();

  /// Mark a lesson as completed
  Future<void> markLessonCompleted(String lessonId) async {
    try {
      await updateLessonProgress(lessonId, 1.0, isCompleted: true);
      debugPrint('Lesson marked as completed: $lessonId');
    } catch (e) {
      debugPrint('Error marking lesson as completed: $e');
      rethrow;
    }
  }

  /// Update lesson progress
  Future<void> updateLessonProgress(
    String lessonId, 
    double progress, {
    bool? isCompleted,
  }) async {
    try {
      // Validate progress value
      if (progress < 0.0 || progress > 1.0) {
        throw ArgumentError('Progress must be between 0.0 and 1.0');
      }

      final userProgress = UserProgress(
        userId: _defaultUserId,
        lessonId: lessonId,
        progress: progress,
        lastAccessed: DateTime.now(),
        isCompleted: isCompleted ?? (progress >= 1.0),
      );

      await _databaseHelper.insertOrUpdateProgress(userProgress);
      debugPrint('Progress updated for lesson $lessonId: ${(progress * 100).toInt()}%');
    } catch (e) {
      debugPrint('Error updating lesson progress: $e');
      rethrow;
    }
  }

  /// Get progress for a specific lesson
  Future<double> getLessonProgress(String lessonId) async {
    try {
      final progress = await _databaseHelper.getProgress(_defaultUserId, lessonId);
      return progress?.progress ?? 0.0;
    } catch (e) {
      debugPrint('Error getting lesson progress: $e');
      return 0.0;
    }
  }

  /// Check if a lesson is completed
  Future<bool> isLessonCompleted(String lessonId) async {
    try {
      final progress = await _databaseHelper.getProgress(_defaultUserId, lessonId);
      return progress?.isCompleted ?? false;
    } catch (e) {
      debugPrint('Error checking lesson completion: $e');
      return false;
    }
  }

  /// Get course progress (percentage of completed lessons)
  Future<double> getCourseProgress(String courseId) async {
    try {
      final lessons = await _courseService.getLessonsForCourse(courseId);
      if (lessons.isEmpty) return 0.0;

      int completedLessons = 0;
      for (final lesson in lessons) {
        final isCompleted = await isLessonCompleted(lesson.id);
        if (isCompleted) {
          completedLessons++;
        }
      }

      final progress = completedLessons / lessons.length;
      debugPrint('Course $courseId progress: ${(progress * 100).toInt()}% ($completedLessons/${lessons.length})');
      return progress;
    } catch (e) {
      debugPrint('Error calculating course progress: $e');
      return 0.0;
    }
  }

  /// Get all completed lessons
  Future<List<String>> getCompletedLessons() async {
    try {
      final allProgress = await _databaseHelper.getAllProgress(_defaultUserId);
      return allProgress.entries
          .where((entry) => entry.value.isCompleted)
          .map((entry) => entry.key)
          .toList();
    } catch (e) {
      debugPrint('Error getting completed lessons: $e');
      return [];
    }
  }

  /// Get all progress data
  Future<Map<String, UserProgress>> getAllProgress() async {
    try {
      return await _databaseHelper.getAllProgress(_defaultUserId);
    } catch (e) {
      debugPrint('Error getting all progress: $e');
      return {};
    }
  }

  /// Get recently accessed lessons
  Future<List<UserProgress>> getRecentlyAccessedLessons({int limit = 10}) async {
    try {
      final allProgress = await getAllProgress();
      final progressList = allProgress.values.toList();
      
      // Sort by last accessed date (most recent first)
      progressList.sort((a, b) => b.lastAccessed.compareTo(a.lastAccessed));
      
      return progressList.take(limit).toList();
    } catch (e) {
      debugPrint('Error getting recently accessed lessons: $e');
      return [];
    }
  }

  /// Get progress statistics for all courses
  Future<Map<String, CourseProgressStats>> getAllCourseProgress() async {
    try {
      final allCourses = await _courseService.getAllCourses();
      final Map<String, CourseProgressStats> courseProgress = {};

      for (final course in allCourses) {
        final progress = await getCourseProgress(course.id);
        final completedLessons = await getCompletedLessonsInCourse(course.id);
        
        courseProgress[course.id] = CourseProgressStats(
          courseId: course.id,
          courseName: course.title,
          totalLessons: course.lessons.length,
          completedLessons: completedLessons.length,
          progress: progress,
        );
      }

      return courseProgress;
    } catch (e) {
      debugPrint('Error getting all course progress: $e');
      return {};
    }
  }

  /// Get completed lessons in a specific course
  Future<List<String>> getCompletedLessonsInCourse(String courseId) async {
    try {
      final lessons = await _courseService.getLessonsForCourse(courseId);
      final completedLessons = <String>[];

      for (final lesson in lessons) {
        final isCompleted = await isLessonCompleted(lesson.id);
        if (isCompleted) {
          completedLessons.add(lesson.id);
        }
      }

      return completedLessons;
    } catch (e) {
      debugPrint('Error getting completed lessons in course: $e');
      return [];
    }
  }

  /// Get next lesson to study (first incomplete lesson in order)
  Future<String?> getNextLessonToStudy(String courseId) async {
    try {
      final lessons = await _courseService.getLessonsForCourse(courseId);
      lessons.sort((a, b) => a.order.compareTo(b.order));

      for (final lesson in lessons) {
        final isCompleted = await isLessonCompleted(lesson.id);
        if (!isCompleted) {
          return lesson.id;
        }
      }

      return null; // All lessons completed
    } catch (e) {
      debugPrint('Error getting next lesson to study: $e');
      return null;
    }
  }

  /// Calculate overall learning statistics
  Future<LearningStats> getLearningStats() async {
    try {
      final allProgress = await getAllProgress();
      final completedLessons = allProgress.values.where((p) => p.isCompleted).length;
      final totalLessons = allProgress.length;
      
      final allCourses = await _courseService.getAllCourses();
      int completedCourses = 0;
      
      for (final course in allCourses) {
        final courseProgress = await getCourseProgress(course.id);
        if (courseProgress >= 1.0) {
          completedCourses++;
        }
      }

      // Calculate study streak (consecutive days with progress)
      final studyStreak = await _calculateStudyStreak();

      return LearningStats(
        totalLessons: totalLessons,
        completedLessons: completedLessons,
        totalCourses: allCourses.length,
        completedCourses: completedCourses,
        studyStreak: studyStreak,
        lastStudyDate: await _getLastStudyDate(),
      );
    } catch (e) {
      debugPrint('Error calculating learning stats: $e');
      return LearningStats(
        totalLessons: 0,
        completedLessons: 0,
        totalCourses: 0,
        completedCourses: 0,
        studyStreak: 0,
        lastStudyDate: null,
      );
    }
  }

  /// Calculate study streak
  Future<int> _calculateStudyStreak() async {
    try {
      final allProgress = await getAllProgress();
      if (allProgress.isEmpty) return 0;

      // Get all unique study dates
      final studyDates = allProgress.values
          .map((p) => DateTime(p.lastAccessed.year, p.lastAccessed.month, p.lastAccessed.day))
          .toSet()
          .toList();

      studyDates.sort((a, b) => b.compareTo(a)); // Sort descending

      if (studyDates.isEmpty) return 0;

      // Check if studied today or yesterday
      final today = DateTime.now();
      final todayDate = DateTime(today.year, today.month, today.day);
      final yesterdayDate = todayDate.subtract(const Duration(days: 1));

      if (!studyDates.contains(todayDate) && !studyDates.contains(yesterdayDate)) {
        return 0; // Streak broken
      }

      // Count consecutive days
      int streak = 0;
      DateTime expectedDate = studyDates.contains(todayDate) ? todayDate : yesterdayDate;

      for (final date in studyDates) {
        if (date == expectedDate) {
          streak++;
          expectedDate = expectedDate.subtract(const Duration(days: 1));
        } else {
          break;
        }
      }

      return streak;
    } catch (e) {
      debugPrint('Error calculating study streak: $e');
      return 0;
    }
  }

  /// Get last study date
  Future<DateTime?> _getLastStudyDate() async {
    try {
      final allProgress = await getAllProgress();
      if (allProgress.isEmpty) return null;

      return allProgress.values
          .map((p) => p.lastAccessed)
          .reduce((a, b) => a.isAfter(b) ? a : b);
    } catch (e) {
      debugPrint('Error getting last study date: $e');
      return null;
    }
  }

  /// Reset all progress (for testing or user request)
  Future<void> resetAllProgress() async {
    try {
      await _databaseHelper.clearAllData();
      debugPrint('All progress data reset');
    } catch (e) {
      debugPrint('Error resetting progress: $e');
      rethrow;
    }
  }
}

/// Course progress statistics
class CourseProgressStats {
  final String courseId;
  final String courseName;
  final int totalLessons;
  final int completedLessons;
  final double progress;

  CourseProgressStats({
    required this.courseId,
    required this.courseName,
    required this.totalLessons,
    required this.completedLessons,
    required this.progress,
  });

  bool get isCompleted => progress >= 1.0;
  int get remainingLessons => totalLessons - completedLessons;

  @override
  String toString() {
    return 'CourseProgressStats(course: $courseName, progress: ${(progress * 100).toInt()}%, completed: $completedLessons/$totalLessons)';
  }
}

/// Overall learning statistics
class LearningStats {
  final int totalLessons;
  final int completedLessons;
  final int totalCourses;
  final int completedCourses;
  final int studyStreak;
  final DateTime? lastStudyDate;

  LearningStats({
    required this.totalLessons,
    required this.completedLessons,
    required this.totalCourses,
    required this.completedCourses,
    required this.studyStreak,
    this.lastStudyDate,
  });

  double get overallProgress => totalLessons > 0 ? completedLessons / totalLessons : 0.0;
  double get courseCompletionRate => totalCourses > 0 ? completedCourses / totalCourses : 0.0;

  @override
  String toString() {
    return 'LearningStats(lessons: $completedLessons/$totalLessons, courses: $completedCourses/$totalCourses, streak: $studyStreak)';
  }
}