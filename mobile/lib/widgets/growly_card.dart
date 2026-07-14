import 'package:flutter/material.dart';

import '../theme/growly_tokens.dart';

class GrowlyCard extends StatelessWidget {
  const GrowlyCard({
    super.key,
    required this.child,
    this.color,
    this.padding = const EdgeInsets.all(18),
    this.onTap,
  });
  final Widget child;
  final Color? color;
  final EdgeInsetsGeometry padding;
  final VoidCallback? onTap;
  @override
  Widget build(BuildContext context) {
    final content = Padding(padding: padding, child: child);
    return Card(
      color: color ?? GrowlyColors.surface,
      clipBehavior: Clip.antiAlias,
      child: onTap == null ? content : InkWell(onTap: onTap, child: content),
    );
  }
}
