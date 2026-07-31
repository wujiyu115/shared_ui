import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_ui/shared_ui.dart';

Widget _wrap({required Widget child}) {
  final scheme = ColorScheme.fromSeed(seedColor: Colors.indigo);
  return MaterialApp(
    theme: ThemeData(
      colorScheme: scheme,
      useMaterial3: true,
      dialogTheme: buildTpDialogTheme(
        colorScheme: scheme,
        textTheme: ThemeData.light().textTheme,
      ),
    ),
    home: TpTheme(
      data: TpThemeData.fromColorScheme(scheme, scale: 1.0),
      child: child,
    ),
  );
}

Future<void> _pumpSized(WidgetTester tester, Size size, Widget child) async {
  tester.view.physicalSize = size;
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
  await tester.pumpWidget(_wrap(child: child));
}

List<TpDialogNavEntry> _testEntries() => [
  TpDialogNavEntry(
    icon: Icons.home_outlined,
    navLabel: (_) => 'Section A',
    title: (_) => 'Section A Title',
    subtitle: (_) => 'Section A subtitle',
    bodyBuilder: (_) => const Text('body-a'),
  ),
  TpDialogNavEntry(
    icon: Icons.settings_outlined,
    navLabel: (_) => 'Section B',
    title: (_) => 'Section B Title',
    subtitle: (_) => 'Section B subtitle',
    bodyBuilder: (_) => const Text('body-b'),
  ),
];

Widget _navShell({int initialIndex = 0, VoidCallback? onClose}) {
  return TpDialogNavShell(
    navTitle: (_) => 'Settings',
    entries: _testEntries(),
    initialIndex: initialIndex,
    onClose: onClose,
  );
}

Future<void> _openNarrowNavShell(
  WidgetTester tester, {
  int initialIndex = 0,
}) async {
  await _pumpSized(
    tester,
    const Size(400, 800),
    Builder(
      builder: (context) => Scaffold(
        body: TextButton(
          onPressed: () {
            showTpDialog<void>(
              context: context,
              presentation: TpDialogPresentation.page,
              mobileBreakpoint: 768,
              builder: (dialogContext) => _navShell(
                initialIndex: initialIndex,
                onClose: () => Navigator.of(dialogContext).pop(),
              ),
            );
          },
          child: const Text('open'),
        ),
      ),
    ),
  );

  await tester.tap(find.text('open'));
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('wide: nav and body visible; tap changes body', (tester) async {
    await _pumpSized(tester, const Size(1200, 800), _navShell());

    expect(find.text('Settings'), findsOneWidget);
    expect(find.text('Section A'), findsOneWidget);
    expect(find.text('Section B'), findsOneWidget);
    expect(find.text('Section A Title'), findsOneWidget);
    expect(find.text('body-a'), findsOneWidget);
    expect(find.text('body-b'), findsNothing);

    await tester.tap(find.text('Section B'));
    await tester.pumpAndSettle();

    expect(find.text('Section B Title'), findsOneWidget);
    expect(find.text('body-b'), findsOneWidget);
    expect(find.text('body-a'), findsNothing);
  });

  testWidgets('narrow: nav then detail; back; leading dismisses dialog', (
    tester,
  ) async {
    await _openNarrowNavShell(tester);

    expect(find.byType(TpDialogPageShell), findsNothing);
    expect(find.text('Settings'), findsOneWidget);
    expect(find.text('Section A'), findsOneWidget);
    expect(find.text('Section A Title'), findsNothing);
    expect(find.text('body-a'), findsNothing);
    expect(find.byIcon(Icons.chevron_left_rounded), findsOneWidget);
    expect(find.byIcon(Icons.close_rounded), findsNothing);

    await tester.tap(find.text('Section A'));
    await tester.pumpAndSettle();

    expect(find.text('Section A Title'), findsOneWidget);
    expect(find.text('body-a'), findsOneWidget);
    // Detail uses leading chevron for back (same icon as nav dismiss).
    expect(find.byIcon(Icons.chevron_left_rounded), findsOneWidget);
    expect(find.byIcon(Icons.close_rounded), findsNothing);

    await tester.tap(find.byIcon(Icons.chevron_left_rounded));
    await tester.pumpAndSettle();

    expect(find.text('Settings'), findsOneWidget);
    expect(find.text('Section A Title'), findsNothing);
    expect(find.text('body-a'), findsNothing);

    await tester.tap(find.byIcon(Icons.chevron_left_rounded));
    await tester.pumpAndSettle();

    expect(find.text('Settings'), findsNothing);
    expect(find.text('open'), findsOneWidget);
  });

  testWidgets('narrow: initialIndex opens detail; back returns to nav', (
    tester,
  ) async {
    await _openNarrowNavShell(tester, initialIndex: 1);

    expect(find.text('Settings'), findsNothing);
    expect(find.text('Section B Title'), findsOneWidget);
    expect(find.text('body-b'), findsOneWidget);

    await tester.pageBack();
    await tester.pumpAndSettle();

    expect(find.text('Settings'), findsOneWidget);
    expect(find.text('Section B Title'), findsNothing);
    expect(find.text('body-b'), findsNothing);
  });

  testWidgets('narrow nav route has a single top bar without PageShell', (
    tester,
  ) async {
    await _openNarrowNavShell(tester);

    expect(find.byType(TpDialogPageShell), findsNothing);
    expect(find.byType(TpDialogNavShell), findsOneWidget);
    expect(find.byType(TpDialogMobileNavBar), findsOneWidget);
    expect(find.byIcon(Icons.chevron_left_rounded), findsOneWidget);
    expect(find.byIcon(Icons.close_rounded), findsNothing);
  });

  testWidgets('onSelectedIndexChanged fires when selection changes', (
    tester,
  ) async {
    var selectedIndex = 0;
    await _pumpSized(
      tester,
      const Size(1200, 800),
      TpDialogNavShell(
        navTitle: (_) => 'Settings',
        entries: _testEntries(),
        onSelectedIndexChanged: (index) => selectedIndex = index,
      ),
    );

    expect(selectedIndex, 0);

    await tester.tap(find.text('Section B'));
    await tester.pumpAndSettle();

    expect(selectedIndex, 1);
  });
}
