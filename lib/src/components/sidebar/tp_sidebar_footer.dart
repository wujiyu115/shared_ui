import 'package:flutter/material.dart';

import '../../theme/tp_theme.dart';
import 'tp_sidebar_icon_collapse.dart';

/// Sticky bottom slot inside [TpSidebar] (non-scrolling).
class TpSidebarFooter extends StatelessWidget {
  const TpSidebarFooter({
    super.key,
    required this.child,
    this.padding,
  });

  final Widget child;
  final EdgeInsetsGeometry? padding;

  @override
  Widget build(BuildContext context) {
    final spacing = context.tpSpacing;
    final collapsed = hideInIconCollapse(context);
    return Padding(
      padding: padding ??
          (collapsed
              ? EdgeInsets.symmetric(vertical: spacing.xs)
              : EdgeInsets.all(spacing.sm)),
      child: child,
    );
  }
}
