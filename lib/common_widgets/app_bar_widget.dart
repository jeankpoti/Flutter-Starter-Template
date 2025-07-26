import 'package:flutter/material.dart';

import 'text_widgets.dart';

class AppBarWidget extends StatelessWidget implements PreferredSizeWidget {
  final String? title;
  final bool? isAction;
  const AppBarWidget({super.key, this.title, this.isAction});

  @override
  // final Size preferredSize = const Size.fromHeight(kToolbarHeight);
  final Size preferredSize = const Size.fromHeight(80);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      toolbarHeight: preferredSize.height,
      elevation: 5,
      title: TitleLargeText(title ?? ""),
      // centerTitle: true,
      backgroundColor: Theme.of(context).colorScheme.surface,

      // actions: isAction == true ? [] : null,
    );
  }
}
