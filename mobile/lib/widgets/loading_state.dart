import 'package:flutter/material.dart';
import '../theme/growly_tokens.dart';
import 'growly_mascot.dart';

class LoadingState extends StatelessWidget {
  const LoadingState({
    super.key,
    this.message = 'Growly готовит следующий шаг…',
  });

  final String message;

  @override
  Widget build(BuildContext context) => Center(
    child: Padding(
      padding: const EdgeInsets.all(32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const GrowlyMascot(size: 82, mood: GrowlyMood.thinking),
          const SizedBox(height: 14),
          const SizedBox(
            width: 130,
            child: LinearProgressIndicator(
              minHeight: 8,
              borderRadius: BorderRadius.all(Radius.circular(GrowlyRadii.pill)),
            ),
          ),
          const SizedBox(height: 18),
          Text(message, textAlign: TextAlign.center),
        ],
      ),
    ),
  );
}
