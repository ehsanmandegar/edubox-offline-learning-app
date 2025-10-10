import 'package:flutter/foundation.dart';
import '../models/search_result.dart';
import '../models/lesson.dart';
import '../models/course.dart';
import '../models/category.dart';
import 'course_service.dart';

class SearchService {
  final CourseService _courseService;

  SearchService({CourseService? courseService})
      : _courseService = courseService ?? CourseService();

  /// Search across all content (lessons, courses, categories)
  Future<List<SearchResult>> searchContent(String query) async {
    try {
      if (query.trim().isEmpty) return [];

      final results = <SearchResult>[];
      final lowerQuery = query.toLowerCase();

      // Search in lessons
      final lessonResults = await _searchInLessons(lowerQuery);
      results.addAll(lessonResults);

      // Search in course titles and descriptions
      final courseResults = await _searchInCourses(lowerQuery);
      results.addAll(courseResults);

      // Remove duplicates and sort by relevance
      final uniqueResults = _removeDuplicates(results);
      _sortByRelevance(uniqueResults, lowerQuery);

      debugPrint('Search for "$query" returned ${uniqueResults.length} results');
      return uniqueResults;
    } catch (e) {
      debugPrint('Error searching content: $e');
      return [];
    }
  }  /// S
earch within a specific category
  Future<List<SearchResult>> searchByCategory(String categoryId, String query) async {
    try {
      if (query.trim().isEmpty) return [];

      final courses = await _courseService.getCoursesByCategory(categoryId);
      final results = <SearchResult>[];
      final lowerQuery = query.toLowerCase();

      for (final course in courses) {
        // Search in course lessons
        for (final lesson in course.lessons) {
          if (_matchesQuery(lesson, lowerQuery)) {
            final snippet = _generateSnippet(lesson.content, lowerQuery);
            results.add(SearchResult(
              lessonId: lesson.id,
              courseId: course.id,
              title: lesson.title,
              snippet: snippet,
              isAccessible: lesson.isFree, // Will be updated with purchase status
              courseName: course.title,
              categoryName: categoryId,
            ));
          }
        }
      }

      _sortByRelevance(results, lowerQuery);
      debugPrint('Category search for "$query" in $categoryId returned ${results.length} results');
      return results;
    } catch (e) {
      debugPrint('Error searching in category: $e');
      return [];
    }
  }

  /// Search specifically in lessons
  Future<List<SearchResult>> _searchInLessons(String query) async {
    try {
      final allCourses = await _courseService.getAllCourses();
      final results = <SearchResult>[];

      for (final course in allCourses) {
        for (final lesson in course.lessons) {
          if (_matchesQuery(lesson, query)) {
            final snippet = _generateSnippet(lesson.content, query);
            results.add(SearchResult(
              lessonId: lesson.id,
              courseId: course.id,
              title: lesson.title,
              snippet: snippet,
              isAccessible: lesson.isFree,
              courseName: course.title,
            ));
          }
        }
      }

      return results;
    } catch (e) {
      debugPrint('Error searching in lessons: $e');
      return [];
    }
  }

  /// Search in course titles and descriptions
  Future<List<SearchResult>> _searchInCourses(String query) async {
    try {
      final allCourses = await _courseService.getAllCourses();
      final results = <SearchResult>[];

      for (final course in allCourses) {
        if (course.title.toLowerCase().contains(query) ||
            course.description.toLowerCase().contains(query)) {
          
          // Add the first lesson of the course as the result
          if (course.lessons.isNotEmpty) {
            final firstLesson = course.lessons.first;
            final snippet = _generateSnippet(course.description, query);
            
            results.add(SearchResult(
              lessonId: firstLesson.id,
              courseId: course.id,
              title: '${course.title} - ${firstLesson.title}',
              snippet: snippet,
              isAccessible: firstLesson.isFree,
              courseName: course.title,
            ));
          }
        }
      }

      return results;
    } catch (e) {
      debugPrint('Error searching in courses: $e');
      return [];
    }
  }  /// Ch
eck if a lesson matches the search query
  bool _matchesQuery(Lesson lesson, String query) {
    final searchableText = [
      lesson.title,
      lesson.content,
      lesson.translatedContent,
      ...lesson.examples,
    ].join(' ').toLowerCase();

    return searchableText.contains(query);
  }

