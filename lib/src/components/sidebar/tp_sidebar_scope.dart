import 'package:flutter/material.dart';

/// Desktop sidebar expansion derived from [TpSidebarScope.open].
enum TpSidebarDesktopState {
  expanded,
  collapsed,
}

/// Inherited scope exposing sidebar open state, width, and actions.
class TpSidebarScope extends InheritedWidget {
  const TpSidebarScope({
    super.key,
    required this.open,
    required this.openMobile,
    required this.isMobile,
    required this.edgeOpenEnabled,
    required this.width,
    required this.minWidth,
    required this.maxWidth,
    required this.isResizing,
    required this.setOpen,
    required this.setOpenMobile,
    required this.setWidth,
    required this.beginResize,
    required this.endResize,
    required this.toggleSidebar,
    required super.child,
  });

  final bool open;
  final bool openMobile;
  final bool isMobile;
  final bool edgeOpenEnabled;

  /// Current expanded desktop width (clamped to [minWidth]–[maxWidth]).
  final double width;
  final double minWidth;
  final double maxWidth;

  /// True while the user is dragging the resize rail.
  final bool isResizing;

  final ValueChanged<bool> setOpen;
  final ValueChanged<bool> setOpenMobile;
  final ValueChanged<double> setWidth;
  final VoidCallback beginResize;
  final VoidCallback endResize;
  final VoidCallback toggleSidebar;

  TpSidebarDesktopState get state =>
      open ? TpSidebarDesktopState.expanded : TpSidebarDesktopState.collapsed;

  static TpSidebarScope of(BuildContext context) {
    final scope = maybeOf(context);
    if (scope == null) {
      throw FlutterError(
        'TpSidebarScope.of() called with a context that does not contain a '
        'TpSidebarScope.\n'
        'No TpSidebarScope ancestor could be found starting from the context '
        'that was passed to TpSidebarScope.of().\n'
        'The context used was:\n'
        '  $context',
      );
    }
    return scope;
  }

  static TpSidebarScope? maybeOf(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<TpSidebarScope>();

  @override
  bool updateShouldNotify(TpSidebarScope oldWidget) =>
      open != oldWidget.open ||
      openMobile != oldWidget.openMobile ||
      isMobile != oldWidget.isMobile ||
      edgeOpenEnabled != oldWidget.edgeOpenEnabled ||
      width != oldWidget.width ||
      minWidth != oldWidget.minWidth ||
      maxWidth != oldWidget.maxWidth ||
      isResizing != oldWidget.isResizing;
}
