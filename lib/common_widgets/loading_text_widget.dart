import 'package:flutter/material.dart';

/// Loading state widgets that show skeleton loading or animated text
/// These maintain the same visual structure as your text widgets while loading

class LoadingTextWidget extends StatefulWidget {
  /// Width of the loading placeholder
  final double? width;
  
  /// Height of the loading placeholder
  final double? height;
  
  /// Border radius for the placeholder
  final double borderRadius;
  
  /// Whether to animate the shimmer effect
  final bool animate;
  
  /// Base color for the loading effect
  final Color? baseColor;
  
  /// Highlight color for the shimmer effect
  final Color? highlightColor;

  const LoadingTextWidget({
    super.key,
    this.width,
    this.height,
    this.borderRadius = 4.0,
    this.animate = true,
    this.baseColor,
    this.highlightColor,
  });

  @override
  State<LoadingTextWidget> createState() => _LoadingTextWidgetState();
}

class _LoadingTextWidgetState extends State<LoadingTextWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    _animation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    
    if (widget.animate) {
      _animationController.repeat(reverse: true);
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final baseColor = widget.baseColor ?? 
        theme.colorScheme.onSurface.withValues(alpha: 0.1);
    final highlightColor = widget.highlightColor ?? 
        theme.colorScheme.onSurface.withValues(alpha: 0.2);

    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Container(
          width: widget.width,
          height: widget.height ?? 16,
          decoration: BoxDecoration(
            color: widget.animate
                ? Color.lerp(baseColor, highlightColor, _animation.value)
                : baseColor,
            borderRadius: BorderRadius.circular(widget.borderRadius),
          ),
        );
      },
    );
  }
}

/// Specific loading widgets for different text styles
class LoadingDisplayLargeText extends StatelessWidget {
  final double? width;
  final int lines;

  const LoadingDisplayLargeText({
    super.key,
    this.width,
    this.lines = 1,
  });

  @override
  Widget build(BuildContext context) {
    final textStyle = Theme.of(context).textTheme.displayLarge;
    final height = textStyle?.fontSize ?? 32;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: List.generate(lines, (index) => 
        Padding(
          padding: EdgeInsets.only(bottom: index < lines - 1 ? 8.0 : 0),
          child: LoadingTextWidget(
            width: index == lines - 1 ? (width ?? 200) * 0.7 : width ?? 200,
            height: height,
            borderRadius: 6.0,
          ),
        ),
      ),
    );
  }
}

class LoadingHeadlineLargeText extends StatelessWidget {
  final double? width;
  final int lines;

  const LoadingHeadlineLargeText({
    super.key,
    this.width,
    this.lines = 1,
  });

  @override
  Widget build(BuildContext context) {
    final textStyle = Theme.of(context).textTheme.headlineLarge;
    final height = textStyle?.fontSize ?? 28;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: List.generate(lines, (index) => 
        Padding(
          padding: EdgeInsets.only(bottom: index < lines - 1 ? 6.0 : 0),
          child: LoadingTextWidget(
            width: index == lines - 1 ? (width ?? 180) * 0.7 : width ?? 180,
            height: height,
            borderRadius: 5.0,
          ),
        ),
      ),
    );
  }
}

class LoadingTitleLargeText extends StatelessWidget {
  final double? width;
  final int lines;

  const LoadingTitleLargeText({
    super.key,
    this.width,
    this.lines = 1,
  });

  @override
  Widget build(BuildContext context) {
    final textStyle = Theme.of(context).textTheme.titleLarge;
    final height = textStyle?.fontSize ?? 22;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: List.generate(lines, (index) => 
        Padding(
          padding: EdgeInsets.only(bottom: index < lines - 1 ? 4.0 : 0),
          child: LoadingTextWidget(
            width: index == lines - 1 ? (width ?? 150) * 0.8 : width ?? 150,
            height: height,
            borderRadius: 4.0,
          ),
        ),
      ),
    );
  }
}

class LoadingTitleMediumText extends StatelessWidget {
  final double? width;
  final int lines;

  const LoadingTitleMediumText({
    super.key,
    this.width,
    this.lines = 1,
  });

  @override
  Widget build(BuildContext context) {
    final textStyle = Theme.of(context).textTheme.titleMedium;
    final height = textStyle?.fontSize ?? 18;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: List.generate(lines, (index) => 
        Padding(
          padding: EdgeInsets.only(bottom: index < lines - 1 ? 4.0 : 0),
          child: LoadingTextWidget(
            width: index == lines - 1 ? (width ?? 120) * 0.8 : width ?? 120,
            height: height,
            borderRadius: 4.0,
          ),
        ),
      ),
    );
  }
}

class LoadingBodyLargeText extends StatelessWidget {
  final double? width;
  final int lines;

  const LoadingBodyLargeText({
    super.key,
    this.width,
    this.lines = 1,
  });

