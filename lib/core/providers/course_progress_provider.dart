import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../models/lesson.dart';
import '../theme/ios26_colors.dart';
import 'purchase_state.dart';

/// CourseProgressProvider - Neural tracking system for iOS 26
/// Manages lesson completion, progress analytics, and AI-powered recommendations
class CourseProgressProvider extends ChangeNotifier {
  final PurchaseState _purchaseState;
  
  // Neural tracking data
  Map<String, Set<String>> _completedLessons = {};
  Map<String, DateTime> _lastAccessTimes = {};
  Map<String, Map<String, dynamic>> _learningAnalytics = {};
  Map<String, double> _courseProgress = {};
  
  // AI recommendations
  Map<String, List<String>> _aiRecommendations = {};
  Map<String, List<String>> _masteredLessons = {};
  
  bool _isInitialized = false;
  
  CourseProgressProvider(this._purchaseState) {
    _purchaseState.addListener(_onPurchaseStateChanged);
    _initialize();
  }

  // Getters
  Map<String, Set<String>> get completedLessons => _completedLessons;
  Map<String, DateTime> get lastAccessTimes => _lastAccessTimes;
  Map<String, double> get courseProgress => _courseProgress;
  bool get isInitialized => _isInitialized;

  /// Initialize the provider and load saved data
  Future<void> _initialize() async {
    if (_isInitialized) return;
    
    try {
      await _loadProgressData();
      await _loadAnalyticsData();
      _isInitialized = true;
      notifyListeners();
    } catch (e) {
      debugPrint('Error initializing CourseProgressProvider: $e');
    }
  }

  /// Load progress data from local storage
  Future<void> _loadProgressData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      
      // Load completed lessons
      final completedJson = prefs.getString('completed_lessons');
      if (completedJson != null) {
        final Map<String, dynamic> data = json.decode(completedJson);
        _completedLessons = data.map((key, value) => 
          MapEntry(key, Set<String>.from(value as List))
        );
      }
      
      // Load last access times
      final accessTimesJson = prefs.getString('last_access_times');
      if (accessTimesJson != null) {
        final Map<String, dynamic> data = json.decode(accessTimesJson);
        _lastAccessTimes = data.map((key, value) => 
          MapEntry(key, DateTime.parse(value as String))
        );
      }
      
      // Load course progress
      final progressJson = prefs.getString('course_progress');
      if (progressJson != null) {
        final Map<String, dynamic> data = json.decode(progressJson);
        _courseProgress = data.map((key, value) => 
          MapEntry(key, (value as num).toDouble())
        );
      }
      
      // Load AI recommendations
      final aiRecommendationsJson = prefs.getString('ai_recommendations');
      if (aiRecommendationsJson != null) {
        final Map<String, dynamic> data = json.decode(aiRecommendationsJson);
        _aiRecommendations = data.map((key, value) => 
          MapEntry(key, List<String>.from(value as List))
        );
      }
      