  /// Generate a snippet from content highlighting the search term
  String _generateSnippet(String content, String query, {int maxLength = 150}) {
    if (content.isEmpty) return '';

    final lowerContent = content.toLowerCase();
    final queryIndex = lowerContent.indexOf(query);

    if (queryIndex == -1) {
      // Query not found, return beginning of content
      return content.length > maxLength 
          ? '${content.substring(0, maxLength)}...'
          : content;
    }

    // Calculate snippet boundaries
    final start = (queryIndex - 50).clamp(0, content.length);
    final end = (queryIndex + query.length + 50).clamp(0, content.length);

    String snippet = content.substring(start, end);
    
    // Add ellipsis if needed
    if (start > 0) snippet = '...$snippet';
    if (end < content.length) snippet = '$snippet...';

    return snippet;
  }

  /// Remove duplicate search results
  List<SearchResult> _removeDuplicates(List<SearchResult> results) {
    final seen = <String>{};
    return results.where((result) {
      final key = '${result.lessonId}_${result.courseId}';
      if (seen.contains(key)) {
        return false;
      }
      seen.add(key);
      return true;
    }).toList();
  }

  /// Sort results by relevance
  void _sortByRelevance(List<SearchResult> results, String query) {
    results.sort((a, b) {
      // Prioritize title matches over content matches
      final aInTitle = a.title.toLowerCase().contains(query) ? 1 : 0;
      final bInTitle = b.title.toLowerCase().contains(query) ? 1 : 0;
      
      if (aInTitle != bInTitle) {
        return bInTitle.compareTo(aInTitle);
      }

      // Prioritize accessible content
      if (a.isAccessible != b.isAccessible) {
        return a.isAccessible ? -1 : 1;
      }

      // Sort alphabetically as final criteria
      return a.title.compareTo(b.title);
    });
  }

  /// Get search suggestions based on popular terms
  Future<List<String>> getSearchSuggestions(String partialQuery) async {
    try {
      if (partialQuery.trim().isEmpty) return [];

      final suggestions = <String>[];
      final lowerQuery = partialQuery.toLowerCase();

      // Get all courses and lessons for suggestions
      final allCourses = await _courseService.getAllCourses();
      
      // Collect potential suggestions from course and lesson titles
      final terms = <String>{};
      
      for (final course in allCourses) {
        // Add course title words
        terms.addAll(_extractWords(course.title));
        
        // Add lesson title words
        for (final lesson in course.lessons) {
          terms.addAll(_extractWords(lesson.title));
        }
      }

      // Filter terms that start with the query
      suggestions.addAll(
        terms.where((term) => term.toLowerCase().startsWith(lowerQuery))
             .take(10)
             .toList()
      );

      suggestions.sort();
      return suggestions;
    } catch (e) {
      debugPrint('Error getting search suggestions: $e');
      return [];
    }
  }

  /// Extract words from text for suggestions
  Set<String> _extractWords(String text) {
    return text
        .toLowerCase()
        .replaceAll(RegExp(r'[^\w\s]'), ' ')
        .split(RegExp(r'\s+'))
        .where((word) => word.length > 2)
        .toSet();
  }

  /// Update search results with purchase status
  List<SearchResult> updateResultsWithPurchaseStatus(
    List<SearchResult> results, {
    Set<String> purchasedCourses = const {},
    bool hasUnlockAll = false,
  }) {
    return results.map((result) {
      final isAccessible = hasUnlockAll || 
                          purchasedCourses.contains(result.courseId) ||
                          result.isAccessible; // Keep original if already accessible (free)
      
      return SearchResult(
        lessonId: result.lessonId,
        courseId: result.courseId,
        title: result.title,
        snippet: result.snippet,
        isAccessible: isAccessible,
        courseName: result.courseName,
        categoryName: result.categoryName,
      );
    }).toList();
  }
}