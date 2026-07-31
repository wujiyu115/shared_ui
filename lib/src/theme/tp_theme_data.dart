import 'package:flutter/material.dart';

import 'components/tp_button_theme.dart';
import 'components/tp_card_theme.dart';
import 'components/tp_dialog_theme.dart';
import 'components/tp_input_theme.dart';
import 'components/tp_popover_theme.dart';
import 'components/tp_select_theme.dart';
import 'components/tp_separator_theme.dart';
import 'components/tp_sidebar_theme.dart';
import 'components/tp_textarea_theme.dart';
import 'components/tp_toast_theme.dart';
import 'tokens/tp_control_metrics.dart';
import 'tokens/tp_icon_sizes.dart';
import 'tokens/tp_spacing.dart';
import 'tokens/tp_typography.dart';

/// Design-system theme data: tokens built from a [ColorScheme] and UI [scale].
@immutable
class TpThemeData {
  const TpThemeData({
    required this.colorScheme,
    required this.spacing,
    required this.iconSizes,
    required this.typography,
    required this.control,
    this.dialog,
    this.input,
    this.textarea,
    this.popover,
    this.select,
    this.button,
    this.card,
    this.separator,
    this.sidebar,
    this.toast,
  });

  factory TpThemeData.fromColorScheme(
    ColorScheme scheme, {
    required double scale,
    double? iconScale,
    /// Button / input control metrics. Defaults to [scale]. Hosts that keep
    /// layout spacing fixed while text grows should pass the text multiplier.
    double? controlScale,
    TpDialogTheme? dialog,
    TpInputTheme? input,
    TpTextareaTheme? textarea,
    TpPopoverTheme? popover,
    TpSelectTheme? select,
    TpButtonTheme? button,
    TpCardTheme? card,
    TpSeparatorTheme? separator,
    TpSidebarTheme? sidebar,
    TpToastTheme? toast,
  }) {
    final icons = iconScale ?? scale;
    final controls = controlScale ?? scale;
    return TpThemeData(
      colorScheme: scheme,
      spacing: TpSpacing.fromScale(scale),
      iconSizes: TpIconSizes.fromScale(icons),
      typography: TpTypography(scale: scale),
      control: TpControlMetrics.fromScale(controls),
      dialog: dialog,
      input: input,
      textarea: textarea,
      popover: popover,
      select: select,
      button: button,
      card: card,
      separator: separator,
      sidebar: sidebar,
      toast: toast,
    );
  }

  /// Sane defaults when no [TpTheme] ancestor is present.
  factory TpThemeData.fallback() => TpThemeData.fromColorScheme(
    ColorScheme.fromSeed(seedColor: const Color(0xFFD4A06A)),
    scale: 1.0,
  );

  /// Stored for future component themes; tokens themselves are scale-driven.
  final ColorScheme colorScheme;
  final TpSpacing spacing;
  final TpIconSizes iconSizes;
  final TpTypography typography;
  final TpControlMetrics control;

  /// Optional dialog metrics override; resolved via [dialogTheme].
  final TpDialogTheme? dialog;

  /// Optional outline-input metrics override; resolved via [inputTheme].
  final TpInputTheme? input;

  /// Optional textarea metrics override; resolved via [textareaTheme].
  final TpTextareaTheme? textarea;

  /// Optional popover metrics override; resolved via [popoverTheme].
  final TpPopoverTheme? popover;

  /// Optional select metrics override; resolved via [selectTheme].
  final TpSelectTheme? select;

  /// Optional button metrics override; resolved via [buttonTheme].
  final TpButtonTheme? button;

  /// Optional card metrics override; resolved via [cardTheme].
  final TpCardTheme? card;

  /// Optional separator metrics override; resolved via [separatorTheme].
  final TpSeparatorTheme? separator;

  /// Optional sidebar metrics override; resolved via [sidebarTheme].
  final TpSidebarTheme? sidebar;

  /// Optional toast metrics override; resolved via [toastTheme].
  final TpToastTheme? toast;

  /// Resolved dialog theme (defaults when [dialog] is null).
  TpDialogTheme get dialogTheme => dialog ?? TpDialogTheme.defaults();

  /// Resolved input theme (defaults when [input] is null).
  TpInputTheme get inputTheme => input ?? TpInputTheme.defaults();

  /// Resolved textarea theme (defaults when [textarea] is null).
  TpTextareaTheme get textareaTheme => textarea ?? TpTextareaTheme.defaults();

  /// Resolved popover theme (defaults when [popover] is null).
  TpPopoverTheme get popoverTheme => popover ?? TpPopoverTheme.defaults();

  /// Resolved select theme (defaults when [select] is null).
  TpSelectTheme get selectTheme => select ?? TpSelectTheme.defaults();

  /// Resolved button theme (defaults when [button] is null).
  TpButtonTheme get buttonTheme => button ?? TpButtonTheme.defaults();

  /// Resolved card theme (defaults when [card] is null).
  TpCardTheme get cardTheme => card ?? TpCardTheme.defaults();

  /// Resolved separator theme (defaults when [separator] is null).
  TpSeparatorTheme get separatorTheme =>
      separator ?? TpSeparatorTheme.defaults();

  /// Resolved sidebar theme (defaults from [colorScheme] when [sidebar] is null).
  TpSidebarTheme get sidebarTheme =>
      sidebar ?? TpSidebarTheme.fromColorScheme(colorScheme);

  /// Resolved toast theme (defaults from [colorScheme] when [toast] is null).
  TpToastTheme get toastTheme =>
      toast ?? TpToastTheme.fromColorScheme(colorScheme);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TpThemeData &&
          colorScheme == other.colorScheme &&
          spacing == other.spacing &&
          iconSizes == other.iconSizes &&
          typography == other.typography &&
          control == other.control &&
          dialogTheme == other.dialogTheme &&
          inputTheme == other.inputTheme &&
          textareaTheme == other.textareaTheme &&
          popoverTheme == other.popoverTheme &&
          selectTheme == other.selectTheme &&
          buttonTheme == other.buttonTheme &&
          cardTheme == other.cardTheme &&
          separatorTheme == other.separatorTheme &&
          sidebarTheme == other.sidebarTheme &&
          toastTheme == other.toastTheme;

  @override
  int get hashCode => Object.hash(
    colorScheme,
    spacing,
    iconSizes,
    typography,
    control,
    dialogTheme,
    inputTheme,
    textareaTheme,
    popoverTheme,
    selectTheme,
    buttonTheme,
    cardTheme,
    separatorTheme,
    sidebarTheme,
    toastTheme,
  );
}
