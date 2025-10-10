import 'package:flutter/material.dart';
import 'ios26_colors.dart';

/// iOS 26 Neural Animation System
/// AI-adaptive timing and physics-based animations
class iOS26Animations {
  // Neural Duration Constants (AI-adaptive timing)
  static const Duration quantumFlash = Duration(milliseconds: 120);
  static const Duration neuralFlow = Duration(milliseconds: 280);
  static const Duration cosmicTransition = Duration(milliseconds: 450);
  static const Duration voidMorphing = Duration(milliseconds: 800);
  static const Duration holographicShimmer = Duration(milliseconds: 1200);
  
  // Advanced Curve Constants (Physics-based)
  static const Curve neuralEase = Cubic(0.25, 0.8, 0.25, 1);
  static const Curve quantumBounce = Cubic(0.68, -0.55, 0.265, 1.55);
  static const Curve cosmicFlow = Cubic(0.4, 0, 0.2, 1);
  static const Curve voidRipple = Cubic(0.25, 0.46, 0.45, 0.94);
  static const Curve holographicWave = Cubic(0.23, 1, 0.32, 1);
  
  // Holographic Transition Builders
  static Widget holographicSlide(Widget child, Animation<double> animation) {
    return SlideTransition(
      position: Tween<Offset>(
        begin: const Offset(1.2, 0.0),
        end: Offset.zero,
      ).animate(CurvedAnimation(
        parent: animation,
        curve: neuralEase,
      )),
      child: ShaderMask(
        shaderCallback: (bounds) => LinearGradient(
          colors: iOS26Colors.holographicSpectrum,
        ).createShader(bounds),
        child: child,
      ),
    );
  }
  
  // Quantum Morphing Effects
  static Widget quantumMorph(Widget child, Animation<double> animation) {
    return AnimatedBuilder(
      animation: animation,
      builder: (context, child) {
        return Transform.scale(
          scale: 0.8 + (animation.value * 0.2),
          child: Opacity(
            opacity: animation.value,
            child: Container(
              decoration: BoxDecoration(
                boxShadow: [
                  BoxShadow(
                    color: iOS26Colors.holographicShimmer,
                    blurRadius: 20 * animation.value,
                    spreadRadius: 5 * animation.value,
                  ),
                ],
              ),
              child: child,
            ),
          ),
        );
      },
      child: child,
    );
  }
  
  // Neural Pulse Animation
  static Widget neuralPulse(Widget child, AnimationController controller) {
    final pulseAnimation = Tween<double>(
      begin: 1.0,
      end: 1.1,
    ).animate(CurvedAnimation(
      parent: controller,
      curve: Curves.easeInOut,
    ));
    
    return AnimatedBuilder(
      animation: pulseAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: pulseAnimation.value,
          child: Container(
            decoration: BoxDecoration(
              boxShadow: [
                BoxShadow(
                  color: iOS26Colors.neuralBlue.withOpacity(0.3),
                  blurRadius: 15 * pulseAnimation.value,
                  spreadRadius: 3 * pulseAnimation.value,
                ),
              ],
            ),
            child: child,
          ),
        );
      },
      child: child,
    );
  }
  
  // Cosmic Shimmer Effect
  static Widget cosmicShimmer(Widget child, AnimationController controller) {
    final shimmerAnimation = Tween<double>(
      begin: -1.0,
      end: 2.0,
    ).animate(CurvedAnimation(
      parent: controller,
      curve: holographicWave,
    ));
    
    return AnimatedBuilder(
      animation: shimmerAnimation,
      builder: (context, child) {
        return ShaderMask(
          shaderCallback: (bounds) {
            return LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: const [
                Colors.transparent,
                Color(0x40FFFFFF),
                Colors.transparent,
              ],
              stops: [
                shimmerAnimation.value - 0.3,
                shimmerAnimation.value,
                shimmerAnimation.value + 0.3,
              ].map((stop) => stop.clamp(0.0, 1.0)).toList(),
            ).createShader(bounds);
          },
          blendMode: BlendMode.srcATop,
          child: child,
        );
      },
      child: child,
    );
  }
  
  // Quantum Glow Animation
  static Widget quantumGlow(Widget child, Color glowColor, AnimationController controller) {
    final glowAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: controller,
      curve: Curves.easeInOut,
    ));
    
    return AnimatedBuilder(
      animation: glowAnimation,
      builder: (context, child) {
        return Container(
          decoration: BoxDecoration(
            boxShadow: [
              BoxShadow(
                color: glowColor.withOpacity(0.4 * glowAnimation.value),
                blurRadius: 20 * glowAnimation.value,
                spreadRadius: 5 * glowAnimation.value,
              ),
              BoxShadow(
                color: glowColor.withOpacity(0.2 * glowAnimation.value),
                blurRadius: 40 * glowAnimation.value,
                spreadRadius: 10 * glowAnimation.value,
              ),
            ],
          ),
          child: child,
        );
      },
      child: child,
    );
  }
  
  // Void Morphing Animation
  static Widget voidMorph(Widget child, AnimationController controller) {
    final morphAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: controller,
      curve: voidRipple,
    ));
    
    return AnimatedBuilder(
      animation: morphAnimation,
      builder: (context, child) {
        return Transform(
          alignment: Alignment.center,
          transform: Matrix4.identity()
            ..setEntry(3, 2, 0.001)
            ..rotateY(morphAnimation.value * 0.1)
            ..scale(1.0 + (morphAnimation.value * 0.05)),
          child: Opacity(
            opacity: 0.5 + (morphAnimation.value * 0.5),
            child: child,
          ),
        );
      },
      child: child,
    );
  }
  
  // Holographic Entrance Animation
  static Widget holographicEntrance(Widget child, AnimationController controller) {
    final slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: controller,
      curve: const Interval(0.0, 0.6, curve: neuralEase),
    ));
    
    final fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: controller,
      curve: const Interval(0.2, 0.8, curve: cosmicFlow),
    ));
    
    final scaleAnimation = Tween<double>(
      begin: 0.8,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: controller,
      curve: const Interval(0.4, 1.0, curve: quantumBounce),
    ));
    
    return SlideTransition(
      position: slideAnimation,
      child: FadeTransition(
        opacity: fadeAnimation,
        child: ScaleTransition(
          scale: scaleAnimation,
          child: child,
        ),
      ),
    );
  }
  
  // Neural Stagger Animation
  static List<Widget> neuralStagger(
    List<Widget> children,
    AnimationController controller, {
    Duration delay = const Duration(milliseconds: 100),
  }) {
    return children.asMap().entries.map((entry) {
      final index = entry.key;
      final child = entry.value;
      
      final delayedAnimation = Tween<double>(
        begin: 0.0,
        end: 1.0,
      ).animate(CurvedAnimation(
        parent: controller,
        curve: Interval(
          (index * 0.1).clamp(0.0, 0.8),
          ((index * 0.1) + 0.2).clamp(0.2, 1.0),
          curve: neuralEase,
        ),
      ));
      
      return holographicEntrance(child, 
        AnimationController.unbounded(vsync: controller)
          ..value = delayedAnimation.value
      );
    }).toList();
  }
  
  // Page Transition Builder
  static Widget buildPageTransition(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    return SlideTransition(
      position: Tween<Offset>(
        begin: const Offset(1.0, 0.0),
        end: Offset.zero,
      ).animate(CurvedAnimation(
        parent: animation,
        curve: neuralEase,
      )),
      child: FadeTransition(
        opacity: animation,
        child: child,
      ),
    );
  }
}