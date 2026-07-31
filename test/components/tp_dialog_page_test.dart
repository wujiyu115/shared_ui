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

void main() {
  testWidgets('page+narrow uses fullscreen surface with PageShell', (
    tester,
  ) async {
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
                builder: (ctx) => TpDialogPageShell(
                  title: 'Automations',
                  child: const Text('page-body'),
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

    expect(find.byType(Dialog), findsNothing);
    expect(find.text('Automations'), findsOneWidget);
    expect(find.text('page-body'), findsOneWidget);

    final shellRect = tester.getRect(find.byType(TpDialogPageShell));
    expect(shellRect.width, closeTo(400, 0.5));
    expect(shellRect.height, closeTo(800, 0.5));

    await tester.tap(find.byIcon(Icons.chevron_left_rounded));
    await tester.pumpAndSettle();
    expect(find.text('Automations'), findsNothing);
  });

  testWidgets('page+wide uses constrained card, not full-bleed', (
    tester,
  ) async {
    await _pumpSized(
      tester,
      const Size(1200, 800),
      Builder(
        builder: (context) => Scaffold(
          body: TextButton(
            onPressed: () {
              showTpDialog<void>(
                context: context,
                presentation: TpDialogPresentation.page,
                mobileBreakpoint: 768,
                builder: (ctx) => TpDialogPageShell(
                  title: 'Settings',
                  child: const Text('wide-body'),
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

    expect(find.byType(Dialog), findsOneWidget);
    expect(find.byType(TpDialog), findsOneWidget);

    final shellRect = tester.getRect(find.byType(TpDialogPageShell));
    expect(shellRect.width, lessThan(1200));
    expect(shellRect.width, closeTo(kTpDialogPageWideMaxWidth, 48));
  });

  testWidgets('card+narrow still shows centered TpDialog', (tester) async {
    await _pumpSized(
      tester,
      const Size(400, 800),
      Builder(
        builder: (context) => Scaffold(
          body: TextButton(
            onPressed: () {
              showTpDialog<void>(
                context: context,
                presentation: TpDialogPresentation.card,
                mobileBreakpoint: 768,
                builder: (ctx) => TpDialog(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: const [
                      TpDialogHeader(title: 'Confirm'),
                      Text('card-body'),
                    ],
                  ),
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

    expect(find.byType(TpDialog), findsOneWidget);
    expect(find.byType(Dialog), findsOneWidget);
    expect(find.text('Confirm'), findsOneWidget);
    expect(find.text('card-body'), findsOneWidget);

    final dialogRect = tester.getRect(find.byType(Dialog));
    expect(dialogRect.width, lessThanOrEqualTo(400));
  });
}
