import 'package:flutter/material.dart';

import '../../theme/tp_text_styles.dart';
import '../../theme/tp_theme.dart';
import '../../toast/engine/toastification.dart';

enum TpToastVariant { info, success, warning, error }

/// Optional action button on a toast.
final class TpToastAction {
  const TpToastAction({required this.label, required this.onPressed});

  final String label;
  final VoidCallback onPressed;
}

/// Transient feedback toasts backed by the private overlay engine.
abstract final class TpToast {
  static Duration defaultDuration(
    TpToastVariant variant, {
    bool hasAction = false,
  }) {
    if (hasAction) return const Duration(seconds: 8);
    return switch (variant) {
      TpToastVariant.success => const Duration(seconds: 2),
      TpToastVariant.info => const Duration(seconds: 3),
      TpToastVariant.warning => const Duration(seconds: 4),
      TpToastVariant.error => const Duration(seconds: 5),
    };
  }

  static void show(
    BuildContext context, {
    required String message,
    TpToastVariant variant = TpToastVariant.info,
    TpToastAction? action,
    Duration? duration,
  }) {
    final trimmed = message.trim();
    if (trimmed.isEmpty || !context.mounted) return;

    toastification.dismissAll(delayForAnimation: false);

    final toastTheme = TpTheme.of(context).toastTheme;
    final accentColor = toastTheme.accentFor(variant);
    final effectiveDuration =
        duration ?? defaultDuration(variant, hasAction: action != null);

    final config = ToastificationConfigProvider.maybeOf(context)?.config;
    final animationDuration =
        config?.animationDuration ?? const Duration(milliseconds: 200);

    toastification.show(
      context: context,
      type: _toastificationTypeFor(variant),
      style: ToastificationStyle.flat,
      autoCloseDuration: effectiveDuration,
      animationDuration: animationDuration,
      primaryColor: accentColor,
      backgroundColor: toastTheme.backgroundColor,
      foregroundColor: toastTheme.foregroundColor,
      borderRadius: toastTheme.borderRadius,
      borderSide: toastTheme.borderSide,
      boxShadow: toastTheme.boxShadow,
      padding: toastTheme.padding,
      dragToClose: false,
      pauseOnHover: true,
      showIcon: true,
      icon: Icon(
        _toastificationTypeFor(variant).icon,
        color: accentColor,
        size: toastTheme.iconSize,
      ),
      closeButton: const ToastCloseButton(showType: CloseButtonShowType.always),
      title: _buildTitle(
        context: context,
        message: trimmed,
        foregroundColor: toastTheme.foregroundColor,
        accentColor: accentColor,
        action: action,
      ),
      callbacks: ToastificationCallbacks(
        onCloseButtonTap: (item) {
          toastification.dismiss(item, showRemoveAnimation: true);
        },
      ),
    );
  }

  static void dismiss() {
    toastification.dismissAll(delayForAnimation: false);
  }

  static ToastificationType _toastificationTypeFor(TpToastVariant variant) =>
      switch (variant) {
        TpToastVariant.info => ToastificationType.info,
        TpToastVariant.success => ToastificationType.success,
        TpToastVariant.warning => ToastificationType.warning,
        TpToastVariant.error => ToastificationType.error,
      };

  static Widget _buildTitle({
    required BuildContext context,
    required String message,
    required Color foregroundColor,
    required Color accentColor,
    TpToastAction? action,
  }) {
    final styles = TpTextStyles.of(context);
    final messageStyle = styles.mdColored(foregroundColor);

    if (action == null) {
      return Text(message, style: messageStyle, maxLines: 3);
    }

    return Row(
      children: [
        Expanded(child: Text(message, style: messageStyle, maxLines: 3)),
        TextButton(
          onPressed: () {
            dismiss();
            action.onPressed();
          },
          // Geometry comes from the ambient TextButtonTheme, which owns both
          // the minimum and the maximum; a local minimum taller than the
          // theme's height cap produced non-normalized constraints on compact
          // control scales (min 32 > max 26 → render error).
          style: TextButton.styleFrom(foregroundColor: accentColor),
          child: Text(
            action.label,
            style: styles.mdSemiboldColored(foregroundColor),
          ),
        ),
      ],
    );
  }
}
