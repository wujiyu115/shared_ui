import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_ui/shared_ui.dart';

Widget _wrap(Widget child, {Size size = const Size(1200, 800)}) {
  final scheme = ColorScheme.fromSeed(seedColor: Colors.teal);
  return MediaQuery(
    data: MediaQueryData(size: size),
    child: MaterialApp(
      theme: ThemeData(colorScheme: scheme, useMaterial3: true),
      home: TpTheme(
        data: TpThemeData.fromColorScheme(scheme, scale: 1.0),
        child: child,
      ),
    ),
  );
}

void main() {
  testWidgets('uncontrolled toggleSidebar flips open', (tester) async {
    await tester.pumpWidget(
      _wrap(
        TpSidebarProvider(
          child: Builder(
            builder: (context) {
              final s = TpSidebarScope.of(context);
              return TextButton(
                onPressed: s.toggleSidebar,
                child: Text(s.open ? 'open' : 'closed'),
              );
            },
          ),
        ),
      ),
    );
    expect(find.text('open'), findsOneWidget);
    await tester.tap(find.byType(TextButton));
    await tester.pump();
    expect(find.text('closed'), findsOneWidget);
  });

  testWidgets('controlled open stays until parent rebuilds', (tester) async {
    await tester.pumpWidget(
      _wrap(
        TpSidebarProvider(
          open: true,
          onOpenChange: (_) {},
          child: Builder(
            builder: (context) {
              final s = TpSidebarScope.of(context);
              return TextButton(
                onPressed: () => s.setOpen(false),
                child: Text(s.open ? 'open' : 'closed'),
              );
            },
          ),
        ),
      ),
    );
    await tester.tap(find.byType(TextButton));
    await tester.pump();
    expect(find.text('open'), findsOneWidget);
  });

  testWidgets('mobile toggle flips openMobile not open', (tester) async {
    await tester.pumpWidget(
      _wrap(
        size: const Size(400, 800),
        TpSidebarProvider(
          child: Builder(
            builder: (context) {
              final s = TpSidebarScope.of(context);
              return TextButton(
                onPressed: s.toggleSidebar,
                child: Text('m=${s.isMobile} om=${s.openMobile} o=${s.open}'),
              );
            },
          ),
        ),
      ),
    );
    expect(find.textContaining('m=true'), findsOneWidget);
    await tester.tap(find.byType(TextButton));
    await tester.pump();
    expect(find.textContaining('om=true'), findsOneWidget);
    expect(find.textContaining('o=true'), findsOneWidget);
  });

  testWidgets('Ctrl+B toggles when shortcut enabled', (tester) async {
    await tester.pumpWidget(
      _wrap(
        TpSidebarProvider(
          child: Builder(
            builder: (context) {
              final s = TpSidebarScope.of(context);
              return Text(s.open ? 'open' : 'closed');
            },
          ),
        ),
      ),
    );
    await tester.sendKeyDownEvent(LogicalKeyboardKey.controlLeft);
    await tester.sendKeyEvent(LogicalKeyboardKey.keyB);
    await tester.sendKeyUpEvent(LogicalKeyboardKey.controlLeft);
    await tester.pump();
    expect(find.text('closed'), findsOneWidget);
  });
}
