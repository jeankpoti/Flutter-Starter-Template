import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../../l10n/app_localizations.dart';
import '../../../../../common_widgets/scan_effect_loader_widget.dart';
import '../../../../../common_widgets/text_widgets.dart';
import '../../solve_math_cubit.dart';
import '../../image_capture_cubit.dart';
import 'action_buttons_widget.dart';

class PhotoTabWidget extends StatelessWidget {
  final bool isTablet;
  final VoidCallback onCameraPressed;
  final VoidCallback onGalleryPressed;
  final VoidCallback onResetPressed;
  final Future<void> Function() onSolvePressed;

  static const double _spacing4 = 16.0;
  static const double _spacing6 = 24.0;

  const PhotoTabWidget({
    super.key,
    required this.isTablet,
    required this.onCameraPressed,
    required this.onGalleryPressed,
    required this.onResetPressed,
    required this.onSolvePressed,
  });

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ImageCaptureCubit, ImageCaptureState>(
      builder: (context, imageCaptureState) {
        final state = context.watch<SolveMathCubit>().state;

        return SingleChildScrollView(
          child: Column(
            children: [
              // Image Preview Container
              Container(
                width: double.infinity,
                height: isTablet ? 400 : 300,
                margin: const EdgeInsets.only(bottom: _spacing6),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surface,
                  borderRadius: BorderRadius.circular(16.0),
                  border: Border.all(
                    color: Theme.of(
                      context,
                    ).colorScheme.outline.withValues(alpha: 0.2),
                    width: 1,
                  ),
                ),
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    if (imageCaptureState.imageFile != null)
                      ClipRRect(
                        borderRadius: BorderRadius.circular(16.0),
                        child: Image.file(
                          imageCaptureState.imageFile!,
                          width: double.infinity,
                          height: double.infinity,
                          fit: BoxFit.cover,
                        ),
                      )
                    else
                      Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.add_a_photo_outlined,
                            size: isTablet ? 80 : 60,
                            color: Theme.of(
                              context,
                            ).colorScheme.onSurface.withValues(alpha: 0.4),
                          ),
                          const SizedBox(height: 16),
                          BodyLargeText(
                            AppLocalizations.of(context)!.noImageSelected,
                            color: Theme.of(
                              context,
                            ).colorScheme.onSurface.withValues(alpha: 0.6),
                          ),
                          const SizedBox(height: 8),
                          BodyMediumText(
                            AppLocalizations.of(context)!.captureOrUpload,
                            color: Theme.of(
                              context,
                            ).colorScheme.onSurface.withValues(alpha: 0.5),
                          ),
                        ],
                      ),

                    // Loading overlay
                    if (imageCaptureState.isLoading || state.isIdentifying || state.isShowingAd)
                      Container(
                        decoration: BoxDecoration(
                          color: Theme.of(
                            context,
                          ).colorScheme.surface.withValues(alpha: 0.9),
                          borderRadius: BorderRadius.circular(16.0),
                        ),
                        child: Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              ModernScanEffectLoader(
                                size: isTablet ? 120 : 80,
                                duration: const Duration(milliseconds: 1500),
                              ),
                              const SizedBox(height: _spacing4),
                              BodyMediumText(
                                state.isShowingAd
                                    ? AppLocalizations.of(context)!.loadingAd
                                    : state.isIdentifying
                                        ? AppLocalizations.of(context)!.analyzingProblem
                                        : AppLocalizations.of(context)!.processingImage,
                                color: Theme.of(context).colorScheme.primary,
                                fontWeight: FontWeight.w500,
                              ),
                            ],
                          ),
                        ),
                      ),
                  ],
                ),
              ),

              // Action Buttons
              ActionButtonsWidget(
                isTablet: isTablet,
                imageCaptureState: imageCaptureState,
                solveMathState: state,
                onCameraPressed: onCameraPressed,
                onGalleryPressed: onGalleryPressed,
                onResetPressed: onResetPressed,
                onSolvePressed: onSolvePressed,
              ),
            ],
          ),
        );
      },
    );
  }
}
