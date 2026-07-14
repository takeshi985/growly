import 'package:flutter/material.dart';

import '../theme/growly_theme.dart';

class GrowlyCategoryCard extends StatelessWidget {
  const GrowlyCategoryCard({
    super.key,
    required this.emoji,
    required this.title,
    required this.subtitle,
    required this.onTap,
    this.color = GrowlyTheme.softGreen,
  });
  final String emoji;
  final String title;
  final String subtitle;
  final VoidCallback onTap;
  final Color color;
  @override
  Widget build(BuildContext context) => InkWell(
    onTap: onTap,
    borderRadius: BorderRadius.circular(22),
    child: Card(
      color: color,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(emoji, style: const TextStyle(fontSize: 38)),
            const Spacer(),
            Text(title, style: const TextStyle(fontWeight: FontWeight.w800)),
            const SizedBox(height: 3),
            Text(subtitle, style: Theme.of(context).textTheme.labelMedium),
          ],
        ),
      ),
    ),
  );
}
