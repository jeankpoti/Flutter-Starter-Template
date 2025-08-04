import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../features/common/presentation/permission_cubit.dart';
import '../l10n/app_localizations.dart';
import 'text_widgets.dart';

class PermissionDeniedDialogWidget extends StatelessWidget {
  final String permissionType;
  final VoidCallback? onSettingsPressed;

  const PermissionDeniedDialogWidget({
    super.key,
    required this.permissionType,
    this.onSettingsPressed,
  });

  static Future<void> show({
    required BuildContext context,
    required String permissionType,
  }) {
    return showDialog(
      context: context,
      barrierDismissible: false,
      builder:
          (ctx) => PermissionDeniedDialogWidget(permissionType: permissionType),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: Row(
        children: [
          Icon(
            Icons.warning_outlined,
            color: Theme.of(context).colorScheme.error,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: TitleMediumText(
              '${AppLocalizations.of(context)!.permissionDenied}: $permissionType',
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
      content: BodyMediumText(
        AppLocalizations.of(context)!.permissionDeniedMessage(permissionType),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: LabelLargeText(
            AppLocalizations.of(context)!.close,
            color: Theme.of(context).colorScheme.onSurface,
          ),
        ),
        ElevatedButton.icon(
          onPressed: () {
            Navigator.of(context).pop();
            if (onSettingsPressed != null) {
              onSettingsPressed!();
            } else {
              context.read<PermissionCubit>().openSettings();
            }
          },
          icon: Icon(
            Icons.settings,
            size: 18,
            color: Theme.of(context).colorScheme.onSecondary,
          ),
          label: LabelLargeText(
            AppLocalizations.of(context)!.openSettings,
            color: Theme.of(context).colorScheme.onSecondary,
          ),
          style: ElevatedButton.styleFrom(
            backgroundColor: Theme.of(context).colorScheme.secondary,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        ),
      ],
    );
  }
}
