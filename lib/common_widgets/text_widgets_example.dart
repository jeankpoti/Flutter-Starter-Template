import 'package:flutter/material.dart';
import 'text_widgets.dart';

/// Example page demonstrating all text widgets and their usage
/// This serves as both documentation and a visual reference
class TextWidgetsExamplePage extends StatelessWidget {
  const TextWidgetsExamplePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const TitleLargeText('Text Widgets Example'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Display Text Examples
            _buildSection(
              'Display Text (Hero/Large Headings)',
              [
                const DisplayLargeText('Display Large - Hero Text'),
                const SizedBox(height: 8),
                const DisplayMediumText('Display Medium - Major Headlines'),
                const SizedBox(height: 8),
                const DisplaySmallText('Display Small - Section Headers'),
                const SizedBox(height: 16),
                const LabelSmallText('Loading states:'),
                const SizedBox(height: 8),
                const LoadingDisplayLargeText(width: 300),
              ],
            ),

            // Title Text Examples
            _buildSection(
              'Title Text (Card/Component Headers)',
              [
                const TitleLargeText('Title Large - Card Headers'),
                const SizedBox(height: 8),
                const TitleMediumText('Title Medium - Component Titles'),
                const SizedBox(height: 8),
                const TitleSmallText('Title Small - List Item Headers'),
                const SizedBox(height: 16),
                const LabelSmallText('Loading states:'),
                const SizedBox(height: 8),
                const LoadingTitleLargeText(width: 200),
                const SizedBox(height: 8),
                const LoadingTitleMediumText(width: 150),
              ],
            ),

            // Body Text Examples
            _buildSection(
              'Body Text (Main Content)',
              [
                const BodyLargeText('Body Large - Main content, important descriptions'),
                const SizedBox(height: 8),
                const BodyMediumText(
                  'Body Medium - Standard content, paragraphs, explanations. This is the most commonly used text style for readable content.',
                ),
                const SizedBox(height: 8),
                const BodySmallText(
                  'Body Small - Supporting text, captions, secondary information that needs to be readable but less prominent.',
                ),
                const SizedBox(height: 16),
                const LabelSmallText('Loading states:'),
                const SizedBox(height: 8),
                const LoadingBodyLargeText(width: 300, lines: 2),
                const SizedBox(height: 8),
                const LoadingBodyMediumText(width: 280, lines: 3),
                const SizedBox(height: 8),
                const LoadingBodySmallText(width: 200, lines: 2),
              ],
            ),

            // Usage Guidelines
            _buildSection(
              'Usage Guidelines',
              [
                const BodyMediumText(
                  '• Use Display text for hero sections and major page headers\n'
                  '• Use Title text for cards, components, and list items\n'
                  '• Use Body text for main content and descriptions\n'
                  '• Use Label text for buttons, form labels, and UI elements\n'
                  '• Always prefer semantic widgets over custom Text() widgets\n'
                  '• Use loading states during data fetching for better UX',
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSection(String title, List<Widget> children) {
    return Container(
      margin: const EdgeInsets.only(bottom: 32),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border.all(
          color: Colors.grey.withValues(alpha: 0.3),
        ),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TitleMediumText(
            title,
            fontWeight: FontWeight.bold,
          ),
          const SizedBox(height: 16),
          ...children,
        ],
      ),
    );
  }
}