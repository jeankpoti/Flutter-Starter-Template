import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:share_plus/share_plus.dart';
import '../../../common_widgets/app_snackbar_widget.dart';
import '../../../common_widgets/math_markdown_widget.dart';
import '../../../common_widgets/report_content_dialog_widget.dart';
import '../../common/domain/models/content_report.dart';

import '../../../common_widgets/app_bar_widget.dart';
import '../../../l10n/app_localizations.dart';
import '../../../common_widgets/text_widgets.dart';
import '../../../common_widgets/elevated_button_widget.dart';
import '../../../utils/responsive.dart';
import '../domain/models/collection.dart';

class CollectionsDetailsPage extends StatelessWidget {
  final Collection collection;
  final String? imageUrl;
  final String? desc;
  const CollectionsDetailsPage({
    super.key,
    this.imageUrl,
    this.desc,
    required this.collection,
  });

  @override
  Widget build(BuildContext context) {
    final isTablet = Responsive.isTablet(context);

    return Scaffold(
      appBar: AppBarWidget(
        title: AppLocalizations.of(context)!.problemsDetails,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 16.0,
                vertical: 32.0,
              ),
              child: Column(
                // mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                // spacing: 45,
                children: [
                  Container(
                    width: double.infinity,
                    height: isTablet ? 600 : 300,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.1),
                          spreadRadius: 2,
                          blurRadius: 5,
                          offset: const Offset(
                            0,
                            3,
                          ), // changes position of shadow
                        ),
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(20),
                      child:
                          collection.imageUrl != null &&
                                  collection.imageUrl!.isNotEmpty
                              ? Image.network(
                                collection.imageUrl!,
                                fit: BoxFit.cover,
                                width: 100,
                                height: 120,
                                errorBuilder:
                                    (context, error, stackTrace) =>
                                        const Icon(Icons.image_not_supported),
                              )
                              : Image.asset(
                                'assets/icons/app_icon.png',
                                fit: BoxFit.cover,
                                width: 100,
                                height: 120,
                              ),
                    ),
                  ),
                  const SizedBox(height: 45),

                  MathMarkdownWidget(data: collection.solution ?? ''),

                  const SizedBox(height: 32),

                  // Copy and Share buttons
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButtonWidget(
                          text: AppLocalizations.of(context)!.copySolution,
                          onPressed: () async {
                            try {
                              await Clipboard.setData(
                                ClipboardData(text: collection.solution ?? ''),
                              );
                              if (context.mounted) {
                                AppSnackBar.showSuccess(
                                  context,
                                  AppLocalizations.of(
                                    context,
                                  )!.solutionCopiedToClipboard,
                                );
                              }
                            } catch (e) {
                              if (context.mounted) {
                                AppSnackBar.showError(
                                  context,
                                  AppLocalizations.of(
                                    context,
                                  )!.unableToCopySolution,
                                );
                              }
                            }
                          },
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: ElevatedButtonWidget(
                          text: AppLocalizations.of(context)!.shareSolution,
                          onPressed: () async {
                            try {
                              final String shareText = AppLocalizations.of(
                                context,
                              )!.shareText(collection.solution ?? '');

                              if (collection.imageUrl != null &&
                                  collection.imageUrl!.isNotEmpty) {
                                // Share with image if available
                                await Share.share(shareText);
                              } else {
                                // Share text only
                                await Share.share(shareText);
                              }
                            } catch (e) {
                              if (context.mounted) {
                                AppSnackBar.showError(
                                  context,
                                  AppLocalizations.of(
                                    context,
                                  )!.unableToShareSolution,
                                );
                              }
                            }
                          },
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),

                  // Report button
                  Center(
                    child: TextButton.icon(
                      onPressed: () {
                        ReportContentDialogWidget.show(
                          context: context,
                          contentId:
                              collection.id ??
                              DateTime.now().millisecondsSinceEpoch.toString(),
                          contentType: ContentType.mathSolution,
                          contentSnapshot: collection.solution ?? '',
                          contentTitle:
                              AppLocalizations.of(context)!.mathSolution,
                        );
                      },
                      icon: const Icon(Icons.flag_outlined, size: 20),
                      label: BodyMediumText(
                        AppLocalizations.of(context)!.reportContent,
                        color: Theme.of(context).colorScheme.error,
                      ),
                      style: TextButton.styleFrom(
                        foregroundColor: Theme.of(context).colorScheme.error,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.only(
          left: 32.0,
          top: 16.0,
          right: 32.0,
          bottom: 32.0,
        ),
        child: BodySmallText(
          AppLocalizations.of(context)!.mathAiDisclaimer,
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}
