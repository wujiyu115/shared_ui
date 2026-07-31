import 'package:flutter/material.dart';

import '../../theme/tp_text_styles.dart';
import '../../theme/tp_theme.dart';

/// State of one [TpStepItem] in a [TpStepRail].
enum TpStepStatus { idle, active, done, fail }

/// One step: a short [label], its [status], and an optional [note] line under it
/// (a hint while pending, the reason once failed).
@immutable
class TpStepItem {
  const TpStepItem({required this.label, this.status = TpStepStatus.idle, this.note});

  final String label;
  final TpStepStatus status;
  final String? note;
}

/// Vertical progress rail: numbered marks joined by a hairline, one per step.
///
/// Determinate by design — a completed step lights its rail segment instead of
/// pulsing, so the caller must drive [items] from real progress. The active mark
/// is a filled dot, never a spinner: a rail with four spinners reads as four
/// concurrent operations.
///
/// Hosts supply all copy; the package holds no product strings.
class TpStepRail extends StatelessWidget {
  const TpStepRail({super.key, required this.items});

  final List<TpStepItem> items;

  static const double _markSize = 20;
  static const double _railWidth = 1.5;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (var i = 0; i < items.length; i++)
          _TpStep(
            item: items[i],
            index: i,
            isLast: i == items.length - 1,
            markSize: _markSize,
            railWidth: _railWidth,
          ),
      ],
    );
  }
}

class _TpStep extends StatelessWidget {
  const _TpStep({
    required this.item,
    required this.index,
    required this.isLast,
    required this.markSize,
    required this.railWidth,
  });

  final TpStepItem item;
  final int index;
  final bool isLast;
  final double markSize;
  final double railWidth;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final styles = TpTextStyles.of(context);
    final spacing = context.tpSpacing;
    final accent = switch (item.status) {
      TpStepStatus.idle => cs.outlineVariant,
      TpStepStatus.active => cs.primary,
      TpStepStatus.done => cs.tertiary,
      TpStepStatus.fail => cs.error,
    };
    final labelColor = switch (item.status) {
      TpStepStatus.idle => cs.onSurfaceVariant,
      TpStepStatus.active => cs.onSurface,
      TpStepStatus.done => cs.onSurfaceVariant,
      TpStepStatus.fail => cs.error,
    };
    final noteColor = item.status == TpStepStatus.fail
        ? cs.error
        : cs.onSurfaceVariant;

    // IntrinsicHeight so the rail segment (an Expanded in an unbounded Column)
    // can stretch to the label block's height.
    return IntrinsicHeight(
      child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: markSize,
          child: Column(
            children: [
              _StepMark(
                index: index,
                status: item.status,
                accent: accent,
                size: markSize,
              ),
              if (!isLast)
                Expanded(
                  child: Container(
                    width: railWidth,
                    // A done step lights the segment below it: progress reads
                    // top-down without any animation.
                    color: item.status == TpStepStatus.done
                        ? cs.tertiary
                        : cs.outlineVariant,
                  ),
                ),
            ],
          ),
        ),
        SizedBox(width: spacing.md),
        Expanded(
          child: Padding(
            padding: EdgeInsets.only(bottom: isLast ? 0 : spacing.lg),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(item.label, style: styles.smMediumColored(labelColor)),
                if (item.note != null && item.note!.isNotEmpty) ...[
                  SizedBox(height: spacing.xxs),
                  Text(item.note!, style: styles.xsColored(noteColor)),
                ],
              ],
            ),
          ),
        ),
      ],
      ),
    );
  }
}

class _StepMark extends StatelessWidget {
  const _StepMark({
    required this.index,
    required this.status,
    required this.accent,
    required this.size,
  });

  final int index;
  final TpStepStatus status;
  final Color accent;
  final double size;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final styles = TpTextStyles.of(context);
    return Container(
      width: size,
      height: size,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: status == TpStepStatus.idle
            ? cs.surface
            : accent.withValues(alpha: 0.16),
        border: Border.all(color: accent, width: 1.5),
      ),
      child: switch (status) {
        TpStepStatus.done => Icon(Icons.check, size: size * 0.6, color: accent),
        TpStepStatus.fail => Icon(Icons.close, size: size * 0.6, color: accent),
        // Filled dot, not a spinner — see class docs.
        TpStepStatus.active => Container(
          width: size * 0.36,
          height: size * 0.36,
          decoration: BoxDecoration(shape: BoxShape.circle, color: accent),
        ),
        TpStepStatus.idle => Text(
          '${index + 1}',
          style: styles.xsColored(accent),
        ),
      },
    );
  }
}
