import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../../l10n/app_localizations.dart';
import '../../../../../common_widgets/text_widgets.dart';
import '../../solve_math_state.dart';
import '../../image_capture_cubit.dart';
import '../../solve_math_cubit.dart';

class ActionButtonsWidget extends StatelessWidget {
  final bool isTablet;
  final ImageCaptureState imageCaptureState;
  final SolveMathState solveMathState;
  final VoidCallback onCameraPressed;
  final VoidCallback onGalleryPressed;
  final VoidCallback onResetPressed;
  final Future<void> Function() onSolvePressed;

  const ActionButtonsWidget({
    super.key,
    required this.isTablet,
    required this.imageCaptureState,
    required this.solveMathState,
    required this.onCameraPressed,
    required this.onGalleryPressed,
    required this.onResetPressed,
    required this.onSolvePressed,
  });

  @override
  Widget build(BuildContext context) {
    log(' imageCaptureState.isGallery: ${imageCaptureState.isGallery}');
    // log(' imageCaptureState.isCamera: ${imageCaptureState.isCamera}');
    // log(' imageCaptureState.imageFile: ${imageCaptureState.imageFile}');
    // log(' solveMathState.result.isEmpty: ${solveMathState.result.isEmpty}');

    return Column(
      children: [
        // Primary Actions Row
        Row(
          children: [
            Expanded(
              child: _ActionButton(
                icon: Icons.camera_alt,
                label:
                    imageCaptureState.isCamera &&
                            imageCaptureState.imageFile != null &&
                            solveMathState.result.isEmpty
                        ? AppLocalizations.of(context)!.solveProblem
                        : AppLocalizations.of(context)!.takePhoto,
                onPressed:
                    imageCaptureState.isLoading
                        ? null
                        : () async {
                          if (imageCaptureState.isCamera &&
                              imageCaptureState.imageFile != null &&
                              solveMathState.result.isEmpty) {
                            await onSolvePressed();
                          } else {
                            context.read<SolveMathCubit>().emptyResult();
                            onCameraPressed();
                          }
                        },
                isPrimary:
                    imageCaptureState.isCamera &&
                    imageCaptureState.imageFile != null &&
                    solveMathState.result.isEmpty,
                isLoading:
                    imageCaptureState.isLoading && imageCaptureState.isCamera,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _ActionButton(
                icon: Icons.photo_library,
                label:
                    imageCaptureState.isGallery &&
                            imageCaptureState.imageFile != null &&
                            solveMathState.result.isEmpty
                        ? AppLocalizations.of(context)!.solveProblem
                        : AppLocalizations.of(context)!.uploadPhoto,
                onPressed:
                    imageCaptureState.isLoading
                        ? null
                        : () async {
                          if (imageCaptureState.isGallery &&
                              imageCaptureState.imageFile != null &&
                              solveMathState.result.isEmpty) {
                            await onSolvePressed();
                          } else {
                            context.read<SolveMathCubit>().emptyResult();
                            onGalleryPressed();
                          }
                        },
                isPrimary:
                    imageCaptureState.isGallery &&
                    imageCaptureState.imageFile != null &&
                    solveMathState.result.isEmpty,
                isLoading:
                    imageCaptureState.isLoading && imageCaptureState.isGallery,
              ),
            ),
          ],
        ),

        // Reset Button
        if ((imageCaptureState.isGallery || imageCaptureState.isCamera) &&
            imageCaptureState.imageFile != null &&
            solveMathState.result.isEmpty) ...[
          const SizedBox(height: 45),
          SizedBox(
            width: double.infinity,
            child: _ActionButton(
              icon: Icons.refresh,
              label: AppLocalizations.of(context)!.reset,
              onPressed: onResetPressed,
              isSecondary: true,
            ),
          ),
        ],
      ],
    );
  }
}

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback? onPressed;
  final bool isPrimary;
  final bool isSecondary;
  final bool isLoading;

  const _ActionButton({
    required this.icon,
    required this.label,
    required this.onPressed,
    this.isPrimary = false,
    this.isSecondary = false,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    if (isPrimary) {
      return ElevatedButton.icon(
        onPressed: onPressed,
        icon:
            isLoading
                ? SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Theme.of(context).colorScheme.onSecondary,
                  ),
                )
                : Icon(icon, size: 20),
        label: LabelLargeText(
          label,
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
      );
    } else if (isSecondary) {
      return OutlinedButton.icon(
        onPressed: onPressed,
        icon: Icon(icon, size: 20),
        label: LabelLargeText(
          label,
          color: Theme.of(context).colorScheme.onSecondary,
        ),
        style: OutlinedButton.styleFrom(
          backgroundColor: Theme.of(context).colorScheme.secondary,
          foregroundColor: Theme.of(context).colorScheme.onSecondary,
          side: BorderSide(color: Theme.of(context).colorScheme.outline),
          minimumSize: const Size(double.infinity, 56),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12.0),
          ),
        ),
      );
    } else {
      return FilledButton.icon(
        onPressed: onPressed,
        icon:
            isLoading
                ? SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Theme.of(context).colorScheme.onSecondary,
                  ),
                )
                : Icon(icon, size: 20),
        label: LabelLargeText(
          label,
          color: Theme.of(context).colorScheme.onSecondary,
        ),
        style: FilledButton.styleFrom(
          backgroundColor: Theme.of(context).colorScheme.secondary,
          foregroundColor: Theme.of(context).colorScheme.onSecondary,
          minimumSize: const Size(double.infinity, 56),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12.0),
          ),
        ),
      );
    }
  }
}
