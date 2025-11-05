import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:share_plus/share_plus.dart';
import 'math_text_widget.dart';

class ExpressionSharingWidget extends StatelessWidget {
  final String expression;
  final String? title;
  final String? description;

  const ExpressionSharingWidget({
    super.key,
    required this.expression,
    this.title,
    this.description,
  });

  static void shareExpression(
    BuildContext context, {
    required String expression,
    String? title,
    String? description,
  }) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => ExpressionSharingWidget(
        expression: expression,
        title: title,
        description: description,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle bar
          Container(
            width: 40,
            height: 4,
            margin: const EdgeInsets.symmetric(vertical: 12),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          
          // Title
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              children: [
                Icon(
                  Icons.share_outlined,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(width: 12),
                Text(
                  'Share Expression',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const Spacer(),
                IconButton(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: const Icon(Icons.close),
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 16),
          
          // Expression preview
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 20),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surfaceContainer,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.3),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (title != null) ...[
                  Text(
                    title!,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 8),
                ],
                
                // Mathematical expression
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surface,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: MathTextWidget(
                    expression,
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      height: 1.5,
                    ),
                  ),
                ),
                
                if (description != null) ...[
                  const SizedBox(height: 8),
                  Text(
                    description!,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
                    ),
                  ),
                ],
              ],
            ),
          ),
          
          const SizedBox(height: 24),
          
          // Sharing options
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              children: [
                // Copy to clipboard
                _buildSharingOption(
                  context,
                  icon: Icons.copy_outlined,
                  title: 'Copy Expression',
                  subtitle: 'Copy LaTeX expression to clipboard',
                  onTap: () => _copyToClipboard(context),
                ),
                
                const SizedBox(height: 12),
                
                // Share as text
                _buildSharingOption(
                  context,
                  icon: Icons.text_fields_outlined,
                  title: 'Share as Text',
                  subtitle: 'Share the mathematical expression',
                  onTap: () => _shareAsText(context),
                ),
                
                const SizedBox(height: 12),
                
                // Share formatted
                _buildSharingOption(
                  context,
                  icon: Icons.format_quote_outlined,
                  title: 'Share Formatted',
                  subtitle: 'Share with title and description',
                  onTap: () => _shareFormatted(context),
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _buildSharingOption(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          border: Border.all(
            color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.3),
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primaryContainer,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                icon,
                size: 20,
                color: Theme.of(context).colorScheme.onPrimaryContainer,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.arrow_forward_ios,
              size: 16,
              color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.5),
            ),
          ],
        ),
      ),
    );
  }

  void _copyToClipboard(BuildContext context) {
    Clipboard.setData(ClipboardData(text: expression));
    Navigator.of(context).pop();
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Expression copied to clipboard'),
        duration: const Duration(seconds: 2),
        backgroundColor: Theme.of(context).colorScheme.primaryContainer,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _shareAsText(BuildContext context) {
    Navigator.of(context).pop();
    
    SharePlus.instance.share(ShareParams(
      text: expression,
      subject: title ?? 'Mathematical Expression',
    ));
  }

  void _shareFormatted(BuildContext context) {
    Navigator.of(context).pop();
    
    final formattedText = _buildFormattedText();
    
    SharePlus.instance.share(ShareParams(
      text: formattedText,
      subject: title ?? 'Mathematical Expression',
    ));
  }

  String _buildFormattedText() {
    final buffer = StringBuffer();
    
    if (title != null) {
      buffer.writeln(title!);
      buffer.writeln('');
    }
    
    buffer.writeln('Mathematical Expression:');
    buffer.writeln(expression);
    
    if (description != null) {
      buffer.writeln('');
      buffer.writeln('Description:');
      buffer.writeln(description!);
    }
    
    buffer.writeln('');
    buffer.writeln('Generated with Math AI - Your Mathematical Problem Solver');
    
    return buffer.toString();
  }
}