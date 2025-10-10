import 'package:flutter/material.dart';
import '../models/course.dart';
import '../models/category.dart';
import '../services/course_service.dart';

class CourseState extends ChangeNotifier {
  final CourseService _courseService;
  
  List<Category> _categories = [];
  List<Course> _courses = [];
  Course? _selectedCourse;
  bool _isLoading = false;
  String? _error;
  bool _isInitialized = false;

  CourseState({CourseService? courseService}) 
      : _courseService = courseService ?? CourseService();

  List<Category> get categories => _categories;
  List<Course> get courses => _courses;
  Course? get selectedCourse => _selectedCourse;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isInitialized => _isInitialized;

  void setLoading(bool loading) {
    if (_isLoading != loading) {
      _isLoading = loading;
      notifyListeners();
    }
  }

  void setError(String? error) {
    if (_error != error) {
      _error = error;
      notifyListeners();
    }
  }

  void setCategories(List<Category> categories) {
    _categories = categories;
    notifyListeners();
  }

  void setCourses(List<Course> courses) {
    _courses = courses;
    notifyListeners();
  }

  void setSelectedCourse(Course? course) {
    _selectedCourse = course;
    notifyListeners();
  }

  List<Course> getCoursesByCategory(String categoryId) {
    return _courses.where((course) => course.categoryId == categoryId).toList();
  }

  Course? getCourseById(String courseId) {
    try {
      return _courses.firstWhere((course) => course.id == courseId);
    } catch (e) {
      return null;
    }
  }
} 
 /// Initialize course data
  Future<void> initialize() async {
    if (_isInitialized) return;
    
    setLoading(true);
    setError(null);
    
    try {
      await loadCategories();
      await loadAllCourses();
      _isInitialized = true;
    } catch (e) {
      setError('Failed to initialize course data: $e');
    } finally {
      setLoading(false);
    }
  }

  /// Load all categories
  Future<void> loadCategories() async {
    try {
      final categories = await _courseService.getCategories();
      setCategories(categories);
    } catch (e) {
      setError('Failed to load categories: $e');
      rethrow;
    }
  }

  /// Load all courses
  Future<void> loadAllCourses() async {
    try {
      final courses = await _courseService.getAllCourses();
      setCourses(courses);
    } catch (e) {
      setError('Failed to load courses: $e');
      rethrow;
    }
  }

  /// Load courses for a specific category
  Future<void> loadCoursesByCategory(String categoryId) async {
    setLoading(true);
    setError(null);
    
    try {
      final courses = await _courseService.getCoursesByCategory(categoryId);
      setCourses(courses);
    } catch (e) {
      setError('Failed to load courses for category: $e');
    } finally {
      setLoading(false);
    }
  }

  /// Load a specific course
  Future<void> loadCourse(String courseId) async {
    setLoading(true);
    setError(null);
    
    try {
      final course = await _courseService.getCourseById(courseId);
      setSelectedCourse(course);
    } catch (e) {
      setError('Failed to load course: $e');
    } finally {
      setLoading(false);
    }
  }

  /// Refresh all data
  Future<void> refresh() async {
    _isInitialized = false;
    await initialize();
  }
}