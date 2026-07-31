import 'package:flutter/material.dart';
import 'package:toggle_switch/toggle_switch.dart';

import '../../theme/tp_theme.dart';

/// Compact pill height for preference-row segmented controls.
const tpSegmentedControlMinHeight = 32.0;

/// Default corner radius for [TpSegmentedControl].
const tpSegmentedControlCornerRadius = 30.0;

/// Content-driven floor for short labels.
const tpSegmentedControlMinSegmentWidth = 72.0;

/// Matches [ToggleSwitch] segment `padding: EdgeInsets.symmetric(horizontal: 10)`.
const _segmentHorizontalPadding = 20.0;

/// Matches [ToggleSwitch] icon→label `padding: EdgeInsets.only(left: 5)`.
const _segmentIconTextGap = 5.0;

/// Extra width so CJK / custom UI fonts are not ellipsized at the edge.
const _segmentWidthSlack = 12.0;

/// Per-segment widths from [labels], [fontSize], and optional [icons].
List<double> computeTpSegmentedControlWidths({
  required List<String> labels,
  required double fontSize,
  required double iconSize,
  required TextStyle textStyle,
  List<IconData?>? icons,
  double minSegmentWidth = tpSegmentedControlMinSegmentWidth,
}) {
  final iconList = icons;
  final hasIcons = iconList != null && iconList.isNotEmpty;
  return List.generate(labels.length, (i) {
    final label = labels[i];
    final hasIcon = hasIcons && i < iconList.length && iconList[i] != null;
    final painter = TextPainter(
      text: TextSpan(text: label, style: textStyle),
      textDirection: TextDirection.ltr,
      maxLines: 1,
    )..layout();
    final iconPart = hasIcon ? iconSize + _segmentIconTextGap : 0.0;
    final width =
        _segmentHorizontalPadding +
        iconPart +
        painter.width +
        _segmentWidthSlack;
    return width < minSegmentWidth ? minSegmentWidth : width.ceilToDouble();
  });
}

/// Pill multi-segment control styled from [ColorScheme] + [TpTheme] tokens.
///
/// Uses [toggle_switch]; this is **not** a binary on/off switch.
///
/// Lays out at the full content width ([customWidths] sum) so [Flexible]
/// segments inside the package cannot shrink labels into ellipsis. Narrow
/// parents should scroll (see [TpSegmentedPicker]), same idea as theme-color
/// chips — not [FittedBox] scale-down.
class TpSegmentedControl extends StatelessWidget {
  const TpSegmentedControl({
    super.key,
    required this.totalSwitches,
    required this.initialLabelIndex,
    required this.labels,
    required this.onToggle,
    this.icons,
    this.minWidth,
    this.customWidths,
    this.minHeight,
    this.cornerRadius = tpSegmentedControlCornerRadius,
  });

  final int totalSwitches;
  final int initialLabelIndex;
  final List<String> labels;
  final List<IconData?>? icons;
  final OnToggle? onToggle;
  final double? minWidth;
  final List<double>? customWidths;

  /// Track height. Defaults to [tpSegmentedControlMinHeight].
  final double? minHeight;
  final double cornerRadius;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final theme = Theme.of(context);
    final tp = context.tpTheme;
    final textStyle =
        (theme.textTheme.labelLarge ??
                theme.textTheme.bodyMedium ??
                TextStyle(fontSize: tp.typography.bodySize))
            .copyWith(height: 1.0);
    final textBase = cs.onSurface;
    final inactiveFg = textBase.withValues(alpha: 0.72);
    final n = totalSwitches;
    final resolvedMinHeight = minHeight ?? tpSegmentedControlMinHeight;
    final resolvedMinWidth = minWidth ?? tpSegmentedControlMinSegmentWidth;
    final fontSize = textStyle.fontSize ?? tp.typography.bodySize;
    final iconSize = context.tpIconSizes.sm;
    final resolvedCustomWidths =
        customWidths ??
        computeTpSegmentedControlWidths(
          labels: labels,
          fontSize: fontSize,
          iconSize: iconSize,
          icons: icons,
          minSegmentWidth: resolvedMinWidth,
          textStyle: textStyle,
        );
    final totalWidth = resolvedCustomWidths.fold<double>(0, (a, b) => a + b);

    return SizedBox(
      width: totalWidth,
      child: ToggleSwitch(
        totalSwitches: n,
        initialLabelIndex: initialLabelIndex,
        labels: labels,
        icons: icons,
        cornerRadius: cornerRadius,
        radiusStyle: true,
        minHeight: resolvedMinHeight,
        minWidth: resolvedMinWidth,
        customWidths: resolvedCustomWidths,
        fontSize: fontSize,
        iconSize: iconSize,
        customTextStyles: List<TextStyle>.filled(n, textStyle),
        activeFgColor: cs.onPrimary,
        inactiveFgColor: inactiveFg,
        inactiveBgColor: cs.surfaceContainerHighest,
        dividerColor: Colors.transparent,
        dividerMargin: 0,
        activeBgColors: List.generate(n, (_) => <Color>[cs.primary]),
        animate: false,
        onToggle: onToggle,
      ),
    );
  }
}
