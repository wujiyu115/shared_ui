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
  testWidgets('drag from left edge past midpoint opens drawer', (tester) async {
    await tester.pumpWidget(
      _wrapMobile(
        child: const TpSidebar(child: Text('drawer-body')),
      ),
    );
    final gesture = await tester.startGesture(const Offset(2, 400));
    await gesture.moveBy(const Offset(200, 0));
    await gesture.up();
    await tester.pumpAndSettle();
    expect(find.text('drawer-body'), findsOneWidget);
  });

  testWidgets('drag below midpoint from open snaps back open', (tester) async {
    await tester.pumpWidget(
      _wrapMobile(
        child: const TpSidebar(child: Text('drawer-body')),
        content: Builder(
          builder: (context) => TextButton(
            onPressed: () => TpSidebarScope.of(context).setOpenMobile(true),
            child: const Text('open-drawer'),
          ),
        ),
      ),
    );
    await tester.tap(find.text('open-drawer'));
    await tester.pumpAndSettle();
    expect(find.text('drawer-body'), findsOneWidget);

    final panel = tester.getRect(find.text('drawer-body'));
    expect(panel.width, closeTo(320, 0.5));

    final gesture = await tester.startGesture(panel.center);
    await gesture.moveBy(const Offset(-80, 0));
    await gesture.up();
    await tester.pumpAndSettle();
    expect(find.text('drawer-body'), findsOneWidget);
  });

  testWidgets('drag past midpoint from open closes drawer', (tester) async {
    const drawerWidth = 320;

    await tester.pumpWidget(
      _wrapMobile(
        child: const TpSidebar(child: Text('drawer-body')),
        content: Builder(
          builder: (context) => TextButton(
            onPressed: () => TpSidebarScope.of(context).setOpenMobile(true),
            child: const Text('open-drawer'),
          ),
        ),
      ),
    );
    await tester.tap(find.text('open-drawer'));
    await tester.pumpAndSettle();
    expect(find.text('drawer-body'), findsOneWidget);

    final panel = tester.getRect(find.text('drawer-body'));
    final gesture = await tester.startGesture(panel.center);
    await gesture.moveBy(Offset(-drawerWidth * 0.6, 0));
    await gesture.up();
    await tester.pumpAndSettle();
    expect(find.text('drawer-body'), findsNothing);
  });

  testWidgets('system back closes open drawer without claiming route pop',
      (tester) async {
    await tester.pumpWidget(
      _wrapMobile(
        child: const TpSidebar(child: Text('drawer-body')),
        content: Builder(
          builder: (context) => TextButton(
            onPressed: () => TpSidebarScope.of(context).setOpenMobile(true),
            child: const Text('open-drawer'),
          ),
        ),
      ),
    );
    await tester.tap(find.text('open-drawer'));
    await tester.pumpAndSettle();
    expect(find.text('drawer-body'), findsOneWidget);

    final handled = await tester.binding.handlePopRoute();
    await tester.pumpAndSettle();
    expect(find.text('drawer-body'), findsNothing);
    expect(tester.takeException(), isNull);
    expect(handled, isA<bool>());
  });

  testWidgets('edge drag does nothing when edgeOpenEnabled is false',
      (tester) async {
    await tester.pumpWidget(
      _wrapMobile(
        edgeOpenEnabled: false,
        child: const TpSidebar(child: Text('drawer-body')),
      ),
    );
    final gesture = await tester.startGesture(const Offset(2, 400));
    await gesture.moveBy(const Offset(200, 0));
    await gesture.up();
    await tester.pumpAndSettle();
    expect(find.text('drawer-body'), findsNothing);
  });

  testWidgets('widthMobileOverride keeps fixed drawer width', (tester) async {
    await tester.pumpWidget(
      _wrapMobile(
        child: TpSidebar(
          themeOverride: const TpSidebarTheme(widthMobileOverride: 288),
          child: const Text('drawer-body'),
        ),
        content: Builder(
          builder: (context) => TextButton(
            onPressed: () => TpSidebarScope.of(context).setOpenMobile(true),
            child: const Text('open-drawer'),
          ),
        ),
      ),
    );
    await tester.tap(find.text('open-drawer'));
    await tester.pumpAndSettle();
    expect(find.text('drawer-body'), findsOneWidget);

    final panel = tester.getRect(find.text('drawer-body'));
    expect(panel.width, closeTo(288, 0.5));
  });

  testWidgets('tap scrim closes open drawer', (tester) async {
    await tester.pumpWidget(
      _wrapMobile(
        child: const TpSidebar(child: Text('drawer-body')),
        content: Builder(
          builder: (context) => TextButton(
            onPressed: () => TpSidebarScope.of(context).setOpenMobile(true),
            child: const Text('open-drawer'),
          ),
        ),
      ),
    );
    await tester.tap(find.text('open-drawer'));
    await tester.pumpAndSettle();
    expect(find.text('drawer-body'), findsOneWidget);

    await tester.tapAt(const Offset(350, 400));
    await tester.pumpAndSettle();
    expect(find.text('drawer-body'), findsNothing);
  });
}
