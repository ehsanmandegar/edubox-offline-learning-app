import 'package:flutter/material.dart';

/// iOS 26 Advanced Typography System
/// Neural-adaptive font system with holographic text effects
class iOS26Typography {
  static const String primaryFontFamily = 'SF Pro Display';
  static const String secondaryFontFamily = 'SF Pro Text';
  
  // Neural Title Styles
  static const TextStyle neuralLargeTitle = TextStyle(
    fontSize: 34,
    fontWeight: FontWeight.w700,
    fontFamily: primaryFontFamily,
    letterSpacing: -0.5,
    height: 1.2,
  );
  
  static const TextStyle quantumTitle1 = TextStyle(
    fontSize: 28,
    fontWeight: FontWeight.w700,
    fontFamily: primaryFontFamily,
    letterSpacing: -0.3,
    height: 1.25,
  );
  
  static const TextStyle cosmicTitle2 = TextStyle(
    fontSize: 22,
    fontWeight: FontWeight.w600,
    fontFamily: primaryFontFamily,
    letterSpacing: -0.2,
    height: 1.3,
  );
  
  static const TextStyle voidTitle3 = TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.w600,
    fontFamily: primaryFontFamily,
    letterSpacing: -0.1,
    height: 1.35,
  );
  
  // Neural Body Styles
  static const TextStyle neuralHeadline = TextStyle(
    fontSize: 17,
    fontWeight: FontWeight.w600,
    fontFamily: primaryFontFamily,
    letterSpacing: 0,
    height: 1.4,
  );
  
  static const TextStyle quantumBody = TextStyle(
    fontSize: 17,
    fontWeight: FontWeight.w400,
    fontFamily: secondaryFontFamily,
    letterSpacing: 0,
    height: 1.45,
  );
  
  static const TextStyle cosmicCallout = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w400,
    fontFamily: secondaryFontFamily,
    letterSpacing: 0,
    height: 1.4,
  );
  
  static const TextStyle voidSubheadline = TextStyle(
    fontSize: 15,
    fontWeight: FontWeight.w400,
    fontFamily: secondaryFontFamily,
    letterSpacing: 0,
    height: 1.35,
  );
  
  static const TextStyle neuralFootnote = TextStyle(
    fontSize: 13,
    fontWeight: FontWeight.w400,
    fontFamily: secondaryFontFamily,
    letterSpacing: 0,
    height: 1.3,
  );
  
  static const TextStyle quantumCaption1 = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w400,
    fontFamily: secondaryFontFamily,
    letterSpacing: 0,
    height: 1.25,
  );
  
  static const TextStyle cosmicCaption2 = TextStyle(
    fontSize: 11,
    fontWeight: FontWeight.w400,
    fontFamily: secondaryFontFamily,
    letterSpacing: 0,
    height: 1.2,
  );
  
  // Holographic Text Effects
  static TextStyle getHolographicText(TextStyle baseStyle) {
    return baseStyle.copyWith(
      foreground: Paint()
        ..shader = const LinearGradient(
          colors: [
            Color(0xFFFF0080),
            Color(0xFF8000FF),
            Color(0xFF0080FF),
            Color(0xFF00FF80),
            Color(0xFFFF8000),
          ],
        ).createShader(const Rect.fromLTWH(0.0, 0.0, 200.0, 70.0)),
    );
  }
  
  // Neural Glow Text Effects
  static TextStyle getNeuralGlowText(TextStyle baseStyle, Color glowColor) {
    return baseStyle.copyWith(
      shadows: [
        Shadow(
          color: glowColor.withOpacity(0.5),
          blurRadius: 10,
          offset: const Offset(0, 0),
        ),
        Shadow(
          color: glowColor.withOpacity(0.3),
          blurRadius: 20,
          offset: const Offset(0, 0),
        ),
      ],
    );
  }
  
  // Quantum Shimmer Text Effects
  static TextStyle getQuantumShimmerText(TextStyle baseStyle) {
    return baseStyle.copyWith(
      foreground: Paint()
        ..shader = const LinearGradient(
          colors: [
            Color(0xFF0066FF),
            Color(0xFF00AAFF),
            Color(0xFF0066FF),
          ],
          stops: [0.0, 0.5, 1.0],
        ).createShader(const Rect.fromLTWH(0.0, 0.0, 200.0, 70.0)),
    );
  }
  
  // Contextual Text Styles
  static TextStyle getLessonTitleStyle(bool isCompleted, bool isLocked) {
    if (isCompleted) {
      return getNeuralGlowText(neuralHeadline, const Color(0xFF00FF77));
    } else if (isLocked) {
      return voidSubheadline.copyWith(
        color: const Color(0xFF666677),
      );
    } else {
      return neuralHeadline.copyWith(
        color: const Color(0xFF0077FF),
      );
    }
  }
  
  static TextStyle getCourseProgressStyle() {
    return getQuantumShimmerText(cosmicCallout);
  }
}