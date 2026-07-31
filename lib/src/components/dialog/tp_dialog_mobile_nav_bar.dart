import 'package:flutter/material.dart';

import '../../theme/tp_theme.dart';
import '../icon_button/tp_icon_button.dart';

/// Minimal mobile page nav bar: leading chevron + centered title.
///
/// Matches system-style settings chrome (flat, no bottom rule, no trailing
/// close). Leading defaults to [Icons.chevron_left_rounded].
class TpDialogMobileNavBar extends StatelessWidget {
  const TpDialogMobileNavBar({
    required this.title,
    required this.onLeading,
    this.leadingTooltip,
    this.trailing,
    super.key,
  });

  final String title;
  final VoidCallback onLeading;
  final String? leadingTooltip;
  final Widget? trailing;

  static const double height = 48;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final spacing = context.tpSpacing;
    final iconSizes = context.tpIconSizes;
    final l10n = MaterialLocalizations.of(context);
    final titleStyle = (Theme.of(context).textTheme.titleMedium ??
            const TextStyle())
        .copyWith(
          fontWeight: FontWeight.w600,
          height: 1.2,
          color: cs.onSurface,
        );

    return SafeArea(
      bottom: false,
      child: SizedBox(
        height: height,
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: spacing.sm),
          child: Stack(
            alignment: Alignment.center,
            children: [
              // Centered title (independent of leading/trailing width).
              Padding(
                padding: EdgeInsets.symmetric(horizontal: spacing.xxl),
                child: Text(
                  title,
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: titleStyle,
                ),
              ),
              Row(
                children: [
                  TpIconButton(
                    icon: Icons.chevron_left_rounded,
                    tooltip: leadingTooltip ?? l10n.backButtonTooltip,
                    compact: true,
                    iconSize: iconSizes.lg,
                    color: cs.onSurface,
                    onTap: onLeading,
                  ),
                  const Spacer(),
                  if (trailing != null) trailing!,
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
