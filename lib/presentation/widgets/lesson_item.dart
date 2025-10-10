import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../core/models/lesson.dart';
import '../../core/theme/ios26_colors.dart';
import '../../core/theme/ios26_typography.dart';
import '../../core/theme/ios26_animations.dart';
import '../../core/widgets/hyper_glass_container.dart';

/// LessonItem - Neural status indicators for iOS 26
/// Features holographic icons, quantum glow effects, and contextual animations
class LessonItem extends StatefulWidget {
  final Lesson lesson;
  final LessonStatus status;
  final VoidCallback onTap;
  final Duration animationDelay;
  final bool showProgress;

  const LessonItem({
    super.key,
    required this.lesson,
    required this.status,
    required this.onTap,
    this.animationDelay = Duration.zero,
    this.showProgress = false,
  });

  @override
  State<LessonItem> createState() => _LessonItemState();
}

class _LessonItemState extends State<LessonItem>
    with TickerProviderStateMixin {
  
  // Animation controllers
  late AnimationController _entranceController;
  late AnimationController _statusController;
  late AnimationController _hoverController;
  late AnimationController _tapController;
  
  // Animations
  late Animation<double> _entranceAnimation;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _statusAnimation;
  late Animation<double> _hoverAnimation;
  late Animation<double> _tapAnimation;
  
  bool _isHovered = false;

  @override
  void initState() {
    super.initState();
    _setupAnimations();
    _startEntranceAnimation();
  }

  void _setupAnimations() {
    _entranceController = AnimationController(
      duration: iOS26Animations.cosmicTransition,
      vsync: this,
    );
    
    _statusController = AnimationController(
      duration: iOS26Animations.neuralFlow,
      vsync: this,
    );
    
    _hoverController = AnimationController(
      duration: iOS26Animations.quantumFlash,
      vsync: this,
    );
    
    _tapController = AnimationController(
      duration: const Duration(milliseconds: 100),
      vsync: this,
    );
    
    _entranceAnimation = CurvedAnimation(
      parent: _entranceController,
      curve: iOS26Animations.neuralEase,
    );
    
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0.3, 0),
      end: Offset.zero,
    ).animate(_entranceAnimation);
    
    _statusAnimation = CurvedAnimation(
      parent: _statusController,
      curve: iOS26Animations.cosmicFlow,
    );
    
    _hoverAnimation = CurvedAnimation(
      parent: _hoverController,
      curve: iOS26Animations.quantumBounce,
    );
    
    _tapAnimation = Tween<double>(
      begin: 1.0,
      end: 0.95,
    ).animate(CurvedAnimation(
      parent: _tapController,
      curve: Curves.easeInOut,
    ));
  }

  void _startEntranceAnimation() {
    Future.delayed(widget.animationDelay, () {
      if (mounted) {
        _entranceController.forward();
        _statusController.forward();
      }
    });
  }

  void _handleHover(bool isHovered) {
    setState(() {
      _isHovered = isHovered;
    });
    
    if (isHovered) {
      _hoverController.forward();
    } else {
      _hoverController.reverse();
    }
  }

  void _handleTap() {
    // Haptic feedback
    HapticFeedback.lightImpact();
    
    // Tap animation
    _tapController.forward().then((_) {
      _tapController.reverse();
    });
    
    // Call the onTap callback
    widget.onTap();
  }

  @override
  void dispose() {
    _entranceController.dispose();
    _statusController.dispose();
    _hoverController.dispose();
    _tapController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _entranceAnimation,
      child: SlideTransition(
        position: _slideAnimation,
        child: AnimatedBuilder(
          animation: Listenable.merge([
            _statusAnimation,
            _hoverAnimation,
            _tapAnimation,
          ]),
          builder: (context, child) {
            return Transform.scale(
              scale: _tapAnimation.value,
              child: MouseRegion(
                onEnter: (_) => _handleHover(true),
                onExit: (_) => _handleHover(false),
                child: GestureDetector(
                  onTap: _isLessonAccessible() ? _handleTap : _showAccessDialog,
                  child: HyperGlassContainer(
                    padding: const EdgeInsets.all(16),
                    enableQuantumBorders: _isHovered,
                    enableHolographicShimmer: _isHovered && _isLessonAccessible(),
                    neuralBlur: 10 + (_hoverAnimation.value * 5),
                    child: Row(
                      children: [
                        _buildStatusIcon(),
                        const SizedBox(width: 16),
                        Expanded(
                          child: _buildLessonContent(),
                        ),
                        _buildAccessoryIcon(),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildStatusIcon() {
    return AnimatedBuilder(
      animation: _statusAnimation,
      builder: (context, child) {
        return Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: _getStatusColor().withOpacity(0.1 + (_statusAnimation.value * 0.1)),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: _getStatusColor().withOpacity(0.3 + (_hoverAnimation.value * 0.2)),
              width: 1 + (_hoverAnimation.value * 0.5),
            ),
            boxShadow: _buildStatusShadows(),
          ),
          child: _buildStatusIconContent(),
        );
      },
    );
  }

  Widget _buildStatusIconContent() {
    switch (widget.status) {
      case LessonStatus.completed:
        return _buildQuantumCheckmark();
      case LessonStatus.available:
        return _buildPulsingPlay();
      case LessonStatus.locked:
        return _buildMorphingLock();
      case LessonStatus.purchased:
        return _buildRotatingStar();
      case LessonStatus.aiRecommended:
        return _buildRainbowPulse();
      case LessonStatus.mastered:
        return _buildCrownEffect();
    }
  }

  Widget _buildQuantumCheckmark() {
    return AnimatedBuilder(
      animation: _statusAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: 0.8 + (_statusAnimation.value * 0.2),
          child: Icon(
            Icons.check_circle_rounded,
            color: iOS26Colors.completedQuantum,
            size: 24,
          ),
        );
      },
    );
  }

  Widget _buildPulsingPlay() {
    return AnimatedBuilder(
      animation: _statusController,
      builder: (context, child) {
        final pulseValue = (1 + 0.2 * (_statusController.value * 2 % 1));
        return Transform.scale(
          scale: pulseValue,
          child: Icon(
            Icons.play_circle_rounded,
            color: iOS26Colors.availableNeural,
            size: 24,
          ),
        );
      },
    );
  }

  Widget _buildMorphingLock() {
    return AnimatedBuilder(
      animation: _statusAnimation,
      builder: (context, child) {
        return Transform.rotate(
          angle: _statusAnimation.value * 0.1,
          child: Icon(
            Icons.lock_rounded,
            color: iOS26Colors.lockedVoid,
            size: 24,
          ),
        );
      },
    );
  }

  Widget _buildRotatingStar() {
    return AnimatedBuilder(
      animation: _statusController,
      builder: (context, child) {
        return Transform.rotate(
          angle: _statusController.value * 6.28,
          child: Icon(
            Icons.star_rounded,
            color: iOS26Colors.purchasedCosmic,
            size: 24,
          ),
        );
      },
    );
  }

  Widget _buildRainbowPulse() {
    return AnimatedBuilder(
      animation: _statusController,
      builder: (context, child) {
        final colorIndex = (_statusController.value * iOS26Colors.holographicSpectrum.length).floor() %
            iOS26Colors.holographicSpectrum.length;
        return Transform.scale(
          scale: 1 + 0.1 * (_statusController.value * 4 % 1),
          child: Icon(
            Icons.auto_awesome_rounded,
            color: iOS26Colors.holographicSpectrum[colorIndex],
            size: 24,
          ),
        );
      },
    );
  }

  Widget _buildCrownEffect() {
    return AnimatedBuilder(
      animation: _statusAnimation,
      builder: (context, child) {
        return Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Colors.amber.shade300,
                Colors.amber.shade100,
              ],
            ),
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.amber.withOpacity(0.3),
                blurRadius: 10,
                spreadRadius: 2,
              ),
            ],
          ),
          child: Icon(
            Icons.workspace_premium_rounded,
            color: Colors.amber.shade800,
            size: 24,
          ),
        );
      },
    );
  }

  Widget _buildLessonContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          widget.lesson.title,
          style: _getLessonTitleStyle(),
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        const SizedBox(height: 4),
        Row(
          children: [
            _buildLessonMetadata(),
            if (widget.showProgress) ...[
              const SizedBox(width: 8),
              _buildProgressIndicator(),
            ],
          ],
        ),
      ],
    );
  }

  Widget _buildLessonMetadata() {
    return Row(
      children: [
        Icon(
          Icons.access_time_rounded,
          size: 12,
          color: Colors.grey.shade500,
        ),
        const SizedBox(width: 4),
        Text(
          '${widget.lesson.order}. درس',
          style: iOS26Typography.quantumCaption1.copyWith(
            color: Colors.grey.shade500,
          ),
        ),
        if (widget.lesson.isFree) ...[
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color: iOS26Colors.quantumGreen.withOpacity(0.1),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              'رایگان',
              style: iOS26Typography.cosmicCaption2.copyWith(
                color: iOS26Colors.quantumGreen,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildProgressIndicator() {
    // This would show actual progress if available
    return Container(
      width: 40,
      height: 4,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(2),
        color: Colors.grey.shade200,
      ),
      child: FractionallySizedBox(
        alignment: Alignment.centerLeft,
        widthFactor: widget.status == LessonStatus.completed ? 1.0 : 0.0,
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(2),
            color: iOS26Colors.completedQuantum,
          ),
        ),
      ),
    );
  }

  Widget _buildAccessoryIcon() {
    if (!_isLessonAccessible()) {
      return Icon(
        Icons.lock_outline_rounded,
        color: iOS26Colors.lockedVoid,
        size: 20,
      );
    }
    
    return AnimatedBuilder(
      animation: _hoverAnimation,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(_hoverAnimation.value * 4, 0),
          child: Icon(
            Icons.arrow_forward_ios_rounded,
            color: iOS26Colors.neuralBlue.withOpacity(0.6 + (_hoverAnimation.value * 0.4)),
            size: 16,
          ),
        );
      },
    );
  }

  List<BoxShadow> _buildStatusShadows() {
    final color = _getStatusColor();
    final intensity = _statusAnimation.value * _hoverAnimation.value;
    
    return [
      BoxShadow(
        color: color.withOpacity(0.2 * intensity),
        blurRadius: 8 * intensity,
        spreadRadius: 2 * intensity,
        offset: const Offset(0, 2),
      ),
      if (_isHovered)
        BoxShadow(
          color: color.withOpacity(0.1),
          blurRadius: 15,
          spreadRadius: 3,
          offset: const Offset(0, 0),
        ),
    ];
  }

  Color _getStatusColor() {
    return iOS26Colors.getStatusColor(widget.status);
  }

  TextStyle _getLessonTitleStyle() {
    final baseStyle = iOS26Typography.neuralHeadline.copyWith(fontSize: 16);
    
    switch (widget.status) {
      case LessonStatus.completed:
        return iOS26Typography.getNeuralGlowText(baseStyle, iOS26Colors.completedQuantum);
      case LessonStatus.mastered:
        return baseStyle.copyWith(
          color: Colors.amber.shade700,
          fontWeight: FontWeight.w700,
        );
      case LessonStatus.locked:
        return baseStyle.copyWith(
          color: iOS26Colors.lockedVoid,
        );
      case LessonStatus.aiRecommended:
        return iOS26Typography.getHolographicText(baseStyle);
      default:
        return baseStyle.copyWith(
          color: iOS26Colors.neuralBlue,
        );
    }
  }

  bool _isLessonAccessible() {
    return widget.status != LessonStatus.locked;
  }

  void _showAccessDialog() {
    HapticFeedback.mediumImpact();
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.transparent,
        content: HyperGlassContainer(
          padding: const EdgeInsets.all(24),
          enableHolographicShimmer: true,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.lock_rounded,
                size: 48,
                color: iOS26Colors.cosmicRed,
              ),
              const SizedBox(height: 16),
              Text(
                'درس قفل شده',
                style: iOS26Typography.cosmicTitle2.copyWith(
                  color: iOS26Colors.cosmicRed,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'برای دسترسی به این درس، ابتدا دوره را خریداری کنید.',
                style: iOS26Typography.voidSubheadline,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('بستن'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context);
                        // TODO: Navigate to purchase screen
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: iOS26Colors.neuralBlue,
                      ),
                      child: const Text('خرید دوره'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}