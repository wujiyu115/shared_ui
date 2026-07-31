import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_ui/shared_ui.dart';

Widget _wrapMobileStack({
  required List<Widget> stackChildren,
  bool? openMobile = true,
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
          // null → uncontrolled openMobile (matches HomeShell production).
          openMobile: openMobile,
          child: Stack(fit: StackFit.expand, children: stackChildren),
        ),
      ),
    ),
  );
}

void main() {
  testWidgets('only overlayActive TpSidebar mounts mobile overlay', (
    tester,
  ) async {
    var homeActive = true;
    late StateSetter setParent;

    await tester.pumpWidget(
      StatefulBuilder(
        builder: (context, setState) {
          setParent = setState;
          return _wrapMobileStack(
            openMobile: true,
            stackChildren: [
              TpSidebar(
                overlayActive: homeActive,
                child: const Text('HOME-NAV'),
              ),
              TpSidebar(
                overlayActive: !homeActive,
                child: const Text('WS-NAV'),
              ),
            ],
          );
        },
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('HOME-NAV'), findsOneWidget);
    expect(find.text('WS-NAV'), findsNothing);

    setParent(() => homeActive = false);
    await tester.pumpAndSettle();

    expect(find.text('HOME-NAV'), findsNothing);
    expect(find.text('WS-NAV'), findsOneWidget);
  });

  testWidgets('overlayActive false hides overlay immediately', (tester) async {
    var overlayActive = true;
    late StateSetter setParent;

    await tester.pumpWidget(
      StatefulBuilder(
        builder: (context, setState) {
          setParent = setState;
          return _wrapMobileStack(
            openMobile: true,
            stackChildren: [
              TpSidebar(
                overlayActive: overlayActive,
                child: const Text('drawer-body'),
              ),
            ],
          );
        },
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('drawer-body'), findsOneWidget);

    setParent(() => overlayActive = false);
    await tester.pumpAndSettle();
    expect(find.text('drawer-body'), findsNothing);
  });

  testWidgets(
    'deactivating overlayActive while open does not setState during build',
    (tester) async {
      FlutterErrorDetails? caught;
      final previous = FlutterError.onError;
      FlutterError.onError = (details) {
        caught ??= details;
        previous?.call(details);
      };
      addTearDown(() => FlutterError.onError = previous);

      var overlayActive = true;
      late StateSetter setParent;

      await tester.pumpWidget(
        StatefulBuilder(
          builder: (context, setState) {
            setParent = setState;
            return _wrapMobileStack(
              openMobile: true,
              stackChildren: [
                TpSidebar(
                  overlayActive: overlayActive,
                  child: const Text('drawer-body'),
                ),
              ],
            );
          },
        ),
      );
      await tester.pumpAndSettle();

      setParent(() => overlayActive = false);
      await tester.pump();
      await tester.pumpAndSettle();

      expect(caught, isNull);
      expect(tester.takeException(), isNull);
      expect(find.text('drawer-body'), findsNothing);
    },
  );

  testWidgets(
    'inactive overlay host does not close drawer opened by active host',
    (tester) async {
      // Mirrors HomeShell + kept-alive workspace: one shared provider, two
      // TpSidebars, only the foreground route owns overlayActive.
      await tester.pumpWidget(
        _wrapMobileStack(
          openMobile: null,
          stackChildren: [
            const TpSidebar(
              overlayActive: false,
              child: Text('HOME-NAV'),
            ),
            const TpSidebar(
              overlayActive: true,
              child: Text('WS-NAV'),
            ),
          ],
        ),
      );
      await tester.pumpAndSettle();
      expect(find.text('WS-NAV'), findsNothing);

      TpSidebarScope.of(
        tester.element(find.byType(TpSidebar).last),
      ).setOpenMobile(true);
      await tester.pumpAndSettle();

      final scope = TpSidebarScope.of(
        tester.element(find.byType(TpSidebar).last),
      );
      expect(scope.openMobile, isTrue);
      expect(find.text('WS-NAV'), findsOneWidget);
      expect(find.text('HOME-NAV'), findsNothing);
    },
  );

  testWidgets(
    'losing overlay ownership closes shared openMobile',
    (tester) async {
      var workspaceActive = true;
      late StateSetter setParent;

      await tester.pumpWidget(
        StatefulBuilder(
          builder: (context, setState) {
            setParent = setState;
            return _wrapMobileStack(
              openMobile: null,
              stackChildren: [
                TpSidebar(
                  overlayActive: !workspaceActive,
                  child: const Text('HOME-NAV'),
                ),
                TpSidebar(
                  overlayActive: workspaceActive,
                  child: const Text('WS-NAV'),
                ),
              ],
            );
          },
        ),
      );
      await tester.pumpAndSettle();

      TpSidebarScope.of(
        tester.element(find.byType(TpSidebar).last),
      ).setOpenMobile(true);
      await tester.pumpAndSettle();
      expect(find.text('WS-NAV'), findsOneWidget);

      // Leave workspace → home owns overlay; previous owner must release.
      setParent(() => workspaceActive = false);
      await tester.pumpAndSettle();

      final scope = TpSidebarScope.of(
        tester.element(find.byType(TpSidebar).first),
      );
      expect(scope.openMobile, isFalse);
      expect(find.text('WS-NAV'), findsNothing);
      expect(find.text('HOME-NAV'), findsNothing);
    },
  );
}
