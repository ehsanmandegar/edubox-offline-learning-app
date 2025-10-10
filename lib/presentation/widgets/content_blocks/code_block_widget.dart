import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../core/models/content_block.dart';

class CodeBlockWidget extends StatefulWidget {
  final ContentBlock contentBlock;

  const CodeBlockWidget({
    super.key,
    required this.contentBlock,
  });

  @override
  State<CodeBlockWidget> createState() => _CodeBlockWidgetState();
}

class _CodeBlockWidgetState extends State<CodeBlockWidget> {
  bool _copied = false;

  @override
  Widget build(BuildContext context) {
    final content = CodeContent.fromJson(widget.contentBlock.content);
    final style = widget.contentBlock.style ?? {};
    final features = widget.contentBlock.features ?? {};

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      decoration: BoxDecoration(
        color: _parseColor(style['backgroundColor']) ?? 
               Colors.grey.shade100,
        borderRadius: BorderRadius.circular(
          style['borderRadius']?.toDouble() ?? 6.0,
        ),
        border: Border.all(
          color: _parseColor(style['border']) ?? Colors.grey.shade300,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with title and actions
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
            decoration: BoxDecoration(
              color: Colors.grey.shade200,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(6.0),
                topRight: Radius.circular(6.0),
              ),
            ),
            child: Row(
              children: [
                Icon(
                  _getLanguageIcon(content.language),
                  size: 16,
                  color: Colors.grey.shade700,
                ),
                const SizedBox(width: 8),
                
                Text(
                  widget.contentBlock.title.isNotEmpty 
                      ? widget.contentBlock.title
                      : content.language.toUpperCase(),
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Colors.grey.shade700,
                  ),
                ),
                
                const Spacer(),
                
                if (features['copyable'] == true)
                  IconButton(
                    onPressed: _copyCode,
                    icon: Icon(
                      _copied ? Icons.check : Icons.copy,
                      size: 16,
                      color: _copied ? Colors.green : Colors.grey.shade600,
                    ),
                    tooltip: _copied ? 'کپی شد!' : 'کپی کردن',
                  ),
                
                if (features['runnable'] == true)
                  IconButton(
                    onPressed: () {
                      // Handle run code
                      _showRunDialog();
                    },
                    icon: Icon(
                      Icons.play_arrow,
                      size: 16,
                      color: Colors.green.shade600,
                    ),
                    tooltip: 'اجرای کد',
                  ),
              ],
            ),
          ),
          
          // Code content
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16.0),
            child: SelectableText(
              content.code,
              style: TextStyle(
                fontFamily: 'monospace',
                fontSize: 14,
                height: 1.4,
                color: Colors.grey.shade800,
              ),
            ),
          ),
          
          // Explanation
          if (content.explanation != null && content.explanation!.isNotEmpty)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(16.0, 0, 16.0, 16.0),
              child: Text(
                content.explanation!,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Colors.grey.shade600,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ),
        ],
      ),
    );
  }

  IconData _getLanguageIcon(String language) {
    switch (language.toLowerCase()) {
      case 'html':
        return Icons.web;
      case 'css':
        return Icons.palette;
      case 'javascript':
      case 'js':
        return Icons.code;
      case 'python':
        return Icons.smart_toy;
      default:
        return Icons.code;
    }
  }

  void _copyCode() async {
    final content = CodeContent.fromJson(widget.contentBlock.content);
    await Clipboard.setData(ClipboardData(text: content.code));
    
    setState(() {
      _copied = true;
    });
    
    // Reset after 2 seconds
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        setState(() {
          _copied = false;
        });
      }
    });
  }

  void _showRunDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('اجرای کد'),
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

  Color? _parseColor(dynamic colorValue) {
    if (colorValue == null) return null;
    
    if (colorValue is String) {
      if (colorValue.startsWith('#')) {
        return Color(int.parse(colorValue.substring(1), radix: 16) + 0xFF000000);
      }
    }
    
    return null;
  }
}