import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:math_ai/common_widgets/elevated_button_widget.dart';
import 'package:math_ai/common_widgets/text_widgets.dart';
import 'package:math_ai/features/common/presentation/permission_cubit.dart';
import 'package:math_ai/l10n/app_localizations.dart';

class TrackingPermissionDialog extends StatelessWidget {
  const TrackingPermissionDialog({super.key});

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;
    
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      contentPadding: const EdgeInsets.all(24),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.analytics_outlined,
            size: 64,
            color: Theme.of(context).colorScheme.primary,
          ),
          const SizedBox(height: 16),
          HeadlineSmallText(
            localizations.trackingPermissionTitle,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 12),
          BodyLargeText(
            localizations.trackingPermissionDescription,
            textAlign: TextAlign.center,
            color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  style: OutlinedButton.styleFrom(
                    minimumSize: const Size(double.infinity, 48),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: () async {
                    // User declined - just close the dialog
                    Navigator.of(context).pop();
                  },
                  child: Text(localizations.notNow),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButtonWidget(
                  onPressed: () async {
                    final permissionCubit = context.read<PermissionCubit>();
                    await permissionCubit.requestTrackingPermission();
                    if (context.mounted) {
                      Navigator.of(context).pop();
                    }
                  },
                  text: localizations.allow,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}