  @override
  Widget build(BuildContext context) {
    final textStyle = Theme.of(context).textTheme.bodyLarge;
    final height = textStyle?.fontSize ?? 16;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: List.generate(lines, (index) => 
        Padding(
          padding: EdgeInsets.only(bottom: index < lines - 1 ? 4.0 : 0),
          child: LoadingTextWidget(
            width: index == lines - 1 ? (width ?? 200) * 0.6 : width ?? 200,
            height: height,
            borderRadius: 3.0,
          ),
        ),
      ),
    );
  }
}

class LoadingBodyMediumText extends StatelessWidget {
  final double? width;
  final int lines;

  const LoadingBodyMediumText({
    super.key,
    this.width,
    this.lines = 1,
  });

  @override
  Widget build(BuildContext context) {
    final textStyle = Theme.of(context).textTheme.bodyMedium;
    final height = textStyle?.fontSize ?? 14;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: List.generate(lines, (index) => 
        Padding(
          padding: EdgeInsets.only(bottom: index < lines - 1 ? 3.0 : 0),
          child: LoadingTextWidget(
            width: index == lines - 1 ? (width ?? 180) * 0.7 : width ?? 180,
            height: height,
            borderRadius: 3.0,
          ),
        ),
      ),
    );
  }
}

class LoadingBodySmallText extends StatelessWidget {
  final double? width;
  final int lines;

  const LoadingBodySmallText({
    super.key,
    this.width,
    this.lines = 1,
  });

  @override
  Widget build(BuildContext context) {
    final textStyle = Theme.of(context).textTheme.bodySmall;
    final height = textStyle?.fontSize ?? 12;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: List.generate(lines, (index) => 
        Padding(
          padding: EdgeInsets.only(bottom: index < lines - 1 ? 2.0 : 0),
          child: LoadingTextWidget(
            width: index == lines - 1 ? (width ?? 140) * 0.8 : width ?? 140,
            height: height,
            borderRadius: 2.0,
          ),
        ),
      ),
    );
  }
}

/// Animated typing text effect
class TypingTextWidget extends StatefulWidget {
  final String text;
  final TextStyle? style;
  final Duration duration;
  final Duration? startDelay;
  final VoidCallback? onComplete;

  const TypingTextWidget(
    this.text, {
    super.key,
    this.style,
    this.duration = const Duration(milliseconds: 50),
    this.startDelay,
    this.onComplete,
  });

  @override
  State<TypingTextWidget> createState() => _TypingTextWidgetState();
}

class _TypingTextWidgetState extends State<TypingTextWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<int> _characterCount;
  
  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: widget.duration * widget.text.length,
      vsync: this,
    );
    
    _characterCount = IntTween(
      begin: 0,
      end: widget.text.length,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOut,
    ));

    // Start animation after delay
    if (widget.startDelay != null) {
      Future.delayed(widget.startDelay!, () {
        if (mounted) {
          _animationController.forward().then((_) {
            widget.onComplete?.call();
          });
        }
      });
    } else {
      _animationController.forward().then((_) {
        widget.onComplete?.call();
      });
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _characterCount,
      builder: (context, child) {
        final displayText = widget.text.substring(0, _characterCount.value);
        return Text(
          displayText,
          style: widget.style ?? Theme.of(context).textTheme.bodyMedium,
        );
      },
    );
  }
}

/// Shimmer loading effect for text blocks
class ShimmerTextBlock extends StatefulWidget {
  final double width;
  final double height;
  final int lines;
  final double spacing;

  const ShimmerTextBlock({
    super.key,
    required this.width,
    required this.height,
    this.lines = 3,
    this.spacing = 8.0,
  });

  @override
  State<ShimmerTextBlock> createState() => _ShimmerTextBlockState();
}

class _ShimmerTextBlockState extends State<ShimmerTextBlock>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );
    _animation = Tween<double>(begin: -1.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    _animationController.repeat();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: List.generate(widget.lines, (index) {
        final isLastLine = index == widget.lines - 1;
        final lineWidth = isLastLine ? widget.width * 0.7 : widget.width;
        
        return Padding(
          padding: EdgeInsets.only(
            bottom: index < widget.lines - 1 ? widget.spacing : 0,
          ),
          child: AnimatedBuilder(
            animation: _animation,
            builder: (context, child) {
              return Container(
                width: lineWidth,
                height: widget.height,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(4),
                  gradient: LinearGradient(
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                    colors: [
                      theme.colorScheme.onSurface.withValues(alpha: 0.1),
                      theme.colorScheme.onSurface.withValues(alpha: 0.2),
                      theme.colorScheme.onSurface.withValues(alpha: 0.1),
                    ],
                    stops: [
                      0.0,
                      0.5 + _animation.value * 0.5,
                      1.0,
                    ],
                  ),
                ),
              );
            },
          ),
        );
      }),
    );
  }
}