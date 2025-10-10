import 'package:flutter/foundation.dart';
import '../models/course.dart';
import '../models/lesson.dart';
import '../models/category.dart';
import '../services/asset_manager.dart';
import 'course_repository.dart';

class LocalCourseRepository implements CourseRepository {
  final AssetManager _assetManager;
  
  // Cache for loaded data
  List<Category>? _cachedCategories;
  final Map<String, List<Course>> _cachedCoursesByCategory = {};
  final Map<String, Course> _cachedCourses = {};

  LocalCourseRepository({AssetManager? assetManager}) 
      : _assetManager = assetManager ?? AssetManager();

  @override
  Future<List<Category>> getAllCategories() async {
    try {
      if (_cachedCategories != null) {
        return _cachedCategories!;
      }

      final categoriesData = await _assetManager.loadJsonAsset('assets/data/categories.json');
      final List<dynamic> categoriesJson = categoriesData['categories'] ?? [];
      
      _cachedCategories = categoriesJson
          .map((json) => Category.fromJson(json as Map<String, dynamic>))
          .toList();

      debugPrint('Loaded ${_cachedCategories!.length} categories');
      return _cachedCategories!;
    } catch (e) {
      debugPrint('Error loading categories: $e');
      return [];
    }
  }

  @override
  Future<List<Course>> getCoursesByCategory(String categoryId) async {
    try {
      if (_cachedCoursesByCategory.containsKey(categoryId)) {
        return _cachedCoursesByCategory[categoryId]!;
      }

      final categoryData = await _assetManager.loadCategoryData(categoryId);
      final List<dynamic> coursesJson = categoryData['courses'] ?? [];
      
      final courses = coursesJson
          .map((json) => Course.fromJson(json as Map<String, dynamic>))
          .toList();

      // Cache courses individually and by category
      _cachedCoursesByCategory[categoryId] = courses;
      for (final course in courses) {
        _cachedCourses[course.id] = course;
      }

      debugPrint('Loaded ${courses.length} courses for category: $categoryId');
      return courses;
    } catch (e) {
      debugPrint('Error loading courses for category $categoryId: $e');
      return [];
    }
  }

  @override
  Future<List<Course>> getAllCourses() async {
    try {
      final categories = await getAllCategories();
      final List<Course> allCourses = [];

      for (final category in categories) {
        final courses = await getCoursesByCategory(category.id);
        allCourses.addAll(courses);
      }

      debugPrint('Loaded total ${allCourses.length} courses');
      return allCourses;
    } catch (e) {
      debugPrint('Error loading all courses: $e');
      return [];
    }
  }

  @override
  Future<Course?> getCourseById(String id) async {
    try {
      // Check cache first
      if (_cachedCourses.containsKey(id)) {
        return _cachedCourses[id];
      }

      // If not in cache, load all courses to find it
      await getAllCourses();
      
      return _cachedCourses[id];
    } catch (e) {
      debugPrint('Error getting course by id $id: $e');
      return null;
    }
  }

  @override
  Future<List<Lesson>> getLessonsForCourse(String courseId) async {
    try {
      final course = await getCourseById(courseId);
      if (course == null) {
        debugPrint('Course not found: $courseId');
        return [];
      }

      // Sort lessons by order
      final lessons = List<Lesson>.from(course.lessons);
      lessons.sort((a, b) => a.order.compareTo(b.order));

      debugPrint('Found ${lessons.length} lessons for course: $courseId');
      return lessons;
    } catch (e) {
      debugPrint('Error getting lessons for course $courseId: $e');
      return [];
    }
  }

  @override
  Future<Lesson?> getLessonById(String lessonId) async {
    try {
      final allCourses = await getAllCourses();
      
      for (final course in allCourses) {
        for (final lesson in course.lessons) {
          if (lesson.id == lessonId) {
            debugPrint('Found lesson: $lessonId in course: ${course.id}');
            return lesson;
          }
        }
      }

      debugPrint('Lesson not found: $lessonId');
      return null;
    } catch (e) {
      debugPrint('Error getting lesson by id $lessonId: $e');
      return null;
    }
  }

  /// Clear all cached data
  void clearCache() {
    _cachedCategories = null;
    _cachedCoursesByCategory.clear();
    _cachedCourses.clear();
    debugPrint('Course repository cache cleared');
  }

  /// Get cache statistics
  Map<String, int> getCacheStats() {
    return {
      'categories': _cachedCategories?.length ?? 0,
      'courses': _cachedCourses.length,
      'coursesByCategory': _cachedCoursesByCategory.length,
    };
  }

  /// Preload all data
  Future<void> preloadAllData() async {
    try {
      debugPrint('Preloading all course data...');
      await getAllCourses();
      debugPrint('All course data preloaded successfully');
    } catch (e) {
      debugPrint('Error preloading course data: $e');
    }
  }
}