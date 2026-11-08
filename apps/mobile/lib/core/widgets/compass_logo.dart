import 'dart:math' as math;
import 'package:flutter/material.dart';

/// A custom-painted vector Compass Logo matching Compass web's `CompassLogo.tsx`.
/// Features smooth animated compass needle rotation with organic easing.
class CompassLogoWidget extends StatefulWidget {
  final double size;
  final Color? color;
  final bool animated;
  final double? fixedAngleDegrees;

  const CompassLogoWidget({
    super.key,
    this.size = 36.0,
    this.color,
    this.animated = true,
    this.fixedAngleDegrees,
  });

  @override
  State<CompassLogoWidget> createState() => _CompassLogoWidgetState();
}

class _CompassLogoWidgetState extends State<CompassLogoWidget>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  double _manualAngle = 0.0;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 12),
    );
    if (widget.animated && widget.fixedAngleDegrees == null) {
      _controller.repeat();
    }
  }

  @override
  void didUpdateWidget(covariant CompassLogoWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.animated && !_controller.isAnimating && widget.fixedAngleDegrees == null) {
      _controller.repeat();
    } else if (!widget.animated && _controller.isAnimating) {
      _controller.stop();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final effectiveColor = widget.color ?? const Color(0xFF0D9488); // Teal-600

    return GestureDetector(
      onPanUpdate: (details) {
        setState(() {
          _manualAngle += details.delta.dx * 0.02;
        });
      },
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          final animRotation = widget.fixedAngleDegrees != null
              ? (widget.fixedAngleDegrees! * math.pi / 180)
              : (_controller.value * 2 * math.pi + _manualAngle);

          return Transform.rotate(
            angle: animRotation,
            child: CustomPaint(
              size: Size(widget.size, widget.size),
              painter: _CompassPainter(color: effectiveColor),
            ),
          );
        },
      ),
    );
  }
}

class _CompassPainter extends CustomPainter {
  final Color color;

  _CompassPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final scale = (size.width / 200.0);

    // Paints
    final ringPaint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.5 * scale;

    final innerRingPaint = Paint()
      ..color = color.withValues(alpha: 0.5)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5 * scale;

    final dashPaint = Paint()
      ..color = color.withValues(alpha: 0.4)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0 * scale;

    final solidNeedlePaint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    final semiNeedlePaint = Paint()
      ..color = color.withValues(alpha: 0.3)
      ..style = PaintingStyle.fill;

    final accentNeedlePaint = Paint()
      ..color = const Color(0xFF06B6D4) // Cyan-500
      ..style = PaintingStyle.fill;

    final centerDotFill = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;

    final centerDotStroke = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0 * scale;

    // 1. Outer Rings (r=90 and r=80 in 200x200 space)
    canvas.drawCircle(center, 90 * scale, ringPaint);
    canvas.drawCircle(center, 80 * scale, innerRingPaint);

    // 2. Dashed Cross Hairs
    _drawDashedLine(canvas, Offset(center.dx, center.dy - 85 * scale),
        Offset(center.dx, center.dy + 85 * scale), dashPaint, scale,);
    _drawDashedLine(canvas, Offset(center.dx - 85 * scale, center.dy),
        Offset(center.dx + 85 * scale, center.dy), dashPaint, scale,);

    final diag = 60.0 * scale;
    _drawDashedLine(canvas, Offset(center.dx - diag, center.dy - diag),
        Offset(center.dx + diag, center.dy + diag), dashPaint, scale,);
    _drawDashedLine(canvas, Offset(center.dx - diag, center.dy + diag),
        Offset(center.dx + diag, center.dy - diag), dashPaint, scale,);

    Offset t(double x, double y) {
      return Offset(center.dx + (x - 100) * scale, center.dy + (y - 100) * scale);
    }

    void drawPolygon(List<Offset> pts, Paint paint) {
      final path = Path()..moveTo(pts[0].dx, pts[0].dy);
      for (int i = 1; i < pts.length; i++) {
        path.lineTo(pts[i].dx, pts[i].dy);
      }
      path.close();
      canvas.drawPath(path, paint);
    }

