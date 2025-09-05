import 'package:flutter/material.dart';
import '../../../../../l10n/app_localizations.dart';

class FlashcardOptionsModalWidget extends StatelessWidget {
  final VoidCallback onManual;
  final VoidCallback onCamera;
  final VoidCallback onGallery;
  final VoidCallback onFile;

  const FlashcardOptionsModalWidget({
    super.key,
    required this.onManual,
    required this.onCamera,
    required this.onGallery,
    required this.onFile,
  });

  static void show(
    BuildContext context, {
    required VoidCallback onManual,
    required VoidCallback onCamera,
    required VoidCallback onGallery,
    required VoidCallback onFile,
  }) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => FlashcardOptionsModalWidget(
        onManual: onManual,
        onCamera: onCamera,
        onGallery: onGallery,
        onFile: onFile,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.4),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            AppLocalizations.of(context)!.addNewFlashcard,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            AppLocalizations.of(context)!.chooseCreationMethod,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          
          _buildOption(
            context,
            icon: Icons.edit_rounded,
            title: AppLocalizations.of(context)!.createManually,
            subtitle: AppLocalizations.of(context)!.typeQuestionAndAnswer,
            onTap: () {
              Navigator.pop(context);
              onManual();
            },
          ),
          
          const SizedBox(height: 16),
          
          _buildOption(
            context,
            icon: Icons.camera_alt_rounded,
            title: AppLocalizations.of(context)!.takePhoto,
            subtitle: AppLocalizations.of(context)!.captureContentWithCamera,
            onTap: () {
              Navigator.pop(context);
              onCamera();
            },
          ),
          
          const SizedBox(height: 16),
          
          _buildOption(
            context,
            icon: Icons.photo_library_rounded,
            title: AppLocalizations.of(context)!.uploadPhoto,
            subtitle: AppLocalizations.of(context)!.selectImageFromGallery,
            onTap: () {
              Navigator.pop(context);
              onGallery();
            },
          ),
          
          const SizedBox(height: 16),
          
          _buildOption(
            context,
            icon: Icons.upload_file_rounded,
            title: AppLocalizations.of(context)!.uploadFile,
            subtitle: AppLocalizations.of(context)!.importFromDocument,
            onTap: () {
              Navigator.pop(context);
              onFile();
            },
          ),
          
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildOption(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            border: Border.all(
              color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.2),
            ),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.secondary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(24),
                ),
                child: Icon(
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
                    Text(
                      title,
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.arrow_forward_ios_rounded,
                size: 16,
                color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.4),
              ),
            ],
          ),
        ),
      ),
    );
  }
}