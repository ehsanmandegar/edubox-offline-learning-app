import 'package:flutter/material.dart';
import '../../../core/models/content_block.dart';

class HighlightBoxWidget extends StatelessWidget {
  final ContentBlock contentBlock;

  const HighlightBoxWidget({
    super.key,
    required this.contentBlock,
  });

  @override
  Widget build(BuildContext context) {
    final content = contentBlock.content;
    final style = contentBlock.style ?? {};
    final icon = content['icon'] as String?;
    final text = content['persian'] as String? ?? '';

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(style['padding']?.toDouble() ?? 12.0),
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      decoration: BoxDecoration(
        color: _parseColor(style['backgroundColor']) ?? 
               Colors.amber.shade50,
        borderRadius: BorderRadius.circular(
          style['borderRadius']?.toDouble() ?? 4.0,
        ),
        border: Border(
          left: BorderSide(
            color: _parseColor(style['borderLeft']?.split(' ').last) ?? 
                   Colors.amber,
            width: 4.0,
          ),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (icon != null && icon.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(right: 12.0),
              child: Text(
                icon,
                style: const TextStyle(fontSize: 20),
              ),
            ),
          
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (contentBlock.title.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 8.0),
                    child: Text(
                      contentBlock.title,
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Colors.amber.shade800,
                      ),
                    ),
                  ),
                
                Text(
                  text,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    height: 1.5,
                    color: Colors.amber.shade900,
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
      if (colorValue.startsWith('#')) {
        return Color(int.parse(colorValue.substring(1), radix: 16) + 0xFF000000);
      }
    }
    
    return null;
  }
}