      // Load mastered lessons
      final masteredJson = prefs.getString('mastered_lessons');
      if (masteredJson != null) {
        final Map<String, dynamic> data = json.decode(masteredJson);
        _masteredLessons = data.map((key, value) => 
          MapEntry(key, List<String>.from(value as List))
        );
      }
      
    } catch (e) {
      debugPrint('Error loading progress data: $e');
    }
  }

  /// Load learning analytics data
  Future<void> _loadAnalyticsData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final analyticsJson = prefs.getString('learning_analytics');
      
      if (analyticsJson != null) {
        final Map<String, dynamic> data = json.decode(analyticsJson);
        _learningAnalytics = data.map((key, value) => 
          MapEntry(key, Map<String, dynamic>.from(value as Map))
        );
      }
    } catch (e) {
      debugPrint('Error loading analytics data: $e');
    }
  }

  /// Save progress data to local storage
  Future<void> _saveProgressData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      
      // Save completed lessons
      final completedData = _completedLessons.map((key, value) => 
        MapEntry(key, value.toList())
      );
      await prefs.setString('completed_lessons', json.encode(completedData));
      
      // Save last access times
      final accessTimesData = _lastAccessTimes.map((key, value) => 
        MapEntry(key, value.toIso8601String())
      );
      await prefs.setString('last_access_times', json.encode(accessTimesData));
      
      // Save course progress
      await prefs.setString('course_progress', json.encode(_courseProgress));
      
      // Save AI recommendations
      await prefs.setString('ai_recommendations', json.encode(_aiRecommendations));
      
      // Save mastered lessons
      await prefs.setString('mastered_lessons', json.encode(_masteredLessons));
      
    } catch (e) {
      debugPrint('Error saving progress data: $e');
    }
  }

  /// Save learning analytics data
  Future<void> _saveAnalyticsData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('learning_analytics', json.encode(_learningAnalytics));
    } catch (e) {
      debugPrint('Error saving analytics data: $e');
    }
  }

  /// Check if a lesson is completed
  bool isLessonCompleted(String courseId, String lessonId) {
    return _completedLessons[courseId]?.contains(lessonId) ?? false;
  }

  /// Mark a lesson as completed with neural tracking
  Future<void> markLessonCompleted(String courseId, String lessonId) async {
    if (!_completedLessons.containsKey(courseId)) {
      _completedLessons[courseId] = <String>{};
    }
    
    _completedLessons[courseId]!.add(lessonId);
    _lastAccessTimes['$courseId:$lessonId'] = DateTime.now();
    
    // Update course progress
    await _updateCourseProgress(courseId);
    
    // Update learning analytics
    _updateLearningAnalytics(courseId, lessonId);
    
    // Generate AI recommendations
    await _generateAIRecommendations(courseId);
    
    // Check for mastery
    _checkForMastery(courseId, lessonId);
    
    await _saveProgressData();
    await _saveAnalyticsData();
    
    notifyListeners();
  }

  /// Update course progress percentage
  Future<void> _updateCourseProgress(String courseId) async {
    // This would typically get the total lessons from a course service
    // For now, we'll calculate based on available data
    final completedCount = _completedLessons[courseId]?.length ?? 0;
    
    // Assuming we have access to total lesson count somehow
    // In a real implementation, this would come from the course data
    final totalLessons = await _getTotalLessonsForCourse(courseId);
    
    if (totalLessons > 0) {
      _courseProgress[courseId] = completedCount / totalLessons;
    }
  }

  /// Get total lessons for a course (placeholder implementation)
  Future<int> _getTotalLessonsForCourse(String courseId) async {
    // This would typically query the course data
    // For now, return a default value
    return 10; // Placeholder
  }

  /// Get course progress percentage
  double getCourseProgress(String courseId) {
    return _courseProgress[courseId] ?? 0.0;
  }

  /// Get lesson status with neural analysis
  LessonStatus getLessonStatus(Lesson lesson) {
    final courseId = lesson.courseId;
    final lessonId = lesson.id;
    
    // Check if mastered
    if (_masteredLessons[courseId]?.contains(lessonId) ?? false) {
      return LessonStatus.mastered;
    }
    
    // Check if completed
    if (isLessonCompleted(courseId, lessonId)) {
      return LessonStatus.completed;
    }
    
    // Check if AI recommended
    if (_aiRecommendations[courseId]?.contains(lessonId) ?? false) {
      return LessonStatus.aiRecommended;
    }
    
    // Check if purchased or free
    if (lesson.isFree || _purchaseState.isPurchased(courseId)) {
      return LessonStatus.available;
    }
    
    // Check if purchased individually (if that's supported)
    if (_purchaseState.isPurchased(lessonId)) {
      return LessonStatus.purchased;
    }
    
    // Default to locked
    return LessonStatus.locked;
  }

  /// Update learning analytics with neural data
  void _updateLearningAnalytics(String courseId, String lessonId) {
    final key = '$courseId:$lessonId';
    final now = DateTime.now();
    
    if (!_learningAnalytics.containsKey(key)) {
      _learningAnalytics[key] = {
        'completionCount': 0,
        'totalTimeSpent': 0,
        'lastCompleted': now.toIso8601String(),
        'difficultyRating': 0.0,
        'comprehensionScore': 0.0,
      };
    }
    
    _learningAnalytics[key]!['completionCount'] = 
        (_learningAnalytics[key]!['completionCount'] as int) + 1;
    _learningAnalytics[key]!['lastCompleted'] = now.toIso8601String();
    
    // Simulate neural analysis (in real implementation, this would use ML)
    _learningAnalytics[key]!['comprehensionScore'] = 
        0.7 + (0.3 * (DateTime.now().millisecondsSinceEpoch % 100) / 100);
  }

  /// Generate AI-powered lesson recommendations
  Future<void> _generateAIRecommendations(String courseId) async {
    // Simulate AI recommendation algorithm
    // In real implementation, this would use machine learning
    
    final completedLessons = _completedLessons[courseId] ?? <String>{};
    final recommendations = <String>[];
    
    // Simple recommendation logic (would be replaced with actual AI)
    if (completedLessons.length >= 3) {
      // Recommend advanced lessons
      recommendations.addAll(['advanced_lesson_1', 'advanced_lesson_2']);
    }
    
    if (completedLessons.length >= 5) {
      // Recommend specialized topics
      recommendations.addAll(['specialized_topic_1']);
    }
    
    _aiRecommendations[courseId] = recommendations;
  }

  /// Check if a lesson should be marked as mastered
  void _checkForMastery(String courseId, String lessonId) {
    final key = '$courseId:$lessonId';
    final analytics = _learningAnalytics[key];
    
    if (analytics != null) {
      final completionCount = analytics['completionCount'] as int;
      final comprehensionScore = analytics['comprehensionScore'] as double;
      
      // Mark as mastered if completed multiple times with high comprehension
      if (completionCount >= 2 && comprehensionScore >= 0.9) {
        if (!_masteredLessons.containsKey(courseId)) {
          _masteredLessons[courseId] = <String>[];
        }
        
        if (!_masteredLessons[courseId]!.contains(lessonId)) {
          _masteredLessons[courseId]!.add(lessonId);
        }
      }
    }
  }

  /// Get AI recommendations for a course
  List<String> getAIRecommendations(String courseId) {
    return _aiRecommendations[courseId] ?? [];
  }

  /// Get mastered lessons for a course
  List<String> getMasteredLessons(String courseId) {
    return _masteredLessons[courseId] ?? [];
  }

  /// Get learning analytics for a lesson
  Map<String, dynamic>? getLearningAnalytics(String courseId, String lessonId) {
    return _learningAnalytics['$courseId:$lessonId'];
  }

  /// Reset progress for a course
  Future<void> resetCourseProgress(String courseId) async {
    _completedLessons.remove(courseId);
    _courseProgress.remove(courseId);
    _aiRecommendations.remove(courseId);
    _masteredLessons.remove(courseId);
    
    // Remove analytics for this course
    _learningAnalytics.removeWhere((key, value) => key.startsWith('$courseId:'));
    _lastAccessTimes.removeWhere((key, value) => key.startsWith('$courseId:'));
    
    await _saveProgressData();
    await _saveAnalyticsData();
    
    notifyListeners();
  }

  /// Handle purchase state changes
  void _onPurchaseStateChanged() {
    // Recalculate lesson statuses when purchase state changes
    notifyListeners();
  }

  /// Get completion statistics for a course
  Map<String, dynamic> getCourseStatistics(String courseId) {
    final completed = _completedLessons[courseId]?.length ?? 0;
    final mastered = _masteredLessons[courseId]?.length ?? 0;
    final progress = _courseProgress[courseId] ?? 0.0;
    
    return {
      'completedLessons': completed,
      'masteredLessons': mastered,
      'progressPercentage': progress,
      'aiRecommendations': _aiRecommendations[courseId]?.length ?? 0,
    };
  }

  @override
  void dispose() {
    _purchaseState.removeListener(_onPurchaseStateChanged);
    super.dispose();
  }
}