import 'dart:math' as math;
import 'package:flutter/material.dart';

class ModernScanEffectLoader extends StatefulWidget {
  final double size;
  final Color primaryColor;
  final Color accentColor;
  final Duration duration;
  final bool showPulse;
  final bool showGlow;

  const ModernScanEffectLoader({
    super.key,
    this.size = 200.0,
    this.primaryColor = Colors.white,
    // const Color(0xFF00D4FF),
    this.accentColor = Colors.white,
    // const Color(0xFF0099CC),
    this.duration = const Duration(milliseconds: 2500),
    this.showPulse = true,
    this.showGlow = true,
  });

  @override
  State<ModernScanEffectLoader> createState() => _ModernScanEffectLoaderState();
}

class _ModernScanEffectLoaderState extends State<ModernScanEffectLoader>
    with TickerProviderStateMixin {
  late AnimationController _scanController;
  late AnimationController _pulseController;
  late AnimationController _rotationController;

  late Animation<double> _scanAnimation;
  late Animation<double> _pulseAnimation;
  late Animation<double> _rotationAnimation;

  @override
  void initState() {
    super.initState();

    // Scan line animation
    _scanController = AnimationController(
      vsync: this,
      duration: widget.duration,
    )..repeat(reverse: true);

    _scanAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _scanController, curve: Curves.easeInOutCubic),
    );

    // Pulse animation for corners
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);

    _pulseAnimation = Tween<double>(begin: 0.6, end: 1.0).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    // Subtle rotation for modern feel
    _rotationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 20),
    )..repeat();

    _rotationAnimation = Tween<double>(begin: 0.0, end: 2 * math.pi).animate(
      CurvedAnimation(parent: _rotationController, curve: Curves.linear),
    );
  }

  @override
  void dispose() {
    _scanController.dispose();
    _pulseController.dispose();
    _rotationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: Listenable.merge([
        _scanAnimation,
        _pulseAnimation,
        _rotationAnimation,
      ]),
      builder: (context, child) {
        return SizedBox(
          width: widget.size,
          height: widget.size,
          child: Stack(
            alignment: Alignment.center,
            children: [
              // Background glow effect
              if (widget.showGlow)
                Container(
                  width: widget.size * 1.2,
                  height: widget.size * 1.2,
                  decoration: BoxDecoration(
                    shape: BoxShape.rectangle,
                    borderRadius: BorderRadius.circular(12),
                    gradient: RadialGradient(
                      colors: [
                        widget.primaryColor.withOpacity(0.1),
                        widget.primaryColor.withOpacity(0.05),
                        Colors.transparent,
                      ],
                    ),
                  ),
                ),

              // Main scanner
              Transform.rotate(
                angle: _rotationAnimation.value * 0.1, // Subtle rotation
                child: CustomPaint(
                  size: Size(widget.size, widget.size),
                  painter: ModernScanEffectPainter(
                    scanProgress: _scanAnimation.value,
                    pulseProgress: _pulseAnimation.value,
                    primaryColor: widget.primaryColor,
                    accentColor: widget.accentColor,
                    showPulse: widget.showPulse,
                  ),
                ),
              ),

              // Center indicator
              Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: widget.primaryColor,
                  boxShadow: [
                    BoxShadow(
                      color: widget.primaryColor.withOpacity(0.5),
                      blurRadius: 8,
                      spreadRadius: 2,
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class ModernScanEffectPainter extends CustomPainter {
  final double scanProgress;
  final double pulseProgress;
  final Color primaryColor;
  final Color accentColor;
  final bool showPulse;

  ModernScanEffectPainter({
    required this.scanProgress,
    required this.pulseProgress,
    required this.primaryColor,
    required this.accentColor,
    required this.showPulse,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final rect = Rect.fromCenter(
      center: center,
      width: size.width - 20,
      height: size.height - 20,
    );

    // Background border with gradient
    final borderPaint =
        Paint()
          ..shader = LinearGradient(
            colors: [
              primaryColor.withOpacity(0.3),
              accentColor.withOpacity(0.5),
              primaryColor.withOpacity(0.3),
            ],
            stops: const [0.0, 0.5, 1.0],
          ).createShader(rect)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.5;

    final borderRadius = Radius.circular(12);
    final rrect = RRect.fromRectAndRadius(rect, borderRadius);
    canvas.drawRRect(rrect, borderPaint);

    // Scanning line with gradient effect
    final scanLineY = rect.top + (rect.height * scanProgress);
    final scanGradient = LinearGradient(
      begin: Alignment.centerLeft,
      end: Alignment.centerRight,
      colors: [
        Colors.transparent,
        primaryColor.withOpacity(0.3),
        primaryColor.withOpacity(0.8),
        primaryColor,
        primaryColor.withOpacity(0.8),
        primaryColor.withOpacity(0.3),
        Colors.transparent,
      ],
      stops: const [0.0, 0.2, 0.4, 0.5, 0.6, 0.8, 1.0],
    );

    final scanPaint =
        Paint()
          ..shader = scanGradient.createShader(
            Rect.fromLTWH(rect.left, scanLineY - 2, rect.width, 4),
          );

    canvas.drawRect(
      Rect.fromLTWH(rect.left, scanLineY - 2, rect.width, 4),
      scanPaint,
    );

    // Enhanced corner indicators with modern design
    final cornerSize = 25.0;
    final cornerStroke = 3.0;
    final cornerRadius = 8.0;

    final cornerPaint =
        Paint()
          ..color =
              showPulse ? primaryColor.withOpacity(pulseProgress) : primaryColor
          ..strokeWidth = cornerStroke
          ..style = PaintingStyle.stroke
          ..strokeCap = StrokeCap.round;

    // Top-left corner
    _drawModernCorner(
      canvas,
      cornerPaint,
      Offset(rect.left, rect.top),
      cornerSize,
      cornerRadius,
      isTopLeft: true,
    );

    // Top-right corner
    _drawModernCorner(
      canvas,
      cornerPaint,
      Offset(rect.right, rect.top),
      cornerSize,
      cornerRadius,
      isTopRight: true,
    );

    // Bottom-left corner
    _drawModernCorner(
      canvas,
      cornerPaint,
      Offset(rect.left, rect.bottom),
      cornerSize,
      cornerRadius,
      isBottomLeft: true,
    );

    // Bottom-right corner
    _drawModernCorner(
      canvas,
      cornerPaint,
      Offset(rect.right, rect.bottom),
      cornerSize,
      cornerRadius,
      isBottomRight: true,
    );

    // Scanning area highlight
    final highlightRect = Rect.fromLTWH(
      rect.left,
      math.max(rect.top, scanLineY - 10),
      rect.width,
      20,
    );

    final highlightPaint =
        Paint()
          ..shader = LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              primaryColor.withOpacity(0.0),
              primaryColor.withOpacity(0.1),
              primaryColor.withOpacity(0.0),
            ],
          ).createShader(highlightRect);

    canvas.drawRect(highlightRect, highlightPaint);
  }

  void _drawModernCorner(
    Canvas canvas,
    Paint paint,
    Offset corner,
    double size,
    double radius, {
    bool isTopLeft = false,
    bool isTopRight = false,
    bool isBottomLeft = false,
    bool isBottomRight = false,
  }) {
    final path = Path();

    if (isTopLeft) {
      path.moveTo(corner.dx, corner.dy + size);
      path.lineTo(corner.dx, corner.dy + radius);
      path.quadraticBezierTo(
        corner.dx,
        corner.dy,
        corner.dx + radius,
        corner.dy,
      );
      path.lineTo(corner.dx + size, corner.dy);
    } else if (isTopRight) {
      path.moveTo(corner.dx - size, corner.dy);
      path.lineTo(corner.dx - radius, corner.dy);
      path.quadraticBezierTo(
        corner.dx,
        corner.dy,
        corner.dx,
        corner.dy + radius,
      );
      path.lineTo(corner.dx, corner.dy + size);
    } else if (isBottomLeft) {
      path.moveTo(corner.dx, corner.dy - size);
      path.lineTo(corner.dx, corner.dy - radius);
      path.quadraticBezierTo(
        corner.dx,
        corner.dy,
        corner.dx + radius,
        corner.dy,
      );
      path.lineTo(corner.dx + size, corner.dy);
    } else if (isBottomRight) {
      path.moveTo(corner.dx - size, corner.dy);
      path.lineTo(corner.dx - radius, corner.dy);
      path.quadraticBezierTo(
        corner.dx,
        corner.dy,
        corner.dx,
        corner.dy - radius,
      );
      path.lineTo(corner.dx, corner.dy - size);
    }

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
