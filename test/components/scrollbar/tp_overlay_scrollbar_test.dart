import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_ui/shared_ui.dart';

Widget _harness({
  required ScrollController controller,
  Axis axis = Axis.vertical,
}) {
  final list = ListView.builder(
    controller: controller,
    itemExtent: 32,
    itemCount: 500,
    itemBuilder: (context, index) => Text('row $index'),
  );
  return MaterialApp(
    home: Scaffold(
      body: Center(
        child: SizedBox(
          width: 300,
          height: 300,
          child: TpOverlayScrollbar(
            controller: controller,
            axis: axis,
            child: axis == Axis.vertical
                ? list
                : SingleChildScrollView(
                    controller: controller,
                    scrollDirection: Axis.horizontal,
                    child: const SizedBox(width: 5000, child: Text('wide')),
                  ),
          ),
        ),
      ),
    ),
  );
}

bool _thumbVisibility(WidgetTester tester) =>
    tester.widget<Scrollbar>(find.byType(Scrollbar)).thumbVisibility ?? false;

void main() {
  testWidgets('thumb stays hidden until the pointer enters the edge strip', (
    tester,
  ) async {
    final controller = ScrollController();
    addTearDown(controller.dispose);
    await tester.pumpWidget(_harness(controller: controller));

    expect(_thumbVisibility(tester), isFalse);

    final gesture = await tester.createGesture(kind: PointerDeviceKind.mouse);
    await gesture.addPointer(location: Offset.zero);
    addTearDown(gesture.removePointer);

    // Middle of the panel, far from the bar: still hidden.
    final rect = tester.getRect(find.byType(TpOverlayScrollbar));
    await gesture.moveTo(rect.center);
    await tester.pump();
    expect(_thumbVisibility(tester), isFalse);

    // Anywhere along the right edge reveals it — not just next to the thumb,
    // which is what vanilla [Scrollbar] hover does.
    await gesture.moveTo(rect.centerRight + const Offset(-4, 0));
    await tester.pump();
    expect(_thumbVisibility(tester), isTrue);
  });

  testWidgets('thumb hides again after the pointer leaves and the delay', (
    tester,
  ) async {
    final controller = ScrollController();
    addTearDown(controller.dispose);
    await tester.pumpWidget(_harness(controller: controller));

    final gesture = await tester.createGesture(kind: PointerDeviceKind.mouse);
    await gesture.addPointer(location: Offset.zero);
    addTearDown(gesture.removePointer);

    final rect = tester.getRect(find.byType(TpOverlayScrollbar));
    await gesture.moveTo(rect.centerRight + const Offset(-4, 0));
    await tester.pump();
    expect(_thumbVisibility(tester), isTrue);

    await gesture.moveTo(rect.center);
    await tester.pump();
    expect(_thumbVisibility(tester), isTrue, reason: 'still inside hide delay');

    await tester.pump(const Duration(milliseconds: 900));
    expect(_thumbVisibility(tester), isFalse);
  });

  testWidgets('horizontal bar reveals from the bottom edge', (tester) async {
    final controller = ScrollController();
    addTearDown(controller.dispose);
    await tester.pumpWidget(
      _harness(controller: controller, axis: Axis.horizontal),
    );

    final gesture = await tester.createGesture(kind: PointerDeviceKind.mouse);
    await gesture.addPointer(location: Offset.zero);
    addTearDown(gesture.removePointer);

    final rect = tester.getRect(find.byType(TpOverlayScrollbar));
    await gesture.moveTo(rect.center);
    await tester.pump();
    expect(_thumbVisibility(tester), isFalse);

    await gesture.moveTo(rect.bottomCenter + const Offset(0, -4));
    await tester.pump();
    expect(_thumbVisibility(tester), isTrue);
  });
}
