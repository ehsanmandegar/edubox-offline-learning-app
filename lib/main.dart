import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'core/providers/app_state.dart';
import 'core/providers/course_state.dart';
import 'core/providers/purchase_state.dart';
import 'core/providers/progress_state.dart';
import 'presentation/screens/home_screen.dart';
import 'core/theme/app_theme.dart';

void main() {
  runApp(const EduBoxApp());
}

class EduBoxApp extends StatelessWidget {
  const EduBoxApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AppState()),
        ChangeNotifierProvider(create: (_) => CourseState()),
        ChangeNotifierProvider(create: (_) => PurchaseState()),
        ChangeNotifierProvider(create: (_) => ProgressState()),
      ],
      child: Consumer<AppState>(
        builder: (context, appState, child) {
          return MaterialApp(
            title: 'EduBox',
            debugShowCheckedModeBanner: false,
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            themeMode: appState.themeMode,
            locale: appState.locale,
            home: const AppInitializer(),
          );
        },
      ),
    );
  }
}

class AppInitializer extends StatefulWidget {
  const AppInitializer({super.key});

  @override
  State<AppInitializer> createState() => _AppInitializerState();
}

class _AppInitializerState extends State<AppInitializer> {
  @override
  void initState() {
    super.initState();
    _initializeApp();
  }

  Future<void> _initializeApp() async {
    final courseState = context.read<CourseState>();
    final purchaseState = context.read<PurchaseState>();
    final progressState = context.read<ProgressState>();

    // Initialize all states
    await Future.wait([
      courseState.initialize(),
      purchaseState.initialize(),
      progressState.initialize(),
    ]);
  }

  @override
  Widget build(BuildContext context) {
    return Consumer3<CourseState, PurchaseState, ProgressState>(
      builder: (context, courseState, purchaseState, progressState, child) {
        final isLoading = !courseState.isInitialized || 
                         !purchaseState.isInitialized || 
                         !progressState.isInitialized;

        if (isLoading) {
          return const Scaffold(
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text('Loading EduBox...'),
                ],
              ),
            ),
          );
        }

        return const HomeScreen();
      },
    );
  }
}