import 'dart:math' as math;
import 'package:material_ui/material_ui.dart';

class GoogleLogoWidget extends StatelessWidget {
  final double size;

  const GoogleLogoWidget({super.key, this.size = 24.0});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(
        painter: _GoogleLogoPainter(),
      ),
    );
  }
}

class _GoogleLogoPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final double radius = size.width / 2;
    final Offset center = Offset(radius, radius);
    final double strokeWidth = size.width * 0.22;

    final Paint paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.butt;

    final Rect rect = Rect.fromCircle(center: center, radius: radius - (strokeWidth / 2));

    // 1. Red Top Arc (195° to 330°)
    paint.color = const Color(0xFFEA4335);
    canvas.drawArc(rect, _degToRad(195), _degToRad(135), false, paint);

    // 2. Yellow Bottom-Left Arc (130° to 195°)
    paint.color = const Color(0xFFFBBC05);
    canvas.drawArc(rect, _degToRad(130), _degToRad(65), false, paint);

    // 3. Green Bottom Arc (25° to 130°)
    paint.color = const Color(0xFF34A853);
    canvas.drawArc(rect, _degToRad(25), _degToRad(105), false, paint);

    // 4. Blue Right Arc & Horizontal Bar
    paint.color = const Color(0xFF4285F4);
    canvas.drawArc(rect, _degToRad(-35), _degToRad(60), false, paint);

    // Blue Center Horizontal Crossbar
    final Paint fillPaint = Paint()
      ..color = const Color(0xFF4285F4)
      ..style = PaintingStyle.fill;

    final Rect crossBar = Rect.fromLTRB(
      center.dx,
      center.dy - (strokeWidth / 2),
      size.width,
      center.dy + (strokeWidth / 2),
    );
    canvas.drawRect(crossBar, fillPaint);
  }

  double _degToRad(double deg) => deg * (math.pi / 180.0);

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
