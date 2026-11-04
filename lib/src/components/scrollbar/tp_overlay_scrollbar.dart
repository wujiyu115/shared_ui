import 'dart:async';

import 'package:flutter/material.dart';

/// VS Code-style overlay scrollbar host.
///
/// A plain [Scrollbar] with `thumbVisibility: false` only fades a hidden thumb
/// back in when the pointer is within ~24 px of *the thumb itself*
/// (`RawScrollbar.handleHover` → padded rect around the thumb). On a long list
/// that makes most of the edge dead: hovering halfway down a panel whose thumb
/// sits at the top shows nothing.
///
/// This wrapper owns the reveal instead: the whole edge strip of the scroll view
/// lights the bar up, then it fades out once the pointer leaves (and after
/// [hideDelay], so brushing past it does not flash). Visibility is driven
/// through [Scrollbar.thumbVisibility], so thumb geometry, drag, track taps and
/// the theme's colours/width all stay Flutter's.
class TpOverlayScrollbar extends StatefulWidget {
  const TpOverlayScrollbar({
    required this.child,
    this.controller,
    this.axis = Axis.vertical,
    this.notificationPredicate,
    this.hoverExtent,
    this.hideDelay = const Duration(milliseconds: 700),
    super.key,
  });

  /// The scroll view (or the nested [TpOverlayScrollbar] for the other axis).
  final Widget child;

  /// Controller of the scroll view this bar listens to.
  final ScrollController? controller;

  /// Which edge reveals the bar: the right edge for [Axis.vertical], the bottom
  /// edge for [Axis.horizontal].
  final Axis axis;

  /// Forwarded to [Scrollbar.notificationPredicate].
  final bool Function(ScrollNotification notification)? notificationPredicate;

  /// Thickness of the reveal strip. Defaults to the theme's bar thickness + 8.
  final double? hoverExtent;

  /// How long the bar stays visible after the pointer leaves the strip.
  final Duration hideDelay;

  /// Fallback when the theme does not set [ScrollbarThemeData.thickness].
  static const double fallbackThickness = 10;

  /// Reveal strip width for a scrollbar of [thickness].
  static double hoverExtentFor(double thickness) => thickness + 8;

  /// Resolved thickness of the bars in [context].
  static double thicknessOf(BuildContext context) =>
      ScrollbarTheme.of(context).thickness?.resolve(<WidgetState>{}) ??
      fallbackThickness;

  @override
  State<TpOverlayScrollbar> createState() => _TpOverlayScrollbarState();
}

class _TpOverlayScrollbarState extends State<TpOverlayScrollbar> {
  bool _visible = false;
  bool _pointerInStrip = false;
  Timer? _hideTimer;

  @override
  void dispose() {
    _hideTimer?.cancel();
    super.dispose();
  }

  void _show() {
    _hideTimer?.cancel();
    _hideTimer = null;
    if (!_visible) setState(() => _visible = true);
  }

  void _scheduleHide() {
    _hideTimer?.cancel();
    if (_pointerInStrip) return;
    _hideTimer = Timer(widget.hideDelay, () {
      _hideTimer = null;
      if (!mounted || _pointerInStrip) return;
      setState(() => _visible = false);
    });
  }

  bool _isInsideStrip(Offset position, Size size, double extent) {
    return switch (widget.axis) {
      Axis.vertical => position.dx >= size.width - extent,
      Axis.horizontal => position.dy >= size.height - extent,
    };
  }

  @override
  Widget build(BuildContext context) {
    final thickness = TpOverlayScrollbar.thicknessOf(context);
    final extent =
        widget.hoverExtent ?? TpOverlayScrollbar.hoverExtentFor(thickness);

    return LayoutBuilder(
      builder: (context, constraints) {
        final size = constraints.biggest;
        return MouseRegion(
          onHover: (event) {
            if (!size.width.isFinite || !size.height.isFinite) return;
            final inside = _isInsideStrip(event.localPosition, size, extent);
            if (inside == _pointerInStrip) return;
            _pointerInStrip = inside;
            if (inside) {
              _show();
            } else {
              _scheduleHide();
            }
          },
          onExit: (event) {
            if (!_pointerInStrip) return;
            _pointerInStrip = false;
            _scheduleHide();
          },
          child: Scrollbar(
            controller: widget.controller,
            notificationPredicate:
                widget.notificationPredicate ??
                defaultScrollNotificationPredicate,
            thumbVisibility: _visible,
            child: widget.child,
          ),
        );
      },
    );
  }
}
