import 'package:flutter/material.dart';
import '../../../../../l10n/app_localizations.dart';

class ModernTabBarWidget extends StatelessWidget {
  final TabController tabController;

  static const double _spacing6 = 24.0;

  const ModernTabBarWidget({super.key, required this.tabController});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 50,
      margin: const EdgeInsets.only(bottom: _spacing6),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(16.0),
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).colorScheme.shadow.withValues(alpha: 0.08),
            offset: const Offset(0, 4),
            blurRadius: 12.0,
            spreadRadius: 0,
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
        ).colorScheme.onSurface.withValues(alpha: 0.6),
        indicatorSize: TabBarIndicatorSize.tab,
        dividerColor: Colors.transparent,
        labelStyle: Theme.of(
          context,
        ).textTheme.labelLarge?.copyWith(fontWeight: FontWeight.w600),
        tabs: [
          Tab(
            icon: const Icon(Icons.camera_alt_outlined),
            text: AppLocalizations.of(context)!.photo,
            height: 60,
          ),
          Tab(
            icon: const Icon(Icons.edit_outlined),
            text: AppLocalizations.of(context)!.text,
            height: 60,
          ),
          Tab(
            icon: const Icon(Icons.mic_outlined),
            text: 'Voice',
            height: 60,
          ),
        ],
      ),
    );
  }
}
