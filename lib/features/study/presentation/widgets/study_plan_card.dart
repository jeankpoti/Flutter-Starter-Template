import 'package:flutter/material.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../../common_widgets/text_widgets.dart';
import '../../domain/models/study_plan.dart';
import 'stat_chip.dart';

// class StudyPlanCard extends StatelessWidget {
//   final StudyPlan plan;
//   final VoidCallback onDelete;
//   final VoidCallback onShowTopics;
//   final VoidCallback onStartQuiz;
//   final bool isProcessing;

//   const StudyPlanCard({
//     super.key,
//     required this.plan,
//     required this.onDelete,
//     required this.onShowTopics,
//     required this.onStartQuiz,
//     required this.isProcessing,
//   });

//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       width: 280,
//       height: 250,
//       margin: const EdgeInsets.only(right: 16),
//       child: Card(
//         elevation: 2,
//         child: InkWell(
//           onTap: onShowTopics,
//           borderRadius: BorderRadius.circular(12),
//           child: Container(
//             padding: const EdgeInsets.all(12),
//             decoration: BoxDecoration(
//               gradient: LinearGradient(
//                 colors: [
//                   Theme.of(
//                     context,
//                   ).colorScheme.secondaryContainer.withOpacity(0.3),
//                   Theme.of(
//                     context,
//                   ).colorScheme.tertiaryContainer.withOpacity(0.2),
//                 ],
//                 begin: Alignment.topLeft,
//                 end: Alignment.bottomRight,
//               ),
//               borderRadius: BorderRadius.circular(12),
//             ),
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 _StudyPlanCardHeader(plan: plan, onDelete: onDelete),
//                 const SizedBox(height: 6),
//                 _StudyPlanCardDetails(plan: plan, onShowTopics: onShowTopics),
//                 const Spacer(),
//                 _StudyPlanCardActions(
//                   onShowTopics: onShowTopics,
//                   onStartQuiz: onStartQuiz,
//                   isProcessing: isProcessing,
//                 ),
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }

// class _StudyPlanCardHeader extends StatelessWidget {
//   final StudyPlan plan;
//   final VoidCallback onDelete;

//   const _StudyPlanCardHeader({required this.plan, required this.onDelete});

//   @override
//   Widget build(BuildContext context) {
//     return Row(
//       children: [
//         Icon(
//           Icons.auto_awesome,
//           color: Theme.of(context).colorScheme.secondary,
//           size: 20,
//         ),
//         const SizedBox(width: 8),
//         Expanded(
//           child: TitleMediumText(
//             plan.title,
//             fontWeight: FontWeight.bold,
//             color: Theme.of(context).colorScheme.onSurface,
//             maxLines: 2,
//             overflow: TextOverflow.ellipsis,
//           ),
//         ),
//         PopupMenuButton<String>(
//           icon: Icon(
//             Icons.more_vert,
//             color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
//             size: 20,
//           ),
//           onSelected: (value) {
//             if (value == 'delete') {
//               onDelete();
//             }
//           },
//           itemBuilder:
//               (context) => [
//                 PopupMenuItem(
//                   value: 'delete',
//                   child: LabelLargeText(
//                     AppLocalizations.of(context)!.deletePlan,
//                   ),
//                 ),
//               ],
//         ),
//       ],
//     );
//   }
// }

// class _StudyPlanCardDetails extends StatelessWidget {
//   final StudyPlan plan;
//   final VoidCallback onShowTopics;

//   const _StudyPlanCardDetails({required this.plan, required this.onShowTopics});

