import 'package:flutter/foundation.dart';
import '../models/course.dart';
import '../models/lesson.dart';
import '../models/category.dart';
import '../repositories/course_repository.dart';
import '../repositories/local_course_repository.dart';
import '../repositories/purchase_repository.dart';
import '../repositories/local_purchase_repository.dart';

class CourseService {
  final CourseRepository _courseRepository;
  final PurchaseRepository _purchaseRepository;
  
  CourseService({
    CourseRepository? courseRepository,
    PurchaseRepository? purchaseRepository,
  }) : _courseRepository = courseRepository ?? LocalCourseRepository(),
       _purchaseRepository = purchaseRepository ?? LocalPurchaseRepository();

  /// Get all available categories
  Future<List<Category>> getCategories() async {
    try {
      return await _courseRepository.getAllCategories();
    } catch (e) {
      debugPrint('Error getting categories: $e');
      return [];
    }
  }

  /// Get courses for a specific category
  Future<List<Course>> getCoursesByCategory(String categoryId) async {
    try {
      return await _courseRepository.getCoursesByCategory(categoryId);
    } catch (e) {
      debugPrint('Error getting courses for category $categoryId: $e');
      return [];
    }
  }

  /// Get all courses across all categories
  Future<List<Course>> getAllCourses() async {
    try {
      return await _courseRepository.getAllCourses();
    } catch (e) {
      debugPrint('Error getting all courses: $e');
      return [];
    }
  }

  /// Get a specific course by ID
  Future<Course?> getCourseById(String courseId) async {
    try {
      return await _courseRepository.getCourseById(courseId);
    } catch (e) {
      debugPrint('Error getting course $courseId: $e');
      return null;
    }
  }

  /// Get lessons for a specific course
  Future<List<Lesson>> getLessonsForCourse(String courseId) async {
    try {
      return await _courseRepository.getLessonsForCourse(courseId);
    } catch (e) {
      debugPrint('Error getting lessons for course $courseId: $e');
      return [];
    }
  }

  /// Get a specific lesson by ID
  Future<Lesson?> getLessonById(String lessonId) async {
    try {
      return await _courseRepository.getLessonById(lessonId);
    } catch (e) {
      debugPrint('Error getting lesson $lessonId: $e');
      return null;
    }
  }

  /// Check if a lesson can be accessed (free or purchased)
  Future<bool> canAccessLesson(String lessonId) async {
    try {
      final lesson = await getLessonById(lessonId);
      if (lesson == null) {
        debugPrint('Lesson not found: $lessonId');
        return false;
      }

      // If lesson is free, always accessible
      if (lesson.isFree) {
        return true;
      }

      // Check if user has unlock all
      final hasUnlockAll = await _purchaseRepository.hasUnlockAll();
      if (hasUnlockAll) {
        return true;
      }

      // Check if the course is purchased
      return await _purchaseRepository.isPurchased(lesson.courseId);
    } catch (e) {
      debugPrint('Error checking lesson access for $lessonId: $e');
      return false;
    }
  }

  /// Get free lessons for a course (first N lessons)
  Future<List<Lesson>> getFreeLessons(String courseId) async {
    try {
      final lessons = await getLessonsForCourse(courseId);
      return lessons.where((lesson) => lesson.isFree).toList();
    } catch (e) {
      debugPrint('Error getting free lessons for course $courseId: $e');
      return [];
    }
  }

  /// Get premium lessons for a course
  Future<List<Lesson>> getPremiumLessons(String courseId) async {
    try {
      final lessons = await getLessonsForCourse(courseId);
      return lessons.where((lesson) => !lesson.isFree).toList();
    } catch (e) {
      debugPrint('Error getting premium lessons for course $courseId: $e');
      return [];
    }
  }

