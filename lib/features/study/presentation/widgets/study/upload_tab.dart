import 'package:flutter/material.dart';
import '../../../../../l10n/app_localizations.dart';
import '../../../../../common_widgets/text_widgets.dart';
import '../../../domain/models/study_material.dart' as study;
import '../../../../../common_widgets/math_symbols_widget.dart';

class UploadTab extends StatelessWidget {
  final bool isProcessing;
  final List<study.StudyMaterial> studyMaterials;
  final VoidCallback onPhotoUpload;
  final VoidCallback onGalleryUpload;
  final VoidCallback onTextInput;

  const UploadTab({
    super.key,
    required this.isProcessing,
    required this.studyMaterials,
    required this.onPhotoUpload,
    required this.onGalleryUpload,
    required this.onTextInput,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _UploadHeader(),
          const SizedBox(height: 32.0),
          if (isProcessing) ...[
            const _ProcessingIndicator(),
            const SizedBox(height: 24.0),
          ],
          _UploadOptions(
            isProcessing: isProcessing,
            onPhotoUpload: onPhotoUpload,
            onGalleryUpload: onGalleryUpload,
            onTextInput: onTextInput,
          ),
          const SizedBox(height: 32.0),
          _RecentUploadsSection(studyMaterials: studyMaterials),
        ],
      ),
    );
  }
}

class _UploadHeader extends StatelessWidget {
  const _UploadHeader();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Theme.of(
              context,
            ).colorScheme.secondaryContainer.withValues(alpha: 0.3),
            Theme.of(
              context,
            ).colorScheme.tertiaryContainer.withValues(alpha: 0.2),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.auto_awesome,
                color: Theme.of(context).colorScheme.secondary,
                size: 28,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: HeadlineSmallText(
                  AppLocalizations.of(context)!.uploadYourStudyMaterial,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          BodyMediumText(
            AppLocalizations.of(context)!.uploadDescription,
            color: Theme.of(
              context,
            ).colorScheme.onSurface.withValues(alpha: 0.8),
          ),
        ],
      ),
    );
  }
}

