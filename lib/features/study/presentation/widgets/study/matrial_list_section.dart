import 'package:flutter/material.dart';
import '../../../../../l10n/app_localizations.dart';
import '../../../../../common_widgets/text_widgets.dart';
import '../../../domain/models/study_material.dart' as study;

class MaterialsListSection extends StatelessWidget {
  final List<study.StudyMaterial> studyMaterials;

  const MaterialsListSection({super.key, required this.studyMaterials});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        HeadlineSmallText(
          AppLocalizations.of(context)!.myStudyMaterials,
          fontWeight: FontWeight.bold,
          color: Theme.of(context).colorScheme.onSurface,
        ),
        const SizedBox(height: 16),
        if (studyMaterials.isEmpty)
          const EmptyMaterialsWidget()
        else
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: studyMaterials.length,
            itemBuilder: (context, index) {
              final material = studyMaterials[index];
              return MaterialCardWidget(material: material);
            },
          ),
      ],
    );
  }
}

class MaterialCardWidget extends StatelessWidget {
  final study.StudyMaterial material;

  const MaterialCardWidget({super.key, required this.material});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Theme.of(
                    context,
                  ).colorScheme.secondaryContainer.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  material.type == study.MaterialType.image
                      ? Icons.image
                      : Icons.text_snippet,
                  color: Theme.of(context).colorScheme.secondary,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TitleMediumText(
                      material.title,
                      fontWeight: FontWeight.w600,
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                    BodySmallText(
                      material.difficultyLevel,
                      color: Theme.of(
                        context,
                      ).colorScheme.onSurface.withValues(alpha: 0.6),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color:
                      material.status == study.MaterialStatus.completed
                          ? Theme.of(context).colorScheme.secondary
                          : Theme.of(context).colorScheme.outline,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  material.status == study.MaterialStatus.completed
                      ? Icons.check
                      : Icons.access_time,
                  color: Theme.of(context).colorScheme.onSecondary,
                  size: 16,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class EmptyMaterialsWidget extends StatelessWidget {
  const EmptyMaterialsWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(32.0),
      decoration: BoxDecoration(
        color: Theme.of(
          context,
        ).colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Icon(
            Icons.library_books,
            size: 64,
            color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.4),
          ),
          const SizedBox(height: 16),
          TitleMediumText(
            AppLocalizations.of(context)!.noStudyMaterials,
            fontWeight: FontWeight.w600,
            color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
          ),
          const SizedBox(height: 8),
          BodyMediumText(
            AppLocalizations.of(context)!.noStudyMaterialsDescription,
            color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.5),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