  /// Get accessible lessons for a course based on purchase status
  Future<List<Lesson>> getAccessibleLessons(String courseId) async {
    try {
      final lessons = await getLessonsForCourse(courseId);
      final accessibleLessons = <Lesson>[];

      for (final lesson in lessons) {
        final canAccess = await canAccessLesson(lesson.id);
        if (canAccess) {
          accessibleLessons.add(lesson);
        }
      }

      return accessibleLessons;
    } catch (e) {
      debugPrint('Error getting accessible lessons for course $courseId: $e');
      return [];
    }
  }

  /// Get course statistics
  Future<CourseStats> getCourseStats(String courseId) async {
    try {
      final lessons = await getLessonsForCourse(courseId);
      final freeLessons = lessons.where((lesson) => lesson.isFree).length;
      final premiumLessons = lessons.where((lesson) => !lesson.isFree).length;

      return CourseStats(
        totalLessons: lessons.length,
        freeLessons: freeLessons,
        premiumLessons: premiumLessons,
      );
    } catch (e) {
      debugPrint('Error getting course stats for $courseId: $e');
      return CourseStats(totalLessons: 0, freeLessons: 0, premiumLessons: 0);
    }
  }

  /// Get next lesson in a course
  Future<Lesson?> getNextLesson(String currentLessonId) async {
    try {
      final currentLesson = await getLessonById(currentLessonId);
      if (currentLesson == null) return null;

      final lessons = await getLessonsForCourse(currentLesson.courseId);
      lessons.sort((a, b) => a.order.compareTo(b.order));

      final currentIndex = lessons.indexWhere((lesson) => lesson.id == currentLessonId);
      if (currentIndex == -1 || currentIndex >= lessons.length - 1) {
        return null; // No next lesson
      }

      return lessons[currentIndex + 1];
    } catch (e) {
      debugPrint('Error getting next lesson for $currentLessonId: $e');
      return null;
    }
  }

  /// Get previous lesson in a course
  Future<Lesson?> getPreviousLesson(String currentLessonId) async {
    try {
      final currentLesson = await getLessonById(currentLessonId);
      if (currentLesson == null) return null;

      final lessons = await getLessonsForCourse(currentLesson.courseId);
      lessons.sort((a, b) => a.order.compareTo(b.order));

      final currentIndex = lessons.indexWhere((lesson) => lesson.id == currentLessonId);
      if (currentIndex <= 0) {
        return null; // No previous lesson
      }

      return lessons[currentIndex - 1];
    } catch (e) {
      debugPrint('Error getting previous lesson for $currentLessonId: $e');
      return null;
    }
  }

  /// Search for courses by title or description
  Future<List<Course>> searchCourses(String query) async {
    try {
      if (query.trim().isEmpty) return [];

      final allCourses = await getAllCourses();
      final lowerQuery = query.toLowerCase();

      return allCourses.where((course) {
        return course.title.toLowerCase().contains(lowerQuery) ||
               course.description.toLowerCase().contains(lowerQuery);
      }).toList();
    } catch (e) {
      debugPrint('Error searching courses: $e');
      return [];
    }
  }

  /// Get featured courses (first course from each category)
  Future<List<Course>> getFeaturedCourses() async {
    try {
      final categories = await getCategories();
      final featuredCourses = <Course>[];

      for (final category in categories) {
        final courses = await getCoursesByCategory(category.id);
        if (courses.isNotEmpty) {
          featuredCourses.add(courses.first);
        }
      }

      return featuredCourses;
    } catch (e) {
      debugPrint('Error getting featured courses: $e');
      return [];
    }
  }
}

/// Course statistics model
class CourseStats {
  final int totalLessons;
  final int freeLessons;
  final int premiumLessons;

  CourseStats({
    required this.totalLessons,
    required this.freeLessons,
    required this.premiumLessons,
  });

  double get freePercentage => totalLessons > 0 ? (freeLessons / totalLessons) * 100 : 0;
  double get premiumPercentage => totalLessons > 0 ? (premiumLessons / totalLessons) * 100 : 0;

