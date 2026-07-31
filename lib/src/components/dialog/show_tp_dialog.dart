import 'package:flutter/material.dart';

import '../../theme/tp_theme.dart';
import 'tp_dialog.dart';
import 'tp_dialog_presentation.dart';

/// Default max width for [TpDialogPresentation.page] on wide viewports.
const double kTpDialogPageWideMaxWidth = 1160;

/// Default max height for [TpDialogPresentation.page] on wide viewports.
const double kTpDialogPageWideMaxHeight = 960;

/// Presents a modal dialog as a centered card or a full-bleed page on narrow.
///
/// When [presentation] is [TpDialogPresentation.page] and the viewport width is
/// below [mobileBreakpoint], uses [showGeneralDialog] with a zero-inset
/// fullscreen [Material] surface. The [builder] is mounted as-is — wrap simple
/// pages in [TpDialogPageShell]; dual-pane hosts use [TpDialogNavShell] alone.
///
/// Otherwise uses [showDialog]. For [TpDialogPresentation.card], [builder]
/// should return a [TpDialog] (or equivalent). For page on wide, the result is
/// wrapped in [TpDialog] with [maxWidth] / [maxHeight] defaults suited to
/// management dialogs ([kTpDialogPageWideMaxWidth] / [kTpDialogPageWideMaxHeight]).
Future<T?> showTpDialog<T>({
  required BuildContext context,
  required WidgetBuilder builder,
  TpDialogPresentation presentation = TpDialogPresentation.card,
  double mobileBreakpoint = 768,
  bool barrierDismissible = true,
  bool useRootNavigator = true,
  RouteSettings? routeSettings,
  Color? barrierColor,
  /// Optional dialog/page surface. Prefer leaving null so [TpDialog] /
  /// fullscreen [Material] resolve [ColorScheme] live — a Theme-captured
  /// [Color] freezes at open and will not follow theme toggles.
  Color? backgroundColor,
  double? maxWidth,
  double? maxHeight,
}) {
  final isNarrow = MediaQuery.sizeOf(context).width < mobileBreakpoint;

  if (presentation == TpDialogPresentation.page && isNarrow) {
    return showGeneralDialog<T>(
      context: context,
      barrierDismissible: barrierDismissible,
      barrierLabel: MaterialLocalizations.of(context).modalBarrierDismissLabel,
      barrierColor:
          barrierColor ??
          Theme.of(context).dialogTheme.barrierColor ??
          Colors.black.withValues(
            alpha: context.tpTheme.dialogTheme.barrierAlpha,
          ),
      useRootNavigator: useRootNavigator,
      routeSettings: routeSettings,
      pageBuilder: (dialogContext, animation, secondaryAnimation) {
        return Material(
          type: MaterialType.canvas,
          color:
              backgroundColor ??
              Theme.of(dialogContext).colorScheme.surface,
          child: SizedBox.expand(child: builder(dialogContext)),
        );
      },
      transitionBuilder: (context, animation, secondaryAnimation, child) {
        return FadeTransition(opacity: animation, child: child);
      },
    );
  }

  return showDialog<T>(
    context: context,
    barrierDismissible: barrierDismissible,
    barrierColor: barrierColor,
    useRootNavigator: useRootNavigator,
    routeSettings: routeSettings,
    builder: (dialogContext) {
      final content = builder(dialogContext);
      if (presentation == TpDialogPresentation.page) {
        return TpDialog(
          maxWidth: maxWidth ?? kTpDialogPageWideMaxWidth,
          maxHeight: maxHeight ?? kTpDialogPageWideMaxHeight,
          contentPadding: EdgeInsets.zero,
          backgroundColor: backgroundColor,
          child: content,
        );
      }
      return content;
    },
  );
}
