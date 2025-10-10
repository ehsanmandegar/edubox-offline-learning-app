import 'package:flutter/material.dart';
import '../../../core/models/content_block.dart';

class TextContentWidget extends StatelessWidget {
  final ContentBlock contentBlock;
  final bool showEnglish;

  const TextContentWidget({
    super.key,
    required this.contentBlock,
    this.showEnglish = false,
  });

  @override
  Widget build(BuildContext context) {
    final content = TextContent.fromJson(contentBlock.content);
    final style = contentBlock.style ?? {};

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(style['padding']?.toDouble() ?? 16.0),
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      decoration: BoxDecoration(
        color: _parseColor(style['backgroundColor']) ?? 
               Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(
          style['borderRadius']?.toDouble() ?? 8.0,
        ),
        border: style['border'] != null 
            ? Border.all(color: Colors.grey.shade300)
            : null,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (contentBlock.title.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(bottom: 12.0),
              child: Text(
                contentBlock.title,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
            ),
          
          Text(
            showEnglish && content.english != null 
                ? content.english! 
                : content.persian,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              fontSize: style['fontSize']?.toDouble() ?? 16.0,
              height: 1.6,
            ),
            textAlign: TextAlign.justify,
          ),
          
          if (content.english != null && content.english!.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 12.0),
              child: Row(
                children: [
                  Icon(
                    showEnglish ? Icons.translate : Icons.translate_outlined,
                    size: 16,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  const SizedBox(width: 4),
                  GestureDetector(
                    onTap: () {
                      // Toggle language - this would be handled by parent widget
                    },
                    child: Text(
                      showEnglish ? 'نمایش فارسی' : 'Show English',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context).colorScheme.primary,
                        decoration: TextDecoration.underline,
                      ),
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Color? _parseColor(dynamic colorValue) {
    if (colorValue == null) return null;
    
    if (colorValue is String) {
      // Parse hex color like "#f8f9fa"
      if (colorValue.startsWith('#')) {
        return Color(int.parse(colorValue.substring(1), radix: 16) + 0xFF000000);
      }
    }
    
    return null;
  }
}