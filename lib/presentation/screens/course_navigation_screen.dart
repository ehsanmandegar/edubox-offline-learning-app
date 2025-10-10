import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:convert';
import 'package:flutter/services.dart';
import '../../core/models/course.dart';
import '../../core/models/lesson.dart';
import '../../core/providers/course_progress_provider.dart';
import '../../core/providers/purchase_state.dart';
import '../../core/theme/ios26_colors.dart';
import '../../core/theme/ios26_typography.dart';
import '../../core/theme/ios26_animations.dart';
import '../../core/widgets/hyper_glass_container.dart';
import '../widgets/course_card.dart';
import '../widgets/glass_app_bar.dart';
import 'rich_lesson_screen.dart';

/// CourseNavigationScreen - iOS 26 Neural Course Navigation
/// Features holographic glass morphism, AI-powered recommendations, and quantum animations
class CourseNavigationScreen extends StatefulWidget {
  const CourseNavigationScreen({super.key});

  @override
  State<CourseNavigationScreen> createState() => _CourseNavigationScreenState();
}

class _CourseNavigationScreenState extends State<CourseNavigationScreen>
    with TickerProviderStateMixin {
  
  List<Course> _courses = [];
  bool _isLoading = true;
  String? _error;
  
  // Animation controllers
  late AnimationController _mainAnimationController;
  late AnimationController _backgroundController;
  late AnimationController _staggerController;
  
  // Animations
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _backgroundAnimation;

  @override
  void initState() {
    super.initState();
    _setupAnimations();
    _loadCourses();
  }

  void _setupAnimations() {
    // Main animation controller for entrance
    _mainAnimationController = AnimationController(
      duration: iOS26Animations.cosmicTransition,
      vsync: this,
    );
    
    // Background animation controller
    _backgroundController = AnimationController(
      duration: const Duration(seconds: 10),
      vsync: this,
    );
    
    // Stagger animation controller
    _staggerController = AnimationController(
      duration: iOS26Animations.voidMorphing,
      vsync: this,
    );
    
    // Setup animations
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _mainAnimationController,
      curve: const Interval(0.0, 0.6, curve: iOS26Animations.neuralEase),
    ));
    
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _mainAnimationController,
      curve: const Interval(0.2, 0.8, curve: iOS26Animations.cosmicFlow),
    ));
    
    _backgroundAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _backgroundController,
      curve: Curves.linear,
    ));
    
    // Start background animation
    _backgroundController.repeat();
  }

  Future<void> _loadCourses() async {
    try {
      setState(() {
        _isLoading = true;
        _error = null;
      });
      
      // Load course data from JSON
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
      
      // Start entrance animations
      _mainAnimationController.forward();
      
      // Delay stagger animation
      Future.delayed(const Duration(milliseconds: 300), () {
        if (mounted) {
          _staggerController.forward();
        }
      });
      
    } catch (e) {
      setState(() {
        _error = 'خطا در بارگذاری دوره‌ها: $e';
        _isLoading = false;
      });
      debugPrint('Error loading courses: $e');
    }
  }

  Future<void> _refreshCourses() async {
    await _loadCourses();
  }

  void _onCourseSelected(String courseId) {
    // Handle course selection (expand/collapse)
    debugPrint('Course selected: $courseId');
  }

  void _onLessonSelected(String lessonId) {
    // Navigate to lesson
    final lesson = _findLessonById(lessonId);
    if (lesson != null) {
      Navigator.push(
        context,
        PageRouteBuilder(
          pageBuilder: (context, animation, secondaryAnimation) =>
              RichLessonScreen(lesson: lesson),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return iOS26Animations.buildPageTransition(
              context,
              animation,
              secondaryAnimation,
              child,
            );
          },
        ),
      );
    }
  }

  Lesson? _findLessonById(String lessonId) {
    for (final course in _courses) {
      for (final lesson in course.lessons) {
        if (lesson.id == lessonId) {
          return lesson;
        }
      }
    }
    return null;
  }

  @override
  void dispose() {
    _mainAnimationController.dispose();
    _backgroundController.dispose();
    _staggerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: GlassAppBar(
        title: 'دوره‌های آموزشی',
        backgroundAnimation: _backgroundAnimation,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: _buildNeuralBackground(),
        ),
        child: SafeArea(
          child: _buildBody(),
        ),
      ),
    );
  }

  LinearGradient _buildNeuralBackground() {
    return LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [
        Color.lerp(
          iOS26Colors.neuralBackground[0],
          iOS26Colors.neuralBackground[1],
          _backgroundAnimation.value,
        )!,
        iOS26Colors.neuralBackground[1],
        Color.lerp(
          iOS26Colors.neuralBackground[2],
          iOS26Colors.neuralBackground[0],
          _backgroundAnimation.value,
        )!,
      ],
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return _buildLoadingState();
    }
    
    if (_error != null) {
      return _buildErrorState();
    }
    
    if (_courses.isEmpty) {
      return _buildEmptyState();
    }
    
    return _buildCourseList();
  }

  Widget _buildLoadingState() {
    return Center(
      child: HyperGlassContainer(
        padding: const EdgeInsets.all(32),
        enableHolographicShimmer: true,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              width: 60,
              height: 60,
              child: CircularProgressIndicator(
                color: iOS26Colors.neuralBlue,
                strokeWidth: 3,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'بارگذاری دوره‌ها...',
              style: iOS26Typography.neuralHeadline.copyWith(
                color: iOS26Colors.neuralBlue,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: HyperGlassContainer(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.error_outline_rounded,
              size: 64,
              color: iOS26Colors.cosmicRed,
            ),
            const SizedBox(height: 16),
            Text(
              'خطا در بارگذاری',
              style: iOS26Typography.cosmicTitle2.copyWith(
                color: iOS26Colors.cosmicRed,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              _error!,
              style: iOS26Typography.voidSubheadline,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: _refreshCourses,
              icon: const Icon(Icons.refresh_rounded),
              label: const Text('تلاش مجدد'),
              style: ElevatedButton.styleFrom(
                backgroundColor: iOS26Colors.neuralBlue,
                foregroundColor: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: FadeTransition(
        opacity: _fadeAnimation,
        child: SlideTransition(
          position: _slideAnimation,
          child: HyperGlassContainer(
            padding: const EdgeInsets.all(32),
            enableHolographicShimmer: true,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.school_outlined,
                  size: 80,
                  color: iOS26Colors.neuralBlue.withOpacity(0.7),
                ),
                const SizedBox(height: 20),
                Text(
                  'هیچ دوره‌ای یافت نشد',
                  style: iOS26Typography.cosmicTitle2.copyWith(
                    color: iOS26Colors.neuralBlue,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'دوره‌های جدید به زودی اضافه خواهند شد',
                  style: iOS26Typography.voidSubheadline,
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCourseList() {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: SlideTransition(
        position: _slideAnimation,
        child: RefreshIndicator(
          onRefresh: _refreshCourses,
          color: iOS26Colors.neuralBlue,
          backgroundColor: iOS26Colors.hyperGlass,
          child: CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              // Header section
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: _buildHeader(),
                ),
              ),
              
              // Course cards
              SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      return AnimatedBuilder(
                        animation: _staggerController,
                        builder: (context, child) {
                          final staggerDelay = index * 0.1;
                          final staggerAnimation = Tween<double>(
                            begin: 0.0,
                            end: 1.0,
                          ).animate(CurvedAnimation(
                            parent: _staggerController,
                            curve: Interval(
                              staggerDelay.clamp(0.0, 0.8),
                              (staggerDelay + 0.2).clamp(0.2, 1.0),
                              curve: iOS26Animations.neuralEase,
                            ),
                          ));
                          
                          return FadeTransition(
                            opacity: staggerAnimation,
                            child: SlideTransition(
                              position: Tween<Offset>(
                                begin: const Offset(0, 0.3),
                                end: Offset.zero,
                              ).animate(staggerAnimation),
                              child: Padding(
                                padding: const EdgeInsets.only(bottom: 20),
                                child: CourseCard(
                                  course: _courses[index],
                                  onCourseSelected: _onCourseSelected,
                                  onLessonSelected: _onLessonSelected,
                                ),
                              ),
                            ),
                          );
                        },
                      );
                    },
                    childCount: _courses.length,
                  ),
                ),
              ),
              
              // Bottom padding
              const SliverToBoxAdapter(
                child: SizedBox(height: 40),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
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
                  gradient: iOS26Colors.getHolographicGradient(),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: iOS26Colors.neuralBlue.withOpacity(0.3),
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.auto_awesome_rounded,
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
                      'یادگیری هوشمند',
                      style: iOS26Typography.cosmicTitle2.copyWith(
                        color: iOS26Colors.neuralBlue,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'با تکنولوژی iOS 26 و هوش مصنوعی',
                      style: iOS26Typography.voidSubheadline.copyWith(
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Consumer<CourseProgressProvider>(
            builder: (context, progressProvider, child) {
              final totalCourses = _courses.length;
              final completedCourses = _courses.where((course) {
                final progress = progressProvider.getCourseProgress(course.id);
                return progress >= 1.0;
              }).length;
              
              return Row(
                children: [
                  _buildStatCard('دوره‌ها', totalCourses.toString(), iOS26Colors.neuralBlue),
                  const SizedBox(width: 12),
                  _buildStatCard('تکمیل شده', completedCourses.toString(), iOS26Colors.quantumGreen),
                  const SizedBox(width: 12),
                  _buildStatCard('در حال یادگیری', (totalCourses - completedCourses).toString(), iOS26Colors.plasmaOrange),
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(String label, String value, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: color.withOpacity(0.3),
            width: 1,
          ),
        ),
        child: Column(
          children: [
            Text(
              value,
              style: iOS26Typography.cosmicTitle2.copyWith(
                color: color,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: iOS26Typography.neuralFootnote.copyWith(
                color: color.withOpacity(0.8),
              ),
            ),
          ],
        ),
      ),
    );
  }
}