import 'package:flutter/material.dart';

import '../models/curriculum.dart';

class LevelMap extends StatelessWidget {
  const LevelMap({
    super.key,
    required this.lessons,
    this.onLessonTap,
    this.readOnly = false,
  });
  final List<Lesson> lessons;
  final ValueChanged<Lesson>? onLessonTap;
  final bool readOnly;
  @override
  Widget build(BuildContext context) => SizedBox(
    height: 260,
    child: SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: SizedBox(
        width: (lessons.length * 150 + 80).toDouble(),
        child: Stack(
          children: [
            Positioned.fill(
              child: CustomPaint(painter: _DottedPathPainter(lessons.length)),
            ),
            for (var index = 0; index < lessons.length; index++)
              Positioned(
                left: 45 + index * 150,
                top: index.isEven ? 58 : 132,
                child: _LevelNode(
                  lesson: lessons[index],
                  readOnly: readOnly,
                  onTap: onLessonTap == null
                      ? null
                      : () => onLessonTap!(lessons[index]),
                ),
              ),
          ],
        ),
      ),
    ),
  );
}

class _LevelNode extends StatefulWidget {
  const _LevelNode({required this.lesson, required this.readOnly, this.onTap});
  final Lesson lesson;
  final bool readOnly;
  final VoidCallback? onTap;
  @override
  State<_LevelNode> createState() => _LevelNodeState();
}

class _LevelNodeState extends State<_LevelNode>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 900),
  )..repeat(reverse: true);
  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final status = widget.lesson.status;
    final (icon, color) = switch (status) {
      'completed' => (Icons.star_rounded, const Color(0xFF5C9E6A)),
      'needs_review' => (Icons.replay_rounded, const Color(0xFFE6A13B)),
      'locked' => (Icons.lock_rounded, const Color(0xFF98A0A0)),
      _ => (Icons.flag_rounded, const Color(0xFF5C7CD9)),
    };
    final content = Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        AnimatedBuilder(
          animation: _controller,
          builder: (context, child) => Transform.scale(
            scale: status == 'available' ? 1 + _controller.value * .06 : 1,
            child: child,
          ),
          child: CircleAvatar(
            radius: 31,
            backgroundColor: color,
            child: Icon(icon, color: Colors.white, size: 30),
          ),
        ),
        const SizedBox(height: 7),
        SizedBox(
          width: 125,
          child: Text(
            widget.lesson.title,
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 12),
          ),
        ),
      ],
    );
    return widget.readOnly || status == 'locked'
        ? content
        : InkWell(
            onTap: widget.onTap,
            borderRadius: BorderRadius.circular(40),
            child: content,
          );
  }
}

class _DottedPathPainter extends CustomPainter {
  _DottedPathPainter(this.count);
  final int count;
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFFB8D8A8)
      ..strokeWidth = 4
      ..style = PaintingStyle.stroke;
    for (var x = 100.0; x < count * 150; x += 12) {
      final y = ((x ~/ 150).isEven) ? 93.0 : 167.0;
      canvas.drawCircle(Offset(x, y), 2, paint..style = PaintingStyle.fill);
    }
  }

  @override
  bool shouldRepaint(covariant _DottedPathPainter oldDelegate) =>
      oldDelegate.count != count;
}
