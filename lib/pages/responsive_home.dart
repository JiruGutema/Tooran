import 'package:flutter/material.dart';

import 'desktop/desktop_home_page.dart';
import 'home_page.dart';

/// Picks between mobile and desktop home layouts based on window width.
/// At ≥ 900 px (typical for an undecorated desktop window) the user gets the
/// sidebar + main pane experience; below that the existing mobile layout.
class ResponsiveHome extends StatelessWidget {
  const ResponsiveHome({super.key});

  static const double desktopBreakpoint = 900;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (_, c) {
        if (c.maxWidth >= desktopBreakpoint) return const DesktopHomePage();
        return const HomePage();
      },
    );
  }
}
