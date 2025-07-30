import 'dart:async';
import 'dart:io';
import 'dart:math' as math;
import 'package:flutter/material.dart';

class GlitchImageWidget extends StatefulWidget {
  final File imagePath;
  final double width;
  final double height;
  final bool isTablet;
  final bool enableGlitch;
  final Duration glitchDuration;
  final double glitchIntensity;

  const GlitchImageWidget({
    super.key,
    required this.imagePath,
    this.width = 300,
    this.height = 300,
    this.isTablet = false,
    this.enableGlitch = true,
    this.glitchDuration = const Duration(milliseconds: 150),
    this.glitchIntensity = 1.0,
  });

  @override
  State<GlitchImageWidget> createState() => _GlitchImageWidgetState();
}

class _GlitchImageWidgetState extends State<GlitchImageWidget>
    with TickerProviderStateMixin {
  late AnimationController _glitchController;
  late AnimationController _colorController;
  late AnimationController _shakeController;

  Timer? _glitchTimer;
  bool _isGlitching = false;

  @override
  void initState() {
    super.initState();

    _glitchController = AnimationController(
      vsync: this,
      duration: widget.glitchDuration,
    );

    _colorController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 100),
    );

    _shakeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 50),
    );

    if (widget.enableGlitch) {
      _startRandomGlitch();
    }
  }

  void _startRandomGlitch() {
    _glitchTimer = Timer.periodic(
      Duration(
        milliseconds: math.Random().nextInt(3000) + 1000,
      ), // Random interval 1-4 seconds
      (timer) {
        if (mounted && !_isGlitching) {
          _triggerGlitch();
        }
      },
    );
  }

  void _triggerGlitch() async {
    if (!mounted) return;

    setState(() => _isGlitching = true);

    // Multiple glitch effects in sequence
    for (int i = 0; i < math.Random().nextInt(3) + 2; i++) {
      await Future.delayed(
        Duration(milliseconds: math.Random().nextInt(50) + 30),
      );

      if (mounted) {
        _glitchController.forward().then((_) {
          if (mounted) _glitchController.reverse();
        });

        _colorController.forward().then((_) {
          if (mounted) _colorController.reverse();
        });

        _shakeController.forward().then((_) {
          if (mounted) _shakeController.reverse();
        });
      }
    }

    await Future.delayed(const Duration(milliseconds: 300));
    if (mounted) {
      setState(() => _isGlitching = false);
    }
  }

  @override
  void dispose() {
    _glitchTimer?.cancel();
    _glitchController.dispose();
    _colorController.dispose();
    _shakeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: Listenable.merge([
        _glitchController,
        _colorController,
        _shakeController,
      ]),
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(
            (_shakeController.value *
                    math.sin(_shakeController.value * math.pi * 4) *
                    3) *
                widget.glitchIntensity,
            (_shakeController.value *
                    math.cos(_shakeController.value * math.pi * 6) *
                    2) *
                widget.glitchIntensity,
          ),
          child: Stack(
            children: [
              // Main image
              ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: Image.file(
                  widget.imagePath,
                  width: widget.isTablet ? double.infinity : widget.width,
                  height: widget.isTablet ? 600 : widget.height,
                  fit: BoxFit.cover,
                ),
              ),

              // Glitch overlays
              if (_glitchController.value > 0) ...[
                // Red channel offset
                ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: Transform.translate(
                    offset: Offset(
                      (_glitchController.value * 5 * widget.glitchIntensity) *
                          (math.Random().nextBool() ? 1 : -1),
                      0,
                    ),
                    child: ColorFiltered(
                      colorFilter: const ColorFilter.matrix([
                        1,
                        0,
                        0,
                        0,
                        0,
                        0,
                        0,
                        0,
                        0,
                        0,
                        0,
                        0,
                        0,
                        0,
                        0,
                        0,
                        0,
                        0,
                        1,
                        0,
                      ]),
                      child: Opacity(
                        opacity: 0.7,
                        child: Image.file(
                          widget.imagePath,
                          width:
                              widget.isTablet ? double.infinity : widget.width,
                          height: widget.isTablet ? 600 : widget.height,
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                  ),
                ),

                // Blue channel offset
                ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: Transform.translate(
                    offset: Offset(
                      (_glitchController.value * -3 * widget.glitchIntensity) *
                          (math.Random().nextBool() ? 1 : -1),
                      (_glitchController.value * 2 * widget.glitchIntensity) *
                          (math.Random().nextBool() ? 1 : -1),
                    ),
                    child: ColorFiltered(
                      colorFilter: const ColorFilter.matrix([
                        0,
                        0,
                        0,
                        0,
                        0,
                        0,
                        0,
                        0,
                        0,
                        0,
                        0,
                        0,
                        1,
                        0,
                        0,
                        0,
                        0,
                        0,
                        1,
                        0,
                      ]),
                      child: Opacity(
                        opacity: 0.6,
                        child: Image.file(
                          widget.imagePath,
                          width:
                              widget.isTablet ? double.infinity : widget.width,
                          height: widget.isTablet ? 600 : widget.height,
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                  ),
                ),
              ],

              // Horizontal glitch lines
              if (_glitchController.value > 0)
                ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: CustomPaint(
                    size: Size(
                      widget.isTablet ? double.infinity : widget.width,
                      widget.isTablet ? 600 : widget.height,
                    ),
                    painter: GlitchLinesPainter(
                      progress: _glitchController.value,
                      intensity: widget.glitchIntensity,
                    ),
                  ),
                ),

              // Digital noise overlay
              if (_colorController.value > 0)
                ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: SizedBox(
                    width: widget.isTablet ? double.infinity : widget.width,
                    height: widget.isTablet ? 600 : widget.height,
                    child: CustomPaint(
                      painter: DigitalNoisePainter(
                        progress: _colorController.value,
                        intensity: widget.glitchIntensity,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}

class GlitchLinesPainter extends CustomPainter {
  final double progress;
  final double intensity;

  GlitchLinesPainter({required this.progress, required this.intensity});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..blendMode = BlendMode.difference;

    final random = math.Random(
      42,
    ); // Fixed seed for consistent lines during animation

    for (int i = 0; i < (10 * intensity).round(); i++) {
      final y = random.nextDouble() * size.height;
      final height = random.nextDouble() * 5 + 1;
      final offset = (random.nextDouble() - 0.5) * 20 * progress * intensity;

      paint.color = Color.fromARGB(
        (255 * progress * 0.8).round(),
        random.nextInt(256),
        random.nextInt(256),
        random.nextInt(256),
      );

      canvas.drawRect(Rect.fromLTWH(offset, y, size.width, height), paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

class DigitalNoisePainter extends CustomPainter {
  final double progress;
  final double intensity;

  DigitalNoisePainter({required this.progress, required this.intensity});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..blendMode = BlendMode.overlay;

    final random = math.Random();

    for (int i = 0; i < (50 * intensity * progress).round(); i++) {
      final x = random.nextDouble() * size.width;
      final y = random.nextDouble() * size.height;
      final sizeDot = random.nextDouble() * 2 + 1;

      paint.color = Color.fromARGB(
        (255 * progress * 0.6).round(),
        random.nextInt(256),
        random.nextInt(256),
        random.nextInt(256),
      );

      canvas.drawCircle(Offset(x, y), sizeDot, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

// Alternative: Simpler glitch effect using just transforms and color filters
class SimpleGlitchImage extends StatefulWidget {
  final File imagePath;
  final double width;
  final double height;
  final bool isTablet;

  const SimpleGlitchImage({
    super.key,
    required this.imagePath,
    this.width = 300,
    this.height = 300,
    this.isTablet = false,
  });

  @override
  State<SimpleGlitchImage> createState() => _SimpleGlitchImageState();
}

class _SimpleGlitchImageState extends State<SimpleGlitchImage>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  Timer? _glitchTimer;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 100),
    );

    // Random glitch every 2-5 seconds
    _startGlitchTimer();
  }

  void _startGlitchTimer() {
    _glitchTimer = Timer.periodic(
      Duration(seconds: math.Random().nextInt(3) + 2),
      (_) => _triggerGlitch(),
    );
  }

  void _triggerGlitch() {
    _controller.forward().then((_) {
      Future.delayed(const Duration(milliseconds: 50), () {
        if (mounted) _controller.reverse();
      });
    });
  }

  @override
  void dispose() {
    _glitchTimer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Stack(
          children: [
            // Original image
            ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: Image.file(
                widget.imagePath,
                width: widget.isTablet ? double.infinity : widget.width,
                height: widget.isTablet ? 600 : widget.height,
                fit: BoxFit.cover,
              ),
            ),

            // Glitch overlay
            if (_controller.value > 0)
              ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: Transform.translate(
                  offset: Offset(_controller.value * 5, 0),
                  child: ColorFiltered(
                    colorFilter: ColorFilter.matrix([
                      1,
                      0,
                      0,
                      0,
                      0,
                      0,
                      0,
                      0,
                      0,
                      0,
                      0,
                      0,
                      1,
                      0,
                      0,
                      0,
                      0,
                      0,
                      _controller.value * 0.8,
                      0,
                    ]),
                    child: Image.file(
                      widget.imagePath,
                      width: widget.isTablet ? double.infinity : widget.width,
                      height: widget.isTablet ? 600 : widget.height,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              ),
          ],
        );
      },
    );
  }
}
