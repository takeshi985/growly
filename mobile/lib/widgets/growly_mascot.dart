import 'package:flutter/material.dart';

import '../theme/growly_tokens.dart';

enum GrowlyMood { ready, happy, thinking, proud }

class GrowlyMascot extends StatelessWidget {
  const GrowlyMascot({super.key, this.size = 92, this.mood = GrowlyMood.ready});

  final double size;
  final GrowlyMood mood;

  @override
  Widget build(BuildContext context) => Semantics(
    image: true,
    label: switch (mood) {
      GrowlyMood.ready => 'Growly готов к занятию',
      GrowlyMood.happy => 'Growly радуется',
      GrowlyMood.thinking => 'Growly помогает подумать',
      GrowlyMood.proud => 'Growly гордится твоим результатом',
    },
    child: SizedBox.square(
      dimension: size,
      child: CustomPaint(painter: _GrowlyMascotPainter(mood)),
    ),
  );
}

class _GrowlyMascotPainter extends CustomPainter {
  const _GrowlyMascotPainter(this.mood);
  final GrowlyMood mood;

  @override
  void paint(Canvas canvas, Size canvasSize) {
    final size = canvasSize.shortestSide;
    final body = Paint()..color = GrowlyColors.brand;
    final dark = Paint()..color = GrowlyColors.brandPressed;
    final warm = Paint()..color = GrowlyColors.accent;
    final white = Paint()..color = Colors.white;
    final ink = Paint()
      ..color = GrowlyColors.ink
      ..strokeWidth = size * .035
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(size * .5, size * .57),
        width: size * .67,
        height: size * .62,
      ),
      body,
    );
    canvas.drawCircle(Offset(size * .3, size * .3), size * .12, dark);
    canvas.drawCircle(Offset(size * .7, size * .3), size * .12, dark);
    canvas.drawCircle(Offset(size * .37, size * .48), size * .105, white);
    canvas.drawCircle(Offset(size * .63, size * .48), size * .105, white);
    canvas.drawCircle(Offset(size * .39, size * .49), size * .035, dark);
    canvas.drawCircle(Offset(size * .61, size * .49), size * .035, dark);
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(size * .5, size * .62),
        width: size * .17,
        height: size * .11,
      ),
      warm,
    );
    final mouth = Path()..moveTo(size * .36, size * .7);
    if (mood == GrowlyMood.thinking) {
      mouth.lineTo(size * .52, size * .7);
    } else {
      mouth.quadraticBezierTo(size * .5, size * .85, size * .66, size * .7);
    }
    canvas.drawPath(mouth, ink);
    canvas.drawCircle(Offset(size * .18, size * .61), size * .045, warm);
    canvas.drawCircle(Offset(size * .82, size * .61), size * .045, warm);
  }

  @override
  bool shouldRepaint(covariant _GrowlyMascotPainter oldDelegate) =>
      oldDelegate.mood != mood;
}
