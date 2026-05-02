import 'dart:convert';
import 'package:flutter/material.dart';

class MoodIcon extends StatelessWidget {
  final String pathDataJson;
  final Color color;
  final double size;

  const MoodIcon({
    super.key,
    required this.pathDataJson,
    required this.color,
    this.size = 100.0,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(
        painter: MoodPainter(pathDataJson: pathDataJson, color: color),
      ),
    );
  }
}

class MoodPainter extends CustomPainter {
  final String pathDataJson;
  final Color color;

  MoodPainter({required this.pathDataJson, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 4.0
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..style = PaintingStyle.stroke;

    final path = Path();
    List<dynamic> points = jsonDecode(pathDataJson);

    // Points are stored scaled to a 100x100 box, we need to map them to `size`.
    double scaleX = size.width / 100.0;
    double scaleY = size.height / 100.0;

    for (var pointInfo in points) {
      double x = pointInfo['x'] * scaleX;
      double y = pointInfo['y'] * scaleY;
      String type = pointInfo['type'];

      if (type == 'move') {
        path.moveTo(x, y);
      } else if (type == 'line') {
        path.lineTo(x, y);
      }
    }

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant MoodPainter oldDelegate) {
    return oldDelegate.pathDataJson != pathDataJson ||
        oldDelegate.color != color;
  }
}