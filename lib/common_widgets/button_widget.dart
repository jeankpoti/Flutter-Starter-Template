import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class ButtonWidget extends StatefulWidget {
  final Widget text;
  final Color? color;
  final Widget? icon;
  final double? width;
  final double? height;
  final Function() onPressed;

  const ButtonWidget({
    super.key,
    required this.text,
    this.color,
    this.icon,
    this.width,
    this.height,
    required this.onPressed,
  });

  @override
  State<ButtonWidget> createState() => _ButtonWidgetState();
}

class _ButtonWidgetState extends State<ButtonWidget>
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
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ).createShader(bounds),
                  child:
                      widget.icon ??
                      FaIcon(
                        FontAwesomeIcons.google,
                        size: 25,
                        color:
                            Colors.white, // This color will be used as a mask
                      ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor:
                      widget.color ?? Theme.of(context).colorScheme.secondary,
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

// import 'package:flutter/material.dart';
// import 'package:font_awesome_flutter/font_awesome_flutter.dart';

// class ButtonWidget extends StatelessWidget {
//   final Widget text;
//   final Color? color;
//   final Function() onPressed;

//   const ButtonWidget({
//     super.key,
//     required this.text,
//     this.color,
//     required this.onPressed,
//   });

//   @override
//   Widget build(BuildContext context) {
//     return SizedBox(
//       height: 50,
//       width: 375,
//       child: ElevatedButton.icon(
//         icon: ShaderMask(
//           shaderCallback:
//               (bounds) => const LinearGradient(
//                 colors: [
//                   Colors.red,
//                   Colors.yellow,
//                   Colors.green,
//                   Colors.blue,
//                 ], // Replace with your desired colors
//                 begin: Alignment.topLeft,
//                 end: Alignment.bottomRight,
//               ).createShader(bounds),
//           child: const FaIcon(
//             FontAwesomeIcons.google,
//             size: 25,
//             color: Colors.white, // This color will be used as a mask
//           ),
//         ),
//         style: ElevatedButton.styleFrom(
//           backgroundColor: color,
//           shape: RoundedRectangleBorder(
//             borderRadius: BorderRadius.circular(10),
//           ),
//         ),
//         onPressed: () => onPressed(),
//         label: text,
//       ),
//     );
//   }
// }
