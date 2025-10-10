import 'package:flutter/material.dart';

/// iOS 26 Future-Ready Color System
/// Neural and holographic color palette for next-generation UI
class iOS26Colors {
  // Neural System Colors (AI-adaptive)
  static const Color neuralBlue = Color(0xFF0066FF);
  static const Color quantumGreen = Color(0xFF00FF88);
  static const Color plasmaOrange = Color(0xFFFF6600);
  static const Color cosmicRed = Color(0xFFFF0044);
  static const Color voidPurple = Color(0xFF6644FF);
  
  // Advanced Glass Morphism
  static const Color hyperGlass = Color(0x90FFFFFF);
  static const Color quantumBorder = Color(0x60FFFFFF);
  static const Color voidGlass = Color(0x60000000);
  static const Color holographicShimmer = Color(0x30FFFFFF);
  
  // Dynamic Status Colors (Context-aware)
  static const Color completedQuantum = Color(0xFF00FF77);
  static const Color availableNeural = Color(0xFF0077FF);
  static const Color lockedVoid = Color(0xFF666677);
  static const Color purchasedCosmic = Color(0xFFFFAA00);
  static const Color aiRecommended = Color(0xFFFF00FF);
  static const Color mastered = Color(0xFFE6E6FA);
  
  // Holographic Gradients
  static const List<Color> holographicSpectrum = [
    Color(0xFFFF0080),
    Color(0xFF8000FF),
    Color(0xFF0080FF),
    Color(0xFF00FF80),
    Color(0xFFFF8000),
  ];
  
  // Background Gradients
  static const List<Color> neuralBackground = [
    Color(0xFFF2F2F7),
    Color(0xFFE5E5EA),
    Color(0xFFF2F2F7),
  ];
  
  static const List<Color> darkNeuralBackground = [
    Color(0xFF000000),
    Color(0xFF1C1C1E),
    Color(0xFF000000),
  ];
  
  // Quantum Glow Colors
  static const Color quantumGlow = Color(0x40007AFF);
  static const Color cosmicGlow = Color(0x40FF6600);
  static const Color voidGlow = Color(0x40666677);
  
  // Helper methods for dynamic colors
  static Color getStatusColor(LessonStatus status) {
    switch (status) {
      case LessonStatus.completed:
        return completedQuantum;
      case LessonStatus.available:
        return availableNeural;
      case LessonStatus.locked:
        return lockedVoid;
      case LessonStatus.purchased:
        return purchasedCosmic;
      case LessonStatus.aiRecommended:
        return aiRecommended;
      case LessonStatus.mastered:
        return mastered;
    }
  }
  
  static LinearGradient getHolographicGradient({
    AlignmentGeometry begin = Alignment.topLeft,
    AlignmentGeometry end = Alignment.bottomRight,
  }) {
    return LinearGradient(
      begin: begin,
      end: end,
      colors: holographicSpectrum,
    );
  }
  
  static LinearGradient getNeuralBackgroundGradient({
    bool isDark = false,
    AlignmentGeometry begin = Alignment.topLeft,
    AlignmentGeometry end = Alignment.bottomRight,
  }) {
    return LinearGradient(
      begin: begin,
      end: end,
      colors: isDark ? darkNeuralBackground : neuralBackground,
    );
  }
}

/// Lesson status enumeration for iOS 26
enum LessonStatus {
  completed,
  available,
  locked,
  purchased,
  aiRecommended,
  mastered,
}