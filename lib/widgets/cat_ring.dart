import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

/// Circular progress ring used as the category glyph and elsewhere.
class CatRing extends StatelessWidget {
  const CatRing({
    super.key,
    required this.progress,
    this.size = 36,
    this.stroke = 2.5,
    this.color,
    this.trackColor,
  });

  final double progress; // 0..1
  final double size;
  final double stroke;
  final Color? color;
  final Color? trackColor;

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    final c = color ?? Theme.of(context).colorScheme.primary;
    final track = trackColor ?? (dark ? AppTheme.dInk4 : AppTheme.lInk4);
    return SizedBox(
      width: size,
      height: size,
      child: TweenAnimationBuilder<double>(
        tween: Tween(begin: 0, end: progress.clamp(0.0, 1.0)),
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeOutCubic,
        builder: (_, v, __) => CustomPaint(
          painter: _RingPainter(progress: v, color: c, track: track.withOpacity(0.4), stroke: stroke),
        ),
      ),
    );
  }
}

class _RingPainter extends CustomPainter {
  _RingPainter({required this.progress, required this.color, required this.track, required this.stroke});
  final double progress;
  final Color color;
  final Color track;
  final double stroke;

  @override
  void paint(Canvas canvas, Size size) {
    final center = size.center(Offset.zero);
    final radius = (size.shortestSide - stroke) / 2;
    final tp = Paint()
      ..color = track
      ..style = PaintingStyle.stroke
      ..strokeWidth = stroke;
    final fp = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = stroke
      ..strokeCap = StrokeCap.round;

    canvas.drawCircle(center, radius, tp);
    if (progress <= 0) return;
    final rect = Rect.fromCircle(center: center, radius: radius);
    canvas.drawArc(rect, -math.pi / 2, 2 * math.pi * progress, false, fp);
  }

  @override
  bool shouldRepaint(covariant _RingPainter old) =>
      old.progress != progress || old.color != color || old.track != track;
}
