class Category {
  final String id;
  final String name;
  final String iconPath;
  final String description;
  final int courseCount;

  Category({
    required this.id,
    required this.name,
    required this.iconPath,
    required this.description,
    this.courseCount = 0,
  });

  factory Category.fromJson(Map<String, dynamic> json) {
    try {
      return Category(
        id: json['id'] as String? ?? '',
        name: json['name'] as String? ?? '',
        iconPath: json['iconPath'] as String? ?? '',
        description: json['description'] as String? ?? '',
        courseCount: json['courseCount'] as int? ?? 0,
      );
    } catch (e) {
      throw FormatException('Invalid category JSON format: $e');
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'iconPath': iconPath,
      'description': description,
      'courseCount': courseCount,
    };
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Category && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() {
    return 'Category(id: $id, name: $name, courseCount: $courseCount)';
  }
}