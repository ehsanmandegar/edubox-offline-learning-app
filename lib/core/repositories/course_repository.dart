import '../models/course.dart';
import '../models/lesson.dart';
import '../models/category.dart';

abstract class CourseRepository {
  Future<List<Category>> getAllCategories();
  Future<List<Course>> getAllCourses();
  Future<Course?> getCourseById(String id);
  Future<List<Lesson>> getLessonsForCourse(String courseId);
  Future<Lesson?> getLessonById(String lessonId);
  Future<List<Course>> getCoursesByCategory(String categoryId);
}