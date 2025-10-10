import 'package:flutter/material.dart';

/// LessonProgress - Advanced metadata model for iOS 26 neural tracking
/// Tracks completion, emotional state, and learning analytics
class LessonProgress {
  final String lessonId;
  final String courseId;
  final bool isCompleted;
  final DateTime? completedAt;
  final DateTime? lastAccessedAt;
  final double progressPercentage;
  final Map<String, dynamic>? metadata;
  
  // Neural tracking fields
  final EmotionalState? emotionalState;
  final double comprehensionScore;
  final int completionCount;
  final Duration totalTimeSpent;
  final double difficultyRating;
  final List<String> strugglingConcepts;
  final List<String> masteredConcepts;
  final Map<String, double> skillScores;

  const LessonProgress({
    required this.lessonId,
    required this.courseId,
    required this.isCompleted,
    this.completedAt,
    this.lastAccessedAt,
    required this.progressPercentage,
    this.metadata,
    this.emotionalState,
    required this.comprehensionScore,
    required this.completionCount,
    required this.totalTimeSpent,
    required this.difficultyRating,
    this.strugglingConcepts = const [],
    this.masteredConcepts = const [],
    this.skillScores = const {},
  });

  /// Create from JSON with neural data
  factory LessonProgress.fromJson(Map<String, dynamic> json) {
    return LessonProgress(
      lessonId: json['lessonId'] as String,
      courseId: json['courseId'] as String,
      isCompleted: json['isCompleted'] as bool? ?? false,
      completedAt: json['completedAt'] != null 
          ? DateTime.parse(json['completedAt'] as String)
          : null,
      lastAccessedAt: json['lastAccessedAt'] != null
          ? DateTime.parse(json['lastAccessedAt'] as String)
          : null,
      progressPercentage: (json['progressPercentage'] as num?)?.toDouble() ?? 0.0,
      metadata: json['metadata'] as Map<String, dynamic>?,
      emotionalState: json['emotionalState'] != null
          ? EmotionalState.values.firstWhere(
              (e) => e.name == json['emotionalState'],
              orElse: () => EmotionalState.neutral,
            )
          : null,
      comprehensionScore: (json['comprehensionScore'] as num?)?.toDouble() ?? 0.0,
      completionCount: json['completionCount'] as int? ?? 0,
      totalTimeSpent: Duration(
        milliseconds: json['totalTimeSpentMs'] as int? ?? 0,
      ),
      difficultyRating: (json['difficultyRating'] as num?)?.toDouble() ?? 0.0,
      strugglingConcepts: List<String>.from(
        json['strugglingConcepts'] as List? ?? [],
      ),
      masteredConcepts: List<String>.from(
        json['masteredConcepts'] as List? ?? [],
      ),
      skillScores: Map<String, double>.from(
        (json['skillScores'] as Map?)?.map(
          (key, value) => MapEntry(key.toString(), (value as num).toDouble()),
        ) ?? {},
      ),
    );
  }

  /// Convert to JSON with neural data
  Map<String, dynamic> toJson() {
    return {
      'lessonId': lessonId,
      'courseId': courseId,
      'isCompleted': isCompleted,
      'completedAt': completedAt?.toIso8601String(),
      'lastAccessedAt': lastAccessedAt?.toIso8601String(),
      'progressPercentage': progressPercentage,
      'metadata': metadata,
      'emotionalState': emotionalState?.name,
      'comprehensionScore': comprehensionScore,
      'completionCount': completionCount,
      'totalTimeSpentMs': totalTimeSpent.inMilliseconds,
      'difficultyRating': difficultyRating,
      'strugglingConcepts': strugglingConcepts,
      'masteredConcepts': masteredConcepts,
      'skillScores': skillScores,
    };
  }

  /// Create a copy with updated values
  LessonProgress copyWith({
    String? lessonId,
    String? courseId,
    bool? isCompleted,
    DateTime? completedAt,
    DateTime? lastAccessedAt,
    double? progressPercentage,
    Map<String, dynamic>? metadata,
    EmotionalState? emotionalState,
    double? comprehensionScore,
    int? completionCount,
    Duration? totalTimeSpent,
    double? difficultyRating,
    List<String>? strugglingConcepts,
    List<String>? masteredConcepts,
    Map<String, double>? skillScores,
  }) {
    return LessonProgress(
      lessonId: lessonId ?? this.lessonId,
      courseId: courseId ?? this.courseId,
      isCompleted: isCompleted ?? this.isCompleted,
      completedAt: completedAt ?? this.completedAt,
      lastAccessedAt: lastAccessedAt ?? this.lastAccessedAt,
      progressPercentage: progressPercentage ?? this.progressPercentage,
      metadata: metadata ?? this.metadata,
      emotionalState: emotionalState ?? this.emotionalState,
      comprehensionScore: comprehensionScore ?? this.comprehensionScore,
      completionCount: completionCount ?? this.completionCount,
      totalTimeSpent: totalTimeSpent ?? this.totalTimeSpent,
      difficultyRating: difficultyRating ?? this.difficultyRating,
      strugglingConcepts: strugglingConcepts ?? this.strugglingConcepts,
      masteredConcepts: masteredConcepts ?? this.masteredConcepts,
      skillScores: skillScores ?? this.skillScores,
    );
  }

