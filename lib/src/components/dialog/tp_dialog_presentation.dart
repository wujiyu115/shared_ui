/// How [showTpDialog] presents its content.
enum TpDialogPresentation {
  /// Centered card dialog via [showDialog]. Callers typically return [TpDialog].
  card,

  /// Full-bleed page on narrow viewports; constrained card on wide.
  page,
}
