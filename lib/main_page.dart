import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'l10n/app_localizations.dart';

import 'features/solve_math/presentation/collections_page.dart';
import 'features/solve_math/presentation/home_page.dart';
import 'features/study/presentation/study_page.dart';
import 'settings_page.dart';
import 'theme/theme_cubit.dart';
import 'utils/responsive.dart';
import 'common_widgets/text_widgets.dart';

class MainPage extends StatefulWidget {
  const MainPage({super.key});

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

    // Bottom Navigation Bar Items
    items.add(
      BottomNavigationBarItem(
        backgroundColor: Theme.of(context).colorScheme.surface,
        icon: Icon(CupertinoIcons.function),
        label: AppLocalizations.of(context)!.solve,
      ),
    );
    items.add(
      BottomNavigationBarItem(
        backgroundColor: Theme.of(context).colorScheme.surface,
        icon: Icon(CupertinoIcons.book),
        label: AppLocalizations.of(context)!.study,
      ),
    );
    items.add(
      BottomNavigationBarItem(
        backgroundColor: Theme.of(context).colorScheme.surface,
        icon: Icon(CupertinoIcons.time),
        label: AppLocalizations.of(context)!.history,
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
        icon: Icon(CupertinoIcons.function),
        selectedIcon: Icon(CupertinoIcons.function),
        label: LabelSmallText(AppLocalizations.of(context)!.solve),
      ),
    );
    railItems.add(
      NavigationRailDestination(
        icon: Icon(CupertinoIcons.book),
        selectedIcon: Icon(CupertinoIcons.book),
        label: LabelSmallText(AppLocalizations.of(context)!.study),
      ),
    );
    railItems.add(
      NavigationRailDestination(
        icon: Icon(CupertinoIcons.time),
        selectedIcon: Icon(CupertinoIcons.time),
        label: LabelSmallText(AppLocalizations.of(context)!.history),
      ),
    );

    railItems.add(
      NavigationRailDestination(
        icon: Icon(CupertinoIcons.settings),
        selectedIcon: Icon(CupertinoIcons.settings),
        // indicatorColor: Colors.amber,
        label: LabelSmallText(AppLocalizations.of(context)!.settings),
      ),
    );
  }

  List<Widget> _buildScreens() {
    return [
      const HomePage(),
      const StudyPage(),
      const CollectionsPage(),
      const SettingsPage(),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final isDesktop = Responsive.isDesktop(context);
    final screens = _buildScreens();

    // Ensure selectedIndex is within valid range
    if (selectedIndex >= screens.length) {
      selectedIndex = 0;
    }

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
                onDestinationSelected: (int index) {
                  setState(() {
                    selectedIndex = index.clamp(0, screens.length - 1);
                  });
                },
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
          Expanded(
            flex: 13,
            child: IndexedStack(index: selectedIndex, children: screens),
          ),
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
                type: BottomNavigationBarType.fixed, // Add this line
                showUnselectedLabels: true,
                currentIndex: selectedIndex,
                onTap: (int index) {
                  setState(() {
                    selectedIndex = index.clamp(0, screens.length - 1);
                  });
                },
                items: items,
              )
              : null,
    );
  }
}
