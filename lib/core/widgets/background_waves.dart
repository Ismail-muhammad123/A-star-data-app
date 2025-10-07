import 'package:flutter/material.dart';

class BackgroundCurves extends StatelessWidget {
  const BackgroundCurves({super.key});

  @override
  Widget build(BuildContext context) {
    return CustomPaint(painter: CurvesPainter());
  }
}

class CurvesPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint();

    // Red background
    paint.color = Colors.red;
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), paint);

    // Black wave
    paint.color = Colors.black;
    final path =
        Path()
          ..moveTo(size.width * 0.7, 0)
          ..quadraticBezierTo(
            size.width * 0.6,
            size.height * 0.5,
            size.width,
            size.height,
          )
          ..lineTo(size.width, 0)
          ..close();
    canvas.drawPath(path, paint);

    // Optional: Add other curves (gray area)
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}
