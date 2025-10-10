/// Content block models for rich lesson content
class ContentBlock {
  final String type;
  final String id;
  final String title;
  final Map<String, dynamic> content;
  final Map<String, dynamic>? style;
  final Map<String, dynamic>? features;

  ContentBlock({
    required this.type,
    required this.id,
    required this.title,
    required this.content,
    this.style,
    this.features,
  });

  factory ContentBlock.fromJson(Map<String, dynamic> json) {
    return ContentBlock(
      type: json['type'] ?? '',
      id: json['id'] ?? '',
      title: json['title'] ?? '',
      content: json['content'] ?? {},
      style: json['style'],
      features: json['features'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'type': type,
      'id': id,
      'title': title,
      'content': content,
      if (style != null) 'style': style,
      if (features != null) 'features': features,
    };
  }
}

/// Specific content block types
class TextContent {
  final String persian;
  final String? english;

  TextContent({required this.persian, this.english});

  factory TextContent.fromJson(Map<String, dynamic> json) {
    return TextContent(
      persian: json['persian'] ?? '',
      english: json['english'],
    );
  }
}

class CodeContent {
  final String code;
  final String language;
  final String? explanation;

  CodeContent({
    required this.code,
    required this.language,
    this.explanation,
  });

  factory CodeContent.fromJson(Map<String, dynamic> json) {
    return CodeContent(
      code: json['code'] ?? '',
      language: json['language'] ?? 'text',
      explanation: json['explanation'],
    );
  }
}

class QuizContent {
  final String question;
  final List<String> options;
  final int correctAnswer;
  final String? explanation;

  QuizContent({
    required this.question,
    required this.options,
    required this.correctAnswer,
    this.explanation,
  });

  factory QuizContent.fromJson(Map<String, dynamic> json) {
    return QuizContent(
      question: json['question'] ?? '',
      options: List<String>.from(json['options'] ?? []),
      correctAnswer: json['correctAnswer'] ?? 0,
      explanation: json['explanation'],
    );
  }
}