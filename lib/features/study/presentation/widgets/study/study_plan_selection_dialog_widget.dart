import 'package:flutter/material.dart';

import '../../../../../common_widgets/text_widgets.dart';
import '../../../../../l10n/app_localizations.dart';
import '../../../domain/models/study_plan.dart';

class StudyPlanSelectionDialog extends StatelessWidget {
  final List<StudyPlan> studyPlans;
  final bool hasStudyMaterials;

  const StudyPlanSelectionDialog({
    super.key,
    required this.studyPlans,
    required this.hasStudyMaterials,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: TitleLargeText(
        AppLocalizations.of(context)!.selectStudyPlan,
        fontWeight: FontWeight.bold,
      ),
      content: SizedBox(
        width: double.maxFinite,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            BodyMediumText(
              AppLocalizations.of(context)!.chooseStudyPlanForQuiz,
              color: Theme.of(
                context,
              ).colorScheme.onSurface.withValues(alpha: 0.7),
            ),
            const SizedBox(height: 16),
            Flexible(
              child: ListView(
                shrinkWrap: true,
                children: [
                  // Individual study plans
                  for (final plan in studyPlans)
                    Card(
                      margin: const EdgeInsets.only(bottom: 8),
                      child: ListTile(
                        leading: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color:
                                Theme.of(
                                  context,
                                ).colorScheme.secondaryContainer,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Icon(
                            Icons.library_books,
                            color: Theme.of(context).colorScheme.secondary,
                          ),
                        ),
                        title: TitleMediumText(plan.title),
                        subtitle: BodySmallText('${plan.topics.length} topics'),
                        onTap: () => Navigator.of(context).pop(plan),
                      ),
                    ),

                  // All materials option
                  if (hasStudyMaterials) ...[
                    const SizedBox(height: 8),
                    Card(
                      color: Theme.of(context).colorScheme.primaryContainer,
                      child: ListTile(
                        leading: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Theme.of(context).colorScheme.primary,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Icon(
                            Icons.quiz,
                            color: Theme.of(context).colorScheme.onPrimary,
                          ),
                        ),
                        title: TitleMediumText(
                          AppLocalizations.of(context)!.allStudyMaterials,
                          color:
                              Theme.of(context).colorScheme.onPrimaryContainer,
                        ),
                        subtitle: BodySmallText(
                          AppLocalizations.of(
                            context,
                          )!.generateFromAllMaterials,
                          color: Theme.of(context)
                              .colorScheme
                              .onPrimaryContainer
                              .withValues(alpha: 0.7),
                        ),
                        onTap: () => Navigator.of(context).pop('ALL_MATERIALS'),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: LabelLargeText(AppLocalizations.of(context)!.cancel),
        ),
      ],
    );
  }
}
