import 'package:flutter/material.dart';
import 'dart:math';

class BMIGauge extends StatelessWidget {
  final double bmi;

  const BMIGauge({super.key, required this.bmi});

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: const Size(250, 150),
      painter: GaugePainter(bmi),
    );
  }
}

class GaugePainter extends CustomPainter {
  final double bmi;

  GaugePainter(this.bmi);

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height);
    final radius = size.width / 2;

    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 20;

    final colors = [
      Colors.red,
      Colors.yellow,
      Colors.green,
      Colors.orange,
      Colors.red
    ];

    double start = pi;

    for (var color in colors) {
      paint.color = color;
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        start,
        pi / colors.length,
        false,
        paint,
      );
      start += pi / colors.length;
    }

    // needle
    double angle = pi - ((bmi.clamp(10, 40) - 10) / 30) * pi;

    final needle = Paint()
      ..color = Colors.black
      ..strokeWidth = 3;

    final end = Offset(
      center.dx + radius * cos(angle),
      center.dy + radius * sin(angle),
    );

    canvas.drawLine(center, end, needle);
    canvas.drawCircle(center, 5, Paint()..color = Colors.black);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}