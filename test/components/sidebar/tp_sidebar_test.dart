import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_ui/shared_ui.dart';

Widget _wrap(
  Widget sidebar, {
  Size size = const Size(1200, 800),
  bool open = false,
  Widget? content,
}) {
  final scheme = ColorScheme.fromSeed(seedColor: Colors.teal);
  return MediaQuery(
    data: MediaQueryData(size: size),
    child: MaterialApp(
      theme: ThemeData(colorScheme: scheme, useMaterial3: true),
      home: TpTheme(
        data: TpThemeData.fromColorScheme(scheme, scale: 1.0),
        child: TpSidebarProvider(
          open: open,
          onOpenChange: (_) {},
          child: Row(
            children: [
              sidebar,
              Expanded(child: content ?? const SizedBox()),
            ],
          ),
        ),
      ),
    ),
  );
}

void main() {
  testWidgets('collapsible none keeps full width when open false',
      (tester) async {
    await tester.pumpWidget(
      _wrap(
        const TpSidebar(
          collapsible: TpSidebarCollapsible.none,
          child: Text('nav'),
        ),
      ),
    );
    await tester.pumpAndSettle();

    final theme = TpSidebarTheme.defaults();
    final size = tester.getSize(find.byKey(const Key('sidebar-panel')));
    expect(size.width, closeTo(theme.width, 0.5));
  });

  testWidgets('collapsible icon collapses to widthIcon when open false',
      (tester) async {
    await tester.pumpWidget(
      _wrap(
        const TpSidebar(
          collapsible: TpSidebarCollapsible.icon,
          child: Text('nav'),
        ),
      ),
    );
    await tester.pumpAndSettle();

    final theme = TpSidebarTheme.defaults();
    final size = tester.getSize(find.byKey(const Key('sidebar-panel')));
    expect(size.width, closeTo(theme.widthIcon, 0.5));
  });

  testWidgets('collapsible offcanvas collapses in-flow width when open false',
      (tester) async {
    await tester.pumpWidget(
      _wrap(
        const TpSidebar(
          collapsible: TpSidebarCollapsible.offcanvas,
          child: Text('nav'),
        ),
      ),
    );
    await tester.pumpAndSettle();

    final size = tester.getSize(find.byKey(const Key('sidebar-panel')));
    expect(size.width, closeTo(0, 0.5));
  });

  testWidgets('mobile reserves ~0 width and drawer shows content',
      (tester) async {
    await tester.pumpWidget(
      _wrap(
        size: const Size(400, 800),
        open: true,
        const TpSidebar(
          child: Text('drawer-body'),
        ),
        content: Builder(
          builder: (context) {
            return TextButton(
              onPressed: () => TpSidebarScope.of(context).setOpenMobile(true),
              child: const Text('open-drawer'),
            );
          },
        ),
      ),
    );
    await tester.pumpAndSettle();

    final size = tester.getSize(find.byKey(const Key('sidebar-panel')));
    expect(size.width, closeTo(0, 0.5));
    expect(find.text('drawer-body'), findsNothing);

    await tester.tap(find.text('open-drawer'));
    await tester.pumpAndSettle();

    expect(find.text('drawer-body'), findsOneWidget);
  });

  testWidgets('resizing open mobile drawer to desktop does not assert',
      (tester) async {
    Widget buildAt(Size size) {
      return _wrap(
        size: size,
        open: false,
        const TpSidebar(
          child: Text('drawer-body'),
        ),
        content: Builder(
          builder: (context) {
            return TextButton(
              onPressed: () => TpSidebarScope.of(context).setOpenMobile(true),
              child: const Text('open-drawer'),
            );
          },
        ),
      );
    }

    await tester.pumpWidget(buildAt(const Size(400, 800)));
    await tester.pumpAndSettle();
    await tester.tap(find.text('open-drawer'));
    await tester.pumpAndSettle();
    expect(find.text('drawer-body'), findsOneWidget);

    await tester.pumpWidget(buildAt(const Size(1200, 800)));
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
    expect(find.text('drawer-body'), findsNothing);
    expect(find.byKey(const Key('sidebar-panel')), findsOneWidget);
  });

  testWidgets('variant sidebar exposes sidebar-panel', (tester) async {
    await tester.pumpWidget(
      _wrap(
        const TpSidebar(
          variant: TpSidebarVariant.sidebar,
          child: Text('nav'),
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('sidebar-panel')), findsOneWidget);
  });

  testWidgets('variant floating exposes sidebar-panel', (tester) async {
    await tester.pumpWidget(
      _wrap(
        const TpSidebar(
          variant: TpSidebarVariant.floating,
          child: Text('nav'),
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('sidebar-panel')), findsOneWidget);
  });

  testWidgets('variant inset exposes sidebar-panel', (tester) async {
    await tester.pumpWidget(
      _wrap(
        const TpSidebar(
          variant: TpSidebarVariant.inset,
          child: Text('nav'),
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('sidebar-panel')), findsOneWidget);
  });
}
