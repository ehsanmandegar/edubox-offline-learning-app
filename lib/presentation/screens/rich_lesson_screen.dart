import 'package:flutter/material.dart';
import '../../core/models/lesson.dart';
import '../widgets/content_blocks/content_block_renderer.dart';

class RichLessonScreen extends StatefulWidget {
  final Lesson lesson;

  const RichLessonScreen({
    super.key,
    required this.lesson,
  });

  @override
  State<RichLessonScreen> createState() => _RichLessonScreenState();
}

class _RichLessonScreenState extends State<RichLessonScreen> {
  bool _showEnglish = false;
  double _progress = 0.0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.lesson.title,
          style: const TextStyle(fontSize: 18),
        ),
        actions: [
          if (widget.lesson.hasRichContent)
            IconButton(
              onPressed: () {
                setState(() {
                  _showEnglish = !_showEnglish;
                });
              },
              icon: Icon(
                _showEnglish ? Icons.translate : Icons.translate_outlined,
              ),
              tooltip: _showEnglish ? 'نمایش فارسی' : 'Show English',
            ),
          
          PopupMenuButton<String>(
            onSelected: (value) {
              switch (value) {
                case 'bookmark':
                  _toggleBookmark();
                  break;
                case 'share':
                  _shareLesson();
                  break;
                case 'report':
                  _reportIssue();
                  break;
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'bookmark',
                child: Row(
                  children: [
                    Icon(Icons.bookmark_outline),
                    SizedBox(width: 8),
                    Text('نشانک‌گذاری'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'share',
                child: Row(
                  children: [
                    Icon(Icons.share),
                    SizedBox(width: 8),
                    Text('اشتراک‌گذاری'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'report',
                child: Row(
                  children: [
                    Icon(Icons.report_outlined),
                    SizedBox(width: 8),
                    Text('گزارش مشکل'),
                  ],
                ),
              ),
            ],
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(4.0),
          child: LinearProgressIndicator(
            value: _progress,
            backgroundColor: Colors.grey.shade200,
            valueColor: AlwaysStoppedAnimation<Color>(
              Theme.of(context).colorScheme.primary,
            ),
          ),
        ),
      ),
      
      body: Column(
        children: [
          // Lesson info header
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16.0),
            color: Theme.of(context).colorScheme.surface,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    if (widget.lesson.difficulty != null)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8.0,
                          vertical: 4.0,
                        ),
                        decoration: BoxDecoration(
                          color: _getDifficultyColor().withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: _getDifficultyColor()),
                        ),
                        child: Text(
                          widget.lesson.difficulty!,
                          style: TextStyle(
                            fontSize: 12,
                            color: _getDifficultyColor(),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    
                    if (widget.lesson.estimatedTime != null) ...[
                      const SizedBox(width: 8),
                      Icon(
                        Icons.access_time,
                        size: 16,
                        color: Colors.grey.shade600,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        widget.lesson.estimatedTime!,
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                    
                    const Spacer(),
                    
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8.0,
                        vertical: 4.0,
                      ),
                      decoration: BoxDecoration(
                        color: widget.lesson.isFree 
                            ? Colors.green.shade50 
                            : Colors.orange.shade50,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: widget.lesson.isFree 
                              ? Colors.green 
                              : Colors.orange,
                        ),
                      ),
                      child: Text(
                        widget.lesson.isFree ? 'رایگان' : 'پریمیوم',
                        style: TextStyle(
                          fontSize: 12,
                          color: widget.lesson.isFree 
                              ? Colors.green.shade700 
                              : Colors.orange.shade700,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          
          // Content
          Expanded(
            child: widget.lesson.hasRichContent
                ? _buildRichContent()
                : _buildSimpleContent(),
          ),
        ],
      ),
      
      // Bottom navigation
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(16.0),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 4,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () {
                  // Previous lesson
                },
                icon: const Icon(Icons.arrow_back),
                label: const Text('درس قبل'),
              ),
            ),
            
            const SizedBox(width: 16),
            
            Expanded(
              child: ElevatedButton.icon(
                onPressed: () {
                  // Next lesson or mark complete
                  _markAsCompleted();
                },
                icon: const Icon(Icons.arrow_forward),
                label: const Text('درس بعد'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRichContent() {
    return ListView.builder(
      padding: const EdgeInsets.all(16.0),
      itemCount: widget.lesson.contentBlocks!.length,
      itemBuilder: (context, index) {
        final contentBlock = widget.lesson.contentBlocks![index];
        
        return ContentBlockRenderer(
          contentBlock: contentBlock,
          showEnglish: _showEnglish,
        );
      },
    );
  }

  Widget _buildSimpleContent() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            _showEnglish && widget.lesson.translatedContent.isNotEmpty
                ? widget.lesson.content
                : widget.lesson.translatedContent.isNotEmpty
                    ? widget.lesson.translatedContent
                    : widget.lesson.content,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              height: 1.6,
            ),
          ),
          
          if (widget.lesson.examples.isNotEmpty) ...[
            const SizedBox(height: 24),
            Text(
              'مثال‌ها:',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            ...widget.lesson.examples.map((example) => Container(
              width: double.infinity,
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: Text(
                example,
                style: const TextStyle(
                  fontFamily: 'monospace',
                  fontSize: 14,
                ),
              ),
            )),
          ],
        ],
      ),
    );
  }

  Color _getDifficultyColor() {
    switch (widget.lesson.difficulty?.toLowerCase()) {
      case 'مبتدی':
      case 'beginner':
        return Colors.green;
      case 'متوسط':
      case 'intermediate':
        return Colors.orange;
      case 'پیشرفته':
      case 'advanced':
        return Colors.red;
      default:
        return Colors.blue;
    }
  }

  void _toggleBookmark() {
    // TODO: Implement bookmark functionality
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('نشانک اضافه شد')),
    );
  }

  void _shareLesson() {
    // TODO: Implement share functionality
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('لینک درس کپی شد')),
    );
  }

  void _reportIssue() {
    // TODO: Implement report functionality
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('گزارش مشکل'),
        content: const Text('این ویژگی به زودی اضافه خواهد شد.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('باشه'),
          ),
        ],
      ),
    );
  }

  void _markAsCompleted() {
    setState(() {
      _progress = 1.0;
    });
    
    // TODO: Save progress
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('درس تکمیل شد!')),
    );
  }
}