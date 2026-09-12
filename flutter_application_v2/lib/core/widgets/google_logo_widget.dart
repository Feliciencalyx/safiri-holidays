import 'package:flutter/material.dart';

/// Official Google "G" multi-color vector logo.
/// Rendered using the exact official SVG path coordinates (viewBox: 0 0 24 24)
/// with subpixel antialiasing and arbitrary scale support.
class GoogleLogoWidget extends StatelessWidget {
  final double size;

  const GoogleLogoWidget({super.key, this.size = 24.0});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(
        size: Size(size, size),
        painter: const _OfficialGoogleLogoPainter(),
      ),
    );
  }
}

class _OfficialGoogleLogoPainter extends CustomPainter {
  const _OfficialGoogleLogoPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final double scale = size.width / 24.0;
    canvas.save();
    canvas.scale(scale, scale);

    final Paint paint = Paint()
      ..isAntiAlias = true
      ..filterQuality = FilterQuality.high
      ..style = PaintingStyle.fill;

    // 1. BLUE SEGMENT (#4285F4)
    paint.color = const Color(0xFF4285F4);
    Path path = Path()
      ..moveTo(22.56, 12.25)
      ..cubicTo(22.56, 11.47, 22.49, 10.72, 22.36, 10.0)
      ..lineTo(12.0, 10.0)
      ..lineTo(12.0, 14.26)
      ..lineTo(17.92, 14.26)
      ..cubicTo(17.66, 15.63, 16.88, 16.79, 15.71, 17.57)
      ..lineTo(15.71, 20.34)
      ..lineTo(19.28, 20.34)
      ..cubicTo(21.36, 18.42, 22.56, 15.60, 22.56, 12.25)
      ..close();
    canvas.drawPath(path, paint);

    // 2. GREEN SEGMENT (#34A853)
    paint.color = const Color(0xFF34A853);
    path = Path()
      ..moveTo(12.0, 23.0)
      ..cubicTo(14.97, 23.0, 17.46, 22.02, 19.28, 20.34)
      ..lineTo(15.71, 17.57)
      ..cubicTo(14.73, 18.23, 13.48, 18.63, 12.0, 18.63)
      ..cubicTo(9.14, 18.63, 6.71, 16.70, 5.84, 14.10)
      ..lineTo(2.18, 14.10)
      ..lineTo(2.18, 16.94)
      ..cubicTo(3.99, 20.53, 7.70, 23.0, 12.0, 23.0)
      ..close();
    canvas.drawPath(path, paint);

    // 3. YELLOW SEGMENT (#FBBC05)
    paint.color = const Color(0xFFFBBC05);
    path = Path()
      ..moveTo(5.84, 14.09)
      ..cubicTo(5.62, 13.43, 5.49, 12.73, 5.49, 12.0)
      ..cubicTo(5.49, 11.27, 5.62, 10.57, 5.84, 9.91)
      ..lineTo(5.84, 7.07)
      ..lineTo(2.18, 7.07)
      ..cubicTo(1.43, 8.55, 1.0, 10.22, 1.0, 12.0)
      ..cubicTo(1.0, 13.78, 1.43, 15.45, 2.18, 16.93)
      ..lineTo(5.03, 14.71)
      ..lineTo(5.84, 14.09)
      ..close();
    canvas.drawPath(path, paint);

    // 4. RED SEGMENT (#EA4335)
    paint.color = const Color(0xFFEA4335);
    path = Path()
      ..moveTo(12.0, 5.38)
      ..cubicTo(13.62, 5.38, 15.06, 5.94, 16.21, 7.02)
      ..lineTo(19.36, 3.87)
      ..cubicTo(17.45, 2.09, 14.97, 1.0, 12.0, 1.0)
      ..cubicTo(7.70, 1.0, 3.99, 3.47, 2.18, 7.07)
      ..lineTo(5.84, 9.91)
      ..cubicTo(6.71, 7.31, 9.14, 5.38, 12.0, 5.38)
      ..close();
    canvas.drawPath(path, paint);

    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
