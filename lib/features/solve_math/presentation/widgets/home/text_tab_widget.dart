import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../../l10n/app_localizations.dart';
import '../../../../../common_widgets/text_widgets.dart';
import '../../../../../common_widgets/math_symbols_widget.dart';
import '../../solve_math_cubit.dart';

class TextTabWidget extends StatelessWidget {
  final TextEditingController textController;
  final bool isTablet;
  final VoidCallback onSolvePressed;
  final void Function(String, {bool isError}) showSnackBarMessage;

  static const double _spacing4 = 16.0;
  static const double _spacing6 = 24.0;

  const TextTabWidget({
    super.key,
    required this.textController,
    required this.isTablet,
    required this.onSolvePressed,
    required this.showSnackBarMessage,
  });

  @override
  Widget build(BuildContext context) {
    final state = context.watch<SolveMathCubit>().state;
    
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Input Section
          Container(
            padding: const EdgeInsets.all(_spacing6),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              borderRadius: BorderRadius.circular(16.0),
              border: Border.all(
                color: Theme.of(context)
                    .colorScheme
                    .outline
                    .withValues(alpha: 0.2),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.edit_outlined,
                      color: Theme.of(context).colorScheme.primary,
                      size: 24,
                    ),
                    const SizedBox(width: 12),
                    TitleMediumText(
                      AppLocalizations.of(context)!.typeMathProblem,
                      fontWeight: FontWeight.w600,
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                  ],
                ),
                const SizedBox(height: _spacing4),
                TextField(
                  controller: textController,
                  maxLines: 6,
                  decoration: InputDecoration(
                    hintText:
                        '${AppLocalizations.of(context)!.enterMathProblem}\n\n${AppLocalizations.of(context)!.exampleProblem}',
                    hintStyle: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Theme.of(context)
                              .colorScheme
                              .onSurface
                              .withValues(alpha: 0.5),
                        ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12.0),
                      borderSide: BorderSide(
                        color: Theme.of(context)
                            .colorScheme
                            .outline
                            .withValues(alpha: 0.3),
                      ),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12.0),
                      borderSide: BorderSide(
                        color: Theme.of(context)
                            .colorScheme
                            .outline
                            .withValues(alpha: 0.3),
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12.0),
                      borderSide: BorderSide(
                        color: Theme.of(context).colorScheme.primary,
                        width: 2.0,
                      ),
                    ),
                    filled: true,
                    fillColor: Theme.of(context)
                        .colorScheme
                        .surfaceContainer
                        .withValues(alpha: 0.3),
                    contentPadding: const EdgeInsets.all(_spacing4),
                  ),
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
                const SizedBox(height: _spacing4),

                // Math Symbols Widget
                MathSymbolsWidget(controller: textController),

                const SizedBox(height: _spacing6),

                // Solve Button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: (state.isIdentifying || state.isShowingAd)
                        ? null
                        : () async {
                            if (textController.text.trim().isEmpty) {
                              showSnackBarMessage(
                                AppLocalizations.of(context)!
                                    .enterMathProblemError,
                                isError: true,
                              );
                              return;
                            }
                            onSolvePressed();
                          },
                    icon: (state.isIdentifying || state.isShowingAd)
                        ? SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Theme.of(context).colorScheme.onPrimary,
                            ),
                          )
                        : const Icon(Icons.auto_awesome, size: 20),
                    label: LabelLargeText(
                      state.isShowingAd
                          ? AppLocalizations.of(context)!.loadingAd
                          : state.isIdentifying
                              ? AppLocalizations.of(context)!.solving
                              : AppLocalizations.of(context)!.solveProblem,
                      fontWeight: FontWeight.w600,
                      color: Theme.of(context).colorScheme.onSecondary,
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Theme.of(context).colorScheme.secondary,
                      foregroundColor: Theme.of(context).colorScheme.onSecondary,
                      minimumSize: const Size(double.infinity, 56),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12.0),
                      ),
                      elevation: 2,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Tips Section
          const SizedBox(height: _spacing6),
          _TipsSection(),
        ],
      ),
    );
  }
}

class _TipsSection extends StatelessWidget {
  static const double _spacing4 = 16.0;

  const _TipsSection();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(_spacing4),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(12.0),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.lightbulb_outline,
                color: Theme.of(context).colorScheme.onSurface,
                size: 20,
              ),
              const SizedBox(width: 8),
              TitleSmallText(
                AppLocalizations.of(context)!.tipsForBetterResults,
                fontWeight: FontWeight.w600,
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ],
          ),
          const SizedBox(height: 12),
          ...[
            AppLocalizations.of(context)!.beSpecificTip,
            AppLocalizations.of(context)!.useProperNotationTip,
            AppLocalizations.of(context)!.includeNecessaryInfoTip,
          ].map(
            (tip) => Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 4,
                    height: 4,
                    margin: const EdgeInsets.only(top: 8, right: 8),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.onSurface,
                      shape: BoxShape.circle,
                    ),
                  ),
                  Expanded(
                    child: BodySmallText(
                      tip,
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}