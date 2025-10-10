import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:convert';
import 'package:flutter/services.dart';
import 'core/models/lesson.dart';
import 'core/theme/app_theme.dart';
import 'core/providers/course_progress_provider.dart';
import 'core/providers/purchase_state.dart';
import 'presentation/screens/course_navigation_screen.dart';
import 'presentation/screens/rich_lesson_screen.dart';

void main() {
  runApp(const EduBoxApp());
}

class EduBoxApp extends StatelessWidget {
  const EduBoxApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => PurchaseState()),
        ChangeNotifierProxyProvider<PurchaseState, CourseProgressProvider>(
          create: (context) => CourseProgressProvider(
            Provider.of<PurchaseState>(context, listen: false),
          ),
          update: (context, purchaseState, previous) =>
              previous ?? CourseProgressProvider(purchaseState),
        ),
      ],
      child: MaterialApp(
        title: 'EduBox - iOS 26',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        darkTheme: AppTheme.darkTheme,
        themeMode: ThemeMode.system,
        home: const CourseNavigationScreen(),
      ),
    );
  }
}

