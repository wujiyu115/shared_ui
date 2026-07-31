# shared_ui

TeamPilot **Tp** design system — reusable Flutter UI primitives (`Tp*`) and theme tokens.

## Theme

Wrap the app with `TpTheme`. Prefer `TpTextStyles.of(context)` for semantic text,
`context.tpFonts` for families, and `TpGlyphWarmup` for boot glyph shaping:

```dart
import 'package:shared_ui/shared_ui.dart';

MaterialApp(
  theme: ThemeData(
    extensions: [
      TpFontTheme(
        uiFontFamily: 'Noto Sans SC',
        monoFontFamily: 'JetBrains Mono',
        monoFontFamilyFallback: const ['monospace'],
      ),
    ],
  ),
  builder: (context, child) {
    return TpTheme(
      data: TpThemeData.fromColorScheme(
        Theme.of(context).colorScheme,
        scale: 1.0, // layout spacing
        iconScale: iconMultiplier,
        controlScale: textMultiplier, // buttons/inputs track text size
      ),
      child: child ?? const SizedBox.shrink(),
    );
  },
);

// Boot warmup (host supplies glyphs charset):
final styles = TpGlyphWarmup.dedupeByShapeKey([
  ...TpTextStyles(theme).stylesForWarmup(),
  ...hostExtras,
]);
TpGlyphWarmup.shapeAll(styles: styles, glyphs: warmupGlyphs);
```

In `pubspec.yaml`:

```yaml
dependencies:
  shared_ui:
    path: packages/shared_ui
```

```dart
import 'package:shared_ui/shared_ui.dart';
```

## Component categories

| Category | Examples |
|----------|----------|
| **Button** | `TpButton`, `TpIconButton` |
| **Input** | `TpInput`, `TpInputFormField`, `TpTextarea`, `TpTextareaFormField` |
| **Token field** | `TpTokenTextField`, `TpTokenChipMirror`, palette typedefs / edit helpers (`applyTpTokenBackspace`, …) |
| **Select** | `TpSelect`, `TpSelectWithCustomInput`, search / filter helpers |
| **Dialog** | `TpDialog`, `showTpDialog`, `TpDialogPresentation`, `TpDialogPageShell`, `TpDialogNavShell` |
| **Form** | `TpForm`, `TpFormField`, `TpFormFieldLayout`, `TpFormMap` |
| **Overlay** | `TpPopover`, `TpTooltip`, `TpActionMenu` / `TpActionMenuPanel` |
| **Date range** | `TpDateRangePicker`, `TpRangeCalendar`, calendar date utils |
| **Toast** | `TpToast`, `TpToastWrapper`, `TpToastConfig`, `TpToastTheme`, `TpToastVariant`, `TpToastAction` |
| **Layout / chrome** | `TpCard`, `TpCardHeader`, `TpActionRow`, `TpSeparator`, `TpSegmentedControl`, `TpSegmentedPicker`, `TpEmptyState`, `TpHover` / `TpHoverRow`, `TpSidebar` |
| **Deferred / keep-alive** | `TpDeferredMountShell`, `TpDeferredMountAfter`, `TpDeferredForegroundMount`, `TpKeepAliveLayer` — host progressive paint guide (TeamPilot: `docs/PERFORMANCE.md`) |
| **Preference** | `TpPreferenceRow`, `TpPreferenceStack`, `TpSectionHeader`, `TpDisclosure`, `TpStatusBadge`, `TpCompactSelect` |
| **Theme** | `TpTheme`, `TpThemeData`, `TpTextStyles`, `TpFontTheme`, `TpGlyphWarmup`, icon sizes (`sm`/`md`/`lg`/`hero`), spacing / typography / control metrics, per-component themes |

Toast engine sources live under `lib/src/toast/engine/` and are **not** barrel-exported.

## TpSidebar

Composable workspace sidebar: wrap the shell in `TpSidebarProvider`, place `TpSidebar`
beside `TpSidebarInset` (or use `TpSidebarMenu` / `TpSidebarTrigger` inside).

