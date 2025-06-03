import 'package:flutter/material.dart';

import 'title_large_text_widget.dart';
import 'title_medium_text_widget.dart';

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
      title: TitleLargeTextWidget(text: title ?? ""),
      // centerTitle: true,
      backgroundColor: Theme.of(context).colorScheme.surface,

      // actions: isAction == true ? [] : null,
    );
  }
}
