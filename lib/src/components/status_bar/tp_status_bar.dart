import 'package:flutter/material.dart';

import '../../theme/tp_text_styles.dart';

/// App-shell bottom status strip (VS Code / Orca shape): a hairline-topped row
/// with items grouped at the leading and trailing edges.
///
/// The package owns geometry and interaction states only — every label, icon
/// and callback comes from the host, so product copy and the data behind each
/// item stay in the app. Items are plain widgets; [TpStatusBarItem] is the
/// ready-made one but callers may pass any widget with the same height.
class TpStatusBar extends StatelessWidget {
  const TpStatusBar({
    super.key,
    this.start = const [],
    this.end = const [],
    this.height = kHeight,
    this.background,
    this.borderColor,
  });

  /// Design baseline height. Not scaled by the UI font multiplier: a status
  /// strip that grows with text would push the workbench content around.
  static const double kHeight = 26;

  final List<Widget> start;
  final List<Widget> end;
  final double height;

  /// Defaults to [ColorScheme.surfaceContainerLow].
  final Color? background;

  /// Defaults to a 50%-alpha [ColorScheme.outlineVariant].
  final Color? borderColor;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      height: height,
      decoration: BoxDecoration(
        color: background ?? cs.surfaceContainerLow,
        border: Border(
          top: BorderSide(
            color: borderColor ?? cs.outlineVariant.withValues(alpha: 0.5),
          ),
        ),
      ),
      // Baseline-align so icon and label items share a text baseline; the
      // leading group takes the slack so the trailing group stays flush right.
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(children: start),
            ),
          ),
          Row(mainAxisSize: MainAxisSize.min, children: end),
        ],
      ),
    );
  }
}

/// One status-bar entry: optional glyph plus label, ellipsized when the bar
/// runs out of room.
///
/// With [onTap] it becomes an inline button with a hover fill; without one it
/// is static text (still able to carry a [tooltip]).
class TpStatusBarItem extends StatelessWidget {
  const TpStatusBarItem({
    super.key,
    required this.label,
    this.icon,
    this.tooltip,
    this.onTap,
    this.color,
    this.trailing,
    this.selected = false,
    this.maxWidth,
  });

  final String label;
  final IconData? icon;

  /// Full text for truncated labels and for detail that does not fit the bar
  /// (e.g. a blame line's commit hash and author email).
  final String? tooltip;
  final VoidCallback? onTap;

  /// Defaults to [ColorScheme.onSurfaceVariant].
  final Color? color;

  /// Rendered after the label, e.g. a change count.
  final Widget? trailing;

  /// Tints the row with the primary container (an active filter/mode).
  final bool selected;

  /// Caps the item width so a long blame subject cannot starve its neighbours.
  final double? maxWidth;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final styles = TpTextStyles.of(context);
    final fg = selected
        ? cs.onPrimaryContainer
        : (color ?? cs.onSurfaceVariant);

    // The leading group can sit inside a horizontal scroll view, so no
    // [Flexible] here (unbounded width + flex is an assertion). A width cap on
    // the text is what makes the ellipsis kick in.
    Widget content = ConstrainedBox(
      constraints: BoxConstraints(maxWidth: maxWidth ?? 420),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[
              Icon(icon, size: 12, color: fg),
              const SizedBox(width: 4),
            ],
            Flexible(
              child: Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: styles.xsColored(fg),
              ),
            ),
            if (trailing != null) ...[const SizedBox(width: 4), trailing!],
          ],
        ),
      ),
    );

    if (onTap != null) {
      content = _StatusBarTap(
        onTap: onTap!,
        selected: selected,
        borderRadius: BorderRadius.zero,
        child: content,
      );
    } else if (selected) {
      content = ColoredBox(
        color: cs.primaryContainer.withValues(alpha: 0.35),
        child: content,
      );
    }

    final message = tooltip;
    if (message != null && message.isNotEmpty) {
      content = Tooltip(
        message: message,
        waitDuration: const Duration(milliseconds: 400),
        child: content,
      );
    }
    return content;
  }
}

/// Hover/press fill for a tappable status item. Deliberately small: the bar is
/// 26 px tall, so an ink splash would spill past the strip.
class _StatusBarTap extends StatefulWidget {
  const _StatusBarTap({
    required this.onTap,
    required this.selected,
    required this.borderRadius,
    required this.child,
  });

  final VoidCallback onTap;
  final bool selected;
  final BorderRadius borderRadius;
  final Widget child;

  @override
  State<_StatusBarTap> createState() => _StatusBarTapState();
}

class _StatusBarTapState extends State<_StatusBarTap> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final fill = widget.selected
        ? cs.primaryContainer.withValues(alpha: _hovered ? 0.55 : 0.35)
        : (_hovered
              ? cs.onSurface.withValues(alpha: 0.08)
              : Colors.transparent);
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: widget.onTap,
        child: ColoredBox(color: fill, child: widget.child),
      ),
    );
  }
}
