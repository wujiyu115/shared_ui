import 'package:flutter/material.dart';

import '../../theme/tp_text_styles.dart';
import '../../theme/tp_theme.dart';
import '../icon_button/tp_icon_button.dart';
import 'tp_dialog_mobile_nav_bar.dart';

/// One section in a [TpDialogNavShell] left nav.
class TpDialogNavEntry {
  const TpDialogNavEntry({
    required this.icon,
    required this.navLabel,
    required this.title,
    required this.subtitle,
    required this.bodyBuilder,
  });

  final IconData icon;
  final String Function(BuildContext) navLabel;
  final String Function(BuildContext) title;
  final String Function(BuildContext) subtitle;
  final WidgetBuilder bodyBuilder;
}

/// Dual-pane dialog host: side-by-side on wide, nav list → detail on narrow.
///
/// Owns SafeArea app bars on narrow. Do **not** wrap in [TpDialogPageShell].
class TpDialogNavShell extends StatefulWidget {
  const TpDialogNavShell({
    required this.navTitle,
    required this.entries,
    this.initialIndex = 0,
    this.mobileBreakpoint = 768,
    this.onClose,
    this.onSelectedIndexChanged,
    super.key,
  });

  final String Function(BuildContext) navTitle;
  final List<TpDialogNavEntry> entries;
  final int initialIndex;
  final double mobileBreakpoint;
  final VoidCallback? onClose;
  final ValueChanged<int>? onSelectedIndexChanged;

  @override
  State<TpDialogNavShell> createState() => _TpDialogNavShellState();
}

class _TpDialogNavShellState extends State<TpDialogNavShell> {
  static const double _navWidth = 220;

  late int _selectedIndex;
  final _navigatorKey = GlobalKey<NavigatorState>();

  @override
  void initState() {
    super.initState();
    _selectedIndex = widget.initialIndex.clamp(0, widget.entries.length - 1);
  }

  bool _isNarrow(BuildContext context) =>
      MediaQuery.sizeOf(context).width < widget.mobileBreakpoint;

  void _close(BuildContext context) {
    if (widget.onClose != null) {
      widget.onClose!();
      return;
    }
    Navigator.of(context, rootNavigator: true).pop();
  }

  void _selectIndex(int index) {
    if (_selectedIndex == index) return;
    setState(() => _selectedIndex = index);
    widget.onSelectedIndexChanged?.call(index);
  }

  TpDialogNavEntry get _activeEntry => widget.entries[_selectedIndex];

  @override
  Widget build(BuildContext context) {
    if (_isNarrow(context)) {
      return _buildNarrow(context);
    }
    return _buildWide(context);
  }

  Widget _buildWide(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _NavPanel(
          width: _navWidth,
          navTitle: widget.navTitle(context),
          entries: widget.entries,
          selectedIndex: _selectedIndex,
          onSelect: _selectIndex,
        ),
        Expanded(
          child: _BodyPane(
            title: _activeEntry.title(context),
            subtitle: _activeEntry.subtitle(context),
            onClose: () => _close(context),
            child: _activeEntry.bodyBuilder(context),
          ),
        ),
      ],
    );
  }

  Widget _buildNarrow(BuildContext context) {
    final openDetailInitially = widget.initialIndex != 0;
    return Navigator(
      key: _navigatorKey,
      initialRoute: openDetailInitially ? _detailRoute : _navRoute,
      onGenerateRoute: (settings) {
        switch (settings.name) {
          case _detailRoute:
            return MaterialPageRoute<void>(
              builder: (detailContext) => _NarrowDetailPage(
                entry: _activeEntry,
                onBack: () => Navigator.of(detailContext).pop(),
              ),
            );
          case _navRoute:
          default:
            return MaterialPageRoute<void>(
              builder: (navContext) => _NarrowNavPage(
                navTitle: widget.navTitle(navContext),
                entries: widget.entries,
                onClose: () => _close(context),
                onSelect: (index) {
                  _selectIndex(index);
                  Navigator.of(navContext).pushNamed(_detailRoute);
                },
              ),
            );
        }
      },
    );
  }
}

