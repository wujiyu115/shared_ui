import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

import '../../theme/components/tp_sidebar_theme.dart';
import '../../theme/tp_theme.dart';
import 'tp_sidebar_config.dart';
import 'tp_sidebar_mobile_drawer.dart';
import 'tp_sidebar_scope.dart';

/// Sized sidebar panel with collapse animation and mobile overlay drawer.
class TpSidebar extends StatefulWidget {
  const TpSidebar({
    super.key,
    this.side = TpSidebarSide.left,
    this.variant = TpSidebarVariant.sidebar,
    this.collapsible = TpSidebarCollapsible.offcanvas,
    this.themeOverride,
    this.overlayActive = true,
    required this.child,
  });

  final TpSidebarSide side;
  final TpSidebarVariant variant;
  final TpSidebarCollapsible collapsible;
  final TpSidebarTheme? themeOverride;

  /// When false on mobile, this instance does not host the root overlay drawer.
  ///
  /// Multiple [TpSidebar]s may share one [TpSidebarProvider] (e.g. kept-alive
  /// home + workspace). Only the foreground instance should be `true`. Losing
  /// ownership (`true` → `false`) closes shared [TpSidebarScope.openMobile];
  /// already-inactive instances must not touch that flag — otherwise they
  /// immediately close a drawer opened by the active host.
  final bool overlayActive;
  final Widget child;

  @override
  State<TpSidebar> createState() => _TpSidebarState();
}

