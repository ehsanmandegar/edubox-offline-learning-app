import 'package:flutter/material.dart';
import '../../../core/models/content_block.dart';
import 'text_content_widget.dart';
import 'highlight_box_widget.dart';
import 'code_block_widget.dart';
import 'quiz_widget.dart';

class ContentBlockRenderer extends StatelessWidget {
  final ContentBlock contentBlock;
  final bool showEnglish;

  const ContentBlockRenderer({
    super.key,
    required this.contentBlock,
    this.showEnglish = false,
  });

  @override
  Widget build(BuildContext context) {
    switch (contentBlock.type) {
      case 'text':
        return TextContentWidget(
          contentBlock: contentBlock,
          showEnglish: showEnglish,
        );
        
      case 'highlight_box':
      case 'tip':
        return HighlightBoxWidget(
          contentBlock: contentBlock,
        );
        
      case 'code_block':
        return CodeBlockWidget(
          contentBlock: contentBlock,
        );
        
      case 'quiz':
        return QuizWidget(
          contentBlock: contentBlock,
        );
        
      case 'interactive_demo':
        return _buildInteractiveDemo();
        
      case 'image':
        return _buildImageWidget();
        
      case 'video':
        return _buildVideoWidget();
        
      case 'list':
        return _buildListWidget();
        
      case 'table':
        return _buildTableWidget();
        
      case 'exercise':
        return _buildExerciseWidget();
        
      default:
        return _buildUnsupportedWidget();
    }
  }

  Widget _buildInteractiveDemo() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16.0),
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      decoration: BoxDecoration(
        color: Colors.blue.shade50,
        border: Border.all(color: Colors.blue, width: 2),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.play_circle_outline, color: Colors.blue.shade700),
              const SizedBox(width: 8),
              Text(
                contentBlock.title,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.blue.shade700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            contentBlock.content['description'] ?? 'دمو تعاملی',
            style: TextStyle(color: Colors.blue.shade800),
          ),
          const SizedBox(height: 12),
          ElevatedButton.icon(
            onPressed: () {
              // TODO: Open interactive demo
            },
            icon: const Icon(Icons.code),
            label: const Text('باز کردن ویرایشگر'),
          ),
        ],
      ),
    );
  }

  Widget _buildImageWidget() {
    final content = contentBlock.content;
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          if (contentBlock.title.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(bottom: 8.0),
              child: Text(
                contentBlock.title,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ),
          
          Container(
            constraints: BoxConstraints(
              maxWidth: double.tryParse(content['maxWidth']?.toString() ?? '600') ?? 600,
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.asset(
                content['src'] ?? 'assets/images/placeholder.png',
                width: _parseWidth(content['width']),
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    height: 200,
                    color: Colors.grey.shade200,
                    child: const Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.image_not_supported, size: 48, color: Colors.grey),
                          SizedBox(height: 8),
                          Text('تصویر یافت نشد', style: TextStyle(color: Colors.grey)),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
          
          if (content['caption'] != null)
            Padding(
              padding: const EdgeInsets.only(top: 8.0),
              child: Text(
                content['caption'],
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey.shade600,
                  fontStyle: FontStyle.italic,
                ),
                textAlign: TextAlign.center,
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildVideoWidget() {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (contentBlock.title.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(bottom: 8.0),
              child: Text(
                contentBlock.title,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ),
          
          Container(
            height: 200,
            decoration: BoxDecoration(
              color: Colors.black,
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.play_circle_outline, size: 64, color: Colors.white),
                  SizedBox(height: 8),
                  Text(
                    'پخش ویدیو',
                    style: TextStyle(color: Colors.white),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildListWidget() {
    final content = contentBlock.content;
    final items = content['items'] as List? ?? [];
    
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16.0),
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      decoration: BoxDecoration(
        color: Colors.blue.shade50,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (contentBlock.title.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(bottom: 12.0),
              child: Text(
                contentBlock.title,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.blue.shade700,
                ),
              ),
            ),
          
          ...items.map((item) {
            final text = item is Map ? item['text'] : item.toString();
            final icon = item is Map ? item['icon'] : null;
            
            return Padding(
              padding: const EdgeInsets.only(bottom: 8.0),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (icon != null)
                    Padding(
                      padding: const EdgeInsets.only(left: 8.0),
                      child: Text(icon, style: const TextStyle(fontSize: 16)),
                    )
                  else
                    Container(
                      width: 6,
                      height: 6,
                      margin: const EdgeInsets.only(top: 8, left: 8),
                      decoration: BoxDecoration(
                        color: Colors.blue.shade600,
                        shape: BoxShape.circle,
                      ),
                    ),
                  
                  Expanded(
                    child: Text(
                      text,
                      style: TextStyle(color: Colors.blue.shade800),
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
        ],
      ),
    );
  }

  Widget _buildTableWidget() {
    final content = contentBlock.content;
    final headers = content['headers'] as List? ?? [];
    final rows = content['rows'] as List? ?? [];
    
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (contentBlock.title.isNotEmpty)
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                contentBlock.title,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ),
          
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: DataTable(
              columns: headers.map((header) => DataColumn(
                label: Text(
                  header.toString(),
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              )).toList(),
              rows: rows.map((row) => DataRow(
                cells: (row as List).map((cell) => DataCell(
                  Text(cell.toString()),
                )).toList(),
              )).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildExerciseWidget() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16.0),
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      decoration: BoxDecoration(
        color: Colors.orange.shade50,
        border: Border.all(color: Colors.orange.shade200),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.assignment, color: Colors.orange.shade700),
              const SizedBox(width: 8),
              Text(
                contentBlock.title,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.orange.shade700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            contentBlock.content['description'] ?? 'تمرین عملی',
            style: TextStyle(color: Colors.orange.shade800),
          ),
          const SizedBox(height: 12),
          ElevatedButton.icon(
            onPressed: () {
              // TODO: Open exercise
            },
            icon: const Icon(Icons.code),
            label: const Text('شروع تمرین'),
          ),
        ],
      ),
    );
  }

  Widget _buildUnsupportedWidget() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16.0),
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Column(
        children: [
          Icon(Icons.help_outline, size: 32, color: Colors.grey.shade600),
          const SizedBox(height: 8),
          Text(
            'نوع محتوا پشتیبانی نمی‌شود: ${contentBlock.type}',
            style: TextStyle(color: Colors.grey.shade600),
          ),
        ],
      ),
    );
  }

  double? _parseWidth(dynamic widthValue) {
    if (widthValue == null) return null;
    
    final widthStr = widthValue.toString();
    
    // Handle percentage values like "100%"
    if (widthStr.contains('%')) {
      return double.infinity;
    }
    
    // Try to parse as double
    return double.tryParse(widthStr);
  }
}