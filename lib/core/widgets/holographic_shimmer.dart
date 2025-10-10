import 'package:flutter/material.dart';
import '../theme/ios26_colors.dart';
import '../theme/ios26_animations.dart';

class HolographicShimmer extends StatefulWidget {
  final Widget child;
  final Duration duration;
  final List<Color>? colors;
  final bool enabled;
  final double intensity;
  final ShimmerDirection direction;

  const HolographicShimmer({
    super.key,
    required this.child,
    this.duration = const Duration(milliseconds: 2000),
    this.colors,
    this.enabled = true,
    this.intensity = 1.0,
    this.direction = ShimmerDirection.leftToRight,
  });

  @override
  State<HolographicShimmer> createState() => _HolographicShimmerState();
}

class _HolographicShimmerState extends State<HolographicShimmer>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: widget.duration,
      vsync: this,
    );
    
    _animation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.linear),
    );

    if (widget.enabled) {
      _controller.repeat();
    }
  }

  @override
  void didUpdateWidget(HolographicShimmer oldWidget) {
    super.didUpdateWidget(oldWidget);
    
    if (widget.enabled != oldWidget.enabled) {
      if (widget.enabled) {
        _controller.repeat();
      } else {
        _controller.stop();
      }
    }
    
    if (widget.duration != oldWidget.duration) {
      _controller.duration = widget.duration;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.enabled) {
      return widget.child;
    }

    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return ShaderMask(
          shaderCallback: (bounds) => _createShimmerGradient(bounds),
          blendMode: BlendMode.srcATop,
          child: widget.child,
        );
      },
    );
  }

  LinearGradient _createShimmerGradient(Rect bounds) {
    final colors = widget.colors ?? iOS26Colors.holographicSpectrum;
    final progress = _animation.value;
    
    Alignment begin, end;
    
    switch (widget.direction) {
      case ShimmerDirection.leftToRight:
        begin = Alignment(-1.0 - progress * 2, 0.0);
        end = Alignment(1.0 - progress * 2, 0.0);
        break;
      case ShimmerDirection.rightToLeft:
        begin = Alignment(1.0 + progress * 2, 0.0);
        end = Alignment(-1.0 + progress * 2, 0.0);
        break;
      case ShimmerDirection.topToBottom:
        begin = Alignment(0.0, -1.0 - progress * 2);
        end = Alignment(0.0, 1.0 - progress * 2);
        break;
      case ShimmerDirection.bottomToTop:
        begin = Alignment(0.0, 1.0 + progress * 2);
        end = Alignment(0.0, -1.0 + progress * 2);
        break;
      case ShimmerDirection.diagonal:
        begin = Alignment(-1.0 - progress * 2, -1.0 - progress * 2);
        end = Alignment(1.0 - progress * 2, 1.0 - progress * 2);
        break;
    }

    return LinearGradient(
      begin: begin,
      end: end,
      colors: [
        Colors.transparent,
        ...colors.map((color) => color.withOpacity(0.3 * widget.intensity)),
        Colors.transparent,
      ],
      stops: _generateStops(colors.length + 2),
    );
  }

  List<double> _generateStops(int colorCount) {
    final stops = <double>[];
    for (int i = 0; i < colorCount; i++) {
      stops.add(i / (colorCount - 1));
    }
    return stops;
  }
}

enum ShimmerDirection {
  leftToRight,
  rightToLeft,
  topToBottom,
  bottomToTop,
  diagonal,
}

// Specialized shimmer effects
class QuantumShimmer extends StatelessWidget {
  final Widget child;
  final bool enabled;

  const QuantumShimmer({
    super.key,
    required this.child,
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context) {
    return HolographicShimmer(
      enabled: enabled,
      duration: const Duration(milliseconds: 1500),
      colors: const [
        iOS26Colors.neuralBlue,
        iOS26Colors.quantumGreen,
        iOS26Colors.voidPurple,
      ],
      intensity: 0.8,
      direction: ShimmerDirection.diagonal,
      child: child,
    );
  }
}

class CosmicShimmer extends StatelessWidget {
  final Widget child;
  final bool enabled;

