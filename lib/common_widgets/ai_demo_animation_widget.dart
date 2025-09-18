import 'package:flutter/material.dart';
import 'package:math_ai/common_widgets/text_widgets.dart';
import 'package:math_ai/common_widgets/math_markdown_widget.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class AIDemoAnimationWidget extends StatefulWidget {
  const AIDemoAnimationWidget({super.key});

  @override
  State<AIDemoAnimationWidget> createState() => _AIDemoAnimationWidgetState();
}

class _AIDemoAnimationWidgetState extends State<AIDemoAnimationWidget>
    with TickerProviderStateMixin {
  late AnimationController _mainController;
  late AnimationController _thinkingController;
  late Animation<double> _problemFadeIn;
  late Animation<double> _thinkingPulse;
  late Animation<double> _screenTransition;
  late Animation<Offset> _screenSlide;

  bool _isThinking = false;
  bool _showStepByStep = false;
  int _currentStep = 0;

  final String _mathProblem = r"$\frac{x^2 + 3x - 4}{x - 1} = ?$";
  final List<String> _solutionSteps = [
    r"Step 1: Factor: $(x + 4)(x - 1)$",
    r"Step 2: Cancel: $x + 4$",
    r"Answer: $x + 4$ (for $x \neq 1$)",
  ];

  @override
  void initState() {
    super.initState();

    _mainController = AnimationController(
      duration: const Duration(seconds: 8),
      vsync: this,
    );

    _thinkingController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _problemFadeIn = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _mainController,
        curve: const Interval(0.0, 0.15, curve: Curves.easeIn),
      ),
    );

    _thinkingPulse = Tween<double>(begin: 0.8, end: 1.2).animate(
      CurvedAnimation(parent: _thinkingController, curve: Curves.easeInOut),
    );

    _screenTransition = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _mainController,
        curve: const Interval(0.4, 0.6, curve: Curves.easeInOut),
      ),
    );

    _screenSlide = Tween<Offset>(
      begin: const Offset(1.0, 0.0),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _mainController,
        curve: const Interval(0.4, 0.6, curve: Curves.easeOutCubic),
      ),
    );

    _mainController.addListener(() {
      if (_mainController.value >= 0.15 && !_isThinking) {
        setState(() {
          _isThinking = true;
        });
        _thinkingController.repeat(reverse: true);
      }

      if (_mainController.value >= 0.4 && !_showStepByStep) {
        setState(() {
          _showStepByStep = true;
        });
        _thinkingController.stop();
        _thinkingController.reset();
        _animateSteps();
      }
    });

    _startAnimation();
  }

  void _animateSteps() async {
    for (int i = 0; i < _solutionSteps.length; i++) {
      if (!mounted) return;
      await Future.delayed(const Duration(milliseconds: 800));
      if (mounted) {
        setState(() {
          _currentStep = i + 1;
        });
      }
    }
  }

  void _startAnimation() async {
    await Future.delayed(const Duration(milliseconds: 500));
    if (mounted) {
      _mainController.forward().then((_) {
        // Reset and loop the animation
        Future.delayed(const Duration(seconds: 2), () {
          if (mounted) {
            _resetAnimation();
          }
        });
      });
    }
  }

  void _resetAnimation() {
    setState(() {
      _isThinking = false;
      _showStepByStep = false;
      _currentStep = 0;
    });

    _mainController.reset();
    _thinkingController.reset();
    _startAnimation();
  }

  @override
  void dispose() {
    _mainController.dispose();
    _thinkingController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        height: 450,
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Demo Header
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  FontAwesomeIcons.robot,
                  color: Theme.of(context).colorScheme.secondary,
                  size: 18,
                ),
              ],
            ),

            const SizedBox(height: 12),

            // Math Problem Display (only show when not showing step by step)
            if (!_showStepByStep)
              AnimatedBuilder(
                animation: _problemFadeIn,
                builder: (context, child) {
                  return Opacity(
                    opacity: _problemFadeIn.value,
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.surface,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: Theme.of(
                            context,
                          ).colorScheme.outline.withValues(alpha: 0.2),
                        ),
                      ),
                      child: Column(
                        children: [
                          BodySmallText(
                            "Problem:",
                            color: Theme.of(
                              context,
                            ).colorScheme.onSurface.withValues(alpha: 0.6),
                          ),
                          const SizedBox(height: 6),
                          Center(child: MathMarkdownWidget(data: _mathProblem)),
                        ],
                      ),
                    ),
                  );
                },
              ),

            const SizedBox(height: 12),

            // AI Thinking Indicator
            if (_isThinking && !_showStepByStep)
              AnimatedBuilder(
                animation: _thinkingPulse,
                builder: (context, child) {
                  return Transform.scale(
                    scale: _thinkingPulse.value,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: Theme.of(
                          context,
                        ).colorScheme.secondary.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                Theme.of(context).colorScheme.secondary,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          BodySmallText(
                            "AI thinking...",
                            color: Theme.of(context).colorScheme.secondary,
                            fontWeight: FontWeight.w600,
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),

            // Step-by-Step Solution Screen
            if (_showStepByStep)
              Expanded(
                child: AnimatedBuilder(
                  animation: _screenTransition,
                  builder: (context, child) {
                    return SlideTransition(
                      position: _screenSlide,
                      child: FadeTransition(
                        opacity: _screenTransition,
                        child: Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Theme.of(context).colorScheme.surface,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: Theme.of(
                                context,
                              ).colorScheme.outline.withValues(alpha: 0.2),
                            ),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Row(
                                children: [
                                  Icon(
                                    Icons.auto_fix_high,
                                    color:
                                        Theme.of(context).colorScheme.secondary,
                                    size: 16,
                                  ),
                                  const SizedBox(width: 8),
                                  BodySmallText(
                                    "Solution Steps:",
                                    color:
                                        Theme.of(context).colorScheme.secondary,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              // Display steps progressively
                              Expanded(
                                child: SingleChildScrollView(
                                  child: Column(
                                    children: [
                                      for (
                                        int i = 0;
                                        i < _currentStep &&
                                            i < _solutionSteps.length;
                                        i++
                                      )
                                        AnimatedOpacity(
                                          opacity: 1.0,
                                          duration: const Duration(
                                            milliseconds: 500,
                                          ),
                                          child: Container(
                                            margin: const EdgeInsets.only(
                                              bottom: 4,
                                            ),
                                            padding: const EdgeInsets.all(6),
                                            decoration: BoxDecoration(
                                              color: Theme.of(context)
                                                  .colorScheme
                                                  .secondaryContainer
                                                  .withValues(alpha: 0.2),
                                              borderRadius:
                                                  BorderRadius.circular(6),
                                            ),
                                            child: Row(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Container(
                                                  width: 16,
                                                  height: 16,
                                                  decoration: BoxDecoration(
                                                    color:
                                                        Theme.of(
                                                          context,
                                                        ).colorScheme.secondary,
                                                    shape: BoxShape.circle,
                                                  ),
                                                  child: Center(
                                                    child: Icon(
                                                      Icons.check,
                                                      size: 10,
                                                      color:
                                                          Theme.of(context)
                                                              .colorScheme
                                                              .onSecondary,
                                                    ),
                                                  ),
                                                ),
                                                const SizedBox(width: 6),
                                                Expanded(
                                                  child: MathMarkdownWidget(
                                                    data: _solutionSteps[i],
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),

            // Spacer only when not showing step by step
            if (!_showStepByStep) const Spacer(),

            // Demo Action Indicator
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Theme.of(
                  context,
                ).colorScheme.surface.withValues(alpha: 0.8),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    _showStepByStep
                        ? FontAwesomeIcons.graduationCap
                        : FontAwesomeIcons.camera,
                    size: 12,
                    color: Theme.of(
                      context,
                    ).colorScheme.onSurface.withValues(alpha: 0.6),
                  ),
                  const SizedBox(width: 6),
                  BodySmallText(
                    _showStepByStep
                        ? "Step-by-step solutions!"
                        : "Just snap a photo!",
                    color: Theme.of(
                      context,
                    ).colorScheme.onSurface.withValues(alpha: 0.6),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
