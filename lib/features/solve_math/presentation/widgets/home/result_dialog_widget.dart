import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../../l10n/app_localizations.dart';
import '../../../../../common_widgets/math_markdown_widget.dart';
import '../../../../../common_widgets/text_widgets.dart';
import '../../../../../common_widgets/report_content_dialog_widget.dart';
import '../../../../common/domain/models/content_report.dart';
import '../../image_capture_cubit.dart';

class ResultDialogWidget extends StatelessWidget {
  final bool isTablet;
  final String result;
  final Function(String result, File? imageFile) onShare;

  static const double _spacing4 = 16.0;

  const ResultDialogWidget({
    super.key,
    required this.isTablet,
    required this.result,
    required this.onShare,
  });

  static Future<void> show({
    required BuildContext context,
    required bool isTablet,
    required String result,
    required Function(String result, File? imageFile) onShare,
  }) {
    return showDialog(
      context: context,
      builder: (ctx) => ResultDialogWidget(
        isTablet: isTablet,
        result: result,
        onShare: onShare,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ImageCaptureCubit, ImageCaptureState>(
      builder: (context, imageCaptureState) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16.0),
        ),
        title: Row(
          children: [
            Icon(
              Icons.check_circle_outline,
              color: Theme.of(context).colorScheme.secondary,
              size: 28,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: HeadlineSmallText(
                AppLocalizations.of(context)!.mathSolution,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        content: Container(
          width: double.maxFinite,
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(context).size.height * 0.6,
            maxWidth: isTablet ? 600 : double.infinity,
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
              if (imageCaptureState.imageFile != null) ...[
                Container(
                  height: isTablet ? 300 : 150,
                  width: double.infinity,
                  margin: const EdgeInsets.only(bottom: _spacing4),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12.0),
                    image: DecorationImage(
                      image: FileImage(imageCaptureState.imageFile!),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              ],
              Container(
                padding: const EdgeInsets.all(_spacing4),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surfaceContainer,
                  borderRadius: BorderRadius.circular(12.0),
                ),
                child: MathMarkdownWidget(data: result),
              ),
              const SizedBox(height: _spacing4),
              Container(
                padding: const EdgeInsets.all(12.0),
                decoration: BoxDecoration(
                  color: Theme.of(context)
                      .colorScheme
                      .secondaryContainer
                      .withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(8.0),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.info_outline,
                      color: Theme.of(context).colorScheme.secondary,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: BodySmallText(
                        AppLocalizations.of(context)!.aiDisclaimer,
                        color: Theme.of(context).colorScheme.onSecondaryContainer,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        ),
        actions: [
          Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: LabelLargeText(
                      AppLocalizations.of(context)!.close,
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
                  TextButton.icon(
                    onPressed: () {
                      final imageFile = context
                          .read<ImageCaptureCubit>()
                          .state
                          .imageFile;
                      onShare(result, imageFile);
                      Navigator.of(context).pop();
                    },
                    icon: const Icon(Icons.share, size: 16),
                    label: LabelMediumText(
                      AppLocalizations.of(context)!.share,
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
                ],
              ),
              TextButton.icon(
                onPressed: () {
                  Navigator.of(context).pop();
                  ReportContentDialogWidget.show(
                    context: context,
                    contentId: DateTime.now().millisecondsSinceEpoch.toString(),
                    contentType: ContentType.mathSolution,
                    contentSnapshot: result,
                    contentTitle: AppLocalizations.of(context)!.mathSolution,
                  );
                },
                icon: const Icon(Icons.flag_outlined, size: 16),
                label: LabelMediumText(
                  AppLocalizations.of(context)!.reportContent,
                  color: Theme.of(context).colorScheme.error,
                ),
                style: TextButton.styleFrom(
                  foregroundColor: Theme.of(context).colorScheme.error,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}