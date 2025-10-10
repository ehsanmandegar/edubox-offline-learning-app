import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/models/course.dart';
import '../../core/models/lesson.dart';
import '../../core/providers/course_progress_provider.dart';
import '../../core/providers/purchase_state.dart';
import '../../core/theme/ios26_colors.dart';
import '../../core/theme/ios26_typography.dart';
import '../../core/theme/ios26_animations.dart';
import '../../core/widgets/hyper_glass_container.dart';
import 'lesson_item.dart';

/// CourseCard - Holographic glass morphism course card for iOS 26
/// Features expandable lesson list, neural progress tracking, and quantum animations
class CourseCard extends StatefulWidget {
  final Course course;
  final Function(String courseId) onCourseSelected;
  final Function(String lessonId) onLessonSelected;

  const CourseCard({
    super.key,
    required this.course,
    required this.onCourseSelected,
    required this.onLessonSelected,
  });

  @override
  State<CourseCard> createState() => _CourseCardState();
}

class _CourseCardState extends State<CourseCard>
    with TickerProviderStateMixin {
  
  bool _isExpanded = false;
  
  // Animation controllers
  late AnimationController _expansionController;
  late AnimationController _hoverController;
  late AnimationController _progressController;
  
  // Animations
  late Animation<double> _expansionAnimation;
  late Animation<double> _rotationAnimation;
  late Animation<double> _hoverAnimation;
  late Animation<double> _progressAnimation;

  @override
  void initState() {
    super.initState();
    _setupAnimations();
  }

  void _setupAnimations() {
    _expansionController = AnimationController(
      duration: iOS26Animations.cosmicTransition,
      vsync: this,
    );
    
    _hoverController = AnimationController(
      duration: iOS26Animations.quantumFlash,
      vsync: this,
    );
    
    _progressController = AnimationController(
      duration: iOS26Animations.neuralFlow,
      vsync: this,
    );
    
    _expansionAnimation = CurvedAnimation(
      parent: _expansionController,
      curve: iOS26Animations.neuralEase,
    );
    
    _rotationAnimation = Tween<double>(
      begin: 0.0,
      end: 0.5,
    ).animate(_expansionAnimation);
    
    _hoverAnimation = CurvedAnimation(
      parent: _hoverController,
      curve: iOS26Animations.cosmicFlow,
    );
    
    _progressAnimation = CurvedAnimation(
      parent: _progressController,
      curve: iOS26Animations.neuralEase,
    );
    
    // Start progress animation
    _progressController.forward();
  }

  @override
  void dispose() {
    _expansionController.dispose();
    _hoverController.dispose();
    _progressController.dispose();
    super.dispose();
  }

  void _toggleExpansion() {
    setState(() {
      _isExpanded = !_isExpanded;
    });
    
    if (_isExpanded) {
      _expansionController.forward();
    } else {
      _expansionController.reverse();
    }
    
    widget.onCourseSelected(widget.course.id);
  }

  void _handleHover(bool isHovered) {
    if (isHovered) {
      _hoverController.forward();
    } else {
      _hoverController.reverse();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer2<CourseProgressProvider, PurchaseState>(
      builder: (context, progressProvider, purchaseState, child) {
        final progress = progressProvider.getCourseProgress(widget.course.id);
        final isPurchased = purchaseState.isPurchased(widget.course.id);
        final statistics = progressProvider.getCourseStatistics(widget.course.id);
        
        return MouseRegion(
          onEnter: (_) => _handleHover(true),
          onExit: (_) => _handleHover(false),
          child: AnimatedBuilder(
            animation: Listenable.merge([
              _expansionAnimation,
              _hoverAnimation,
              _progressAnimation,
            ]),
            builder: (context, child) {
              return HyperGlassContainer(
                enableHolographicShimmer: _hoverAnimation.value > 0.5,
                enableQuantumBorders: true,
                neuralBlur: 15 + (_hoverAnimation.value * 5),
                onTap: _toggleExpansion,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildCourseHeader(progress, isPurchased, statistics),
                    _buildProgressIndicator(progress),
                    _buildExpandedContent(progressProvider, purchaseState),
                  ],
                ),
              );
            },
          ),
        );
      },
    );
  }

  Widget _buildCourseHeader(double progress, bool isPurchased, Map<String, dynamic> statistics) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          // Course icon with holographic effect
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  widget.course.primaryColor ?? iOS26Colors.neuralBlue,
                  (widget.course.primaryColor ?? iOS26Colors.neuralBlue).withOpacity(0.7),
                ],
              ),
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: (widget.course.primaryColor ?? iOS26Colors.neuralBlue)
                      .withOpacity(0.3 + (_hoverAnimation.value * 0.2)),
                  blurRadius: 15 + (_hoverAnimation.value * 10),
                  offset: Offset(0, 5 + (_hoverAnimation.value * 5)),
                ),
              ],
            ),
            child: Icon(
              _getCourseIcon(),
              color: Colors.white,
              size: 28,
            ),
          ),
          
          const SizedBox(width: 16),
          
          // Course info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.course.title,
                  style: iOS26Typography.cosmicTitle2.copyWith(
                    color: iOS26Colors.neuralBlue,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  widget.course.description,
                  style: iOS26Typography.voidSubheadline.copyWith(
                    color: Colors.grey.shade600,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 8),
                _buildCourseMetadata(),
              ],
            ),
          ),
          
          // Expansion indicator
          AnimatedBuilder(
            animation: _rotationAnimation,
            builder: (context, child) {
              return Transform.rotate(
                angle: _rotationAnimation.value * 3.14159,
                child: Icon(
                  Icons.keyboard_arrow_down_rounded,
                  color: iOS26Colors.neuralBlue,
                  size: 28,
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildCourseMetadata() {
    return Row(
      children: [
        _buildMetadataChip(
          '${widget.course.totalLessons} درس',
          iOS26Colors.neuralBlue,
          Icons.play_lesson_rounded,
        ),
        const SizedBox(width: 8),
        _buildMetadataChip(
          widget.course.formattedDuration,
          iOS26Colors.plasmaOrange,
          Icons.access_time_rounded,
        ),
        const SizedBox(width: 8),
        _buildMetadataChip(
          widget.course.difficultyLevel.persianName,
          widget.course.difficultyLevel.color,
          Icons.trending_up_rounded,
        ),
      ],
    );
  }

  Widget _buildMetadataChip(String text, Color color, IconData icon) {
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
            size: 12,
            color: color,
          ),
          const SizedBox(width: 4),
          Text(
            text,
            style: iOS26Typography.quantumCaption1.copyWith(
              color: color,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProgressIndicator(double progress) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'پیشرفت دوره',
                style: iOS26Typography.neuralFootnote.copyWith(
                  color: Colors.grey.shade600,
                ),
              ),
              Text(
                '${(progress * 100).toInt()}%',
                style: iOS26Typography.neuralFootnote.copyWith(
                  color: iOS26Colors.neuralBlue,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          AnimatedBuilder(
            animation: _progressAnimation,
            builder: (context, child) {
              return Container(
                height: 6,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(3),
                  color: Colors.grey.shade200,
                ),
                child: FractionallySizedBox(
                  alignment: Alignment.centerLeft,
                  widthFactor: progress * _progressAnimation.value,
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(3),
                      gradient: LinearGradient(
                        colors: [
                          iOS26Colors.neuralBlue,
                          iOS26Colors.quantumGreen,
                        ],
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: iOS26Colors.neuralBlue.withOpacity(0.3),
                          blurRadius: 6,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildExpandedContent(CourseProgressProvider progressProvider, PurchaseState purchaseState) {
    return SizeTransition(
      sizeFactor: _expansionAnimation,
      child: Column(
        children: [
          const SizedBox(height: 20),
          const Divider(
            color: iOS26Colors.quantumBorder,
            thickness: 1,
            height: 1,
          ),
          const SizedBox(height: 16),
          
          // Lessons list
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'درس‌ها',
                  style: iOS26Typography.neuralHeadline.copyWith(
                    color: iOS26Colors.neuralBlue,
                  ),
                ),
                const SizedBox(height: 12),
                
                ...widget.course.lessons.asMap().entries.map((entry) {
                  final index = entry.key;
                  final lesson = entry.value;
                  
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: LessonItem(
                      lesson: lesson,
                      status: progressProvider.getLessonStatus(lesson),
                      onTap: () => widget.onLessonSelected(lesson.id),
                      animationDelay: Duration(milliseconds: index * 50),
                    ),
                  );
                }).toList(),
              ],
            ),
          ),
          
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  IconData _getCourseIcon() {
    // Return appropriate icon based on course category or content
    switch (widget.course.categoryId.toLowerCase()) {
      case 'programming':
        return Icons.code_rounded;
      case 'design':
        return Icons.palette_rounded;
      case 'business':
        return Icons.business_rounded;
      case 'language':
        return Icons.translate_rounded;
      default:
        return Icons.school_rounded;
    }
  }
}