class _ProcessingIndicator extends StatelessWidget {
  const _ProcessingIndicator();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Theme.of(context).colorScheme.secondary.withValues(alpha: 0.2),
          width: 1,
        ),
      ),
      child: Column(
        children: [
          Row(
            children: [
              SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2.5,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    Theme.of(context).colorScheme.secondary,
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TitleMediumText(
                      AppLocalizations.of(context)!.processingYourMaterial,
                      fontWeight: FontWeight.w600,
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                    const SizedBox(height: 4),
                    BodySmallText(
                      AppLocalizations.of(context)!.processingDescription,
                      color: Theme.of(
                        context,
                      ).colorScheme.onSurface.withValues(alpha: 0.7),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          LinearProgressIndicator(
            backgroundColor: Theme.of(
              context,
            ).colorScheme.outline.withValues(alpha: 0.2),
            valueColor: AlwaysStoppedAnimation<Color>(
              Theme.of(context).colorScheme.secondary,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              _ProcessingStep(
                emoji: '📷',
                label: AppLocalizations.of(context)!.uploadStep,
                isCompleted: true,
              ),
              _ProcessingStep(
                emoji: '🔍',
                label: AppLocalizations.of(context)!.analyzeStep,
                isCompleted: true,
              ),
              _ProcessingStep(
                emoji: '📚',
                label: AppLocalizations.of(context)!.generatePlan,
                isCompleted: false,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ProcessingStep extends StatelessWidget {
  final String emoji;
  final String label;
  final bool isCompleted;

  const _ProcessingStep({
    required this.emoji,
    required this.label,
    required this.isCompleted,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color:
                  isCompleted
                      ? Theme.of(
                        context,
                      ).colorScheme.secondary.withValues(alpha: 0.1)
                      : Theme.of(
                        context,
                      ).colorScheme.outline.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color:
                    isCompleted
                        ? Theme.of(context).colorScheme.secondary
                        : Theme.of(
                          context,
                        ).colorScheme.outline.withValues(alpha: 0.3),
                width: 1,
              ),
            ),
            child: Center(
              child:
                  isCompleted
                      ? Icon(
                        Icons.check,
                        size: 16,
                        color: Theme.of(context).colorScheme.secondary,
                      )
                      : LabelSmallText(emoji),
            ),
          ),
          const SizedBox(height: 4),
          LabelSmallText(
            label,
            color:
                isCompleted
                    ? Theme.of(context).colorScheme.secondary
                    : Theme.of(
                      context,
                    ).colorScheme.onSurface.withValues(alpha: 0.6),
            fontWeight: isCompleted ? FontWeight.w600 : FontWeight.normal,
          ),
        ],
      ),
    );
  }
}

class _UploadOptions extends StatelessWidget {
  final bool isProcessing;
  final VoidCallback onPhotoUpload;
  final VoidCallback onGalleryUpload;
  final VoidCallback onTextInput;

  const _UploadOptions({
    required this.isProcessing,
    required this.onPhotoUpload,
    required this.onGalleryUpload,
    required this.onTextInput,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _UploadOption(
          icon: Icons.camera_alt,
          title: AppLocalizations.of(context)!.takePhoto,
          subtitle: AppLocalizations.of(context)!.takePhotoSubtitle,
          onTap: onPhotoUpload,
          isDisabled: isProcessing,
        ),
        const SizedBox(height: 16),
        _UploadOption(
          icon: Icons.photo_library,
          title: AppLocalizations.of(context)!.uploadFromGallery,
          subtitle:
              '${AppLocalizations.of(context)!.uploadFromGallerySubtitle} (Max 5 images per selection)',
          onTap: onGalleryUpload,
          isDisabled: isProcessing,
        ),
        const SizedBox(height: 16),
        _UploadOption(
          icon: Icons.edit_note,
          title: AppLocalizations.of(context)!.typeMaterial,
          subtitle: AppLocalizations.of(context)!.typeMaterialSubtitle,
          onTap: onTextInput,
          isDisabled: isProcessing,
        ),
      ],
    );
  }
}

class _UploadOption extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;
  final bool isDisabled;

  const _UploadOption({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
    required this.isDisabled,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color:
            isDisabled
                ? Theme.of(context).colorScheme.surface.withValues(alpha: 0.5)
                : Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color:
              isDisabled
                  ? Theme.of(context).colorScheme.outline.withValues(alpha: 0.1)
                  : Theme.of(
                    context,
                  ).colorScheme.outline.withValues(alpha: 0.2),
        ),
      ),
      child: InkWell(
        onTap: isDisabled ? null : onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Theme.of(
                    context,
                  ).colorScheme.secondaryContainer.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  icon,
                  color:
                      isDisabled
                          ? Theme.of(
                            context,
                          ).colorScheme.secondary.withValues(alpha: 0.4)
                          : Theme.of(context).colorScheme.secondary,
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TitleMediumText(
                      title,
                      fontWeight: FontWeight.w600,
                      color:
                          isDisabled
                              ? Theme.of(
                                context,
                              ).colorScheme.onSurface.withValues(alpha: 0.4)
                              : Theme.of(context).colorScheme.onSurface,
                    ),
                    const SizedBox(height: 4),
                    BodySmallText(
                      subtitle,
                      color:
                          isDisabled
                              ? Theme.of(
                                context,
                              ).colorScheme.onSurface.withValues(alpha: 0.3)
                              : Theme.of(
                                context,
                              ).colorScheme.onSurface.withValues(alpha: 0.7),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.arrow_forward_ios,
                color:
                    isDisabled
                        ? Theme.of(
                          context,
                        ).colorScheme.onSurface.withValues(alpha: 0.2)
                        : Theme.of(
                          context,
                        ).colorScheme.onSurface.withValues(alpha: 0.4),
                size: 16,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _RecentUploadsSection extends StatelessWidget {
  final List<study.StudyMaterial> studyMaterials;

  const _RecentUploadsSection({required this.studyMaterials});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TitleMediumText(
          AppLocalizations.of(context)!.recentUploads,
          fontWeight: FontWeight.bold,
          color: Theme.of(context).colorScheme.onSurface,
        ),
        const SizedBox(height: 16),
        if (studyMaterials.isEmpty)
          const _EmptyUploads()
        else
          SizedBox(
            height: 120,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: studyMaterials.length,
              itemBuilder: (context, index) {
                final material = studyMaterials[index];
                return _RecentUploadCard(material: material);
              },
            ),
          ),
      ],
    );
  }
}

class _EmptyUploads extends StatelessWidget {
  const _EmptyUploads();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24.0),
      decoration: BoxDecoration(
        color: Theme.of(
          context,
        ).colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Icon(
            Icons.upload_file,
            size: 48,
            color: Theme.of(
              context,
            ).colorScheme.onSurface.withValues(alpha: 0.4),
          ),
          const SizedBox(height: 12),
          BodyMediumText(
            AppLocalizations.of(context)!.noMaterialsUploaded,
            color: Theme.of(
              context,
            ).colorScheme.onSurface.withValues(alpha: 0.6),
          ),
          const SizedBox(height: 8),
          BodySmallText(
            AppLocalizations.of(context)!.uploadFirstMaterial,
            color: Theme.of(
              context,
            ).colorScheme.onSurface.withValues(alpha: 0.5),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class _RecentUploadCard extends StatelessWidget {
  final study.StudyMaterial material;

  const _RecentUploadCard({required this.material});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 140,
      margin: const EdgeInsets.only(right: 12),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.3),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  material.type == study.MaterialType.image
                      ? Icons.image
                      : Icons.text_snippet,
                  color: Theme.of(context).colorScheme.secondary,
                  size: 20,
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.all(2),
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
                    size: 12,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  BodySmallText(
                    material.title,
                    fontWeight: FontWeight.w600,
                    color: Theme.of(context).colorScheme.onSurface,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  LabelSmallText(
                    '${material.extractedTopics.length} ${AppLocalizations.of(context)!.topics}',
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

class TextInputDialog extends StatefulWidget {
  const TextInputDialog({super.key});

  @override
  State<TextInputDialog> createState() => _TextInputDialogState();
}

class _TextInputDialogState extends State<TextInputDialog> {
  final TextEditingController _textController = TextEditingController();

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: TitleLargeText(AppLocalizations.of(context)!.addStudyMaterial),
      content: SizedBox(
        width: double.maxFinite,
        height: 500,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              BodyMediumText(
                AppLocalizations.of(context)!.enterStudyMaterialText,
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _textController,
                maxLines: 6,
                decoration: InputDecoration(
                  hintText: AppLocalizations.of(context)!.pasteOrTypeHint,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  alignLabelWithHint: true,
                ),
              ),
              const SizedBox(height: 16),
              MathSymbolsWidget(controller: _textController),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: LabelLargeText(AppLocalizations.of(context)!.cancel),
        ),
        ElevatedButton(
          onPressed: () async {
            if (_textController.text.trim().isNotEmpty) {
              Navigator.of(context).pop(_textController.text.trim());
            }
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: Theme.of(context).colorScheme.secondary,
          ),
          child: LabelLargeText(
            AppLocalizations.of(context)!.addMaterial,
            color: Theme.of(context).colorScheme.onSecondary,
          ),
        ),
      ],
    );
  }
}