const String _navRoute = '/';
const String _detailRoute = '/detail';

class _NavPanel extends StatelessWidget {
  const _NavPanel({
    required this.width,
    required this.navTitle,
    required this.entries,
    required this.selectedIndex,
    required this.onSelect,
  });

  final double width;
  final String navTitle;
  final List<TpDialogNavEntry> entries;
  final int selectedIndex;
  final ValueChanged<int> onSelect;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final styles = TpTextStyles.of(context);

    // Match the pre-NavShell settings rail (WorkspaceHubNavItem): fixed
    // paddings, not denser tpSpacing.sm tiles.
    return Container(
      width: width,
      decoration: BoxDecoration(
        color: cs.surfaceContainerLow,
        border: Border(
          right: BorderSide(color: cs.outlineVariant.withValues(alpha: 0.5)),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 22, 20, 14),
              child: Text(
                navTitle,
                style: styles.lgSemiboldSnugColored(cs.onSurface),
              ),
            ),
            Expanded(
              child: ListView(
                children: [
                  for (final (index, entry) in entries.indexed)
                    _NavTile(
                      label: entry.navLabel(context),
                      icon: entry.icon,
                      selected: index == selectedIndex,
                      onTap: () => onSelect(index),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _NavTile extends StatelessWidget {
  const _NavTile({
    required this.label,
    required this.icon,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;

  static const double _height = 48;
  static const double _itemGap = 8;
  static const double _horizontalPadding = 18;
  static const double _iconLabelGap = 16;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final iconSizes = context.tpIconSizes;
    final styles = TpTextStyles.of(context);
    // Same roles as WorkspaceHubNavItem: regular md type, primaryContainer
    // selection (not secondaryContainer / forced w500–w600).
    final selectedFg = cs.onPrimaryContainer;
    final normalFg = cs.onSurface.withValues(alpha: 0.88);
    final muted = cs.onSurfaceVariant;

    return Padding(
      padding: const EdgeInsets.only(bottom: _itemGap),
      child: Material(
        color: selected ? cs.primaryContainer : Colors.transparent,
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: onTap,
          child: SizedBox(
            height: _height,
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: _horizontalPadding,
              ),
              child: Row(
                children: [
                  Icon(
                    icon,
                    size: iconSizes.md,
                    color: selected ? selectedFg : muted,
                  ),
                  const SizedBox(width: _iconLabelGap),
                  Expanded(
                    child: Text(
                      label,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: styles.md.copyWith(
                        color: selected ? selectedFg : normalFg,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _BodyPane extends StatelessWidget {
  const _BodyPane({
    required this.title,
    required this.subtitle,
    required this.onClose,
    required this.child,
  });

  final String title;
  final String subtitle;
  final VoidCallback onClose;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final styles = TpTextStyles.of(context);
    final spacing = context.tpSpacing;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Container(
          // Match pre-NavShell WorkspaceHubTitleBar / SplitShell insets
          // (24–28), not denser tpSpacing.lg tops that felt cramped.
          padding: const EdgeInsets.fromLTRB(24, 28, 16, 20),
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(color: cs.outlineVariant.withValues(alpha: 0.5)),
            ),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: styles.lgSemiboldSnugColored(cs.onSurface),
                    ),
                    if (subtitle.isNotEmpty) ...[
                      SizedBox(height: spacing.xs),
                      Text(
                        subtitle,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: styles.mutedMd,
                      ),
                    ],
                  ],
                ),
              ),
              SizedBox(width: spacing.sm),
              TpIconButton(
                icon: Icons.close_rounded,
                tooltip: MaterialLocalizations.of(context).closeButtonTooltip,
                compact: true,
                color: cs.onSurfaceVariant,
                onTap: onClose,
              ),
            ],
          ),
        ),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(24, 20, 28, 24),
            child: child,
          ),
        ),
      ],
    );
  }
}

class _NarrowNavPage extends StatelessWidget {
  const _NarrowNavPage({
    required this.navTitle,
    required this.entries,
    required this.onClose,
    required this.onSelect,
  });

  final String navTitle;
  final List<TpDialogNavEntry> entries;
  final VoidCallback onClose;
  final ValueChanged<int> onSelect;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final spacing = context.tpSpacing;

    return ColoredBox(
      color: cs.surfaceContainerLow,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          ColoredBox(
            color: cs.surfaceContainerLow,
            child: TpDialogMobileNavBar(
              title: navTitle,
              onLeading: onClose,
              leadingTooltip:
                  MaterialLocalizations.of(context).cancelButtonLabel,
            ),
          ),
          Expanded(
            child: SafeArea(
              top: false,
              child: ListView(
                padding: EdgeInsets.fromLTRB(
                  spacing.lg,
                  spacing.md,
                  spacing.lg,
                  spacing.xl,
                ),
                children: [
                  _NarrowNavCard(
                    entries: entries,
                    onSelect: onSelect,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Grouped settings-style card for narrow nav lists.
class _NarrowNavCard extends StatelessWidget {
  const _NarrowNavCard({
    required this.entries,
    required this.onSelect,
  });

  final List<TpDialogNavEntry> entries;
  final ValueChanged<int> onSelect;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final spacing = context.tpSpacing;
    final iconSizes = context.tpIconSizes;
    final radius = BorderRadius.circular(12);

    return Material(
      color: cs.surface,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: radius,
        side: BorderSide(
          color: cs.outlineVariant.withValues(alpha: 0.35),
        ),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: [
          for (final (index, entry) in entries.indexed) ...[
            if (index > 0)
              Divider(
                height: 1,
                thickness: 1,
                indent: spacing.lg + iconSizes.md + spacing.md,
                endIndent: spacing.lg,
                color: cs.outlineVariant.withValues(alpha: 0.45),
              ),
            Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () => onSelect(index),
                child: Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: spacing.lg,
                    vertical: spacing.md + 2,
                  ),
                  child: Row(
                    children: [
                      Icon(
                        entry.icon,
                        size: iconSizes.md,
                        color: cs.onSurface,
                      ),
                      SizedBox(width: spacing.md),
                      Expanded(
                        child: Text(
                          entry.navLabel(context),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TpTextStyles.of(context).md.copyWith(
                            color: cs.onSurface.withValues(alpha: 0.88),
                          ),
                        ),
                      ),
                      Icon(
                        Icons.chevron_right_rounded,
                        size: iconSizes.lg,
                        color: cs.onSurfaceVariant.withValues(alpha: 0.55),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _NarrowDetailPage extends StatelessWidget {
  const _NarrowDetailPage({
    required this.entry,
    required this.onBack,
  });

  final TpDialogNavEntry entry;
  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final styles = TpTextStyles.of(context);
    final spacing = context.tpSpacing;
    final subtitle = entry.subtitle(context);

    return ColoredBox(
      color: cs.surfaceContainerLow,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          ColoredBox(
            color: cs.surfaceContainerLow,
            child: TpDialogMobileNavBar(
              title: entry.title(context),
              onLeading: onBack,
            ),
          ),
          Expanded(
            child: SafeArea(
              top: false,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  if (subtitle.isNotEmpty)
                    Padding(
                      padding: EdgeInsets.fromLTRB(
                        spacing.lg,
                        spacing.sm,
                        spacing.lg,
                        spacing.md,
                      ),
                      child: Text(
                        subtitle,
                        style: styles.mutedMd,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  Expanded(
                    child: Padding(
                      padding: EdgeInsets.fromLTRB(
                        spacing.lg,
                        0,
                        spacing.lg,
                        spacing.lg,
                      ),
                      child: Material(
                        color: cs.surface,
                        borderRadius: BorderRadius.circular(12),
                        clipBehavior: Clip.antiAlias,
                        child: entry.bodyBuilder(context),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
