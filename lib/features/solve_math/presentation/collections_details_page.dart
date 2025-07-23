import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:share_plus/share_plus.dart';
import '../../../common_widgets/math_markdown_widget.dart';
import 'home_page.dart';

import '../../../common_widgets/app_bar_widget.dart';
import '../../../common_widgets/body_small_text_widget.dart';
import '../../../common_widgets/elevated_button_widget.dart';
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
      appBar: AppBarWidget(title: 'Problems Details'),
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
                      child: collection.imageUrl != null && collection.imageUrl!.isNotEmpty
                          ? Image.network(
                              collection.imageUrl!,
                              fit: BoxFit.cover,
                              width: 100,
                              height: 120,
                              errorBuilder:
                                  (context, error, stackTrace) =>
                                const Icon(Icons.image_not_supported),
                            )
                          : const Icon(Icons.image_not_supported),
                    ),
                  ),
                  const SizedBox(height: 45),

                  MathMarkdownWidget(data: collection.solution ?? ''),

                  const SizedBox(height: 32),

                  // Copy and Share buttons
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButtonWidget(
                          text: 'Copy Solution',
                          onPressed: () async {
                            try {
                              await Clipboard.setData(
                                ClipboardData(text: collection.solution ?? ''),
                              );
                              if (context.mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text(
                                      'Solution copied to clipboard!',
                                    ),
                                    duration: Duration(seconds: 2),
                                  ),
                                );
                              }
                            } catch (e) {
                              if (context.mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('Unable to copy solution'),
                                    duration: Duration(seconds: 2),
                                  ),
                                );
                              }
                            }
                          },
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: ElevatedButtonWidget(
                          text: 'Share Solution',
                          onPressed: () async {
                            try {
                              final String shareText =
                                  "Math Problem Solution:\n\n${collection.solution ?? ''}";

                              if (collection.imageUrl != null &&
                                  collection.imageUrl!.isNotEmpty) {
                                // Share with image if available
                                await Share.share(
                                  shareText,
                                  subject: 'Math Problem Solution',
                                );
                              } else {
                                // Share text only
                                await Share.share(
                                  shareText,
                                  subject: 'Math Problem Solution',
                                );
                              }
                            } catch (e) {
                              if (context.mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('Unable to share solution'),
                                    duration: Duration(seconds: 2),
                                  ),
                                );
                              }
                            }
                          },
                        ),
                      ),
                    ],
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
          text: 'Math AI can make mistakes, so double check the solution!',
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}
