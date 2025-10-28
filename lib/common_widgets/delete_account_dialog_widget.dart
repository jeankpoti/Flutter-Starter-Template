import 'package:flutter/material.dart';
import '../features/account/presentation/account_cubit.dart';
import 'app_snackbar_widget.dart';
import 'text_widgets.dart';
import '../l10n/app_localizations.dart';

class DeleteAccountDialogWidget extends StatefulWidget {
  final AccountCubit accountCubit;

  const DeleteAccountDialogWidget({
    super.key,
    required this.accountCubit,
  });

  @override
  State<DeleteAccountDialogWidget> createState() => _DeleteAccountDialogWidgetState();

  static Future<void> show(BuildContext context, AccountCubit accountCubit) async {
    await showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return DeleteAccountDialogWidget(accountCubit: accountCubit);
      },
    );
  }
}

class _DeleteAccountDialogWidgetState extends State<DeleteAccountDialogWidget> {
  String _confirmText = '';

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: Theme.of(context).colorScheme.surface,
      title: BodyMediumText(
        AppLocalizations.of(context)!.deleteAccount,
      ),
      content: Column(
        spacing: 16,
        mainAxisSize: MainAxisSize.min,
        children: [
          BodyMediumText(
            AppLocalizations.of(context)!.deleteAccountConfirmation,
          ),
          TextField(
            onChanged: (value) => _confirmText = value,
            style: TextStyle(
              color: Theme.of(context).colorScheme.secondary,
            ),
            cursorColor: Theme.of(context).colorScheme.secondary,
            decoration: InputDecoration(
              hintText: AppLocalizations.of(context)!.typeDeleteHint,
              fillColor: Theme.of(context).colorScheme.secondary,
              labelStyle: TextStyle(
                color: Theme.of(context).colorScheme.secondary,
              ),
              focusColor: Colors.white,
              hintStyle: Theme.of(context).textTheme.titleMedium!,
              enabledBorder: UnderlineInputBorder(
                borderSide: BorderSide(
                  color: Theme.of(context).colorScheme.secondary,
                ),
              ),
              focusedBorder: UnderlineInputBorder(
                borderSide: BorderSide(
                  color: Theme.of(context).colorScheme.secondary,
                ),
              ),
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(
            AppLocalizations.of(context)!.cancel,
            style: Theme.of(context).textTheme.bodyMedium!,
          ),
        ),
        TextButton(
          onPressed: () async {
            if (_confirmText == AppLocalizations.of(context)!.deleteText) {
              Navigator.pop(context);
              await widget.accountCubit.deleteUserWithHisData(context);
            } else {
              AppSnackBar.showError(
                context,
                AppLocalizations.of(context)!.deleteConfirmationError,
              );
            }
          },
          child: Text(
            AppLocalizations.of(context)!.deleteAccount,
            style: Theme.of(context).textTheme.bodyMedium!,
          ),
        ),
      ],
    );
  }
}