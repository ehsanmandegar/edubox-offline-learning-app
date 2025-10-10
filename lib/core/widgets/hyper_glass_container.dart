import 'package:flutter/material.dart';
import 'dart:ui';
import '../theme/ios26_colors.dart';
import '../theme/ios26_animations.dart';

/// HyperGlassContainer - Next-generation glass morphism widget for iOS 26
/// Features advanced blur effects, holographic shimmer, and quantum borders
class HyperGlassContainer extends StatefulWidget {
  final Widget child;
  final double neuralBlur;
  final double quantumOpacity;
  final BorderRadius? borderRadius;
  final EdgeInsets? padding;
  final EdgeInsets? margin;
  final bool enableHolographicShimmer;
  final bool enableQuantumBorders;
  final List<Color>? holographicColors;
  final Duration morphingDuration;
  final double? width;
  final double? height;
  final VoidCallback? onTap;

  const HyperGlassContainer({
    super.key,
    required this.child,
    this.neuralBlur = 15.0,
    this.quantumOpacity = 0.8,
    this.borderRadius,
    this.padding,
    this.margin,
    this.enableHolographicShimmer = false,
    this.enableQuantumBorders = true,
    this.holographicColors,
    this.morphingDuration = iOS26Animations.neuralFlow,
    this.width,
    this.height,
    this.onTap,
  });

  @override
  State<HyperGlassContainer> createState() => _HyperGlassContainerState();
}

class _HyperGlassContainerState extends State<HyperGlassContainer>
    with TickerProviderStateMixin {
  late AnimationController _shimmerController;
  late AnimationController _borderController;
  late AnimationController _hoverController;
  
  bool _isHovered = false;

  @override
  void initState() {
    super.initState();
    
    _shimmerController = AnimationController(
      duration: iOS26Animations.holographicShimmer,
      vsync: this,
    );
    
    _borderController = AnimationController(
      duration: iOS26Animations.cosmicTransition,
      vsync: this,
    );
    
    _hoverController = AnimationController(
      duration: iOS26Animations.quantumFlash,
      vsync: this,
    );

    if (widget.enableHolographicShimmer) {
      _shimmerController.repeat();
    }
    
    if (widget.enableQuantumBorders) {
      _borderController.repeat(reverse: true);
    }
  }

  @override
  void dispose() {
    _shimmerController.dispose();
    _borderController.dispose();
    _hoverController.dispose();
    super.dispose();
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

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final borderRadius = widget.borderRadius ?? BorderRadius.circular(16);
    
    return AnimatedContainer(
      duration: widget.morphingDuration,
      curve: iOS26Animations.neuralEase,
      width: widget.width,
      height: widget.height,
      margin: widget.margin,
      child: MouseRegion(
        onEnter: (_) => _handleHover(true),
        onExit: (_) => _handleHover(false),
        child: GestureDetector(
          onTap: widget.onTap,
          child: AnimatedBuilder(
            animation: Listenable.merge([
              _shimmerController,
              _borderController,
              _hoverController,
            ]),
            builder: (context, child) {
              return Container(
                decoration: BoxDecoration(
                  borderRadius: borderRadius,
                  border: _buildQuantumBorder(isDark),
                  boxShadow: _buildNeuralShadows(isDark),
                ),
                child: ClipRRect(
                  borderRadius: borderRadius,
                  child: BackdropFilter(
                    filter: ImageFilter.blur(
                      sigmaX: widget.neuralBlur + (_hoverController.value * 5),
                      sigmaY: widget.neuralBlur + (_hoverController.value * 5),
                    ),
                    child: Container(
                      padding: widget.padding,
                      decoration: BoxDecoration(
                        color: _getGlassColor(isDark),
                        borderRadius: borderRadius,
                      ),
                      child: Stack(
                        children: [
                          widget.child,
                          if (widget.enableHolographicShimmer)
                            _buildHolographicShimmer(),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Border? _buildQuantumBorder(bool isDark) {
    if (!widget.enableQuantumBorders) return null;
    
    final borderOpacity = 0.3 + (_borderController.value * 0.4);
    final hoverOpacity = _hoverController.value * 0.3;
    
    return Border.all(
      color: isDark
          ? iOS26Colors.quantumBorder.withOpacity(borderOpacity + hoverOpacity)
          : iOS26Colors.quantumBorder.withOpacity(borderOpacity + hoverOpacity),
      width: 1 + (_hoverController.value * 0.5),
    );
  }

  List<BoxShadow> _buildNeuralShadows(bool isDark) {
    final hoverIntensity = _hoverController.value;
    
    return [
      BoxShadow(
        color: iOS26Colors.neuralBlue.withOpacity(0.1 + (hoverIntensity * 0.2)),
        blurRadius: 10 + (hoverIntensity * 10),
        spreadRadius: 2 + (hoverIntensity * 3),
        offset: Offset(0, 4 + (hoverIntensity * 2)),
      ),
      if (_isHovered)
        BoxShadow(
          color: iOS26Colors.holographicShimmer.withOpacity(0.3),
          blurRadius: 20,
          spreadRadius: 5,
          offset: const Offset(0, 0),
        ),
    ];
  }

  Color _getGlassColor(bool isDark) {
    final baseColor = isDark 
        ? iOS26Colors.voidGlass 
        : iOS26Colors.hyperGlass;
    
    final hoverIntensity = _hoverController.value * 0.1;
    
    return Color.lerp(
      baseColor,
      baseColor.withOpacity(widget.quantumOpacity + hoverIntensity),
      _hoverController.value,
    ) ?? baseColor;
  }

  Widget _buildHolographicShimmer() {
    return Positioned.fill(
      child: ClipRRect(
        borderRadius: widget.borderRadius ?? BorderRadius.circular(16),
        child: AnimatedBuilder(
          animation: _shimmerController,
          builder: (context, child) {
            return Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: widget.holographicColors ?? iOS26Colors.holographicSpectrum,
                  stops: [
                    (_shimmerController.value - 0.3).clamp(0.0, 1.0),
                    _shimmerController.value.clamp(0.0, 1.0),
                    (_shimmerController.value + 0.3).clamp(0.0, 1.0),
                  ],
                ),
              ),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.1),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

/// Holographic Shimmer Effect Widget
class HolographicShimmer extends StatefulWidget {
  final Widget child;
  final Duration duration;
  final List<Color> colors;

  const HolographicShimmer({
    super.key,
    required this.child,
    this.duration = iOS26Animations.holographicShimmer,
    this.colors = iOS26Colors.holographicSpectrum,
  });

  @override
  State<HolographicShimmer> createState() => _HolographicShimmerState();
}

class _HolographicShimmerState extends State<HolographicShimmer>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: widget.duration,
      vsync: this,
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return ShaderMask(
          shaderCallback: (bounds) {
            return LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: widget.colors,
              stops: [
                (_controller.value - 0.3).clamp(0.0, 1.0),
                _controller.value.clamp(0.0, 1.0),
                (_controller.value + 0.3).clamp(0.0, 1.0),
              ],
            ).createShader(bounds);
          },
          blendMode: BlendMode.srcATop,
          child: widget.child,
        );
      },
    );
  }
}