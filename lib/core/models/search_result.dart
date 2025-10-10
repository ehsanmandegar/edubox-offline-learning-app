class SearchResult {
  final String lessonId;
  final String courseId;
  final String title;
  final String snippet;
  final bool isAccessible;
  final String courseName;
  final String categoryName;

  SearchResult({
    required this.lessonId,
    required this.courseId,
    required this.title,
    required this.snippet,
    required this.isAccessible,
    this.courseName = '',
    this.categoryName = '',
  });

  factory SearchResult.fromJson(Map<String, dynamic> json) {
    try {
      return SearchResult(
        lessonId: json['lessonId'] as String? ?? '',
        courseId: json['courseId'] as String? ?? '',
        title: json['title'] as String? ?? '',
        snippet: json['snippet'] as String? ?? '',
        isAccessible: json['isAccessible'] as bool? ?? false,
        courseName: json['courseName'] as String? ?? '',
        categoryName: json['categoryName'] as String? ?? '',
      );
    } catch (e) {
      throw FormatException('Invalid search result JSON format: $e');
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'lessonId': lessonId,
      'courseId': courseId,
      'title': title,
      'snippet': snippet,
      'isAccessible': isAccessible,
      'courseName': courseName,
      'categoryName': categoryName,
    };
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is SearchResult &&
        other.lessonId == lessonId &&
        other.courseId == courseId;
  }

  @override
  int get hashCode => Object.hash(lessonId, courseId);

  @override
  String toString() {
    return 'SearchResult(lessonId: $lessonId, title: $title, isAccessible: $isAccessible)';
  }
}