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
                  if (course.lessons.isNotEmpty) {
                    Navigator.push(
                      context,
                      PageRouteBuilder(
                        pageBuilder: (context, animation, secondaryAnimation) =>
                            LessonDetailScreen(lesson: course.lessons.first),
                        transitionsBuilder: (context, animation, secondaryAnimation, child) {
                          return SlideTransition(
                            position: Tween<Offset>(
                              begin: const Offset(1.0, 0.0),
                              end: Offset.zero,
                            ).animate(CurvedAnimation(
                              parent: animation,
                              curve: Curves.easeOutCubic,
                            )),
                            child: child,
                          );
                        },
                      ),
                    );
                  }
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


class LessonDetailScreen extends StatefulWidget {
  final Lesson lesson;

  const LessonDetailScreen({super.key, required this.lesson});

  @override
  State<LessonDetailScreen> createState() => _LessonDetailScreenState();
}

class _LessonDetailScreenState extends State<LessonDetailScreen>
    with TickerProviderStateMixin {
  
  late AnimationController _heroController;
  late AnimationController _contentController;
  late AnimationController _floatingController;
  
  late Animation<double> _heroAnimation;
  late Animation<double> _contentAnimation;
  late Animation<double> _floatingAnimation;
  
  bool _showTranslation = false;
  bool _isCompleted = false;

  @override
  void initState() {
    super.initState();
    _setupAnimations();
    _startAnimations();
  }

  void _setupAnimations() {
    _heroController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    
    _contentController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
    
    _floatingController = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    );
    
    _heroAnimation = CurvedAnimation(
      parent: _heroController,
      curve: Curves.easeOutCubic,
    );
    
    _contentAnimation = CurvedAnimation(
      parent: _contentController,
      curve: const Interval(0.3, 1.0, curve: Curves.easeOut),
    );
    
    _floatingAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _floatingController,
      curve: Curves.linear,
    ));
  }

  void _startAnimations() {
    _heroController.forward();
    Future.delayed(const Duration(milliseconds: 300), () {
      _contentController.forward();
    });
    _floatingController.repeat();
  }

  @override
  void dispose() {
    _heroController.dispose();
    _contentController.dispose();
    _floatingController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: Colors.white.withOpacity(0.3),
                width: 1,
              ),
            ),
            child: const Icon(
              Icons.arrow_back_ios_rounded,
              color: Color(0xFF0066FF),
              size: 20,
            ),
          ),
        ),
        actions: [
          IconButton(
            onPressed: () {
              setState(() {
                _isCompleted = !_isCompleted;
              });
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    _isCompleted ? '✅ درس تکمیل شد!' : '📖 درس به عنوان ناتمام علامت‌گذاری شد',
                  ),
                  backgroundColor: _isCompleted 
                      ? const Color(0xFF00FF77) 
                      : const Color(0xFF0066FF),
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              );
            },
            icon: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: _isCompleted 
                    ? const Color(0xFF00FF77).withOpacity(0.2)
                    : Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: _isCompleted 
                      ? const Color(0xFF00FF77).withOpacity(0.5)
                      : Colors.white.withOpacity(0.3),
                  width: 1,
                ),
              ),
              child: Icon(
                _isCompleted ? Icons.check_circle : Icons.radio_button_unchecked,
                color: _isCompleted ? const Color(0xFF00FF77) : const Color(0xFF0066FF),
                size: 20,
              ),
            ),
          ),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              const Color(0xFF0066FF).withOpacity(0.1),
              const Color(0xFFF2F2F7),
              const Color(0xFF5856D6).withOpacity(0.1),
            ],
          ),
        ),
        child: Stack(
          children: [
            // Floating particles background
            _buildFloatingParticles(),
            
            // Main content
            SafeArea(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Hero section
                    FadeTransition(
                      opacity: _heroAnimation,
                      child: SlideTransition(
                        position: Tween<Offset>(
                          begin: const Offset(0, -0.3),
                          end: Offset.zero,
                        ).animate(_heroAnimation),
                        child: _buildHeroSection(),
                      ),
                    ),
                    
                    const SizedBox(height: 30),
                    
                    // Content section
                    FadeTransition(
                      opacity: _contentAnimation,
                      child: SlideTransition(
                        position: Tween<Offset>(
                          begin: const Offset(0, 0.3),
                          end: Offset.zero,
                        ).animate(_contentAnimation),
                        child: _buildContentSection(),
                      ),
                    ),
                    
                    const SizedBox(height: 30),
                    
                    // Examples section
                    if (widget.lesson.examples.isNotEmpty)
                      FadeTransition(
                        opacity: _contentAnimation,
                        child: _buildExamplesSection(),
                      ),
                    
                    const SizedBox(height: 100), // Space for floating button
                  ],
                ),
              ),
            ),
            
            // Floating action button
            _buildFloatingActionButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildFloatingParticles() {
    return AnimatedBuilder(
      animation: _floatingAnimation,
      builder: (context, child) {
        return Stack(
          children: List.generate(8, (index) {
            final progress = (_floatingAnimation.value + (index * 0.125)) % 1.0;
            final size = MediaQuery.of(context).size;
            
            return Positioned(
              left: (index * size.width / 8) + (progress * 50),
              top: size.height * 0.2 + (30 * (index % 2 == 0 ? 1 : -1)) * progress,
              child: Container(
                width: 4 + (progress * 6),
                height: 4 + (progress * 6),
                decoration: BoxDecoration(
                  color: const Color(0xFF0066FF).withOpacity(0.1 + (progress * 0.2)),
                  shape: BoxShape.circle,
                ),
              ),
            );
          }),
        );
      },
    );
  }

  Widget _buildHeroSection() {
    return HyperGlassContainer(
      padding: const EdgeInsets.all(24),
      enableHolographicShimmer: true,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      const Color(0xFF0066FF),
                      _isCompleted ? const Color(0xFF00FF77) : const Color(0xFF5856D6),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF0066FF).withOpacity(0.3),
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: Icon(
                  _isCompleted ? Icons.check_circle : Icons.play_lesson_rounded,
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
                      'درس ${widget.lesson.order}',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey.shade600,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      widget.lesson.title,
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF0066FF),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 20),
          
          Row(
            children: [
              _buildStatusChip(
                widget.lesson.isFree ? 'رایگان' : 'پریمیوم',
                widget.lesson.isFree ? Icons.lock_open : Icons.lock,
                widget.lesson.isFree ? const Color(0xFF00FF77) : const Color(0xFFFF6600),
              ),
              const SizedBox(width: 12),
              _buildStatusChip(
                _isCompleted ? 'تکمیل شده' : 'در حال مطالعه',
                _isCompleted ? Icons.check_circle : Icons.play_circle,
                _isCompleted ? const Color(0xFF00FF77) : const Color(0xFF0066FF),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildContentSection() {
    return HyperGlassContainer(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'محتوای درس',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF0066FF),
                ),
              ),
              if (widget.lesson.hasTranslation)
                TextButton.icon(
                  onPressed: () {
                    setState(() {
                      _showTranslation = !_showTranslation;
                    });
                  },
                  icon: Icon(
                    _showTranslation ? Icons.translate_off : Icons.translate,
                    size: 18,
                    color: const Color(0xFF0066FF),
                  ),
                  label: Text(
                    _showTranslation ? 'انگلیسی' : 'ترجمه',
                    style: const TextStyle(
                      color: Color(0xFF0066FF),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
            ],
          ),
          
          const SizedBox(height: 16),
          
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 300),
            child: Container(
              key: ValueKey(_showTranslation),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFF0066FF).withOpacity(0.05),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: const Color(0xFF0066FF).withOpacity(0.1),
                  width: 1,
                ),
              ),
              child: Text(
                _showTranslation && widget.lesson.hasTranslation
                    ? widget.lesson.translatedContent
                    : widget.lesson.content,
                style: TextStyle(
                  fontSize: 16,
                  height: 1.6,
                  color: Colors.grey.shade800,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildExamplesSection() {
    return HyperGlassContainer(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'مثال‌های کاربردی',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Color(0xFF0066FF),
            ),
          ),
          
          const SizedBox(height: 16),
          
          ...widget.lesson.examples.asMap().entries.map((entry) {
            final index = entry.key;
            final example = entry.value;
            
            return Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.grey.shade900,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: const Color(0xFF0066FF).withOpacity(0.3),
                    width: 1,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        color: const Color(0xFF0066FF).withOpacity(0.1),
                        borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.code,
                            color: const Color(0xFF0066FF),
                            size: 16,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'مثال ${index + 1}',
                            style: const TextStyle(
                              color: Color(0xFF0066FF),
                              fontWeight: FontWeight.w600,
                              fontSize: 14,
                            ),
                          ),
                          const Spacer(),
                          IconButton(
                            onPressed: () {
                              // Copy to clipboard
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('کد کپی شد! 📋'),
                                  backgroundColor: Color(0xFF00FF77),
                                  behavior: SnackBarBehavior.floating,
                                ),
                              );
                            },
                            icon: const Icon(
                              Icons.copy,
                              color: Color(0xFF0066FF),
                              size: 16,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: Text(
                        example,
                        style: const TextStyle(
                          fontFamily: 'monospace',
                          fontSize: 14,
                          color: Colors.white,
                          height: 1.4,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
        ],
      ),
    );
  }

  Widget _buildStatusChip(String text, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
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
            size: 16,
            color: color,
          ),
          const SizedBox(width: 6),
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

  Widget _buildFloatingActionButton() {
    return Positioned(
      bottom: 30,
      right: 20,
      left: 20,
      child: FadeTransition(
        opacity: _contentAnimation,
        child: SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(0, 1),
            end: Offset.zero,
          ).animate(_contentAnimation),
          child: HyperGlassContainer(
            padding: const EdgeInsets.all(16),
            enableHolographicShimmer: true,
            child: Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('🎯 درس بعدی در حال بارگذاری...'),
                          backgroundColor: Color(0xFF0066FF),
                          behavior: SnackBarBehavior.floating,
                        ),
                      );
                    },
                    icon: const Icon(Icons.arrow_forward_rounded),
                    label: const Text(
                      'درس بعدی',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF0066FF),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Container(
                  decoration: BoxDecoration(
                    color: const Color(0xFF00FF77).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: const Color(0xFF00FF77).withOpacity(0.3),
                      width: 1,
                    ),
                  ),
                  child: IconButton(
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('💾 درس ذخیره شد!'),
                          backgroundColor: Color(0xFF00FF77),
                          behavior: SnackBarBehavior.floating,
                        ),
                      );
                    },
                    icon: const Icon(
                      Icons.bookmark_add_rounded,
                      color: Color(0xFF00FF77),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}