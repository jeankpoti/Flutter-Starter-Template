import 'package:flutter/material.dart';

class KeyboardSlideTransition extends StatefulWidget {
  final Widget child;
  final bool isVisible;
  final VoidCallback? onDismiss;
  final Duration duration;

  const KeyboardSlideTransition({
    super.key,
    required this.child,
    required this.isVisible,
    this.onDismiss,
    this.duration = const Duration(milliseconds: 300),
  });

  @override
  State<KeyboardSlideTransition> createState() => _KeyboardSlideTransitionState();
}

class _KeyboardSlideTransitionState extends State<KeyboardSlideTransition>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(duration: widget.duration, vsync: this);
    
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 1),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.fastOutSlowIn));
    
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));

    if (widget.isVisible) {
      _controller.forward();
    }
  }

  @override
  void didUpdateWidget(KeyboardSlideTransition oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isVisible != oldWidget.isVisible) {
      if (widget.isVisible) {
        _controller.forward();
      } else {
        _controller.reverse().then((_) => widget.onDismiss?.call());
      }
    }
  }

  @override
  void dispose() {
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
            // Backdrop
            if (_controller.value > 0)
              FadeTransition(
                opacity: _fadeAnimation,
                child: GestureDetector(
                  onTap: () => widget.onDismiss?.call(),
                  child: Container(
                    color: Colors.black.withValues(alpha: 0.3),
                  ),
                ),
              ),
            
            // Sliding content
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: SlideTransition(
                position: _slideAnimation,
                child: widget.child,
              ),
            ),
          ],
        );
      },
    );
  }
}

class ResizableContainer extends StatefulWidget {
  final Widget child;
  final double minHeight;
  final double maxHeight;
  final double initialHeight;
  final Function(double height)? onHeightChanged;

  const ResizableContainer({
    super.key,
    required this.child,
    this.minHeight = 280,
    this.maxHeight = 400,
    this.initialHeight = 280,
    this.onHeightChanged,
  });

  @override
  State<ResizableContainer> createState() => _ResizableContainerState();
}

class _ResizableContainerState extends State<ResizableContainer> {
  late double _height;
  double _dragOffset = 0;

  @override
  void initState() {
    super.initState();
    _height = widget.initialHeight;
  }

  void _handleDragUpdate(DragUpdateDetails details) {
    setState(() {
      _dragOffset += details.delta.dy;
      _height = (widget.initialHeight - _dragOffset).clamp(widget.minHeight, widget.maxHeight);
    });
  }

  void _handleDragEnd(DragEndDetails details) {
    widget.onHeightChanged?.call(_height);
    setState(() => _dragOffset = 0);
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onPanUpdate: _handleDragUpdate,
      onPanEnd: _handleDragEnd,
      child: SizedBox(
        height: _height,
        child: widget.child,
      ),
    );
  }
}