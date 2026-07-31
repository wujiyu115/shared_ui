import 'package:flutter_test/flutter_test.dart';
import 'package:shared_ui/shared_ui.dart';

void main() {
  test('fraction 0.8 of 400 => 320', () {
    expect(const TpSidebarTheme().resolveMobileDrawerWidth(400), 320);
  });

  test('override wins over fraction', () {
    expect(
      const TpSidebarTheme(widthMobileOverride: 288).resolveMobileDrawerWidth(
        400,
      ),
      288,
    );
  });
}
