import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../../l10n/app_localizations.dart';
import '../../../../../common_widgets/math_markdown_widget.dart';
import '../../../../../common_widgets/text_widgets.dart';
import '../../../../../common_widgets/report_content_dialog_widget.dart';
import '../../../../common/domain/models/content_report.dart';
import '../../image_capture_cubit.dart';
import '../../solve_math_cubit.dart';
import '../../solve_math_state.dart';

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
    return Navigator.of(context).push(
      MaterialPageRoute(
        fullscreenDialog: true,
        builder: (ctx) => ResultDialogWidget(
          isTablet: isTablet,
          result: result,
          onShare: onShare,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ImageCaptureCubit, ImageCaptureState>(
      builder: (context, imageCaptureState) => BlocBuilder<SolveMathCubit, SolveMathState>(
        builder: (context, solveMathState) => Scaffold(
        backgroundColor: Theme.of(context).colorScheme.surface,
        appBar: AppBar(
          backgroundColor: Theme.of(context).colorScheme.surface,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.close),
            onPressed: () => Navigator.of(context).pop(),
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
        ),
        body: SafeArea(
          child: Container(
            width: double.infinity,
            constraints: BoxConstraints(
              maxWidth: isTablet ? 800 : double.infinity,
            ),
            margin: EdgeInsets.symmetric(
              horizontal: isTablet ? (MediaQuery.of(context).size.width - 800) / 2 : 0,
            ),
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(_spacing4),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (imageCaptureState.imageFile != null) ...[
                    Container(
                      height: isTablet ? 400 : 200,
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
                  // Generated images section
                  if (solveMathState.generatedImages.isNotEmpty) ...[
                    for (int i = 0; i < solveMathState.generatedImages.length; i++)
                      Container(
                        width: double.infinity,
                        margin: const EdgeInsets.only(bottom: _spacing4),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12.0),
                          boxShadow: [
                            BoxShadow(
                              color: Theme.of(context).colorScheme.shadow.withValues(alpha: 0.1),
                              offset: const Offset(0, 2),
                              blurRadius: 8.0,
                            ),
                          ],
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(12.0),
                          child: Image.memory(
                            solveMathState.generatedImages[i],
                            fit: BoxFit.contain,
                          ),
                        ),
                      ),
                  ],
                  
                  // Solution text section
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(_spacing4),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.surfaceContainer,
                      borderRadius: BorderRadius.circular(12.0),
                    ),
                    child: MathMarkdownWidget(data: result),
                  ),
                  const SizedBox(height: _spacing4),
                  Container(
                    width: double.infinity,
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
                  const SizedBox(height: _spacing4 * 2),
                  Center(
                    child: TextButton.icon(
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
                  ),
                  const SizedBox(height: _spacing4),
                ],
              ),
            ),
          ),
        ),
      ),
    ),
    );
  }
}