  @override
  String toString() {
    return 'CourseStats(total: $totalLessons, free: $freeLessons, premium: $premiumLessons)';
  }
}  /// Pur
chase a course
  Future<bool> purchaseCourse(String courseId) async {
    try {
      return await _purchaseRepository.purchaseCourse(courseId);
    } catch (e) {
      debugPrint('Error purchasing course $courseId: $e');
      return false;
    }
  }

  /// Purchase unlock all courses
  Future<bool> purchaseUnlockAll() async {
    try {
      return await _purchaseRepository.purchaseUnlockAll();
    } catch (e) {
      debugPrint('Error purchasing unlock all: $e');
      return false;
    }
  }

  /// Check if a course is purchased
  Future<bool> isCourseUnlocked(String courseId) async {
    try {
      return await _purchaseRepository.isPurchased(courseId);
    } catch (e) {
      debugPrint('Error checking course unlock status: $e');
      return false;
    }
  }

  /// Get all purchased courses
  Future<Set<String>> getPurchasedCourses() async {
    try {
      final purchased = await _purchaseRepository.getPurchasedCourses();
      return purchased.toSet();
    } catch (e) {
      debugPrint('Error getting purchased courses: $e');
      return {};
    }
  }

  /// Check if user has unlock all
  Future<bool> hasUnlockAll() async {
    try {
      return await _purchaseRepository.hasUnlockAll();
    } catch (e) {
      debugPrint('Error checking unlock all status: $e');
      return false;
    }
  }

  /// Get course with purchase information
  Future<CourseWithPurchaseInfo?> getCourseWithPurchaseInfo(String courseId) async {
    try {
      final course = await getCourseById(courseId);
      if (course == null) return null;

      final isUnlocked = await isCourseUnlocked(courseId);
      final hasUnlockAll = await this.hasUnlockAll();
      final accessibleLessons = await getAccessibleLessons(courseId);

      return CourseWithPurchaseInfo(
        course: course,
        isUnlocked: isUnlocked,
        hasUnlockAll: hasUnlockAll,
        accessibleLessonsCount: accessibleLessons.length,
      );
    } catch (e) {
      debugPrint('Error getting course with purchase info: $e');
      return null;
    }
  }

  /// Get all courses with purchase information
  Future<List<CourseWithPurchaseInfo>> getAllCoursesWithPurchaseInfo() async {
    try {
      final courses = await getAllCourses();
      final coursesWithInfo = <CourseWithPurchaseInfo>[];

      for (final course in courses) {
        final courseInfo = await getCourseWithPurchaseInfo(course.id);
        if (courseInfo != null) {
          coursesWithInfo.add(courseInfo);
        }
      }

      return coursesWithInfo;
    } catch (e) {
      debugPrint('Error getting courses with purchase info: $e');
      return [];
    }
  }

  /// Restore purchases
  Future<void> restorePurchases() async {
    try {
      await _purchaseRepository.restorePurchases();
    } catch (e) {
      debugPrint('Error restoring purchases: $e');
      rethrow;
    }
  }
}

/// Course with purchase information
class CourseWithPurchaseInfo {
  final Course course;
  final bool isUnlocked;
  final bool hasUnlockAll;
  final int accessibleLessonsCount;

  CourseWithPurchaseInfo({
    required this.course,
    required this.isUnlocked,
    required this.hasUnlockAll,
    required this.accessibleLessonsCount,
  });

  bool get canAccessAllLessons => isUnlocked || hasUnlockAll;
  int get lockedLessonsCount => course.totalLessons - accessibleLessonsCount;
  double get accessibilityPercentage => course.totalLessons > 0 
      ? (accessibleLessonsCount / course.totalLessons) * 100 
      : 0;

  @override
  String toString() {
    return 'CourseWithPurchaseInfo(course: ${course.title}, isUnlocked: $isUnlocked, accessible: $accessibleLessonsCount/${course.totalLessons})';
  }
}