import 'package:flutter/material.dart';

import '../models/curriculum.dart';
import '../theme/growly_tokens.dart';

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
  Widget build(BuildContext context) => Stack(
    children: [
      Positioned.fill(
        child: CustomPaint(painter: _PathPainter(count: lessons.length)),
      ),
      Column(
        children: [
          for (var index = 0; index < lessons.length; index++)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 10),
              child: Align(
                alignment: index.isEven
                    ? const Alignment(-0.55, 0)
                    : const Alignment(0.55, 0),
                child: _LevelNode(
                  lesson: lessons[index],
                  readOnly: readOnly,
                  onTap: onLessonTap == null
                      ? null
                      : () => onLessonTap!(lessons[index]),
                ),
              ),
            ),
        ],
      ),
    ],
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
  );

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final active =
        widget.lesson.status == 'available' ||
        widget.lesson.status == 'in_progress';
    if (active && !GrowlyMotion.reduce(context)) {
      _controller.repeat(reverse: true);
    } else {
      _controller.stop();
      _controller.value = 0;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final status = widget.lesson.status;
    final state = _styleFor(status);
    final enabled =
        !widget.readOnly && status != 'locked' && widget.onTap != null;
    final content = SizedBox(
      width: 178,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          AnimatedBuilder(
            animation: _controller,
            builder: (context, child) => Transform.scale(
              scale: 1 + _controller.value * .045,
              child: child,
            ),
            child: Container(
              width: 76,
              height: 70,
              decoration: BoxDecoration(
                color: state.color,
                borderRadius: BorderRadius.circular(25),
                border: Border.all(color: state.border, width: 3),
                boxShadow: status == 'locked'
                    ? const []
                    : [
                        BoxShadow(
                          color: state.border,
                          offset: const Offset(0, 5),
                        ),
                      ],
              ),
              child: Icon(state.icon, color: state.iconColor, size: 34),
            ),
          ),
          const SizedBox(height: 10),
          Text(
            widget.lesson.title,
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 14),
          ),
          const SizedBox(height: 3),
          Text(
            state.label,
            style: TextStyle(
              color: state.border,
              fontSize: 12,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );

    return Semantics(
      button: enabled,
      enabled: enabled,
      label: '${widget.lesson.title}, ${state.label}',
      child: enabled
          ? InkWell(
              onTap: widget.onTap,
              borderRadius: BorderRadius.circular(GrowlyRadii.xl),
              child: Padding(padding: const EdgeInsets.all(8), child: content),
            )
          : content,
    );
  }
}

_NodeStyle _styleFor(String status) => switch (status) {
  'completed' => const _NodeStyle(
    Icons.check_rounded,
    'Пройдено',
    GrowlyColors.success,
    GrowlyColors.success,
    Colors.white,
  ),
  'perfect' => const _NodeStyle(
    Icons.star_rounded,
    'Идеально',
    GrowlyColors.reward,
    GrowlyColors.accent,
    GrowlyColors.ink,
  ),
  'in_progress' => const _NodeStyle(
    Icons.play_arrow_rounded,
    'Текущий шаг',
    GrowlyColors.brand,
    GrowlyColors.brandPressed,
    Colors.white,
  ),
  'needs_review' => const _NodeStyle(
    Icons.lightbulb_rounded,
    'Повторим вместе',
    GrowlyColors.helpSoft,
    GrowlyColors.help,
    GrowlyColors.help,
  ),
  'locked' => const _NodeStyle(
    Icons.lock_rounded,
    'Пока закрыто',
    GrowlyColors.outline,
    GrowlyColors.disabled,
    GrowlyColors.inkMuted,
  ),
  _ => const _NodeStyle(
    Icons.flag_rounded,
    'Можно начать',
    GrowlyColors.brandSoft,
    GrowlyColors.brand,
    GrowlyColors.brand,
  ),
};

class _NodeStyle {
  const _NodeStyle(
    this.icon,
    this.label,
    this.color,
    this.border,
    this.iconColor,
  );
  final IconData icon;
  final String label;
  final Color color;
  final Color border;
  final Color iconColor;
}

class _PathPainter extends CustomPainter {
  const _PathPainter({required this.count});
  final int count;

  @override
  void paint(Canvas canvas, Size size) {
    if (count < 2) return;
    final paint = Paint()
      ..color = GrowlyColors.outline
      ..strokeWidth = 5
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;
    final path = Path();
    final step = size.height / count;
    path.moveTo(size.width * .35, step * .55);
    for (var index = 1; index < count; index++) {
      final x = index.isEven ? size.width * .35 : size.width * .65;
      final y = step * (index + .55);
      path.quadraticBezierTo(size.width * .5, y - step * .5, x, y);
    }
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant _PathPainter oldDelegate) =>
      oldDelegate.count != count;
}
