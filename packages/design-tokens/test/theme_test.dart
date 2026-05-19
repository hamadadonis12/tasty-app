import 'package:flutter_test/flutter_test.dart';
import 'package:design_tokens/theme.dart';
import 'package:design_tokens/colors.dart';

void main() {
  test('TastyTheme returns a valid theme', () {
    final theme = TastyTheme.defaultTheme;
    expect(theme.primaryColor, TastyColors.brand);
  });
}
