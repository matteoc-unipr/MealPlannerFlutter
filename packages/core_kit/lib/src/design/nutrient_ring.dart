import 'dart:math' as math;

import 'package:flutter/material.dart';

class NutrientRing extends StatelessWidget {
  const NutrientRing({
    super.key,
    required this.value,
    required this.goal,
    this.size = 96,
    this.strokeWidth = 8,
    this.color,
    this.backgroundColor,
    this.center,
  });

  final double value;
  final double goal;
  final double size;
  final double strokeWidth;
  final Color? color;
  final Color? backgroundColor;
  final Widget? center;

  double get _progress => goal <= 0 ? 0 : (value / goal).clamp(0.0, 1.0);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final progress = _progress;

    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          CustomPaint(
            size: Size.square(size),
            painter: _NutrientRingPainter(
              progress: progress,
              color: color ?? theme.colorScheme.primary,
              backgroundColor:
                  backgroundColor ?? theme.colorScheme.surfaceVariant,
              strokeWidth: strokeWidth,
            ),
          ),
          center ??
              Text(
                '${(progress * 100).round()}%',
                style: theme.textTheme.bodyMedium,
              ),
        ],
      ),
    );
  }
}

class _NutrientRingPainter extends CustomPainter {
  const _NutrientRingPainter({
    required this.progress,
    required this.color,
    required this.backgroundColor,
    required this.strokeWidth,
  });

  final double progress;
  final Color color;
  final Color backgroundColor;
  final double strokeWidth;

  @override
  void paint(Canvas canvas, Size size) {
    final center = size.center(Offset.zero);
    final radius = (size.shortestSide - strokeWidth) / 2;
    final rect = Rect.fromCircle(center: center, radius: radius);

    final backgroundPaint = Paint()
      ..color = backgroundColor
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeWidth = strokeWidth;

    final foregroundPaint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeWidth = strokeWidth;

    canvas.drawArc(rect, -math.pi / 2, math.pi * 2, false, backgroundPaint);
    canvas.drawArc(
      rect,
      -math.pi / 2,
      math.pi * 2 * progress.clamp(0.0, 1.0),
      false,
      foregroundPaint,
    );
  }

  @override
  bool shouldRepaint(covariant _NutrientRingPainter oldDelegate) {
    return oldDelegate.progress != progress ||
        oldDelegate.color != color ||
        oldDelegate.backgroundColor != backgroundColor ||
        oldDelegate.strokeWidth != strokeWidth;
  }
}
