import 'package:flutter/material.dart';

import '../models/growly_feedback.dart';

class FeedbackCard extends StatelessWidget {
  const FeedbackCard({super.key, required this.feedback});

  final GrowlyFeedback feedback;

  @override
  Widget build(BuildContext context) {
    final success = feedback.result == 'correct';
    final colors = Theme.of(context).colorScheme;
    return Card(
      color: success ? const Color(0xFFE4F7EA) : colors.secondaryContainer,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  success ? Icons.celebration_rounded : Icons.lightbulb_rounded,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    feedback.message,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
            if (feedback.hint case final hint?) ...[
              const SizedBox(height: 12),
              Text('Подсказка: $hint'),
            ],
            if (feedback.explanation case final explanation?) ...[
              const SizedBox(height: 12),
              Text(explanation),
            ],
          ],
        ),
      ),
    );
  }
}