  /// Check if lesson is mastered (high comprehension + multiple completions)
  bool get isMastered {
    return comprehensionScore >= 0.9 && 
           completionCount >= 2 && 
           strugglingConcepts.isEmpty;
  }

  /// Check if lesson needs review (low comprehension or struggling concepts)
  bool get needsReview {
    return comprehensionScore < 0.7 || strugglingConcepts.isNotEmpty;
  }

  /// Get overall performance score (0.0 to 1.0)
  double get performanceScore {
    final comprehensionWeight = 0.4;
    final completionWeight = 0.2;
    final timeWeight = 0.2;
    final masteryWeight = 0.2;
    
    final normalizedComprehension = comprehensionScore;
    final normalizedCompletion = (completionCount / 5.0).clamp(0.0, 1.0);
    final normalizedTime = totalTimeSpent.inMinutes > 0 
        ? (1.0 - (totalTimeSpent.inMinutes / 60.0).clamp(0.0, 1.0))
        : 0.0;
    final normalizedMastery = masteredConcepts.length / 
        (masteredConcepts.length + strugglingConcepts.length + 1);
    
    return (normalizedComprehension * comprehensionWeight) +
           (normalizedCompletion * completionWeight) +
           (normalizedTime * timeWeight) +
           (normalizedMastery * masteryWeight);
  }

  /// Get learning insights based on progress data
  LearningInsights get insights {
    final strengths = <String>[];
    final weaknesses = <String>[];
    final recommendations = <String>[];
    
    // Analyze strengths
    if (comprehensionScore >= 0.8) {
      strengths.add('High comprehension');
    }
    if (completionCount >= 3) {
      strengths.add('Consistent practice');
    }
    if (masteredConcepts.length > strugglingConcepts.length) {
      strengths.add('Strong concept mastery');
    }
    
    // Analyze weaknesses
    if (comprehensionScore < 0.6) {
      weaknesses.add('Low comprehension');
    }
    if (strugglingConcepts.isNotEmpty) {
      weaknesses.add('Struggling with: ${strugglingConcepts.join(', ')}');
    }
    if (totalTimeSpent.inMinutes > 120) {
      weaknesses.add('Taking too long to complete');
    }
    
    // Generate recommendations
    if (needsReview) {
      recommendations.add('Review struggling concepts');
    }
    if (comprehensionScore < 0.7) {
      recommendations.add('Practice more examples');
    }
    if (completionCount == 1 && comprehensionScore >= 0.8) {
      recommendations.add('Move to next lesson');
    }
    
    return LearningInsights(
      strengths: strengths,
      weaknesses: weaknesses,
      recommendations: recommendations,
      overallScore: performanceScore,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is LessonProgress &&
           other.lessonId == lessonId &&
           other.courseId == courseId;
  }

  @override
  int get hashCode => Object.hash(lessonId, courseId);

  @override
  String toString() {
    return 'LessonProgress(lessonId: $lessonId, courseId: $courseId, '
           'isCompleted: $isCompleted, comprehensionScore: $comprehensionScore)';
  }
}

/// Emotional state during learning (for neural tracking)
enum EmotionalState {
  focused('متمرکز', Color(0xFF0077FF)),
  excited('هیجان‌زده', Color(0xFFFF6600)),
  stressed('استرس', Color(0xFFFF0044)),
  confused('گیج', Color(0xFF666677)),
  confident('مطمئن', Color(0xFF00FF77)),
  bored('خسته', Color(0xFF8E8E93)),
  neutral('خنثی', Color(0xFF007AFF));

  const EmotionalState(this.persianName, this.color);
  
  final String persianName;
  final Color color;
}

/// Learning insights generated from progress analysis
class LearningInsights {
  final List<String> strengths;
  final List<String> weaknesses;
  final List<String> recommendations;
  final double overallScore;

  const LearningInsights({
    required this.strengths,
    required this.weaknesses,
    required this.recommendations,
    required this.overallScore,
  });

  /// Get performance level based on overall score
  PerformanceLevel get performanceLevel {
    if (overallScore >= 0.9) return PerformanceLevel.excellent;
    if (overallScore >= 0.8) return PerformanceLevel.good;
    if (overallScore >= 0.6) return PerformanceLevel.average;
    if (overallScore >= 0.4) return PerformanceLevel.needsImprovement;
    return PerformanceLevel.struggling;
  }
}

/// Performance level enumeration
enum PerformanceLevel {
  excellent('عالی', Color(0xFF00FF77)),
  good('خوب', Color(0xFF0077FF)),
  average('متوسط', Color(0xFFFFAA00)),
  needsImprovement('نیاز به بهبود', Color(0xFFFF6600)),
  struggling('مشکل دارد', Color(0xFFFF0044));

  const PerformanceLevel(this.persianName, this.color);
  
  final String persianName;
  final Color color;
}