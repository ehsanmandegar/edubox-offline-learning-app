import 'package:flutter/material.dart';
import '../../../core/models/content_block.dart';

class QuizWidget extends StatefulWidget {
  final ContentBlock contentBlock;

  const QuizWidget({
    super.key,
    required this.contentBlock,
  });

  @override
  State<QuizWidget> createState() => _QuizWidgetState();
}

class _QuizWidgetState extends State<QuizWidget> {
  int? _selectedAnswer;
  bool _showResult = false;

  @override
  Widget build(BuildContext context) {
    final content = QuizContent.fromJson(widget.contentBlock.content);
    final style = widget.contentBlock.style ?? {};

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(style['padding']?.toDouble() ?? 20.0),
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      decoration: BoxDecoration(
        color: _parseColor(style['backgroundColor']) ?? 
               Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(
          style['borderRadius']?.toDouble() ?? 8.0,
        ),
        border: Border.all(
          color: _parseColor(style['border']) ?? Colors.grey.shade300,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Quiz header
          Row(
            children: [
              Icon(
                Icons.quiz,
                color: Theme.of(context).colorScheme.primary,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                widget.contentBlock.title,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 16),
          
          // Question
          Text(
            content.question,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              fontWeight: FontWeight.w500,
              height: 1.5,
            ),
          ),
          
          const SizedBox(height: 16),
          
          // Options
          ...content.options.asMap().entries.map((entry) {
            final index = entry.key;
            final option = entry.value;
            final isSelected = _selectedAnswer == index;
            final isCorrect = index == content.correctAnswer;
            
            Color? backgroundColor;
            Color? borderColor;
            Color? textColor;
            
            if (_showResult) {
              if (isCorrect) {
                backgroundColor = Colors.green.shade50;
                borderColor = Colors.green;
                textColor = Colors.green.shade800;
              } else if (isSelected && !isCorrect) {
                backgroundColor = Colors.red.shade50;
                borderColor = Colors.red;
                textColor = Colors.red.shade800;
              }
            } else if (isSelected) {
              backgroundColor = Theme.of(context).colorScheme.primary.withOpacity(0.1);
              borderColor = Theme.of(context).colorScheme.primary;
            }
            
            return Padding(
              padding: const EdgeInsets.only(bottom: 8.0),
              child: InkWell(
                onTap: _showResult ? null : () {
                  setState(() {
                    _selectedAnswer = index;
                  });
                },
                borderRadius: BorderRadius.circular(8),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12.0),
                  decoration: BoxDecoration(
                    color: backgroundColor,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: borderColor ?? Colors.grey.shade300,
                      width: isSelected || (_showResult && isCorrect) ? 2 : 1,
                    ),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 24,
                        height: 24,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: isSelected || (_showResult && isCorrect)
                              ? (borderColor ?? Theme.of(context).colorScheme.primary)
                              : Colors.transparent,
                          border: Border.all(
                            color: borderColor ?? Colors.grey.shade400,
                          ),
                        ),
                        child: _showResult && isCorrect
                            ? const Icon(Icons.check, size: 16, color: Colors.white)
                            : _showResult && isSelected && !isCorrect
                                ? const Icon(Icons.close, size: 16, color: Colors.white)
                                : isSelected
                                    ? const Icon(Icons.circle, size: 12, color: Colors.white)
                                    : null,
                      ),
                      
                      const SizedBox(width: 12),
                      
                      Expanded(
                        child: Text(
                          option,
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: textColor,
                            fontWeight: isSelected ? FontWeight.w500 : null,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }).toList(),
          
          const SizedBox(height: 16),
          
          // Submit/Reset button
          Row(
            children: [
              if (!_showResult && _selectedAnswer != null)
                ElevatedButton(
                  onPressed: () {
                    setState(() {
                      _showResult = true;
                    });
                  },
                  child: const Text('بررسی پاسخ'),
                ),
              
              if (_showResult)
                ElevatedButton(
                  onPressed: () {
                    setState(() {
                      _selectedAnswer = null;
                      _showResult = false;
                    });
                  },
                  child: const Text('تلاش مجدد'),
                ),
            ],
          ),
          
          // Explanation
          if (_showResult && content.explanation != null)
            Container(
              width: double.infinity,
              margin: const EdgeInsets.only(top: 16),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(6),
                border: Border.all(color: Colors.blue.shade200),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.lightbulb_outline,
                        size: 16,
                        color: Colors.blue.shade700,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        'توضیح:',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: Colors.blue.shade700,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    content.explanation!,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Colors.blue.shade800,
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