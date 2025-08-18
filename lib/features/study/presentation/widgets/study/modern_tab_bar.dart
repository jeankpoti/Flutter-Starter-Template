import 'package:flutter/material.dart';
import '../../../../../l10n/app_localizations.dart';

class ModernTabBar extends StatelessWidget {
  final TabController tabController;

  const ModernTabBar({super.key, required this.tabController});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 50,
      margin: const EdgeInsets.only(bottom: 24.0),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(16.0),

        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            offset: const Offset(0, 4),
            blurRadius: 12.0,
          ),
        ],
      ),
      child: TabBar(
        controller: tabController,
        indicator: BoxDecoration(
          borderRadius: BorderRadius.circular(16.0),
          color: Theme.of(context).colorScheme.secondaryContainer,
        ),
        labelColor: Theme.of(context).colorScheme.onSecondaryContainer,
        unselectedLabelColor: Theme.of(
          context,
        ).colorScheme.onSurface.withOpacity(0.6),
        indicatorSize: TabBarIndicatorSize.tab,
        dividerColor: Colors.transparent,
        labelStyle: Theme.of(
          context,
        ).textTheme.labelLarge?.copyWith(fontWeight: FontWeight.w600),
        tabs: [
          Tab(
            icon: const Icon(Icons.upload_file_outlined),
            text: AppLocalizations.of(context)!.uploadTab,
            height: 60,
          ),
          Tab(
            icon: const Icon(Icons.library_books_outlined),
            text: AppLocalizations.of(context)!.myMaterialsTab,
            height: 60,
          ),
        ],
      ),
    );
  }
}
