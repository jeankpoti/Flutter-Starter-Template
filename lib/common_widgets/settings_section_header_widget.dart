import 'package:flutter/material.dart';
import 'text_widgets.dart';

class SettingsSectionHeaderWidget extends StatelessWidget {
  final String title;
  final IconData? icon;
  final EdgeInsets? margin;
  final bool isDeco;

  const SettingsSectionHeaderWidget({
    super.key,
    required this.title,
    this.icon,
    this.margin,
    required this.isDeco,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: margin ?? const EdgeInsets.fromLTRB(16, 24, 16, 8),
      decoration:
          isDeco
              ? BoxDecoration(
                border: Border(
                  top: BorderSide(
                    color: Theme.of(context).colorScheme.primary..withValues(),
                  ),
                ),
              )
              : BoxDecoration(backgroundBlendMode: BlendMode.clear),
      child: Padding(
        padding: const EdgeInsets.only(top: 16.0),
        child: Row(
          children: [
            if (icon != null) ...[
              Icon(
                icon,
                size: 20,
                color: Theme.of(context).colorScheme.secondary,
              ),
              const SizedBox(width: 12),
            ],
            Expanded(
              child: TitleMediumText(
                title,
                color: Theme.of(context).colorScheme.secondary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
