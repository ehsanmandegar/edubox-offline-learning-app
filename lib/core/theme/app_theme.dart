import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:ui';
import 'ios26_colors.dart';
import 'ios26_typography.dart';
import 'ios26_animations.dart';

class AppTheme {
  // iOS 26 Neural colors
  static const Color primaryBlue = iOS26Colors.neuralBlue;
  static const Color systemGray = Color(0xFF8E8E93);
  static const Color systemGray2 = Color(0xFFAEAEB2);
  static const Color systemGray3 = Color(0xFFC7C7CC);
  static const Color systemGray4 = Color(0xFFD1D1D6);
  static const Color systemGray5 = Color(0xFFE5E5EA);
  static const Color systemGray6 = Color(0xFFF0F4FF);
  
  static ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    fontFamily: iOS26Typography.fontFamily,
    colorScheme: ColorScheme.fromSeed(
      seedColor: primaryBlue,
      brightness: Brightness.light,
      surface: systemGray6,
      onSurface: Colors.black,
    ),
    
    // iOS 26 Neural Typography
    textTheme: const TextTheme(
      displayLarge: iOS26Typography.neuralLargeTitle,
      displayMedium: iOS26Typography.quantumTitle1,
      displaySmall: iOS26Typography.cosmicTitle2,
      headlineLarge: iOS26Typography.voidTitle3,
      headlineMedium: iOS26Typography.neuralHeadline,
      headlineSmall: iOS26Typography.neuralHeadline,
      titleLarge: iOS26Typography.cosmicTitle2,
      titleMedium: iOS26Typography.neuralHeadline,
      titleSmall: iOS26Typography.cosmicCallout,
      bodyLarge: iOS26Typography.quantumBody,
      bodyMedium: iOS26Typography.cosmicCallout,
      bodySmall: iOS26Typography.voidSubheadline,
      labelLarge: iOS26Typography.neuralHeadline,
      labelMedium: iOS26Typography.neuralFootnote,
      labelSmall: iOS26Typography.quantumCaption1,
    ),
    
    // Glass morphism app bar
    appBarTheme: AppBarTheme(
      centerTitle: true,
      elevation: 0,
      scrolledUnderElevation: 0,
      backgroundColor: Colors.white.withOpacity(0.8),
      foregroundColor: Colors.black,
      titleTextStyle: const TextStyle(
        color: Colors.black,
        fontSize: 18,
        fontWeight: FontWeight.w600,
      ),
      systemOverlayStyle: const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
      ),
    ),
    
    // Glass cards
    cardTheme: CardTheme(
      elevation: 0,
      color: Colors.white.withOpacity(0.7),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: Colors.white.withOpacity(0.2),
          width: 1,
        ),
      ),
    ),
    
    // Modern buttons
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        elevation: 0,
        backgroundColor: primaryBlue,
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        textStyle: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
        ),
      ),
    ),
    
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: primaryBlue,
        side: BorderSide(color: primaryBlue.withOpacity(0.5)),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      ),
    ),
    
    // Bottom navigation with glass effect
    bottomNavigationBarTheme: BottomNavigationBarThemeData(
      backgroundColor: Colors.white.withOpacity(0.8),
      selectedItemColor: primaryBlue,
      unselectedItemColor: systemGray,
      type: BottomNavigationBarType.fixed,
      elevation: 0,
    ),
    
    // Input decoration
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: systemGray6,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: primaryBlue, width: 2),
      ),
    ),
  );
  
  static ThemeData darkTheme = ThemeData(
    useMaterial3: true,
    colorScheme: ColorScheme.fromSeed(
      seedColor: primaryBlue,
      brightness: Brightness.dark,
      surface: const Color(0xFF1C1C1E),
      onSurface: Colors.white,
    ),
    
    // Dark glass morphism
    appBarTheme: AppBarTheme(
      centerTitle: true,
      elevation: 0,
      scrolledUnderElevation: 0,
      backgroundColor: Colors.black.withOpacity(0.8),
      foregroundColor: Colors.white,
      titleTextStyle: const TextStyle(
        color: Colors.white,
        fontSize: 18,
        fontWeight: FontWeight.w600,
      ),
    ),
    
    cardTheme: CardTheme(
      elevation: 0,
      color: Colors.black.withOpacity(0.6),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: Colors.white.withOpacity(0.1),
          width: 1,
        ),
      ),
    ),
    
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        elevation: 0,
        backgroundColor: primaryBlue,
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      ),
    ),
  );
}

// Glass morphism container widget
class GlassContainer extends StatelessWidget {
  final Widget child;
  final double? width;
  final double? height;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final BorderRadius? borderRadius;

  const GlassContainer({
    super.key,
    required this.child,
    this.width,
    this.height,
    this.padding,
    this.margin,
    this.borderRadius,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Container(
      width: width,
      height: height,
      padding: padding,
      margin: margin,
      decoration: BoxDecoration(
        borderRadius: borderRadius ?? BorderRadius.circular(16),
        border: Border.all(
          color: isDark 
              ? Colors.white.withOpacity(0.1)
              : Colors.white.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: ClipRRect(
        borderRadius: borderRadius ?? BorderRadius.circular(16),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
            decoration: BoxDecoration(
              color: isDark
                  ? Colors.black.withOpacity(0.3)
                  : Colors.white.withOpacity(0.7),
            ),
            child: child,
          ),
        ),
      ),
    );
  }
}