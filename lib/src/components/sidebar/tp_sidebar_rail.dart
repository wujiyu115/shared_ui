import 'package:flutter/material.dart';

import 'tp_sidebar_config.dart';
import 'tp_sidebar_scope.dart';

/// Inner-edge hit strip: drag to resize when expanded; tap to toggle.
///
/// Place inside a [Stack] over the sidebar panel so it receives a bounded height.
class TpSidebarRail extends StatefulWidget {
  const TpSidebarRail({super.key});

  static const double _width = 12;
  static const double _tapSlop = 4;

  @override
  State<TpSidebarRail> createState() => _TpSidebarRailState();
}

class _TpSidebarRailState extends State<TpSidebarRail> {
  double _dragDistance = 0;

  Alignment get _alignment {
    final side = TpSidebarConfig.maybeOf(context)?.side ?? TpSidebarSide.left;
    return side == TpSidebarSide.left
        ? Alignment.centerRight
        : Alignment.centerLeft;
  }

  void _onDragStart(DragStartDetails _) {
    _dragDistance = 0;
    final scope = TpSidebarScope.of(context);
    if (scope.open && !scope.isMobile) {
      scope.beginResize();
    }
  }

  void _onDragUpdate(DragUpdateDetails details) {
    final scope = TpSidebarScope.of(context);
    if (!scope.open || scope.isMobile) return;

    final side = TpSidebarConfig.maybeOf(context)?.side ?? TpSidebarSide.left;
    final delta = details.delta.dx;
    _dragDistance += delta.abs();
    final signed = side == TpSidebarSide.left ? delta : -delta;
    scope.setWidth(scope.width + signed);
  }

  void _onDragEnd(DragEndDetails _) {
    final scope = TpSidebarScope.of(context);
    final wasTap = _dragDistance < TpSidebarRail._tapSlop;
    scope.endResize();
    _dragDistance = 0;
    if (wasTap) {
      scope.toggleSidebar();
    }
  }

  void _onDragCancel() {
    TpSidebarScope.of(context).endResize();
    _dragDistance = 0;
  }

  @override
  Widget build(BuildContext context) {
    final scope = TpSidebarScope.of(context);
    final canResize = scope.open && !scope.isMobile;

    return LayoutBuilder(
      builder: (context, constraints) {
        final height = constraints.maxHeight.isFinite
            ? constraints.maxHeight
            : double.infinity;
        return Align(
          alignment: _alignment,
          child: MouseRegion(
            cursor: canResize
                ? SystemMouseCursors.resizeColumn
                : SystemMouseCursors.click,
            child: GestureDetector(
              key: const Key('tp-sidebar-rail'),
              behavior: HitTestBehavior.opaque,
              onHorizontalDragStart: _onDragStart,
              onHorizontalDragUpdate: _onDragUpdate,
              onHorizontalDragEnd: _onDragEnd,
              onHorizontalDragCancel: _onDragCancel,
              // Tap without drag still toggles when collapsed (no drag gestures).
              onTap: canResize ? null : scope.toggleSidebar,
              child: SizedBox(
                width: TpSidebarRail._width,
                height: height,
              ),
            ),
          ),
        );
      },
    );
  }
}
