class Lesson {
  final String id;
  final String courseId;
  final String title;
  final String content;
  final String translatedContent;
  final List<String> images;
  final List<String> examples;
  final bool isFree;
  final int order;

  Lesson({
    required this.id,
    required this.courseId,
    required this.title,
    required this.content,
    this.translatedContent = '',
    this.images = const [],
    this.examples = const [],
    required this.isFree,
    required this.order,
  });

  factory Lesson.fromJson(Map<String, dynamic> json) {
    try {
      return Lesson(
        id: json['id'] as String? ?? '',
        courseId: json['courseId'] as String? ?? '',
        title: json['title'] as String? ?? '',
        content: json['content'] as String? ?? '',
        translatedContent: json['translatedContent'] as String? ?? '',
        images: List<String>.from(json['images'] as List<dynamic>? ?? []),
        examples: List<String>.from(json['examples'] as List<dynamic>? ?? []),
        isFree: json['isFree'] as bool? ?? false,
        order: json['order'] as int? ?? 0,
      );
    } catch (e) {
      throw FormatException('Invalid lesson JSON format: $e');
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'courseId': courseId,
      'title': title,
      'content': content,
      'translatedContent': translatedContent,
      'images': images,
      'examples': examples,
      'isFree': isFree,
      'order': order,
    };
  }

  bool get hasTranslation => translatedContent.isNotEmpty;
  bool get hasImages => images.isNotEmpty;
  bool get hasExamples => examples.isNotEmpty;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Lesson && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() {
    return 'Lesson(id: $id, title: $title, isFree: $isFree, order: $order)';
  }
}