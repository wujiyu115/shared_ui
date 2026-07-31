import 'package:flutter/material.dart';

import 'tp_dialog_mobile_nav_bar.dart';

/// Simple page chrome for narrow [showTpDialog] page routes.
///
/// Draws a system-style mobile nav bar (leading chevron + centered title) and
/// a bottom SafeArea body. Never used automatically by [showTpDialog]; callers
/// wrap non-[TpDialogNavShell] page content explicitly.
///
/// Do **not** wrap [TpDialogNavShell] — it owns its own nav/detail bars.
class TpDialogPageShell extends StatelessWidget {
  const TpDialogPageShell({
    required this.title,
    required this.child,
    this.onClose,
    this.trailing,
    super.key,
  });

  final String title;
  final Widget child;
  final VoidCallback? onClose;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final close = onClose ?? () => Navigator.of(context).pop();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        TpDialogMobileNavBar(
          title: title,
          onLeading: close,
          leadingTooltip: MaterialLocalizations.of(context).cancelButtonLabel,
          trailing: trailing,
        ),
        Expanded(
          child: SafeArea(
            top: false,
            child: child,
          ),
        ),
      ],
    );
  }
}
