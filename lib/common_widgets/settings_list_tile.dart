import 'package:flutter/material.dart';

class SettingsListTile extends StatelessWidget {
  final String text;
  final Widget icon;
  final Switch? switcher;
  final void Function()? onTap;

  const SettingsListTile({
    super.key,
    required this.text,
    required this.icon,
    this.switcher,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: Theme.of(context).colorScheme.primary..withValues(),
          ),
        ),
      ),
      child: ListTile(
        leading: icon,
        title: Text(
          text,
          style: Theme.of(context).textTheme.bodyMedium!.copyWith(
            color: Theme.of(context).colorScheme.primary,
          ),
        ),
        trailing: switcher,
        onTap: onTap,
      ),
    );
  }
}
