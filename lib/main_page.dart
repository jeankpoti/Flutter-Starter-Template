import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'l10n/app_localizations.dart';

import 'theme/theme_cubit.dart';
import 'utils/responsive.dart';
import 'common_widgets/text_widgets.dart';

class MainPage extends StatefulWidget {
  final Widget child;

  const MainPage({super.key, required this.child});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  List<BottomNavigationBarItem> items = [];
  List<NavigationRailDestination> railItems = [];

  int selectedIndex = 0;

  @override
  void initState() {
    super.initState();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    // Clear lists to prevent duplicates when widget rebuilds
    items = [];
    railItems = [];

    // Bottom Navigation Bar Items - 3 tabs: Home, Explore, Settings
    items.add(
      BottomNavigationBarItem(
        backgroundColor: Theme.of(context).colorScheme.surface,
        icon: Icon(CupertinoIcons.home),
        label: AppLocalizations.of(context)!.home,
      ),
    );
    items.add(
      BottomNavigationBarItem(
        backgroundColor: Theme.of(context).colorScheme.surface,
        icon: Icon(CupertinoIcons.compass),
        label: AppLocalizations.of(context)!.explore,
      ),
    );
    items.add(
      BottomNavigationBarItem(
        backgroundColor: Theme.of(context).colorScheme.surface,
        icon: Icon(CupertinoIcons.settings),
        label: AppLocalizations.of(context)!.settings,
      ),
    );

    // Navigation Rail Items - ensure they match the same number as bottom nav items
    railItems.add(
      NavigationRailDestination(
        icon: Icon(CupertinoIcons.home),
        selectedIcon: Icon(CupertinoIcons.home),
        label: LabelSmallText(AppLocalizations.of(context)!.home),
      ),
    );
    railItems.add(
      NavigationRailDestination(
        icon: Icon(CupertinoIcons.compass),
        selectedIcon: Icon(CupertinoIcons.compass),
        label: LabelSmallText(AppLocalizations.of(context)!.explore),
      ),
    );
    railItems.add(
      NavigationRailDestination(
        icon: Icon(CupertinoIcons.settings),
        selectedIcon: Icon(CupertinoIcons.settings),
        label: LabelSmallText(AppLocalizations.of(context)!.settings),
      ),
    );
  }

  int _calculateSelectedIndex(BuildContext context) {
    final String location = GoRouterState.of(context).uri.toString();
    if (location.startsWith('/explore')) {
      return 1;
    }
    if (location.startsWith('/settings')) {
      return 2;
    }
    return 0;
  }

  void _onItemTapped(int index, BuildContext context) {
    switch (index) {
      case 0:
        context.go('/');
        break;
      case 1:
        context.go('/explore');
        break;
      case 2:
        context.go('/settings');
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDesktop = Responsive.isDesktop(context);
    selectedIndex = _calculateSelectedIndex(context);

    return Scaffold(
      body: Row(
        children: [
          if (isDesktop)
            Expanded(
              flex: 1,
              child: NavigationRail(
                elevation: 5,
                backgroundColor: Theme.of(context).colorScheme.surface,
                selectedIndex: selectedIndex,
                onDestinationSelected:
                    (int index) => _onItemTapped(index, context),
                labelType: NavigationRailLabelType.selected,
                leading: Padding(
                  padding: const EdgeInsets.only(
                    left: 8,
                    top: 8.0,
                    right: 8,
                    bottom: 32,
                  ),
                  child: TitleLargeText('LOGO'),
                ),
                destinations: railItems,
              ),
            ),
          Expanded(flex: 13, child: widget.child),
        ],
      ),
      bottomNavigationBar:
          !isDesktop
              ? BottomNavigationBar(
                backgroundColor: Theme.of(context).colorScheme.surface,
                selectedItemColor:
                    BlocProvider.of<ThemeCubit>(context).state.brightness ==
                            Brightness.dark
                        ? Theme.of(context).colorScheme.tertiary
                        : Theme.of(context).colorScheme.secondary,
                type: BottomNavigationBarType.fixed,
                showUnselectedLabels: true,
                currentIndex: selectedIndex,
                onTap: (int index) => _onItemTapped(index, context),
                items: items,
              )
              : null,
    );
  }
}
