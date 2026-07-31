import 'package:flutter/material.dart';

import '../../theme/tp_theme.dart';
import 'tp_sidebar_icon_collapse.dart';

/// Sticky top slot inside [TpSidebar] (non-scrolling).
class TpSidebarHeader extends StatelessWidget {
  const TpSidebarHeader({
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
