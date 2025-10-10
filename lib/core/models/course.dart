import 'lesson.dart';

class Course {
  final String id;
  final String categoryId;
  final String title;
  final String description;
  final String iconPath;
  final List<Lesson> lessons;
  final double price;
  final int freeLessons;

  Course({
    required this.id,
    required this.categoryId,
    required this.title,
    required this.description,
    required this.iconPath,
    required this.lessons,
    required this.price,
    this.freeLessons = 3,
  });

  int get totalLessons => lessons.length;

  factory Course.fromJson(Map<String, dynamic> json) {
    try {
      final lessonsJson = json['lessons'] as List<dynamic>? ?? [];
      final lessons = lessonsJson
          .map((lessonJson) => Lesson.fromJson(lessonJson as Map<String, dynamic>))
          .toList();

      return Course(
        id: json['id'] as String? ?? '',
        categoryId: json['categoryId'] as String? ?? '',
        title: json['title'] as String? ?? '',
        description: json['description'] as String? ?? '',
        iconPath: json['iconPath'] as String? ?? '',
        price: (json['price'] as num?)?.toDouble() ?? 0.0,
        freeLessons: json['freeLessons'] as int? ?? 3,
        lessons: lessons,
      );
    } catch (e) {
      throw FormatException('Invalid course JSON format: $e');
    }
  }

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
    };
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
    return 'Course(id: $id, title: $title, lessons: ${lessons.length})';
  }
}