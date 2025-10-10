import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:ui';
import '../../core/theme/ios26_colors.dart';
import '../../core/theme/ios26_typography.dart';

/// GlassAppBar - Neural blur app bar for iOS 26
/// Features holographic effects and quantum particle animations
class GlassAppBar extends StatefulWidget implements PreferredSizeWidget {
  final String title;
  final List<Widget>? actions;
  final Widget? leading;
  final bool centerTitle;
  final Animation<double>? backgroundAnimation;
  final VoidCallback? onTitleTap;

  const GlassAppBar({
    super.key,
    required this.title,
    this.actions,
    this.leading,
    this.centerTitle = false,
    this.backgroundAnimation,
    this.onTitleTap,
  });

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  State<GlassAppBar> createState() => _GlassAppBarState();
}

class _GlassAppBarState extends State<GlassAppBar>
    with TickerProviderStateMixin {
  
  late AnimationController _shimmerController;
  late AnimationController _particleController;
  late Animation<double> _shimmerAnimation;
  
  @override
  void initState() {
    super.initState();
    
    _shimmerController = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    );
    
    _particleController = AnimationController(
      duration: const Duration(seconds: 8),
      vsync: this,
    );
    
    _shimmerAnimation = Tween<double>(
      begin: -1.0,
      end: 2.0,
    ).animate(CurvedAnimation(
      parent: _shimmerController,
      curve: Curves.linear,
    ));
    
    // Start animations
    _shimmerController.repeat();
    _particleController.repeat();
  }

  @override
  void dispose() {
    _shimmerController.dispose();
    _particleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Container(
      decoration: BoxDecoration(
        gradient: _buildBackgroundGradient(isDark),
      ),
      child: ClipRRect(
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
          child: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            scrolledUnderElevation: 0,
            centerTitle: widget.centerTitle,
            leading: widget.leading,
            actions: widget.actions,
            systemOverlayStyle: SystemUiOverlayStyle(
              statusBarColor: Colors.transparent,
              statusBarIconBrightness: isDark ? Brightness.light : Brightness.dark,
              statusBarBrightness: isDark ? Brightness.dark : Brightness.light,
            ),
            title: _buildTitle(isDark),
            flexibleSpace: _buildFlexibleSpace(),
          ),
        ),
      ),
    );
  }

  LinearGradient _buildBackgroundGradient(bool isDark) {
    if (widget.backgroundAnimation != null) {
      return LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          Color.lerp(
            isDark ? iOS26Colors.voidGlass : iOS26Colors.hyperGlass,
            isDark ? iOS26Colors.hyperGlass : iOS26Colors.voidGlass,
            widget.backgroundAnimation!.value,
          )!,
          isDark ? iOS26Colors.voidGlass : iOS26Colors.hyperGlass,
        ],
      );
    }
    
    return LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [
        isDark ? iOS26Colors.voidGlass : iOS26Colors.hyperGlass,
        (isDark ? iOS26Colors.voidGlass : iOS26Colors.hyperGlass).withOpacity(0.8),
      ],
    );
  }

  Widget _buildTitle(bool isDark) {
    return GestureDetector(
      onTap: widget.onTitleTap,
      child: AnimatedBuilder(
        animation: _shimmerController,
        builder: (context, child) {
          return ShaderMask(
            shaderCallback: (bounds) {
              return LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  isDark ? Colors.white : Colors.black,
                  iOS26Colors.neuralBlue,
                  isDark ? Colors.white : Colors.black,
                ],
                stops: [
                  (_shimmerAnimation.value - 0.3).clamp(0.0, 1.0),
                  _shimmerAnimation.value.clamp(0.0, 1.0),
                  (_shimmerAnimation.value + 0.3).clamp(0.0, 1.0),
                ],
              ).createShader(bounds);
            },
            blendMode: BlendMode.srcIn,
            child: Text(
              widget.title,
              style: iOS26Typography.neuralLargeTitle.copyWith(
                fontSize: 20,
                fontWeight: FontWeight.w700,
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildFlexibleSpace() {
    return Stack(
      children: [
        // Quantum particles background
        AnimatedBuilder(
          animation: _particleController,
          builder: (context, child) {
            return CustomPaint(
              painter: QuantumParticlePainter(
                animation: _particleController,
                isDark: Theme.of(context).brightness == Brightness.dark,
              ),
              size: Size.infinite,
            );
          },
        ),
        
        // Holographic shimmer overlay
        Positioned.fill(
          child: AnimatedBuilder(
            animation: _shimmerAnimation,
            builder: (context, child) {
              return Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Colors.transparent,
                      iOS26Colors.holographicShimmer,
                      Colors.transparent,
                    ],
                    stops: [
                      (_shimmerAnimation.value - 0.1).clamp(0.0, 1.0),
                      _shimmerAnimation.value.clamp(0.0, 1.0),
                      (_shimmerAnimation.value + 0.1).clamp(0.0, 1.0),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

/// Quantum Particle Painter for background effects
class QuantumParticlePainter extends CustomPainter {
  final Animation<double> animation;
  final bool isDark;

  QuantumParticlePainter({
    required this.animation,
    required this.isDark,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = (isDark ? iOS26Colors.neuralBlue : iOS26Colors.quantumGreen)
          .withOpacity(0.1)
      ..style = PaintingStyle.fill;

    // Draw floating quantum particles
    for (int i = 0; i < 8; i++) {
      final progress = (animation.value + (i * 0.125)) % 1.0;
      final x = (i * size.width / 8) + (progress * 20);
      final y = size.height * 0.5 + (10 * (i % 2 == 0 ? 1 : -1)) * progress;
      final radius = 2 + (progress * 3);
      
      canvas.drawCircle(
        Offset(x, y),
        radius,
        paint..color = paint.color.withOpacity(0.1 + (progress * 0.2)),
      );
    }

    // Draw neural connections
    final connectionPaint = Paint()
      ..color = (isDark ? iOS26Colors.neuralBlue : iOS26Colors.quantumGreen)
          .withOpacity(0.05)
      ..strokeWidth = 1
      ..style = PaintingStyle.stroke;

    for (int i = 0; i < 4; i++) {
      final startX = i * size.width / 4;
      final endX = (i + 1) * size.width / 4;
      final progress = (animation.value + (i * 0.25)) % 1.0;
      
      final path = Path();
      path.moveTo(startX, size.height * 0.3);
      path.quadraticBezierTo(
        (startX + endX) / 2,
        size.height * (0.3 + 0.4 * progress),
        endX,
        size.height * 0.7,
      );
      
      canvas.drawPath(path, connectionPaint);
    }
  }

  @override
  bool shouldRepaint(covariant QuantumParticlePainter oldDelegate) {
    return oldDelegate.animation.value != animation.value ||
           oldDelegate.isDark != isDark;
  }
}