    // 3. Primary 4-point Star (North, South, East, West)
    // North Pointer (solid right, semi left)
    drawPolygon([t(100, 20), t(115, 100), t(100, 100)], solidNeedlePaint);
    drawPolygon([t(100, 20), t(85, 100), t(100, 100)], semiNeedlePaint);

    // South Pointer
    drawPolygon([t(100, 180), t(115, 100), t(100, 100)], semiNeedlePaint);
    drawPolygon([t(100, 180), t(85, 100), t(100, 100)], solidNeedlePaint);

    // East Pointer
    drawPolygon([t(180, 100), t(100, 115), t(100, 100)], solidNeedlePaint);
    drawPolygon([t(180, 100), t(100, 85), t(100, 100)], semiNeedlePaint);

    // West Pointer
    drawPolygon([t(20, 100), t(100, 115), t(100, 100)], semiNeedlePaint);
    drawPolygon([t(20, 100), t(100, 85), t(100, 100)], solidNeedlePaint);

    // 4. Secondary 4-point Star (Diagonals)
    // NE
    drawPolygon([t(150, 50), t(108, 100), t(100, 100)], accentNeedlePaint);
    drawPolygon([t(150, 50), t(100, 92), t(100, 100)], semiNeedlePaint);

    // SW
    drawPolygon([t(50, 150), t(100, 108), t(100, 100)], accentNeedlePaint);
    drawPolygon([t(50, 150), t(92, 100), t(100, 100)], semiNeedlePaint);

    // SE
    drawPolygon([t(150, 150), t(100, 108), t(100, 100)], semiNeedlePaint);
    drawPolygon([t(150, 150), t(108, 100), t(100, 100)], accentNeedlePaint);

    // NW
    drawPolygon([t(50, 50), t(92, 100), t(100, 100)], accentNeedlePaint);
    drawPolygon([t(50, 50), t(100, 92), t(100, 100)], semiNeedlePaint);

    // 5. Center Pivot Dot
    canvas.drawCircle(center, 6 * scale, centerDotFill);
    canvas.drawCircle(center, 6 * scale, centerDotStroke);
  }

  void _drawDashedLine(Canvas canvas, Offset p1, Offset p2, Paint paint, double scale) {
    final dx = p2.dx - p1.dx;
    final dy = p2.dy - p1.dy;
    final distance = math.sqrt(dx * dx + dy * dy);
    final dashLen = 4.0 * scale;
    final gapLen = 4.0 * scale;
    final count = (distance / (dashLen + gapLen)).floor();

    final unitX = dx / distance;
    final unitY = dy / distance;

    for (int i = 0; i < count; i++) {
      final startX = p1.dx + (i * (dashLen + gapLen)) * unitX;
      final startY = p1.dy + (i * (dashLen + gapLen)) * unitY;
      final endX = startX + dashLen * unitX;
      final endY = startY + dashLen * unitY;
      canvas.drawLine(Offset(startX, startY), Offset(endX, endY), paint);
    }
  }

  @override
  bool shouldRepaint(covariant _CompassPainter oldDelegate) {
    return oldDelegate.color != color;
  }
}

/// Brand header widget containing the moving Compass logo and gradient text.
class CompassBrandHeader extends StatelessWidget {
  final double iconSize;
  final double fontSize;
  final bool animated;
  final String title;

  const CompassBrandHeader({
    super.key,
    this.iconSize = 28.0,
    this.fontSize = 20.0,
    this.animated = true,
    this.title = 'Compass',
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        CompassLogoWidget(
          size: iconSize,
          animated: animated,
        ),
        const SizedBox(width: 10),
        ShaderMask(
          blendMode: BlendMode.srcIn,
          shaderCallback: (bounds) => const LinearGradient(
            colors: [Color(0xFF2DD4BF), Color(0xFF3B82F6)], // Teal-400 to Blue-500 matching web
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
          ).createShader(bounds),
          child: Text(
            title,
            style: TextStyle(
              fontSize: fontSize,
              fontWeight: FontWeight.w800,
              letterSpacing: -0.5,
            ),
          ),
        ),
      ],
    );
  }
}
