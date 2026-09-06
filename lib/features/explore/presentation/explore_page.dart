import 'package:flutter/material.dart';
import '../../../common_widgets/app_bar_widget.dart';
import '../../../common_widgets/text_widgets.dart';
import '../../../l10n/app_localizations.dart';

class ExplorePage extends StatelessWidget {
  const ExplorePage({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBarWidget(title: l10n.explore),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Search Bar
              _buildSearchBar(context, l10n),
              const SizedBox(height: 24),

              // Categories
              _buildCategories(context, l10n),
              const SizedBox(height: 24),

              // Featured Content
              _buildFeaturedContent(context, l10n),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSearchBar(BuildContext context, AppLocalizations l10n) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainer,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.2),
        ),
      ),
      child: Row(
        children: [
          Icon(
            Icons.search_rounded,
            color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.5),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: TextField(
              decoration: InputDecoration(
                hintText: l10n.searchPlaceholder,
                border: InputBorder.none,
                hintStyle: TextStyle(
                  color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.5),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategories(BuildContext context, AppLocalizations l10n) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TitleMediumText(
          l10n.categories,
          fontWeight: FontWeight.bold,
        ),
        const SizedBox(height: 16),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              _CategoryChip(
                icon: Icons.all_inclusive,
                label: l10n.all,
                isSelected: true,
              ),
              const SizedBox(width: 8),
              _CategoryChip(
                icon: Icons.trending_up_rounded,
                label: l10n.popular,
                isSelected: false,
              ),
              const SizedBox(width: 8),
              _CategoryChip(
                icon: Icons.new_releases_rounded,
                label: l10n.newCategory,
                isSelected: false,
              ),
              const SizedBox(width: 8),
              _CategoryChip(
                icon: Icons.bookmark_rounded,
                label: l10n.saved,
                isSelected: false,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildFeaturedContent(BuildContext context, AppLocalizations l10n) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TitleMediumText(
          l10n.featuredContent,
          fontWeight: FontWeight.bold,
        ),
        const SizedBox(height: 16),
        _ContentCard(
          title: l10n.contentItemOne,
          description: l10n.contentItemOneDescription,
          icon: Icons.article_rounded,
        ),
        const SizedBox(height: 12),
        _ContentCard(
          title: l10n.contentItemTwo,
          description: l10n.contentItemTwoDescription,
          icon: Icons.play_circle_rounded,
        ),
        const SizedBox(height: 12),
        _ContentCard(
          title: l10n.contentItemThree,
          description: l10n.contentItemThreeDescription,
          icon: Icons.quiz_rounded,
        ),
      ],
    );
  }
}

class _CategoryChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isSelected;

  const _CategoryChip({
    required this.icon,
    required this.label,
    required this.isSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: isSelected
            ? Theme.of(context).colorScheme.primary
            : Theme.of(context).colorScheme.surfaceContainer,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isSelected
              ? Theme.of(context).colorScheme.primary
              : Theme.of(context).colorScheme.outline.withValues(alpha: 0.2),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 18,
            color: isSelected
                ? Theme.of(context).colorScheme.onPrimary
                : Theme.of(context).colorScheme.onSurface,
          ),
          const SizedBox(width: 8),
          LabelMediumText(
            label,
            color: isSelected
                ? Theme.of(context).colorScheme.onPrimary
                : Theme.of(context).colorScheme.onSurface,
            fontWeight: FontWeight.w500,
          ),
        ],
      ),
    );
  }
}

class _ContentCard extends StatelessWidget {
  final String title;
  final String description;
  final IconData icon;

  const _ContentCard({
    required this.title,
    required this.description,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.1),
        ),
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).colorScheme.shadow.withValues(alpha: 0.05),
            offset: const Offset(0, 2),
            blurRadius: 8,
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.secondaryContainer,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              icon,
              color: Theme.of(context).colorScheme.onSecondaryContainer,
              size: 24,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TitleSmallText(
                  title,
                  fontWeight: FontWeight.w600,
                ),
                const SizedBox(height: 4),
                BodySmallText(
                  description,
                  color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          Icon(
            Icons.chevron_right_rounded,
            color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.3),
          ),
        ],
      ),
    );
  }
}
