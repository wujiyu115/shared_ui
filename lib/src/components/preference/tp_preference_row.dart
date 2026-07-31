import 'package:flutter/material.dart';

import '../../theme/tp_text_styles.dart';
import '../../theme/tp_theme.dart';

/// Horizontal preference / settings row: title (+ subtitle) left, [trailing] right.
///
/// Always keeps [trailing] on the same row (e.g. [Switch] stays end-aligned on
/// mobile). Wide trailings such as [TpSegmentedPicker] / theme chips own their
/// own horizontal scroll instead of stacking under the labels.
class TpPreferenceRow extends StatelessWidget {
  const TpPreferenceRow({
    super.key,
    required this.title,
    this.subtitle,
    this.titleLeading,
    required this.trailing,
    this.showDividerBelow = true,
    this.crossAxisAlignment = CrossAxisAlignment.center,
    this.padding,
  });

  final String title;
  final String? subtitle;
  final Widget? titleLeading;
  final Widget trailing;
  final bool showDividerBelow;
  final CrossAxisAlignment crossAxisAlignment;
  final EdgeInsetsGeometry? padding;

  static const EdgeInsets defaultPadding = EdgeInsets.fromLTRB(20, 16, 20, 16);
  static const double _titleSubtitleGap = 4;
  static const double _labelTrailingGap = 24;

  static bool hasSubtitle(String? subtitle) =>
      subtitle != null && subtitle.trim().isNotEmpty;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final spacing = context.tpSpacing;
    final hasSub = hasSubtitle(subtitle);
    final subtitleStyle = TpTextStyles.of(context).mutedSm;
    final resolvedPadding = padding ?? defaultPadding;

    return RepaintBoundary(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: resolvedPadding,
            child: Row(
              crossAxisAlignment: crossAxisAlignment,
              children: [
                if (titleLeading != null) ...[
                  titleLeading!,
                  SizedBox(width: spacing.md),
                ],
                Expanded(
                  child: Padding(
                    padding: crossAxisAlignment == CrossAxisAlignment.start
                        ? const EdgeInsets.only(top: 10)
                        : EdgeInsets.zero,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(title),
                        if (hasSub) ...[
                          const SizedBox(height: _titleSubtitleGap),
                          Text(subtitle!.trim(), style: subtitleStyle),
                        ],
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: _labelTrailingGap),
                Flexible(
                  fit: FlexFit.loose,
                  child: Align(
                    alignment: crossAxisAlignment == CrossAxisAlignment.start
                        ? Alignment.topRight
                        : Alignment.centerRight,
                    child: trailing,
                  ),
                ),
              ],
            ),
          ),
          if (showDividerBelow)
            Divider(
              height: 1,
              thickness: 1,
              color: cs.outlineVariant.withValues(alpha: 0.5),
            ),
        ],
      ),
    );
  }
}
