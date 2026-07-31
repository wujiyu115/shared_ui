import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_ui/shared_ui.dart';

void main() {
  Future<void> pump(WidgetTester tester, List<TpStepItem> items) {
    return tester.pumpWidget(
      MaterialApp(
        home: TpTheme(
          data: TpThemeData.fromColorScheme(
            ColorScheme.fromSeed(seedColor: Colors.indigo),
            scale: 1.0,
          ),
          child: Scaffold(body: TpStepRail(items: items)),
        ),
      ),
    );
  }

  testWidgets('pending steps show their position and note', (tester) async {
    await pump(tester, const [
      TpStepItem(label: 'First', note: 'waiting'),
      TpStepItem(label: 'Second'),
    ]);

    expect(find.text('First'), findsOneWidget);
    expect(find.text('waiting'), findsOneWidget);
    // Idle marks are numbered 1..n.
    expect(find.text('1'), findsOneWidget);
    expect(find.text('2'), findsOneWidget);
  });

  testWidgets('an active step drops its number for a filled dot',
      (tester) async {
    await pump(tester, const [
      TpStepItem(label: 'First', status: TpStepStatus.active),
      TpStepItem(label: 'Second'),
    ]);

    expect(find.text('1'), findsNothing);
    expect(find.text('2'), findsOneWidget);
    // Determinate by design — an in-flight step must not spin.
    expect(find.byType(CircularProgressIndicator), findsNothing);
  });

  testWidgets('done and failed steps swap in their own marks', (tester) async {
    await pump(tester, const [
      TpStepItem(label: 'First', status: TpStepStatus.done),
      TpStepItem(label: 'Second', status: TpStepStatus.fail, note: 'timed out'),
      TpStepItem(label: 'Third'),
    ]);

    expect(find.byIcon(Icons.check), findsOneWidget);
    expect(find.byIcon(Icons.close), findsOneWidget);
    expect(find.text('timed out'), findsOneWidget);
    // Only the untouched step keeps a number, and it keeps its own index.
    expect(find.text('3'), findsOneWidget);
    expect(find.text('1'), findsNothing);
    expect(find.text('2'), findsNothing);
  });
}
