import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import '../../../../common_widgets/text_widgets.dart';
import '../../domain/models/study_plan.dart';

class StudyPlanCardWidget extends StatelessWidget {
  final StudyPlan plan;
  final VoidCallback onTap;
  final VoidCallback onDelete;
  final VoidCallback onGenerateQuiz;

  const StudyPlanCardWidget({
    super.key,
    required this.plan,
    required this.onTap,
    required this.onDelete,
    required this.onGenerateQuiz,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 280,
      height: 250,
      margin: const EdgeInsets.only(right: 16),
      child: Card(
        elevation: 2,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Theme.of(context).colorScheme.secondaryContainer.withValues(alpha: 0.3),
                  Theme.of(context).colorScheme.tertiaryContainer.withValues(alpha: 0.2),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeader(context),
                const SizedBox(height: 6),
                _buildDescription(context),
                const SizedBox(height: 12),
                _buildProgressIndicator(context),
                const SizedBox(height: 8),
                _buildStats(context),
                const Spacer(),
                _buildActionButtons(context),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Row(
      children: [
        Icon(
          Icons.auto_awesome,
          color: Theme.of(context).colorScheme.secondary,
          size: 20,
        ),
        const SizedBox(width: 8),
        Expanded(
          child: TitleMediumText(
            plan.title,
            fontWeight: FontWeight.bold,
            color: Theme.of(context).colorScheme.onSurface,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        PopupMenuButton<String>(
          icon: Icon(
            Icons.more_vert,
            color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
            size: 20,
          ),
          onSelected: (value) {
            if (value == 'delete') {
              onDelete();
            }
          },
          itemBuilder: (context) => [
            PopupMenuItem(
              value: 'delete',
              child: LabelLargeText(
                AppLocalizations.of(context)!.deletePlan,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildDescription(BuildContext context) {
    return BodySmallText(
      plan.description,
      color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
      maxLines: 3,
      overflow: TextOverflow.ellipsis,
    );
  }

  Widget _buildProgressIndicator(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(4),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Row(
          children: [
            Expanded(
              child: LinearProgressIndicator(
                value: plan.calculateProgress() / 100,
                backgroundColor: Theme.of(context).colorScheme.outline.withValues(alpha: 0.3),
                valueColor: AlwaysStoppedAnimation<Color>(
                  Theme.of(context).colorScheme.secondary,
                ),
              ),
            ),
            const SizedBox(width: 8),
            LabelSmallText(
              '${plan.calculateProgress().toStringAsFixed(0)}%',
              fontWeight: FontWeight.w600,
              color: Theme.of(context).colorScheme.secondary,
            ),
            const SizedBox(width: 4),
            Icon(
              Icons.arrow_forward_ios,
              size: 12,
              color: Theme.of(context).colorScheme.secondary,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStats(BuildContext context) {
    return Row(
      children: [
        Flexible(
          child: _buildStatChip(
            context,
            icon: Icons.list_alt,
            label: '${plan.topics.length} ${AppLocalizations.of(context)!.topics}',
          ),
        ),
        const SizedBox(width: 6),
        Flexible(
          child: _buildStatChip(
            context,
            icon: Icons.schedule,
            label: '${plan.totalEstimatedHours}h',
          ),
        ),
      ],
    );
  }

  Widget _buildStatChip(BuildContext context, {required IconData icon, required String label}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface.withValues(alpha: 0.8),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 12,
            color: Theme.of(context).colorScheme.secondary,
          ),
          const SizedBox(width: 3),
          Flexible(
            child: LabelSmallText(
              label,
              color: Theme.of(context).colorScheme.onSurface,
              fontWeight: FontWeight.w500,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: TextButton.icon(
            onPressed: onTap,
            icon: const Icon(Icons.list, size: 16),
            label: LabelSmallText(
              AppLocalizations.of(context)!.viewTopics,
              color: Theme.of(context).colorScheme.secondary,
            ),
            style: TextButton.styleFrom(
              foregroundColor: Theme.of(context).colorScheme.secondary,
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              minimumSize: Size.zero,
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
          ),
        ),
        const SizedBox(width: 4),
        Expanded(
          child: TextButton.icon(
            onPressed: onGenerateQuiz,
            icon: const Icon(Icons.quiz, size: 16),
            label: LabelSmallText(
              AppLocalizations.of(context)!.quiz,
              color: Theme.of(context).colorScheme.secondary,
            ),
            style: TextButton.styleFrom(
              foregroundColor: Theme.of(context).colorScheme.secondary,
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              minimumSize: Size.zero,
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
          ),
        ),
      ],
    );
  }
}