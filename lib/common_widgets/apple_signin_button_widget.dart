import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class AppleSigninButtonWidget extends StatefulWidget {
  final Widget text;
  final Color? color;
  final Widget? icon;
  final double? width;
  final double? height;
  final Function() onPressed;

  const AppleSigninButtonWidget({
    super.key,
    required this.text,
    this.color,
    this.icon,
    this.width,
    this.height,
    required this.onPressed,
  });

  @override
  State<AppleSigninButtonWidget> createState() =>
      _AppleSigninButtonWidgetState();
}

class _AppleSigninButtonWidgetState extends State<AppleSigninButtonWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();

    // Create animation controller for the rotating gradient
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat(); // Makes the animation loop continuously
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        return Container(
          height: widget.height ?? 56,
          width: widget.width ?? 375,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            // Add a gradient border using a shader
            gradient: LinearGradient(
              colors: const [
                Colors.blue,
                Colors.red,
                Colors.yellow,
                Colors.green,
                Colors.blue,
              ],
              stops: const [0.0, 0.25, 0.5, 0.75, 1.0],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              transform: GradientRotation(
                _animationController.value * 2 * 3.14159,
              ),
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(2), // Border thickness
            child: Container(
              decoration: BoxDecoration(
                color: widget.color ?? Theme.of(context).colorScheme.surface,
                borderRadius: BorderRadius.circular(10),
              ),
              child: ElevatedButton.icon(
                icon: ShaderMask(
                  shaderCallback:
                      (bounds) => const LinearGradient(
                        colors: [
                          Colors.red,
                          Colors.yellow,
                          Colors.green,
                          Colors.blue,
                        ], // Replace with your desired colors
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ).createShader(bounds),
                  child:
                  //  Text('Apple Icon'),
                  const FaIcon(
                    FontAwesomeIcons.apple,
                    size: 25,
                    color: Colors.white, // This color will be used as a mask
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).colorScheme.secondary,
                  elevation: 0,
                  shadowColor: Colors.transparent,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                onPressed: () => widget.onPressed(),
                label: widget.text,
              ),
            ),
          ),
        );
      },
    );
  }
}
