import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_ui/shared_ui.dart';

void main() {
  Widget wrap(Widget child) {
    return MaterialApp(
      home: TpTheme(
        data: TpThemeData.fromColorScheme(
          ColorScheme.fromSeed(seedColor: Colors.orange),
          scale: 1.0,
        ),
        child: Scaffold(body: child),
      ),
    );
  }

  testWidgets('TpPreferenceRow shows title and trailing', (tester) async {
    await tester.pumpWidget(
      wrap(
        const TpPreferenceRow(
          title: 'Label',
          subtitle: 'Hint',
          trailing: Text('Value'),
        ),
      ),
    );
    expect(find.text('Label'), findsOneWidget);
    expect(find.text('Hint'), findsOneWidget);
    expect(find.text('Value'), findsOneWidget);
  });

  testWidgets('TpPreferenceStack places body below title', (tester) async {
    await tester.pumpWidget(
      wrap(
        const TpPreferenceStack(
          title: 'Stack',
          body: Text('Body'),
        ),
      ),
    );
    expect(find.text('Stack'), findsOneWidget);
    expect(find.text('Body'), findsOneWidget);
  });

  testWidgets('TpSectionHeader renders title', (tester) async {
    await tester.pumpWidget(wrap(const TpSectionHeader(title: 'Section')));
    expect(find.text('Section'), findsOneWidget);
  });

  testWidgets('TpCard.outlined has transparent fill', (tester) async {
    await tester.pumpWidget(
      wrap(const TpCard.outlined(child: Text('Panel'))),
    );
    final material = tester.widget<Material>(
      find.descendant(
        of: find.byType(TpCard),
        matching: find.byType(Material),
      ).first,
    );
    expect(material.color, Colors.transparent);
  });

  testWidgets('TpStatusBadge shows label', (tester) async {
    await tester.pumpWidget(
      wrap(
        const TpStatusBadge(
          label: 'Ready',
          tone: TpStatusBadgeTone.success,
          icon: Icons.check,
        ),
      ),
    );
    expect(find.text('Ready'), findsOneWidget);
  });

  testWidgets('TpDisclosure expands lazily', (tester) async {
    await tester.pumpWidget(
      wrap(
        const TpDisclosure(
          title: 'Advanced',
          subtitle: 'Agent preset and extra flags.',
          children: [Text('Secret')],
        ),
      ),
    );
    expect(find.text('Secret'), findsNothing);
    expect(find.text('Agent preset and extra flags.'), findsOneWidget);
    await tester.tap(find.text('Advanced'));
    await tester.pumpAndSettle();
    expect(find.text('Secret'), findsOneWidget);
  });

  testWidgets('TpSegmentedPicker notifies typed value', (tester) async {
    String? selected;
    await tester.pumpWidget(
      wrap(
        TpSegmentedPicker<String>(
          // Force pill mode regardless of default test surface width.
          mobileBreakpoint: 0,
          selected: 'a',
          segments: const [
            TpSegmentedOption(value: 'a', label: 'A', icon: Icons.looks_one),
            TpSegmentedOption(value: 'b', label: 'B', icon: Icons.looks_two),
          ],
          onChanged: (v) => selected = v,
        ),
      ),
    );
    await tester.tap(find.text('B'));
    await tester.pumpAndSettle();
    expect(selected, 'b');
  });

  testWidgets('TpSegmentedPicker scrolls horizontally like theme chips', (
    tester,
  ) async {
    await tester.pumpWidget(
      wrap(
        TpSegmentedPicker<String>(
          mobileBreakpoint: 0,
          selected: 'a',
          segments: const [
            TpSegmentedOption(value: 'a', label: 'A', icon: Icons.looks_one),
            TpSegmentedOption(value: 'b', label: 'B', icon: Icons.looks_two),
          ],
          onChanged: (_) {},
        ),
      ),
    );
    expect(find.byType(SingleChildScrollView), findsOneWidget);
    expect(find.byType(FittedBox), findsNothing);
    expect(find.byType(TpSegmentedControl), findsOneWidget);
  });

  testWidgets('TpSegmentedPicker uses compact select on narrow width', (
    tester,
  ) async {
    await tester.pumpWidget(
      wrap(
        SizedBox(
          width: 280,
          child: TpSegmentedPicker<String>(
            mobileBreakpoint: 10000,
            selected: 'a',
            segments: const [
              TpSegmentedOption(value: 'a', label: '主页', icon: Icons.home),
              TpSegmentedOption(
                value: 'b',
                label: '恢复上次工作区',
                icon: Icons.history,
              ),
            ],
            onChanged: (_) {},
          ),
        ),
      ),
    );
    expect(find.byType(TpCompactSelect<String>), findsOneWidget);
    expect(find.byType(TpSegmentedControl), findsNothing);
    expect(find.text('主页'), findsWidgets);
  });

  testWidgets('TpPreferenceRow keeps trailing beside title on narrow width', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(360, 800));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await tester.pumpWidget(
      wrap(
        const SizedBox(
          width: 360,
          child: TpPreferenceRow(
            title: '成员',
            subtitle: '在工具或终端旁显示成员列表。',
            trailing: Text('SW'),
          ),
        ),
      ),
    );
    final titleY = tester.getTopLeft(find.text('成员')).dy;
    final trailingY = tester.getTopLeft(find.text('SW')).dy;
    expect((trailingY - titleY).abs(), lessThan(24));
  });

  testWidgets('TpPreferenceRow keeps trailing beside title when wide', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(900, 800));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await tester.pumpWidget(
      wrap(
        const SizedBox(
          width: 900,
          child: TpPreferenceRow(
            title: '主题模式',
            subtitle: '浅色、深色，或与系统外观一致。',
            trailing: Text('TRAILING'),
          ),
        ),
      ),
    );
    final titleY = tester.getTopLeft(find.text('主题模式')).dy;
    final trailingY = tester.getTopLeft(find.text('TRAILING')).dy;
    expect((trailingY - titleY).abs(), lessThan(24));
  });
}
