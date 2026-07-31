import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_ui/shared_ui.dart';

Widget _wrapMobile({
  required Widget child,
  Widget? content,
  bool? openMobile,
  ValueChanged<bool>? onOpenMobileChange,
  bool edgeOpenEnabled = true,
}) {
  final scheme = ColorScheme.fromSeed(seedColor: Colors.teal);
  return MediaQuery(
    data: const MediaQueryData(size: Size(400, 800)),
    child: MaterialApp(
      theme: ThemeData(colorScheme: scheme, useMaterial3: true),
      home: TpTheme(
        data: TpThemeData.fromColorScheme(scheme, scale: 1.0),
        child: TpSidebarProvider(
          mobileBreakpoint: 840,
          openMobile: openMobile,
          onOpenMobileChange: onOpenMobileChange,
          edgeOpenEnabled: edgeOpenEnabled,
          child: Row(
            children: [
              child,
              Expanded(child: content ?? const SizedBox()),
            ],
          ),
        ),
      ),
    ),
  );
}

void main() {
  testWidgets('controlled openMobile follows parent value', (tester) async {
    var openMobile = false;
    late StateSetter setParent;

    await tester.pumpWidget(
      StatefulBuilder(
        builder: (context, setState) {
          setParent = setState;
          return _wrapMobile(
            openMobile: openMobile,
            onOpenMobileChange: (v) => setState(() => openMobile = v),
            child: const TpSidebar(child: Text('drawer-body')),
          );
        },
      ),
    );
    expect(find.text('drawer-body'), findsNothing);

    setParent(() => openMobile = true);
    await tester.pumpAndSettle();
    expect(find.text('drawer-body'), findsOneWidget);
  });

  testWidgets('edgeOpenEnabled is exposed on scope', (tester) async {
    await tester.pumpWidget(
      _wrapMobile(
        edgeOpenEnabled: false,
        child: const TpSidebar(child: Text('drawer-body')),
        content: Builder(
          builder: (context) {
            expect(TpSidebarScope.of(context).edgeOpenEnabled, isFalse);
            return const SizedBox();
          },
        ),
      ),
    );
  });

  testWidgets('controlled openMobile stays until parent rebuilds',
      (tester) async {
    TpSidebarScope? scope;

    await tester.pumpWidget(
      _wrapMobile(
        openMobile: true,
        onOpenMobileChange: (_) {},
        child: const TpSidebar(child: Text('drawer-body')),
        content: Builder(
          builder: (context) {
            scope = TpSidebarScope.of(context);
            return const SizedBox();
          },
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('drawer-body'), findsOneWidget);

    scope!.setOpenMobile(false);
    await tester.pumpAndSettle();
    expect(find.text('drawer-body'), findsOneWidget);
  });

  testWidgets('onOpenMobileChange is invoked without local UI update',
      (tester) async {
    bool? lastValue;
    TpSidebarScope? scope;

    await tester.pumpWidget(
      _wrapMobile(
        openMobile: true,
        onOpenMobileChange: (v) => lastValue = v,
        child: const TpSidebar(child: Text('drawer-body')),
        content: Builder(
          builder: (context) {
            scope = TpSidebarScope.of(context);
            return const SizedBox();
          },
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('drawer-body'), findsOneWidget);

    scope!.setOpenMobile(false);
    await tester.pumpAndSettle();
    expect(lastValue, isFalse);
    expect(find.text('drawer-body'), findsOneWidget);

    lastValue = null;
    scope!.toggleSidebar();
    await tester.pumpAndSettle();
    expect(lastValue, isFalse);
    expect(find.text('drawer-body'), findsOneWidget);
  });
}
