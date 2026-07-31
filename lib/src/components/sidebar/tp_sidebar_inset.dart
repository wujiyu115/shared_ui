import 'package:flutter/material.dart';

import '../../theme/tp_theme.dart';

/// Main content chrome for [TpSidebarVariant.inset] layouts.
///
/// Applies theme-driven background, radius, border, and light elevation.
class TpSidebarInset extends StatelessWidget {
  const TpSidebarInset({
    super.key,
    required this.child,
  });

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final theme = context.tpTheme.sidebarTheme;
    final cs = Theme.of(context).colorScheme;
    final isDark = cs.brightness == Brightness.dark;
    final radius = BorderRadius.circular(theme.insetRadius);
    final background = theme.insetBackgroundColor ?? cs.surface;
    final borderColor = theme.borderColor ??
        cs.outlineVariant.withValues(alpha: isDark ? 0.45 : 0.55);

    return ClipRRect(
      key: const Key('tp-sidebar-inset'),
      borderRadius: radius,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: background,
          borderRadius: radius,
          border: Border.all(color: borderColor),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: isDark ? 0.28 : 0.08),
              blurRadius: 16,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: child,
      ),
    );
  }
}
