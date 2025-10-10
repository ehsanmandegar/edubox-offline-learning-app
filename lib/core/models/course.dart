import 'package:flutter/material.dart';
import 'lesson.dart';

/// Enhanced Course Model for iOS 26
/// Supports neural analytics and holographic presentation
class Course {
  final String id;
  final String categoryId;
  final String title;
  final String description;
  final String iconPath;
  final double price;
  final int freeLessons;
  final List<Lesson> lessons;
  final String? backgroundImagePath;
  final Color? primaryColor;
  final String? estimatedDuration;
  final String? difficulty;
  final Map<String, dynamic>? metadata;

  const Course({
    required this.id,
    required this.categoryId,
    required this.title,
    required this.description,
    required this.iconPath,
    required this.price,
    required this.freeLessons,
    required this.lessons,
    this.backgroundImagePath,
    this.primaryColor,
    this.estimatedDuration,
    this.difficulty,
    this.metadata,
  });

  /// Create from JSON
  factory Course.fromJson(Map<String, dynamic> json) {
    return Course(
      id: json['id'] as String,
      categoryId: json['categoryId'] as String? ?? '',
      title: json['title'] as String,
      description: json['description'] as String? ?? '',
      iconPath: json['iconPath'] as String? ?? '',
      price: (json['price'] as num?)?.toDouble() ?? 0.0,
      freeLessons: json['freeLessons'] as int? ?? 0,
      lessons: (json['lessons'] as List<dynamic>?)
          ?.map((lessonJson) => Lesson.fromJson(lessonJson as Map<String, dynamic>))
          .toList() ?? [],
      backgroundImagePath: json['backgroundImagePath'] as String?,
      primaryColor: json['primaryColor'] != null
          ? Color(json['primaryColor'] as int)
          : null,
      estimatedDuration: json['estimatedDuration'] as String?,
      difficulty: json['difficulty'] as String?,
      metadata: json['metadata'] as Map<String, dynamic>?,
    );
  }

  /// Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'categoryId': categoryId,
      'title': title,
      'description': description,
      'iconPath': iconPath,
      'price': price,
      'freeLessons': freeLessons,
      'lessons': lessons.map((lesson) => lesson.toJson()).toList(),
      'backgroundImagePath': backgroundImagePath,
      'primaryColor': primaryColor?.value,
      'estimatedDuration': estimatedDuration,
      'difficulty': difficulty,
      'metadata': metadata,
    };
  }

  /// Computed properties
  int get totalLessons => lessons.length;
  
  List<Lesson> get freeLessonsList => 
      lessons.where((lesson) => lesson.isFree).toList();
  
  List<Lesson> get paidLessonsList => 
      lessons.where((lesson) => !lesson.isFree).toList();
  
  bool get hasPaidContent => paidLessonsList.isNotEmpty;
  
  bool get isFree => price == 0.0 && paidLessonsList.isEmpty;
  
  /// Get difficulty level
  CourseDifficulty get difficultyLevel {
    switch (difficulty?.toLowerCase()) {
      case 'beginner':
      case 'مبتدی':
        return CourseDifficulty.beginner;
      case 'intermediate':
      case 'متوسط':
        return CourseDifficulty.intermediate;
      case 'advanced':
      case 'پیشرفته':
        return CourseDifficulty.advanced;
      case 'expert':
      case 'تخصصی':
        return CourseDifficulty.expert;
      default:
        return CourseDifficulty.beginner;
    }
  }

  /// Get estimated duration in minutes
  int get estimatedDurationMinutes {
    if (estimatedDuration == null) return 0;
    
    // Parse duration string (e.g., "2h 30m", "90m", "1.5h")
    final duration = estimatedDuration!.toLowerCase();
    int totalMinutes = 0;
    
    // Extract hours
    final hoursMatch = RegExp(r'(\d+(?:\.\d+)?)h').firstMatch(duration);
    if (hoursMatch != null) {
      final hours = double.parse(hoursMatch.group(1)!);
      totalMinutes += (hours * 60).round();
    }
    
    // Extract minutes
    final minutesMatch = RegExp(r'(\d+)m').firstMatch(duration);
    if (minutesMatch != null) {
      totalMinutes += int.parse(minutesMatch.group(1)!);
    }
    
    return totalMinutes;
  }

  /// Get formatted duration string
  String get formattedDuration {
    final minutes = estimatedDurationMinutes;
    if (minutes == 0) return 'نامشخص';
    
    if (minutes < 60) {
      return '$minutes دقیقه';
    } else {
      final hours = minutes ~/ 60;
      final remainingMinutes = minutes % 60;
      if (remainingMinutes == 0) {
        return '$hours ساعت';
      } else {
        return '$hours ساعت و $remainingMinutes دقیقه';
      }
    }
  }

  /// Create a copy with updated values
  Course copyWith({
    String? id,
    String? categoryId,
    String? title,
    String? description,
    String? iconPath,
    double? price,
    int? freeLessons,
    List<Lesson>? lessons,
    String? backgroundImagePath,
    Color? primaryColor,
    String? estimatedDuration,
    String? difficulty,
    Map<String, dynamic>? metadata,
  }) {
    return Course(
      id: id ?? this.id,
      categoryId: categoryId ?? this.categoryId,
      title: title ?? this.title,
      description: description ?? this.description,
      iconPath: iconPath ?? this.iconPath,
      price: price ?? this.price,
      freeLessons: freeLessons ?? this.freeLessons,
      lessons: lessons ?? this.lessons,
      backgroundImagePath: backgroundImagePath ?? this.backgroundImagePath,
      primaryColor: primaryColor ?? this.primaryColor,
      estimatedDuration: estimatedDuration ?? this.estimatedDuration,
      difficulty: difficulty ?? this.difficulty,
      metadata: metadata ?? this.metadata,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Course && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() {
    return 'Course(id: $id, title: $title, totalLessons: $totalLessons)';
  }
}

/// Course difficulty levels
enum CourseDifficulty {
  beginner('مبتدی', Color(0xFF00FF77), 1),
  intermediate('متوسط', Color(0xFF0077FF), 2),
  advanced('پیشرفته', Color(0xFFFF6600), 3),
  expert('تخصصی', Color(0xFFFF0044), 4);

  const CourseDifficulty(this.persianName, this.color, this.level);
  
  final String persianName;
  final Color color;
  final int level;
}