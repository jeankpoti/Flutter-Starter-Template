import 'package:flutter/material.dart';

import 'text_widgets.dart';

class AppBarWidget extends StatelessWidget implements PreferredSizeWidget {
  final String? title;
  final bool? isAction;
  const AppBarWidget({super.key, this.title, this.isAction});

  @override
  // final Size preferredSize = const Size.fromHeight(kToolbarHeight);
  final Size preferredSize = const Size.fromHeight(50);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      toolbarHeight: preferredSize.height,
      elevation: 0,
      title: TitleLargeText(title ?? ""),
      // centerTitle: true,
      backgroundColor: Colors.transparent,

      // actions: isAction == true ? [] : null,
    );
  }
}