class _TpSidebarState extends State<TpSidebar> {
  final OverlayPortalController _overlayController = OverlayPortalController();
  bool _overlayShown = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _scheduleOverlaySync();
  }

  @override
  void didUpdateWidget(TpSidebar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.overlayActive && !widget.overlayActive) {
      // Only the instance that *loses* ownership may close shared openMobile.
      _releaseOverlayOwnership(TpSidebarScope.maybeOf(context));
    }
    _scheduleOverlaySync();
  }

  @override
  void dispose() {
    if (_overlayShown) {
      _hideOverlay();
    }
    super.dispose();
  }

  void _showOverlay() {
    if (!_overlayController.isShowing) {
      _overlayController.show();
    }
  }

  void _hideOverlay() {
    if (_overlayController.isShowing) {
      _overlayController.hide();
    }
  }

  /// Clear local overlay bookkeeping when this host is not showing a portal.
  ///
  /// Do not call [OverlayPortalController.hide] here — when [overlayActive] is
  /// false the portal leaves the tree on the next build, and hide-after-detach
  /// is unsafe.
  void _detachLocalOverlay() {
    _overlayShown = false;
  }

  /// Called when this instance loses overlay ownership (`overlayActive`
  /// true → false). Closes the shared mobile drawer so the next route starts
  /// closed.
  void _releaseOverlayOwnership(TpSidebarScope? scope) {
    _detachLocalOverlay();
    if (scope == null || !scope.openMobile) return;
    // Never setState the Provider during build / didUpdateWidget.
    SchedulerBinding.instance.addPostFrameCallback((_) {
      if (!mounted || widget.overlayActive) return;
      final current = TpSidebarScope.maybeOf(context);
      if (current != null && current.openMobile) {
        current.setOpenMobile(false);
      }
    });
  }

  void _ensureOverlayVisible(TpSidebarScope scope) {
    if (!widget.overlayActive) {
      _detachLocalOverlay();
      return;
    }
    final show = scope.openMobile || scope.edgeOpenEnabled;
    if (!show) {
      if (_overlayShown) {
        _hideOverlay();
        _overlayShown = false;
      }
      return;
    }
    if (!_overlayShown) {
      _showOverlay();
      _overlayShown = true;
    }
  }

  void _scheduleOverlaySync() {
    SchedulerBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final current = TpSidebarScope.maybeOf(context);

      // Portal is only in the tree while mobile. Never hide() after it detaches.
      if (current == null || !current.isMobile) {
        _overlayShown = false;
        return;
      }

      if (!widget.overlayActive) {
        // Stay inactive: never release shared openMobile owned by another host.
        _detachLocalOverlay();
        return;
      }

      _ensureOverlayVisible(current);
    });
  }

  double _desktopWidth({
    required TpSidebarScope scope,
    required TpSidebarTheme theme,
  }) {
    if (widget.collapsible == TpSidebarCollapsible.none || scope.open) {
      return scope.width;
    }
    return switch (widget.collapsible) {
      TpSidebarCollapsible.icon => theme.widthIcon,
      TpSidebarCollapsible.offcanvas => 0,
      TpSidebarCollapsible.none => scope.width,
    };
  }

  BoxDecoration _decoration(TpSidebarTheme theme, ColorScheme scheme) {
    final bg = theme.backgroundColor ?? scheme.surfaceContainerLow;
    final border = theme.borderColor ??
        scheme.outlineVariant.withValues(alpha: 0.55);
    final isDark = scheme.brightness == Brightness.dark;

    return switch (widget.variant) {
      TpSidebarVariant.sidebar => BoxDecoration(
          color: bg,
          border: Border(
            left: widget.side == TpSidebarSide.right
                ? BorderSide(color: border)
                : BorderSide.none,
            right: widget.side == TpSidebarSide.left
                ? BorderSide(color: border)
                : BorderSide.none,
          ),
        ),
      TpSidebarVariant.floating => BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(theme.floatingRadius),
          border: Border.all(color: border),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: isDark ? 0.35 : 0.08),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
      // Sit on page chrome; keep fill quiet so inset card carries hierarchy.
      TpSidebarVariant.inset => BoxDecoration(
          color: bg,
        ),
    };
  }

  EdgeInsets _margin(TpSidebarTheme theme) {
    if (widget.variant != TpSidebarVariant.floating) {
      return EdgeInsets.zero;
    }
    return EdgeInsets.all(theme.floatingMargin);
  }

  Widget _buildPanel({
    required BuildContext context,
    required TpSidebarTheme theme,
    required TpSidebarScope scope,
    required double width,
    required Widget child,
  }) {
    final scheme = Theme.of(context).colorScheme;
    final margin = _margin(theme);
    final decoration = _decoration(theme, scheme);
    final contentWidth = scope.width;

    return AnimatedContainer(
      key: const Key('sidebar-panel'),
      duration: scope.isResizing
          ? Duration.zero
          : theme.animationDuration,
      curve: Curves.easeInOut,
      width: width,
      margin: margin,
      decoration: decoration,
      clipBehavior: Clip.hardEdge,
      child: width <= 0
          ? const SizedBox.shrink()
          : OverflowBox(
              alignment: widget.side == TpSidebarSide.left
                  ? Alignment.centerLeft
                  : Alignment.centerRight,
              minWidth: 0,
              maxWidth: contentWidth,
              child: SizedBox(
                width: contentWidth,
                child: child,
              ),
            ),
    );
  }

  Widget _buildConfiguredChild(Widget child) {
    return TpSidebarConfig(
      side: widget.side,
      variant: widget.variant,
      collapsible: widget.collapsible,
      child: child,
    );
  }

  @override
  Widget build(BuildContext context) {
    final scope = TpSidebarScope.of(context);
    final theme =
        widget.themeOverride ?? TpTheme.of(context).sidebarTheme;
    final configured = _buildConfiguredChild(widget.child);

    if (!scope.isMobile) {
      // Portal already left the tree with this rebuild — only clear local flag.
      _overlayShown = false;
      final width = _desktopWidth(scope: scope, theme: theme);
      return _buildPanel(
        context: context,
        theme: theme,
        scope: scope,
        width: width,
        child: configured,
      );
    }

    if (!widget.overlayActive) {
      _detachLocalOverlay();
      return _buildPanel(
        context: context,
        theme: theme,
        scope: scope,
        width: 0,
        child: const SizedBox.shrink(),
      );
    }

    _ensureOverlayVisible(scope);
    _scheduleOverlaySync();
    return OverlayPortal.overlayChildLayoutBuilder(
      controller: _overlayController,
      overlayLocation: OverlayChildLocation.rootOverlay,
      overlayChildBuilder: (overlayContext, info) {
        return Positioned(
          left: 0,
          top: 0,
          width: info.overlaySize.width,
          height: info.overlaySize.height,
          child: TpSidebarMobileDrawer(
            side: widget.side,
            theme: theme,
            openMobile: scope.openMobile,
            edgeOpenEnabled: scope.edgeOpenEnabled,
            onOpenMobileChange: scope.setOpenMobile,
            child: configured,
          ),
        );
      },
      child: _buildPanel(
        context: context,
        theme: theme,
        scope: scope,
        width: 0,
        child: const SizedBox.shrink(),
      ),
    );
  }
}
