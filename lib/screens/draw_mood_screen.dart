import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../database/db_helper.dart';

class DrawMoodScreen extends StatefulWidget {
  const DrawMoodScreen({super.key});

  @override
  DrawMoodScreenState createState() => DrawMoodScreenState();
}

class DrawMoodScreenState extends State<DrawMoodScreen> {
  final List<Map<String, dynamic>> _points = [];
  Color _selectedColor = Colors.white;

  final List<Color> _colorPalette = [
    Colors.white,
    Colors.red,
    Colors.orange,
    Colors.yellow,
    Colors.green,
    Colors.blue,
    Colors.indigo,
    Colors.purple,
    Colors.pink,
  ];

  void _saveMood() async {
    if (_points.isEmpty) return;

    String pathDataJson = jsonEncode(_points);
    await DBHelper.instance.insertMood({
      DBHelper.columnColor: _selectedColor.toARGB32(),
      DBHelper.columnPathData: pathDataJson,
    });

    if (!mounted) return;

    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Column(
          children: [
            // Color Picker
            Container(
              height: 80,
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: _colorPalette.length,
                itemBuilder: (context, index) {
                  Color color = _colorPalette[index];
                  return GestureDetector(
                    onTap: () {
                      HapticFeedback.selectionClick();
                      setState(() => _selectedColor = color);
                    },
                    child: Container(
                      margin: const EdgeInsets.symmetric(horizontal: 8),
                      width: 50,
                      decoration: BoxDecoration(
                        color: color,
                        shape: BoxShape.circle,
                        border: _selectedColor == color
                            ? Border.all(color: Colors.white, width: 3)
                            : null,
                      ),
                    ),
                  );
                },
              ),
            ),

            // Drawing Canvas
            Expanded(
              child: Center(
                child: Container(
                  width: 300,
                  height: 300,
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.white24, width: 2),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: GestureDetector(
                    onPanStart: (details) {
                      RenderBox box = context.findRenderObject() as RenderBox;
                      Offset localPosition = box.globalToLocal(details.globalPosition);
                      // scale down to 100x100 space
                      double x = (localPosition.dx / box.size.width) * 100;
                      double y = (localPosition.dy / box.size.height) * 100;
                      setState(() {
                        _points.add({'x': x, 'y': y, 'type': 'move'});
                      });
                    },
                    onPanUpdate: (details) {
                      RenderBox box = context.findRenderObject() as RenderBox;
                      Offset localPosition = box.globalToLocal(details.globalPosition);
                      double x = (localPosition.dx / box.size.width) * 100;
                      double y = (localPosition.dy / box.size.height) * 100;

                      // Only add if within bounds roughly
                      if (x >= 0 && x <= 100 && y >= 0 && y <= 100) {
                        setState(() {
                          _points.add({'x': x, 'y': y, 'type': 'line'});
                        });
                      }
                    },
                    child: CustomPaint(
                      painter: _TempMoodPainter(points: _points, color: _selectedColor),
                      size: const Size(300, 300),
                    ),
                  ),
                ),
              ),
            ),

            // Save / Clear buttons
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  GestureDetector(
                    onTap: () {
                      HapticFeedback.lightImpact();
                      setState(() => _points.clear());
                    },
                    child: const Icon(Icons.refresh, color: Colors.white54, size: 50),
                  ),
                  GestureDetector(
                    onTap: () {
                      HapticFeedback.mediumImpact();
                      _saveMood();
                    },
                    child: const Icon(Icons.check_circle, color: Colors.green, size: 60),
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}

class _TempMoodPainter extends CustomPainter {
  final List<Map<String, dynamic>> points;
  final Color color;

  _TempMoodPainter({required this.points, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 12.0 // thicker since it's 300x300, 3x thicker than 4.0
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..style = PaintingStyle.stroke;

    final path = Path();

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
  bool shouldRepaint(covariant _TempMoodPainter oldDelegate) {
    return true; // Always repaint for temp drawing
  }
}
