import 'package:flutter/material.dart';

import '../select/tp_compact_select.dart';
import 'tp_segmented_control.dart';

/// Default width below which [TpSegmentedPicker] uses a compact select instead
/// of the pill control (matches TeamPilot settings / dialog narrow pane).
const double kTpSegmentedPickerMobileBreakpoint = 840;

/// One option in [TpSegmentedPicker].
class TpSegmentedOption<T extends Object> {
  const TpSegmentedOption({
    required this.value,
    required this.label,
    required this.icon,
  });

  final T value;
  final String label;
  final IconData icon;
}

/// Preference-row choice control: pill segments on wide viewports, compact
/// select on narrow (mobile) so long labels stay readable without scroll /
/// ellipsis.
///
/// Set [scrollable] false when a parent already scrolls (e.g. scale + % field
/// on wide). Ignored on mobile select mode.
class TpSegmentedPicker<T extends Object> extends StatefulWidget {
  const TpSegmentedPicker({
    super.key,
    required this.segments,
    required this.selected,
    required this.onChanged,
    this.alignment = Alignment.centerRight,
    this.minWidth,
    this.customWidths,
    this.scrollable = true,
    this.mobileBreakpoint = kTpSegmentedPickerMobileBreakpoint,
  });

  final List<TpSegmentedOption<T>> segments;
  final T selected;
  final ValueChanged<T> onChanged;
  final AlignmentGeometry alignment;
  final double? minWidth;
  final List<double>? customWidths;
  final bool scrollable;

  /// Below this width, render [TpCompactSelect] instead of the pill.
  final double mobileBreakpoint;

  @override
  State<TpSegmentedPicker<T>> createState() => _TpSegmentedPickerState<T>();
}

class _TpSegmentedPickerState<T extends Object>
    extends State<TpSegmentedPicker<T>> {
  late int _index;

  @override
  void initState() {
    super.initState();
    _index = _indexFor(widget.selected);
  }

  @override
  void didUpdateWidget(covariant TpSegmentedPicker<T> oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.selected != widget.selected) {
      _index = _indexFor(widget.selected);
    }
  }

  int _indexFor(T value) {
    final idx = widget.segments.indexWhere((s) => s.value == value);
    return idx >= 0 ? idx : 0;
  }

  bool get _reverseScroll {
    final resolved = widget.alignment.resolve(TextDirection.ltr);
    return resolved.x > 0;
  }

  bool _useSelect(BuildContext context) =>
      MediaQuery.sizeOf(context).width < widget.mobileBreakpoint;

  @override
  Widget build(BuildContext context) {
    if (_useSelect(context)) {
      // Fill the preference trailing slot so the chevron sits on the far right
      // (TpSelect expands its header only when width is bounded).
      return SizedBox(
        width: double.infinity,
        child: TpCompactSelect<T>(
          value: widget.selected,
          entries: [
            for (final s in widget.segments) (s.value, s.label),
          ],
          onChanged: (v) {
            if (v == null) return;
            setState(() => _index = _indexFor(v));
            widget.onChanged(v);
          },
        ),
      );
    }

    final control = TpSegmentedControl(
      totalSwitches: widget.segments.length,
      initialLabelIndex: _index,
      labels: widget.segments.map((e) => e.label).toList(),
      icons: widget.segments.map((e) => e.icon).toList(),
      minWidth: widget.minWidth,
      customWidths: widget.customWidths,
      onToggle: (index) {
        if (index == null || index < 0 || index >= widget.segments.length) {
          return;
        }
        setState(() => _index = index);
        widget.onChanged(widget.segments[index].value);
      },
    );

    if (!widget.scrollable) {
      return Align(alignment: widget.alignment, child: control);
    }

    return Align(
      alignment: widget.alignment,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        reverse: _reverseScroll,
        child: control,
      ),
    );
  }
}
