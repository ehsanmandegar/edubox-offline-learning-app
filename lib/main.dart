import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:flutter/services.dart';
import 'core/models/lesson.dart';
import 'presentation/screens/rich_lesson_screen.dart';

void main() {
  runApp(const EduBoxApp());
}

class EduBoxApp extends StatelessWidget {
  const EduBoxApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'EduBox',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
        useMaterial3: true,
      ),
      home: const HomeScreen(),
    );
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  Lesson? _sampleLesson;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadSampleLesson();
  }

  Future<void> _loadSampleLesson() async {
    try {
      final String jsonString = await rootBundle.loadString('assets/data/html_rich_sample.json');
      final Map<String, dynamic> jsonData = json.decode(jsonString);
      final courses = jsonData['courses'] as List;
      
      if (courses.isNotEmpty) {
        final course = courses.first;
        final lessons = course['lessons'] as List;
        
        if (lessons.isNotEmpty) {
          setState(() {
            _sampleLesson = Lesson.fromJson(lessons.first);
            _isLoading = false;
          });
        }
      }
    } catch (e) {
      print('Error loading sample lesson: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('EduBox'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.school,
                    size: 100,
                    color: Colors.blue,
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    'Welcome to EduBox',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    'Rich Content Learning Experience',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey,
                    ),
                  ),
                  const SizedBox(height: 40),
                  
                  if (_sampleLesson != null)
                    ElevatedButton.icon(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => RichLessonScreen(
                              lesson: _sampleLesson!,
                            ),
                          ),
                        );
                      },
                      icon: const Icon(Icons.play_arrow),
                      label: const Text('مشاهده درس نمونه'),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 12,
                        ),
                      ),
                    )
                  else
                    const Text(
                      'خطا در بارگذاری درس نمونه',
                      style: TextStyle(color: Colors.red),
                    ),
                ],
              ),
            ),
    );
  }
}