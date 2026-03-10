import 'package:flutter/material.dart';

class FormattedText extends StatelessWidget {
  final String text;
  final TextStyle? style;

  const FormattedText({super.key, required this.text, this.style});

  @override
  Widget build(BuildContext context) {
    if (text.isEmpty) return const SizedBox.shrink();

    final theme = Theme.of(context);
    final baseStyle =
        style ?? theme.textTheme.bodyMedium ?? const TextStyle();
    final lines = text.split('\n');

    List<Widget> widgets = [];

    for (final line in lines) {
      final trimmed = line.trim();

      if (trimmed.isEmpty) {
        widgets.add(const SizedBox(height: 8));
        continue;
      }

      // Bullet point
      if (trimmed.startsWith('• ') || trimmed.startsWith('- ')) {
        final content = trimmed.substring(2);
        widgets.add(
          Padding(
            padding: const EdgeInsets.only(left: 4, bottom: 6),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.only(top: 7, right: 10),
                  child: Container(
                    width: 6,
                    height: 6,
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primary.withOpacity(0.7),
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
                Expanded(
                  child: Text(content, style: baseStyle),
                ),
              ],
            ),
          ),
        );
        continue;
      }

      // Numbered list
      final numMatch = RegExp(r'^(\d+)\.\s(.*)').firstMatch(trimmed);
      if (numMatch != null) {
        final number = numMatch.group(1)!;
        final content = numMatch.group(2)!;
        widgets.add(
          Padding(
            padding: const EdgeInsets.only(left: 4, bottom: 6),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  width: 28,
                  child: Text(
                    '$number.',
                    style: baseStyle.copyWith(
                      fontWeight: FontWeight.w700,
                      color: theme.colorScheme.primary,
                    ),
                  ),
                ),
                Expanded(
                  child: Text(content, style: baseStyle),
                ),
              ],
            ),
          ),
        );
        continue;
      }

      // Section divider
      if (trimmed == '---') {
        widgets.add(
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Divider(
              color: theme.dividerColor.withOpacity(0.3),
              thickness: 1,
            ),
          ),
        );
        continue;
      }

      // Regular text
      widgets.add(
        Padding(
          padding: const EdgeInsets.only(bottom: 4),
          child: Text(trimmed, style: baseStyle),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: widgets,
    );
  }
}