  const CosmicShimmer({
    super.key,
    required this.child,
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context) {
    return HolographicShimmer(
      enabled: enabled,
      duration: const Duration(milliseconds: 2500),
      colors: const [
        iOS26Colors.cosmicRed,
        iOS26Colors.purchasedCosmic,
        iOS26Colors.plasmaOrange,
      ],
      intensity: 1.0,
      direction: ShimmerDirection.leftToRight,
      child: child,
    );
  }
}

class NeuralPulseShimmer extends StatefulWidget {
  final Widget child;
  final Color pulseColor;
  final bool enabled;

  const NeuralPulseShimmer({
    super.key,
    required this.child,
    this.pulseColor = iOS26Colors.neuralBlue,
    this.enabled = true,
  });

  @override
  State<NeuralPulseShimmer> createState() => _NeuralPulseShimmerState();
}

class _NeuralPulseShimmerState extends State<NeuralPulseShimmer>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: iOS26Animations.cosmicTransition,
      vsync: this,
    );
    
    _pulseAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: iOS26Animations.neuralEase),
    );

    if (widget.enabled) {
      _controller.repeat(reverse: true);
    }
  }

  @override
  void didUpdateWidget(NeuralPulseShimmer oldWidget) {
    super.didUpdateWidget(oldWidget);
    
    if (widget.enabled != oldWidget.enabled) {
      if (widget.enabled) {
        _controller.repeat(reverse: true);
      } else {
        _controller.stop();
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.enabled) {
      return widget.child;
    }

    return AnimatedBuilder(
      animation: _pulseAnimation,
      builder: (context, child) {
        final glowIntensity = 0.3 + (0.7 * _pulseAnimation.value);
        
        return Container(
          decoration: BoxDecoration(
            boxShadow: [
              BoxShadow(
                color: widget.pulseColor.withOpacity(0.3 * glowIntensity),
                blurRadius: 15 * glowIntensity,
                spreadRadius: 2 * glowIntensity,
              ),
              BoxShadow(
                color: widget.pulseColor.withOpacity(0.1 * glowIntensity),
                blurRadius: 30 * glowIntensity,
                spreadRadius: 5 * glowIntensity,
              ),
            ],
          ),
          child: widget.child,
        );
      },
    );
  }
}

// Utility class for creating custom shimmer effects
class ShimmerBuilder {
  static Widget createCustomShimmer({
    required Widget child,
    required List<Color> colors,
    Duration duration = const Duration(milliseconds: 2000),
    ShimmerDirection direction = ShimmerDirection.leftToRight,
    double intensity = 1.0,
    bool enabled = true,
  }) {
    return HolographicShimmer(
      colors: colors,
      duration: duration,
      direction: direction,
      intensity: intensity,
      enabled: enabled,
      child: child,
    );
  }

  static Widget createRainbowShimmer({
    required Widget child,
    bool enabled = true,
  }) {
    return HolographicShimmer(
      colors: iOS26Colors.holographicSpectrum,
      duration: const Duration(milliseconds: 3000),
      direction: ShimmerDirection.diagonal,
      intensity: 0.6,
      enabled: enabled,
      child: child,
    );
  }

  static Widget createStatusShimmer({
    required Widget child,
    required LessonStatus status,
    bool enabled = true,
  }) {
    List<Color> colors;
    
    switch (status) {
      case LessonStatus.completed:
        colors = [iOS26Colors.completedQuantum, iOS26Colors.quantumGreen];
        break;
      case LessonStatus.available:
        colors = [iOS26Colors.availableNeural, iOS26Colors.neuralBlue];
        break;
      case LessonStatus.purchased:
        colors = [iOS26Colors.purchasedCosmic, iOS26Colors.plasmaOrange];
        break;
      case LessonStatus.aiRecommended:
        colors = iOS26Colors.holographicSpectrum;
        break;
      case LessonStatus.mastered:
        colors = [Colors.platinum, Colors.white, Colors.silver];
        break;
      default:
        colors = [iOS26Colors.lockedVoid];
    }

    return HolographicShimmer(
      colors: colors,
      duration: const Duration(milliseconds: 2000),
      direction: ShimmerDirection.leftToRight,
      intensity: 0.8,
      enabled: enabled,
      child: child,
    );
  }
}

enum LessonStatus {
  completed,
  available,
  locked,
  purchased,
  aiRecommended,
  mastered,
}

// Extension for easy color access
extension ColorsExtension on Colors {
  static const Color platinum = Color(0xFFE5E4E2);
  static const Color silver = Color(0xFFC0C0C0);
}