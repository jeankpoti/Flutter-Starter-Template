// import 'package:flutter/material.dart';
// import '../../../../common_widgets/text_widgets.dart';

// class StatChip extends StatelessWidget {
//   final IconData icon;
//   final String label;

//   const StatChip({super.key, required this.icon, required this.label});

//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
//       decoration: BoxDecoration(
//         color: Theme.of(context).colorScheme.surface.withOpacity(0.8),
//         borderRadius: BorderRadius.circular(20),
//       ),
//       child: Row(
//         mainAxisSize: MainAxisSize.min,
//         children: [
//           Icon(icon, size: 16, color: Theme.of(context).colorScheme.secondary),
//           const SizedBox(width: 6),
//           LabelSmallText(
//             label,
//             fontWeight: FontWeight.w600,
//             color: Theme.of(context).colorScheme.onSurface,
//           ),
//         ],
//       ),
//     );
//   }
// }
