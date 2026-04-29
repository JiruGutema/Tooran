import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

/// Hairline-bordered surface card. Replaces the previous frosted-glass
/// container with a flat, paper-like surface in keeping with the new
/// design tokens. Kept under the original name to avoid touching every
/// import site.
class GlassContainer extends StatelessWidget {
  const GlassContainer({
    super.key,
    required this.child,
    this.padding,
    this.margin,
    this.borderRadius = const BorderRadius.all(Radius.circular(AppTheme.rMd)),
  });

  final Widget child;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final BorderRadius borderRadius;

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      margin: margin,
      padding: padding,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: borderRadius,
        border: Border.all(color: AppTheme.hairline(dark), width: 1),
      ),
      child: child,
    );
  }
}