- **State:** `TpSidebarProvider` owns desktop `open` + `width` and mobile `openMobile`.
  Read or mutate via `TpSidebarScope.of(context)` / `maybeOf`.
- **Mobile drawer:** below `mobileBreakpoint` (default `768`), the sidebar becomes a hidden
  overlay drawer opened by `TpSidebarTrigger` or edge drag. Close with
  `TpSidebarScope.maybeOf(context)?.setOpenMobile(false)` after navigation.
- **Overlay ownership:** when several `TpSidebar`s share one provider (kept-alive home +
  workspace tabs), only the foreground instance sets `overlayActive: true`. Losing
  ownership (`true` → `false`) closes shared `openMobile`; already-inactive hosts never
  mutate that flag.
- **Mobile drawer width** (`TpSidebarTheme`):
  - `widthMobileFraction` — fraction of viewport width (default `0.8`).
  - `widthMobileOverride` — optional fixed px; wins over fraction when set.
  - `resolveMobileDrawerWidth(screenWidth)` — shared resolver for left drawer and host
    right overlays (`widthMobileOverride ?? screenWidth * widthMobileFraction`).
  - `widthMobile` — legacy fixed default (`288`); not used by `resolveMobileDrawerWidth`.
- **Hosts:** TeamPilot relies on fraction (`widthMobileOverride: null`). huji can pin
  `widthMobileOverride: 288` until it opts into fraction.
- **Breakpoint:** package default `768`; TeamPilot passes `840`
  (`WorkspacePanePolicy.narrowBreakpointWidth`) on `TpSidebarProvider`, `showTpDialog`,
  and `TpDialogNavShell`.

```dart
TpSidebarProvider(
  mobileBreakpoint: 840,
  child: Row(
    children: [
      TpSidebar(child: /* menu */),
      Expanded(child: TpSidebarInset(child: /* main */)),
    ],
  ),
);
```

## Dialogs (`showTpDialog`)

`showTpDialog` presents modal content as a centered card or a full-bleed page on narrow
viewports. Use `TpDialogPresentation.card` (default) for short confirms; use `.page` for
large management surfaces.

- **`TpDialogPresentation.card`** — `showDialog` + caller returns `TpDialog` (or equivalent).
- **`TpDialogPresentation.page`** — below `mobileBreakpoint`, `showGeneralDialog` mounts a
  zero-inset fullscreen `Material` surface; on wide, wraps content in a constrained `TpDialog`.
- **Chrome ownership:** `showTpDialog` does **not** add an app bar. Callers choose:
  - **`TpDialogPageShell`** — simple pages: title row + close + body (wrap explicitly).
  - **`TpDialogNavShell`** — dual-pane nav + detail; owns narrow nav/detail bars.
    **Never** wrap `TpDialogNavShell` in `TpDialogPageShell`.

```dart
// Simple page (settings list, editor form, …)
showTpDialog<void>(
  context: context,
  presentation: TpDialogPresentation.page,
  mobileBreakpoint: 840,
  builder: (ctx) => TpDialogPageShell(
    title: 'Automations',
    child: AutomationsBody(),
  ),
);

// Dual-pane settings (nav list → detail on narrow)
showTpDialog<void>(
  context: context,
  presentation: TpDialogPresentation.page,
  mobileBreakpoint: 840,
  builder: (ctx) => TpDialogNavShell(
    mobileBreakpoint: 840,
    navTitle: (ctx) => 'Settings',
    entries: [/* TpDialogNavEntry … */],
  ),
);
```

## Layout

- `lib/src/components/` — `Tp*` widgets by category
- `lib/src/deferred/` — progressive mount / keep-alive primitives
- `lib/src/theme/` — `TpTheme` / `TpThemeData`, tokens, component themes
- `lib/src/toast/engine/` — private toast overlay engine (not public API)
- `lib/shared_ui.dart` — public barrel export
