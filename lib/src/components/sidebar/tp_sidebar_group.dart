import 'package:flutter/material.dart';

import '../../theme/tp_text_styles.dart';
import '../../theme/tp_theme.dart';
import '../icon_button/tp_icon_button.dart';
import 'tp_sidebar_icon_collapse.dart';

/// Padded section inside [TpSidebarContent] for a label, optional action, and
/// menu block.
class TpSidebarGroup extends StatelessWidget {
  const TpSidebarGroup({
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

/// Small section label above a [TpSidebarGroupContent] block.
class TpSidebarGroupLabel extends StatelessWidget {
  const TpSidebarGroupLabel({
    super.key,
    required this.label,
    this.padding,
  });

  final String label;
  final EdgeInsetsGeometry? padding;

  @override
  Widget build(BuildContext context) {
    if (hideInIconCollapse(context)) {
      return const SizedBox.shrink();
    }

    final spacing = context.tpSpacing;
    final cs = Theme.of(context).colorScheme;
    final styles = TpTextStyles.of(context);

    return Padding(
      padding: padding ??
          EdgeInsets.fromLTRB(spacing.sm, spacing.xs, spacing.sm, spacing.xxs),
      child: SizedBox(
        height: 24,
        child: Align(
          alignment: Alignment.centerLeft,
          child: Text(
            label,
            style: styles.xsTrackColored(
              cs.onSurfaceVariant.withValues(alpha: 0.85),
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ),
    );
  }
}

/// Trailing icon action for a [TpSidebarGroup] header row.
class TpSidebarGroupAction extends StatelessWidget {
  const TpSidebarGroupAction({
    super.key,
    required this.icon,
    this.onPressed,
    this.tooltip,
  });

  final IconData icon;
  final VoidCallback? onPressed;
  final String? tooltip;

  @override
  Widget build(BuildContext context) {
    if (hideInIconCollapse(context)) {
      return const SizedBox.shrink();
    }

    return TpIconButton(
      icon: icon,
      onTap: onPressed,
      tooltip: tooltip,
      compact: true,
      size: TpIconButton.kCompactSize,
    );
  }
}

/// Body slot under a group label (typically [TpSidebarMenu]).
class TpSidebarGroupContent extends StatelessWidget {
  const TpSidebarGroupContent({
    super.key,
    required this.child,
  });

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return child;
  }
}
