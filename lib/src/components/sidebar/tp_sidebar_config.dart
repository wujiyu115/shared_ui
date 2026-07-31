import 'package:flutter/material.dart';

/// Which edge the sidebar docks to.
enum TpSidebarSide { left, right }

/// Visual treatment of the sidebar panel.
enum TpSidebarVariant { sidebar, floating, inset }

/// How the sidebar collapses on desktop.
enum TpSidebarCollapsible { none, icon, offcanvas }

/// Inherited layout config published by [TpSidebar] for descendants.
class TpSidebarConfig extends InheritedWidget {
  const TpSidebarConfig({
    super.key,
    required this.side,
    required this.variant,
    required this.collapsible,
    required super.child,
  });

  final TpSidebarSide side;
  final TpSidebarVariant variant;
  final TpSidebarCollapsible collapsible;

  static TpSidebarConfig of(BuildContext context) {
    final config = maybeOf(context);
    if (config == null) {
      throw FlutterError(
        'TpSidebarConfig.of() called with a context that does not contain a '
        'TpSidebarConfig.\n'
        'No TpSidebarConfig ancestor could be found starting from the context '
        'that was passed to TpSidebarConfig.of().\n'
        'The context used was:\n'
        '  $context',
      );
    }
    return config;
  }

  static TpSidebarConfig? maybeOf(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<TpSidebarConfig>();

  @override
  bool updateShouldNotify(TpSidebarConfig oldWidget) =>
      side != oldWidget.side ||
      variant != oldWidget.variant ||
      collapsible != oldWidget.collapsible;
}
