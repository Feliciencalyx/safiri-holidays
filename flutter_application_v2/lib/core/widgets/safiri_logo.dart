import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/app_state.dart';

class SafiriLogo extends StatelessWidget {
  final double size;
  final bool showText;
  final bool showTagline;
  final bool isHorizontal;
  final Color? textColor;
  final Color? goldColor;
  final bool isDarkBackground;
  final String? customTagline;

  const SafiriLogo({
    super.key,
    this.size = 76.0,
    this.showText = true,
    this.showTagline = false,
    this.isHorizontal = false,
    this.textColor,
    this.goldColor,
    this.isDarkBackground = false,
    this.customTagline,
  });

  @override
  Widget build(BuildContext context) {
    final effectiveNavy = textColor ?? (isDarkBackground ? Colors.white : const Color(0xFF0B2545));
    final effectiveGold = goldColor ?? (isDarkBackground ? const Color(0xFFE5A968) : const Color(0xFFC5902B));

    String resolvedTagline = customTagline ?? '';
    if (resolvedTagline.isEmpty && showTagline) {
      try {
        final appState = Provider.of<AppState>(context);
        resolvedTagline = appState.tr('tagline').toUpperCase();
      } catch (_) {
        resolvedTagline = 'DEFINING A LEGACY OF EXCEPTIONAL TRAVEL';
      }
    }

    final markWidget = SizedBox(
      width: size,
      height: size,
      child: CustomPaint(
        painter: SafiriLogoMarkPainter(isDark: isDarkBackground),
      ),
    );

    if (!showText) {
      return markWidget;
    }

    if (isHorizontal) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          markWidget,
          SizedBox(width: size * 0.22),
          Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSafiriTitleText(size * 0.42, effectiveNavy, effectiveGold),
              const SizedBox(height: 2),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SizedBox(
                    width: size * 0.18,
                    child: Divider(color: effectiveGold, thickness: 1.2, height: 1),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: Text(
                      'HOLIDAYS',
                      style: TextStyle(
                        fontFamily: 'Montserrat',
                        fontSize: size * 0.14,
                        fontWeight: FontWeight.bold,
                        color: effectiveGold,
                        letterSpacing: 2.5,
                      ),
                    ),
                  ),
                  SizedBox(
                    width: size * 0.18,
                    child: Divider(color: effectiveGold, thickness: 1.2, height: 1),
                  ),
                ],
              ),
              if (showTagline) ...[
                const SizedBox(height: 2),
                Text(
                  resolvedTagline,
                  style: TextStyle(
                    fontSize: size * 0.08,
                    fontWeight: FontWeight.bold,
                    color: isDarkBackground ? Colors.white70 : const Color(0xFF444650),
                    letterSpacing: 0.8,
                  ),
                ),
              ],
            ],
          ),
        ],
      );
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        markWidget,
        SizedBox(height: size * 0.12),
        _buildSafiriTitleText(size * 0.38, effectiveNavy, effectiveGold),
        SizedBox(height: size * 0.05),
        Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              width: size * 0.28,
              child: Divider(color: effectiveGold, thickness: 1.2, height: 1),
            ),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: size * 0.08),
              child: Text(
                'HOLIDAYS',
                style: TextStyle(
                  fontFamily: 'Montserrat',
                  fontSize: size * 0.13,
                  fontWeight: FontWeight.bold,
                  color: effectiveGold,
                  letterSpacing: 3.0,
                ),
              ),
            ),
            SizedBox(
              width: size * 0.28,
              child: Divider(color: effectiveGold, thickness: 1.2, height: 1),
            ),
          ],
        ),
        if (showTagline) ...[
          SizedBox(height: size * 0.08),
          Text(
            resolvedTagline,
            style: TextStyle(
              fontSize: size * 0.09,
              fontWeight: FontWeight.bold,
              color: isDarkBackground ? Colors.white70 : const Color(0xFF444650),
              letterSpacing: 0.8,
            ),
          ),
        ],
      ],
    );
  }

  // Renders "Safiri" with the dots on 'i's in bright gold matching the uploaded brand logo!
  Widget _buildSafiriTitleText(double fontSize, Color navyColor, Color goldColor) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.baseline,
      textBaseline: TextBaseline.alphabetic,
      children: [
        Text(
          'Saf',
          style: TextStyle(
            fontFamily: 'Montserrat',
            fontSize: fontSize,
            fontWeight: FontWeight.w800,
            color: navyColor,
            letterSpacing: -0.5,
          ),
        ),
        _buildDotI('i', fontSize, navyColor, goldColor),
        Text(
          'r',
          style: TextStyle(
            fontFamily: 'Montserrat',
            fontSize: fontSize,
            fontWeight: FontWeight.w800,
            color: navyColor,
            letterSpacing: -0.5,
          ),
        ),
        _buildDotI('i', fontSize, navyColor, goldColor),
      ],
    );
  }

  Widget _buildDotI(String char, double fontSize, Color navyColor, Color goldColor) {
    return SizedBox(
      height: fontSize * 1.1,
      child: Stack(
        alignment: Alignment.bottomCenter,
        children: [
          // Stem of letter 'i'
          Text(
            'ı', // Dotless i
            style: TextStyle(
              fontFamily: 'Montserrat',
              fontSize: fontSize,
              fontWeight: FontWeight.w800,
              color: navyColor,
            ),
          ),
          // Gold dot on top of 'i'
          Positioned(
            top: fontSize * 0.14,
            child: Container(
              width: fontSize * 0.18,
              height: fontSize * 0.18,
              decoration: BoxDecoration(
                color: goldColor,
                shape: BoxShape.circle,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class SafiriLogoMarkPainter extends CustomPainter {
  final bool isDark;
  SafiriLogoMarkPainter({this.isDark = false});

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final center = Offset(w / 2, h / 2);
    final radius = w / 2;

    // Outer Circular Boundary Clip
    final clipPath = Path()..addOval(Rect.fromCircle(center: center, radius: radius));
    canvas.save();
    canvas.clipPath(clipPath);

    // 1. TOP-LEFT: Globe & Continents (Navy Blue Theme)
    final topLeftRect = Rect.fromLTRB(0, 0, w, h);
    final navyShader = LinearGradient(
      colors: isDark
          ? const [Color(0xFF07182E), Color(0xFF0F325C)]
          : const [Color(0xFF0B2545), Color(0xFF163E72)],
      begin: Alignment.topLeft,
      end: Alignment.center,
    ).createShader(topLeftRect);
    canvas.drawRect(topLeftRect, Paint()..shader = navyShader);

    // Continent outlines in top left
    final continentPaint = Paint()..color = const Color(0xFF1D5290).withValues(alpha: 0.7);
    final continentPath = Path()
      ..moveTo(w * 0.1, h * 0.15)
      ..cubicTo(w * 0.25, h * 0.08, w * 0.42, h * 0.15, w * 0.45, h * 0.28)
      ..cubicTo(w * 0.35, h * 0.42, w * 0.18, h * 0.38, w * 0.08, h * 0.28)
      ..close();
    canvas.drawPath(continentPath, continentPaint);

    final continentPath2 = Path()
      ..moveTo(w * 0.2, h * 0.35)
      ..cubicTo(w * 0.32, h * 0.30, w * 0.40, h * 0.36, w * 0.38, h * 0.48)
      ..cubicTo(w * 0.28, h * 0.52, w * 0.18, h * 0.46, w * 0.2, h * 0.35)
      ..close();
    canvas.drawPath(continentPath2, continentPaint);

    // 2. TOP-RIGHT: Warm Golden Sunset, Temple Silhouette & Birds
    final topRightPath = Path()
      ..moveTo(w * 0.38, 0)
      ..lineTo(w, 0)
      ..lineTo(w, h * 0.58)
      ..cubicTo(w * 0.65, h * 0.52, w * 0.48, h * 0.32, w * 0.38, 0)
      ..close();

    final sunsetShader = const LinearGradient(
      colors: [
        Color(0xFFFDE0B2),
        Color(0xFFF5B061),
        Color(0xFFD4883B),
        Color(0xFFB86B1D),
      ],
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
    ).createShader(Rect.fromLTWH(w * 0.35, 0, w * 0.65, h * 0.6));
    canvas.drawPath(topRightPath, Paint()..shader = sunsetShader);

    // Glowing Sun
    canvas.drawCircle(
      Offset(w * 0.64, h * 0.28),
      w * 0.09,
      Paint()..color = const Color(0xFFFFFDF5),
    );

    // Temple & Pagoda Silhouettes
    final templePaint = Paint()..color = const Color(0xFF7A4513);
    final templePath = Path()
      ..moveTo(w * 0.74, h * 0.46)
      ..lineTo(w * 0.76, h * 0.36)
      ..lineTo(w * 0.78, h * 0.46)
      ..lineTo(w * 0.83, h * 0.46)
      ..lineTo(w * 0.84, h * 0.40)
      ..lineTo(w * 0.85, h * 0.46)
      ..lineTo(w * 0.90, h * 0.46)
      ..lineTo(w * 0.91, h * 0.50)
      ..lineTo(w * 0.72, h * 0.50)
      ..close();
    canvas.drawPath(templePath, templePaint);

    // Birds flying in sky
    final birdPaint = Paint()
      ..color = const Color(0xFF5A310C)
      ..style = PaintingStyle.stroke
      ..strokeWidth = w * 0.016
      ..strokeCap = StrokeCap.round;

    final bird1 = Path()
      ..moveTo(w * 0.66, h * 0.18)
      ..quadraticBezierTo(w * 0.68, h * 0.16, w * 0.70, h * 0.18)
      ..quadraticBezierTo(w * 0.72, h * 0.16, w * 0.74, h * 0.18);
    canvas.drawPath(bird1, birdPaint);

    final bird2 = Path()
      ..moveTo(w * 0.76, h * 0.22)
      ..quadraticBezierTo(w * 0.78, h * 0.20, w * 0.80, h * 0.22)
      ..quadraticBezierTo(w * 0.82, h * 0.20, w * 0.84, h * 0.22);
    canvas.drawPath(bird2, birdPaint);

    // 3. BOTTOM-LEFT: Tropical Ocean Waves & Palm Tree
    final botLeftPath = Path()
      ..moveTo(0, h * 0.36)
      ..cubicTo(w * 0.28, h * 0.42, w * 0.38, h * 0.58, w * 0.38, h)
      ..lineTo(0, h)
      ..close();

    final oceanShader = const LinearGradient(
      colors: [Color(0xFF4FC3F7), Color(0xFF0288D1), Color(0xFF01579B)],
      begin: Alignment.topRight,
      end: Alignment.bottomLeft,
    ).createShader(Rect.fromLTWH(0, h * 0.35, w * 0.4, h * 0.65));
    canvas.drawPath(botLeftPath, Paint()..shader = oceanShader);

    // Ocean ripples
    final ripplePaint = Paint()
      ..color = const Color(0xFFB2EBF2).withValues(alpha: 0.6)
      ..style = PaintingStyle.stroke
      ..strokeWidth = w * 0.016;

    final ripplePath = Path()
      ..moveTo(w * 0.04, h * 0.72)
      ..quadraticBezierTo(w * 0.16, h * 0.68, w * 0.28, h * 0.75);
    canvas.drawPath(ripplePath, ripplePaint);

    // Palm Tree Silhouette
    final palmPaint = Paint()..color = const Color(0xFF0B2545);

    // Trunk
    final trunkPath = Path()
      ..moveTo(w * 0.17, h * 0.76)
      ..quadraticBezierTo(w * 0.19, h * 0.60, w * 0.24, h * 0.48)
      ..quadraticBezierTo(w * 0.21, h * 0.60, w * 0.14, h * 0.76)
      ..close();
    canvas.drawPath(trunkPath, palmPaint);

    // Palm fronds
    final frondPaint = Paint()
      ..color = const Color(0xFF0B2545)
      ..style = PaintingStyle.stroke
      ..strokeWidth = w * 0.024
      ..strokeCap = StrokeCap.round;

    final fCenter = Offset(w * 0.24, h * 0.48);
    canvas.drawLine(fCenter, Offset(w * 0.11, h * 0.42), frondPaint);
    canvas.drawLine(fCenter, Offset(w * 0.08, h * 0.50), frondPaint);
    canvas.drawLine(fCenter, Offset(w * 0.19, h * 0.38), frondPaint);
    canvas.drawLine(fCenter, Offset(w * 0.32, h * 0.42), frondPaint);

    // 4. SWEEPING "S" RIBBON (Golden S-curve)
    final sRibbonShader = const LinearGradient(
      colors: [
        Color(0xFF0B2545),
        Color(0xFF133B6A),
        Color(0xFFD4AF37), // Metallic gold
        Color(0xFFE5B842),
        Color(0xFFB87B1D),
      ],
      stops: [0.0, 0.15, 0.45, 0.75, 1.0],
      begin: Alignment.bottomLeft,
      end: Alignment.topRight,
    ).createShader(Rect.fromLTWH(0, 0, w, h));

    final sPath = Path()
      ..moveTo(w * 0.12, h * 0.98)
      ..cubicTo(w * 0.65, h * 0.88, w * 0.62, h * 0.48, w * 0.26, h * 0.38)
      ..cubicTo(w * 0.06, h * 0.32, w * 0.12, h * 0.12, w * 0.58, h * 0.04)
      ..cubicTo(w * 0.68, h * 0.02, w * 0.76, 0, w * 0.84, 0)
      // Return path creating ribbon thickness
      ..cubicTo(w * 0.58, h * 0.10, w * 0.28, h * 0.20, w * 0.42, h * 0.46)
      ..cubicTo(w * 0.54, h * 0.62, w * 0.68, h * 0.78, w * 0.32, h * 0.99)
      ..close();

    canvas.drawPath(sPath, Paint()..shader = sRibbonShader);

    canvas.restore(); // Restore oval clip

    // 5. AIRPLANE (Flying top right at top of S-curve)
    final planeCenter = Offset(w * 0.83, h * 0.12);
    canvas.save();
    canvas.translate(planeCenter.dx, planeCenter.dy);
    canvas.rotate(0.58); // Tilted facing top-right

    final planePaint = Paint()..color = const Color(0xFF0B2545);
    final pScale = w * 0.008;

    final planePath = Path()
      ..moveTo(0, -14 * pScale)
      ..lineTo(3 * pScale, -6 * pScale)
      ..lineTo(14 * pScale, -2 * pScale)
      ..lineTo(14 * pScale, 2 * pScale)
      ..lineTo(3 * pScale, 1 * pScale)
      ..lineTo(2 * pScale, 8 * pScale)
      ..lineTo(6 * pScale, 11 * pScale)
      ..lineTo(6 * pScale, 13 * pScale)
      ..lineTo(0, 11 * pScale)
      ..lineTo(-6 * pScale, 13 * pScale)
      ..lineTo(-6 * pScale, 11 * pScale)
      ..lineTo(-2 * pScale, 8 * pScale)
      ..lineTo(-3 * pScale, 1 * pScale)
      ..lineTo(-14 * pScale, 2 * pScale)
      ..lineTo(-14 * pScale, -2 * pScale)
      ..lineTo(-3 * pScale, -6 * pScale)
      ..close();

    canvas.drawPath(planePath, planePaint);
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
