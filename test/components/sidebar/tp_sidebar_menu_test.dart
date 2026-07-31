import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_ui/shared_ui.dart';

Widget _wrap({
  required Widget child,
  bool open = true,
  TpSidebarCollapsible collapsible = TpSidebarCollapsible.icon,
  Size size = const Size(1200, 800),
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
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TpSidebar(
                collapsible: collapsible,
                child: child,
              ),
              const Expanded(child: SizedBox.expand()),
            ],
          ),
        ),
      ),
    ),
  );
}

Widget _sampleMenu({
  VoidCallback? onPressed,
  bool isActive = false,
  String? tooltip,
}) {
  return TpSidebarMenu(
    children: [
      TpSidebarMenuItem(
        children: [
          TpSidebarMenuButton(
            icon: const Icon(Icons.inbox),
            label: 'Tasks',
            isActive: isActive,
            onPressed: onPressed,
            tooltip: tooltip,
          ),
          const TpSidebarMenuBadge(label: '3'),
          TpSidebarMenuSub(
            children: [
              TpSidebarMenuSubItem(
                child: TpSidebarMenuSubButton(
                  label: 'Sub item',
                  onPressed: () {},
                ),
              ),
            ],
          ),
        ],
      ),
    ],
  );
}

void main() {
  testWidgets('expanded shows label, badge text, and MenuSub', (tester) async {
    await tester.pumpWidget(
      _wrap(child: _sampleMenu()),
    );
    await tester.pumpAndSettle();

    expect(find.text('Tasks'), findsOneWidget);
    expect(find.text('3'), findsOneWidget);
    expect(find.text('Sub item'), findsOneWidget);
    expect(find.byKey(const Key('tp-sidebar-badge-dot')), findsNothing);
  });

  testWidgets(
    'icon-collapsed hides label, badge text, MenuSub; shows badge dot',
    (tester) async {
      await tester.pumpWidget(
        _wrap(open: false, child: _sampleMenu()),
      );
      await tester.pumpAndSettle();

      expect(find.text('Tasks'), findsNothing);
      expect(find.text('3'), findsNothing);
      expect(find.text('Sub item'), findsNothing);
      expect(find.byKey(const Key('tp-sidebar-badge-dot')), findsOneWidget);
    },
  );

  testWidgets('MenuButton onPressed fires and isActive builds', (tester) async {
    var pressed = 0;
    await tester.pumpWidget(
      _wrap(
        child: _sampleMenu(
          isActive: true,
          onPressed: () => pressed++,
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
    await tester.tap(find.text('Tasks'));
    await tester.pump();
    expect(pressed, 1);
  });

  testWidgets('action and badge are side by side when expanded', (tester) async {
    var actionPressed = 0;
    await tester.pumpWidget(
      _wrap(
        child: TpSidebarMenu(
          children: [
            TpSidebarMenuItem(
              children: [
                TpSidebarMenuButton(
                  icon: const Icon(Icons.inbox),
                  label: 'Tasks',
                  onPressed: () {},
                ),
                TpSidebarMenuAction(
                  icon: Icons.more_horiz,
                  onPressed: () => actionPressed++,
                ),
                const TpSidebarMenuBadge(label: '3'),
              ],
            ),
          ],
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('3'), findsOneWidget);
    expect(find.byIcon(Icons.more_horiz), findsOneWidget);

    final actionRect = tester.getRect(find.byIcon(Icons.more_horiz));
    final badgeRect = tester.getRect(find.text('3'));
    expect(actionRect.right, lessThanOrEqualTo(badgeRect.left));

    await tester.tap(find.byIcon(Icons.more_horiz));
    await tester.pump();
    expect(actionPressed, 1);
  });

  testWidgets('collapsed tooltip defaults to label', (tester) async {
    await tester.pumpWidget(
      _wrap(open: false, child: _sampleMenu()),
    );
    await tester.pumpAndSettle();

    final tip = find.byType(TpTooltip);
    expect(tip, findsWidgets);
    final widget = tester.widgetList<TpTooltip>(tip).firstWhere(
          (t) => t.message == 'Tasks',
          orElse: () => tester.widget<TpTooltip>(tip.first),
        );
    expect(widget.message, 'Tasks');
  });

  testWidgets('icon-collapsed centers menu icon in the rail', (tester) async {
    await tester.pumpWidget(
      _wrap(
        open: false,
        child: TpSidebarMenu(
          children: [
            TpSidebarMenuItem(
              children: [
                TpSidebarMenuButton(
                  icon: const Icon(Icons.inbox, key: Key('nav-icon')),
                  label: 'Tasks',
                  onPressed: () {},
                ),
              ],
            ),
          ],
        ),
      ),
    );
    await tester.pumpAndSettle();

    final panel = tester.getRect(find.byKey(const Key('sidebar-panel')));
    final icon = tester.getRect(find.byKey(const Key('nav-icon')));
    expect(panel.width, closeTo(48, 0.5));
    expect(
      (icon.center.dx - (panel.left + panel.width / 2)).abs(),
      lessThan(6),
      reason: 'icon should be roughly centered in the icon rail',
    );
  });
}
