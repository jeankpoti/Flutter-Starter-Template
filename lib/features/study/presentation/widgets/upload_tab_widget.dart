import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import '../../../../common_widgets/text_widgets.dart';
import '../../domain/models/study_material.dart';

class UploadTabWidget extends StatelessWidget {
  final bool isProcessing;
  final bool isUploadingText;
  final bool isUploadingPhoto;
  final bool isUploadingFile;
  final List<StudyMaterial> recentMaterials;
  final VoidCallback onTakePhoto;
  final VoidCallback onUploadPhoto;
  final VoidCallback onUploadFile;
  final VoidCallback onTextInput;
  final Function(StudyMaterial) onMaterialTap;

  const UploadTabWidget({
    super.key,
    required this.isProcessing,
    required this.isUploadingText,
    required this.isUploadingPhoto,
    required this.isUploadingFile,
    required this.recentMaterials,
    required this.onTakePhoto,
    required this.onUploadPhoto,
    required this.onUploadFile,
    required this.onTextInput,
    required this.onMaterialTap,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (isProcessing) _buildProcessingIndicator(context),
          const SizedBox(height: 24),
          _buildUploadOptions(context),
          const SizedBox(height: 32),
          _buildRecentUploadsSection(context),
        ],
      ),
    );
  }

  Widget _buildProcessingIndicator(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primaryContainer.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.3),
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
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    Theme.of(context).colorScheme.primary,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: TitleMediumText(
                  AppLocalizations.of(context)!.analyzingContent,
                  fontWeight: FontWeight.w600,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _buildProcessingSteps(context),
        ],
      ),
    );
  }

  Widget _buildProcessingSteps(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _buildProcessingStep(context, '📄', AppLocalizations.of(context)!.extracting, true),
        _buildProcessingStep(context, '🤖', AppLocalizations.of(context)!.analyzing, true),
        _buildProcessingStep(context, '✨', AppLocalizations.of(context)!.generating, false),
      ],
    );
  }

  Widget _buildProcessingStep(BuildContext context, String emoji, String label, bool isCompleted) {
    return Column(
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: isCompleted
                ? Theme.of(context).colorScheme.primary.withValues(alpha: 0.2)
                : Theme.of(context).colorScheme.surface,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: isCompleted
                  ? Theme.of(context).colorScheme.primary
                  : Theme.of(context).colorScheme.outline.withValues(alpha: 0.3),
            ),
          ),
          child: Center(
            child: isCompleted
                ? Text(
                    emoji,
                    style: const TextStyle(fontSize: 18),
                  )
                : SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        Theme.of(context).colorScheme.primary,
                      ),
                    ),
                  ),
          ),
        ),
        const SizedBox(height: 6),
        LabelSmallText(
          label,
          color: isCompleted
              ? Theme.of(context).colorScheme.primary
              : Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
          fontWeight: isCompleted ? FontWeight.w600 : FontWeight.normal,
        ),
      ],
    );
  }

  Widget _buildUploadOptions(BuildContext context) {
    return Column(
      children: [
        _buildUploadOption(
          context,
          icon: Icons.camera_alt,
          title: AppLocalizations.of(context)!.takePhoto,
          subtitle: AppLocalizations.of(context)!.takePhotoSubtitle,
          onTap: onTakePhoto,
          isLoading: isUploadingPhoto,
        ),
        const SizedBox(height: 16),
        _buildUploadOption(
          context,
          icon: Icons.photo_library,
          title: AppLocalizations.of(context)!.uploadPhoto,
          subtitle: AppLocalizations.of(context)!.uploadFromGallery,
          onTap: onUploadPhoto,
          isLoading: isUploadingPhoto,
        ),
        const SizedBox(height: 16),
        _buildUploadOption(
          context,
          icon: Icons.insert_drive_file,
          title: AppLocalizations.of(context)!.uploadFile,
          subtitle: AppLocalizations.of(context)!.uploadFileSubtitle,
          onTap: onUploadFile,
          isLoading: isUploadingFile,
        ),
        const SizedBox(height: 16),
        _buildUploadOption(
          context,
          icon: Icons.edit,
          title: AppLocalizations.of(context)!.typeText,
          subtitle: AppLocalizations.of(context)!.typeTextSubtitle,
          onTap: onTextInput,
          isLoading: isUploadingText,
        ),
      ],
    );
  }

  Widget _buildUploadOption({
    required BuildContext context,
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    required bool isLoading,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.2),
        ),
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).colorScheme.shadow.withValues(alpha: 0.05),
            offset: const Offset(0, 2),
            blurRadius: 8,
            spreadRadius: 0,
          ),
        ],
      ),
      child: InkWell(
        onTap: isLoading ? null : onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.secondaryContainer.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: isLoading
                    ? Center(
                        child: SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              Theme.of(context).colorScheme.secondary,
                            ),
                          ),
                        ),
                      )
                    : Icon(
                        icon,
                        color: Theme.of(context).colorScheme.secondary,
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
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                    const SizedBox(height: 4),
                    BodySmallText(
                      subtitle,
                      color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.arrow_forward_ios,
                color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.4),
                size: 16,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRecentUploadsSection(BuildContext context) {
    if (recentMaterials.isEmpty) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          HeadlineSmallText(
            AppLocalizations.of(context)!.recentUploads,
            fontWeight: FontWeight.bold,
            color: Theme.of(context).colorScheme.onSurface,
          ),
          const SizedBox(height: 16),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surfaceContainer.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.2),
              ),
            ),
            child: Column(
              children: [
                Icon(
                  Icons.upload_file,
                  size: 48,
                  color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.4),
                ),
                const SizedBox(height: 12),
                TitleMediumText(
                  AppLocalizations.of(context)!.noRecentUploads,
                  color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
                ),
                const SizedBox(height: 4),
                BodySmallText(
                  AppLocalizations.of(context)!.uploadFirstMaterial,
                  color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.5),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ],
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        HeadlineSmallText(
          AppLocalizations.of(context)!.recentUploads,
          fontWeight: FontWeight.bold,
          color: Theme.of(context).colorScheme.onSurface,
        ),
        const SizedBox(height: 16),
        ...recentMaterials.take(3).map((material) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: _buildRecentMaterialCard(context, material),
            )),
      ],
    );
  }

  Widget _buildRecentMaterialCard(BuildContext context, StudyMaterial material) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.2),
        ),
      ),
      child: InkWell(
        onTap: () => onMaterialTap(material),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Icon(
                material.type == MaterialType.text ? Icons.text_snippet : Icons.image,
                color: Theme.of(context).colorScheme.secondary,
                size: 20,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TitleSmallText(
                      material.title,
                      fontWeight: FontWeight.w600,
                      color: Theme.of(context).colorScheme.onSurface,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    BodySmallText(
                      '${material.extractedTopics.length} ${AppLocalizations.of(context)!.topics}',
                      color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.arrow_forward_ios,
                color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.4),
                size: 14,
              ),
            ],
          ),
        ),
      ),
    );
  }
}