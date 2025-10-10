class UserProgress {
  final String userId;
  final String lessonId;
  final double progress; // 0.0 to 1.0
  final DateTime lastAccessed;
  final bool isCompleted;

  UserProgress({
    required this.userId,
    required this.lessonId,
    required this.progress,
    required this.lastAccessed,
    required this.isCompleted,
  });

  factory UserProgress.fromJson(Map<String, dynamic> json) {
    try {
      return UserProgress(
        userId: json['userId'] as String? ?? '',
        lessonId: json['lessonId'] as String? ?? '',
        progress: (json['progress'] as num?)?.toDouble() ?? 0.0,
        lastAccessed: DateTime.parse(json['lastAccessed'] as String? ?? DateTime.now().toIso8601String()),
        isCompleted: json['isCompleted'] as bool? ?? false,
      );
    } catch (e) {
      throw FormatException('Invalid user progress JSON format: $e');
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'lessonId': lessonId,
      'progress': progress,
      'lastAccessed': lastAccessed.toIso8601String(),
      'isCompleted': isCompleted,
    };
  }

  UserProgress copyWith({
    String? userId,
    String? lessonId,
    double? progress,
    DateTime? lastAccessed,
    bool? isCompleted,
  }) {
    return UserProgress(
      userId: userId ?? this.userId,
      lessonId: lessonId ?? this.lessonId,
      progress: progress ?? this.progress,
      lastAccessed: lastAccessed ?? this.lastAccessed,
      isCompleted: isCompleted ?? this.isCompleted,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is UserProgress &&
        other.userId == userId &&
        other.lessonId == lessonId &&
        other.progress == progress &&
        other.lastAccessed == lastAccessed &&
        other.isCompleted == isCompleted;
  }

  @override
  int get hashCode {
    return Object.hash(userId, lessonId, progress, lastAccessed, isCompleted);
  }

  @override
  String toString() {
    return 'UserProgress(userId: $userId, lessonId: $lessonId, progress: $progress, isCompleted: $isCompleted)';
  }
}