//   @override
//   Widget build(BuildContext context) {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         BodySmallText(
//           plan.description,
//           color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
//           maxLines: 3,
//           overflow: TextOverflow.ellipsis,
//         ),
//         const SizedBox(height: 12),
//         InkWell(
//           onTap: onShowTopics,
//           borderRadius: BorderRadius.circular(4),
//           child: Padding(
//             padding: const EdgeInsets.symmetric(vertical: 4),
//             child: Row(
//               children: [
//                 Expanded(
//                   child: LinearProgressIndicator(
//                     value: plan.calculateProgress() / 100,
//                     backgroundColor: Theme.of(
//                       context,
//                     ).colorScheme.outline.withOpacity(0.3),
//                     valueColor: AlwaysStoppedAnimation<Color>(
//                       Theme.of(context).colorScheme.secondary,
//                     ),
//                   ),
//                 ),
//                 const SizedBox(width: 8),
//                 LabelSmallText(
//                   '${plan.calculateProgress().toStringAsFixed(0)}%',
//                   fontWeight: FontWeight.w600,
//                   color: Theme.of(context).colorScheme.secondary,
//                 ),
//                 const SizedBox(width: 4),
//                 Icon(
//                   Icons.arrow_forward_ios,
//                   size: 12,
//                   color: Theme.of(context).colorScheme.secondary,
//                 ),
//               ],
//             ),
//           ),
//         ),
//         const SizedBox(height: 8),
//         Row(
//           children: [
//             Flexible(
//               child: StatChip(
//                 icon: Icons.list_alt,
//                 label:
//                     '${plan.topics.length} ${AppLocalizations.of(context)!.topics}',
//               ),
//             ),
//             const SizedBox(width: 6),
//             Flexible(
//               child: StatChip(
//                 icon: Icons.schedule,
//                 label: '${plan.totalEstimatedHours}h',
//               ),
//             ),
//           ],
//         ),
//       ],
//     );
//   }
// }

// class _StudyPlanCardActions extends StatelessWidget {
//   final VoidCallback onShowTopics;
//   final VoidCallback onStartQuiz;
//   final bool isProcessing;

//   const _StudyPlanCardActions({
//     required this.onShowTopics,
//     required this.onStartQuiz,
//     required this.isProcessing,
//   });

//   @override
//   Widget build(BuildContext context) {
//     return Row(
//       children: [
//         Expanded(
//           child: TextButton.icon(
//             onPressed: onShowTopics,
//             icon: const Icon(Icons.list, size: 16),
//             label: LabelMediumText(
//               AppLocalizations.of(context)!.viewTopics,
//               color: Theme.of(context).colorScheme.onSurface,
//             ),
//             style: TextButton.styleFrom(
//               foregroundColor: Theme.of(context).colorScheme.secondary,
//               padding: const EdgeInsets.symmetric(vertical: 6),
//             ),
//           ),
//         ),
//         const SizedBox(width: 4),
//         Expanded(
//           child: ElevatedButton(
//             onPressed: isProcessing ? null : onStartQuiz,
//             style: ElevatedButton.styleFrom(
//               backgroundColor:
//                   isProcessing
//                       ? Theme.of(context).colorScheme.secondary.withOpacity(0.6)
//                       : Theme.of(context).colorScheme.secondary,
//               foregroundColor: Theme.of(context).colorScheme.onSecondary,
//               padding: const EdgeInsets.symmetric(vertical: 6),
//               shape: RoundedRectangleBorder(
//                 borderRadius: BorderRadius.circular(8),
//               ),
//             ),
//             child:
//                 isProcessing
//                     ? Row(
//                       mainAxisAlignment: MainAxisAlignment.center,
//                       children: [
//                         const SizedBox(
//                           width: 10,
//                           height: 10,
//                           child: CircularProgressIndicator(
//                             strokeWidth: 2,
//                             valueColor: AlwaysStoppedAnimation<Color>(
//                               Colors.white,
//                             ),
//                           ),
//                         ),
//                         const SizedBox(width: 6),
//                         LabelSmallText(AppLocalizations.of(context)!.loading),
//                       ],
//                     )
//                     : LabelMediumText(AppLocalizations.of(context)!.takeQuiz),
//           ),
//         ),
//       ],
//     );
//   }
// }
