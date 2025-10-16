import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:convert';
import 'package:flutter/services.dart';
import 'core/theme/app_theme.dart';
import 'core/models/course.dart';
import 'core/models/lesson.dart';
import 'core/widgets/hyper_glass_container.dart';

void main() {
  runApp(const EduBoxApp());
}

class EduBoxApp extends StatelessWidget {
  const EduBoxApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'EduBox - iOS 26',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.system,
      home: const CourseListScreen(),
    );
  }
}

class CourseListScreen extends StatefulWidget {
  const CourseListScreen({super.key});

  @override
  State<CourseListScreen> createState() => _CourseListScreenState();
}

class _CourseListScreenState extends State<CourseListScreen>
    with TickerProviderStateMixin {
  
  List<Course> _courses = [];
  bool _isLoading = true;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _setupAnimations();
    _loadCourses();
  }

  void _setupAnimations() {
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOut,
    ));
  }

  Future<void> _loadCourses() async {
    try {
      final String jsonString = await rootBundle.loadString('assets/data/html_complete.json');
      final Map<String, dynamic> jsonData = json.decode(jsonString);
      final List<dynamic> coursesJson = jsonData['courses'] as List;
      
      final courses = coursesJson
          .map((courseJson) => Course.fromJson(courseJson as Map<String, dynamic>))
          .toList();
      
      setState(() {
        _courses = courses;
        _isLoading = false;
      });
      
      _animationController.forward();
      
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      debugPrint('Error loading courses: $e');
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text(
          'دوره‌های آموزشی',
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: Color(0xFF0066FF),
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: false,
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFFF2F2F7),
              Color(0xFFE5E5EA),
              Color(0xFFF2F2F7),
            ],
          ),
        ),
        child: SafeArea(
          child: _isLoading
              ? const Center(
                  child: CircularProgressIndicator(
                    color: Color(0xFF0066FF),
                  ),
                )
              : FadeTransition(
                  opacity: _fadeAnimation,
                  child: _buildCourseList(),
                ),
        ),
      ),
    );
  }

  Widget _buildCourseList() {
    if (_courses.isEmpty) {
      return const Center(
        child: Text(
          'هیچ دوره‌ای یافت نشد',
          style: TextStyle(
            fontSize: 18,
            color: Colors.grey,
          ),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(20),
      itemCount: _courses.length,
      itemBuilder: (context, index) {
        final course = _courses[index];
        return Padding(
          padding: const EdgeInsets.only(bottom: 20),
          child: HyperGlassContainer(
            padding: const EdgeInsets.all(20),
            enableHolographicShimmer: false,
            onTap: () => _showCourseDetails(course),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 60,
                      height: 60,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFF0066FF), Color(0xFF5856D6)],
                        ),
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF0066FF).withOpacity(0.3),
                            blurRadius: 15,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.code_rounded,
                        color: Colors.white,
                        size: 28,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            course.title,
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF0066FF),
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            course.description,
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey.shade600,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    _buildInfoChip(
                      '${course.totalLessons} درس',
                      Icons.play_lesson_rounded,
                      const Color(0xFF0066FF),
                    ),
                    const SizedBox(width: 12),
                    _buildInfoChip(
                      course.formattedDuration,
                      Icons.access_time_rounded,
                      const Color(0xFFFF6600),
                    ),
                    const SizedBox(width: 12),
                    _buildInfoChip(
                      course.difficultyLevel.persianName,
                      Icons.trending_up_rounded,
                      course.difficultyLevel.color,
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildInfoChip(String text, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: color.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 14,
            color: color,
          ),
          const SizedBox(width: 4),
          Text(
            text,
            style: TextStyle(
              fontSize: 12,
              color: color,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  void _showCourseDetails(Course course) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => HyperGlassContainer(
        padding: const EdgeInsets.all(24),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              course.title,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Color(0xFF0066FF),
              ),
            ),
            const SizedBox(height: 12),
            Text(
              course.description,
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 20),
            Text(
              'درس‌ها (${course.totalLessons}):',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Color(0xFF0066FF),
              ),
            ),
            const SizedBox(height: 12),
            ...course.lessons.take(5).map((lesson) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                children: [
                  Icon(
                    lesson.isFree ? Icons.play_circle : Icons.lock,
                    color: lesson.isFree ? const Color(0xFF00FF77) : Colors.grey,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      lesson.title,
                      style: TextStyle(
                        fontSize: 14,
                        color: lesson.isFree ? Colors.black : Colors.grey,
                      ),
                    ),
                  ),
                ],
              ),
            )).toList(),
            if (course.lessons.length > 5)
              Text(
                '... و ${course.lessons.length - 5} درس دیگر',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey.shade600,
                  fontStyle: FontStyle.italic,
                ),
              ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('شروع دوره: ${course.title}'),
                      backgroundColor: const Color(0xFF0066FF),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF0066FF),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  'شروع دوره',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

