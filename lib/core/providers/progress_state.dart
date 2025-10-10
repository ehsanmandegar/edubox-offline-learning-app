import 'package:flutter/material.dart';
import '../models/user_progress.dart';
import '../services/progress_service.dart';

class ProgressState extends ChangeNotifier {
  final ProgressService _progressService;
  
  Map<String, UserProgress> _lessonProgress = {};
  Map<String, double> _courseProgress = {};
  bool _isInitialized = false;

  ProgressState({ProgressService? progressService}) 
      : _progressService = progressService ?? ProgressService();

  Map<String, UserProgress> get lessonProgress => _lessonProgress;
  Map<String, double> get courseProgress => _courseProgress;
  bool get isInitialized => _isInitialized;

  void updateLessonProgress(String lessonId, double progress, {bool isCompleted = false}) {
    final currentProgress = _lessonProgress[lessonId];
    final newProgress = UserProgress(
      userId: 'default_user',
      lessonId: lessonId,
      progress: progress,
      lastAccessed: DateTime.now(),
      isCompleted: isCompleted,
    );

    if (currentProgress != newProgress) {
      _lessonProgress[lessonId] = newProgress;
      notifyListeners();
    }
  }

  void markLessonCompleted(String lessonId) {
    updateLessonProgress(lessonId, 1.0, isCompleted: true);
  }

  void updateCourseProgress(String courseId, double progress) {
    if (_courseProgress[courseId] != progress) {
      _courseProgress[courseId] = progress;
      notifyListeners();
    }
  }

  double getLessonProgress(String lessonId) {
    return _lessonProgress[lessonId]?.progress ?? 0.0;
  }

  bool isLessonCompleted(String lessonId) {
    return _lessonProgress[lessonId]?.isCompleted ?? false;
  }

  double getCourseProgress(String courseId) {
    return _courseProgress[courseId] ?? 0.0;
  }

  List<String> getCompletedLessons() {
    return _lessonProgress.entries
        .where((entry) => entry.value.isCompleted)
        .map((entry) => entry.key)
        .toList();
  }

  void loadProgress(Map<String, UserProgress> progress) {
    _lessonProgress = progress;
    notifyListeners();
  }
} 
 /// Initialize progress data
  Future<void> initialize() async {
    if (_isInitialized) return;
    
    try {
      await _loadAllProgress();
      _isInitialized = true;
    } catch (e) {
      debugPrint('Error initializing progress state: $e');
    }
  }

  /// Load all progress data
  Future<void> _loadAllProgress() async {
    try {
      final allProgress = await _progressService.getAllProgress();
      loadProgress(allProgress);
      
      // Load course progress
      final courseProgressStats = await _progressService.getAllCourseProgress();
      final courseProgressMap = <String, double>{};
      
      for (final entry in courseProgressStats.entries) {
        courseProgressMap[entry.key] = entry.value.progress;
      }
      
      _courseProgress = courseProgressMap;
      notifyListeners();
    } catch (e) {
      debugPrint('Error loading progress data: $e');
    }
  }

  /// Update lesson progress
  Future<void> updateLessonProgress(String lessonId, double progress, {bool isCompleted = false}) async {
    try {
      await _progressService.updateLessonProgress(lessonId, progress, isCompleted: isCompleted);
      
      // Update local state
      final userProgress = UserProgress(
        userId: 'default_user',
        lessonId: lessonId,
        progress: progress,
        lastAccessed: DateTime.now(),
        isCompleted: isCompleted,
      );
      
      _lessonProgress[lessonId] = userProgress;
      
      // Refresh course progress will be handled by the next refresh call
      
      notifyListeners();
    } catch (e) {
      debugPrint('Error updating lesson progress: $e');
    }
  }

  /// Mark lesson as completed
  Future<void> markLessonCompleted(String lessonId) async {
    try {
      await _progressService.markLessonCompleted(lessonId);
      await updateLessonProgress(lessonId, 1.0, isCompleted: true);
    } catch (e) {
      debugPrint('Error marking lesson as completed: $e');
    }
  }

  /// Get lesson progress
  double getLessonProgress(String lessonId) {
    return _lessonProgress[lessonId]?.progress ?? 0.0;
  }

  /// Check if lesson is completed
  bool isLessonCompleted(String lessonId) {
    return _lessonProgress[lessonId]?.isCompleted ?? false;
  }

  /// Get course progress
  double getCourseProgress(String courseId) {
    return _courseProgress[courseId] ?? 0.0;
  }

  /// Get completed lessons
  List<String> getCompletedLessons() {
    return _lessonProgress.entries
        .where((entry) => entry.value.isCompleted)
        .map((entry) => entry.key)
        .toList();
  }

  /// Get recently accessed lessons
  Future<List<UserProgress>> getRecentlyAccessedLessons({int limit = 10}) async {
    try {
      return await _progressService.getRecentlyAccessedLessons(limit: limit);
    } catch (e) {
      debugPrint('Error getting recently accessed lessons: $e');
      return [];
    }
  }

  /// Get learning statistics
  Future<LearningStats> getLearningStats() async {
    try {
      return await _progressService.getLearningStats();
    } catch (e) {
      debugPrint('Error getting learning stats: $e');
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

  /// Refresh progress data
  Future<void> refresh() async {
    await _loadAllProgress();
  }

  /// Reset all progress
  Future<void> resetAllProgress() async {
    try {
      await _progressService.resetAllProgress();
      _lessonProgress.clear();
      _courseProgress.clear();
      notifyListeners();
    } catch (e) {
      debugPrint('Error resetting progress: $e');
    }
  }
}