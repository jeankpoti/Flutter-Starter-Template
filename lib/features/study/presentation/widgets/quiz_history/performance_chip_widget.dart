import 'package:flutter/material.dart';
import '../../../../../../common_widgets/text_widgets.dart';

class PerformanceChipWidget extends StatelessWidget {
  final IconData icon;
  final String label;
  final int value;
  final Color color;

  const PerformanceChipWidget({
    super.key,
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 16),
          const SizedBox(height: 4),
          LabelMediumText(
            value.toString(),
            fontWeight: FontWeight.bold,
            color: color,
          ),
          LabelSmallText(
            label,
            color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
          ),
        ],
      ),
    );
  }
}