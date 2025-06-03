import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';

import '../../../common_widgets/app_bar_widget.dart';
import '../../../common_widgets/body_small_text_widget.dart';
import '../../../utils/responsive.dart';
import '../domain/models/collection.dart';

class CollectionsDetailsPage extends StatelessWidget {
  Collection collection;
  final String? imageUrl;
  final String? desc;
  CollectionsDetailsPage({
    super.key,
    this.imageUrl,
    this.desc,
    required this.collection,
  });

  @override
  Widget build(BuildContext context) {
    final isTablet = Responsive.isTablet(context);

    return Scaffold(
      appBar: AppBarWidget(title: 'Animals Details'),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 16.0,
                vertical: 32.0,
              ),
              child: Column(
                // mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                // spacing: 45,
                children: [
                  Container(
                    width: double.infinity,
                    height: isTablet ? 600 : 300,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          spreadRadius: 2,
                          blurRadius: 5,
                          offset: const Offset(
                            0,
                            3,
                          ), // changes position of shadow
                        ),
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(20),
                      child: Image.network(
                        collection.imageUrl ?? '',
                        fit: BoxFit.cover,
                        width: 100,
                        height: 120,
                        errorBuilder:
                            (context, error, stackTrace) =>
                                const Icon(Icons.image_not_supported),
                      ),
                    ),
                  ),
                  const SizedBox(height: 45),

                  MarkdownBody(
                    data: collection.description ?? '',
                    selectable: true,
                    styleSheet: MarkdownStyleSheet.fromTheme(
                      Theme.of(context),
                    ).copyWith(
                      p: Theme.of(context).textTheme.bodyMedium,
                      h1: Theme.of(context).textTheme.titleLarge,
                      h2: Theme.of(context).textTheme.titleMedium,
                      h3: Theme.of(context).textTheme.titleSmall,
                      listBullet: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.only(
          left: 32.0,
          top: 16.0,
          right: 32.0,
          bottom: 32.0,
        ),
        child: BodySmallTextWidget(
          text: 'Snap Animal AI can make mistakes, so double check it!',
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}
