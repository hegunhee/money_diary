import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:money_diary/core/themes/app_theme.dart';
import 'package:money_diary/features/home/screens/home_screen.dart';

void main() {
  testWidgets('홈 화면이 라이트·다크 테마에서 렌더링된다', (tester) async {
    for (final theme in [AppTheme.lightTheme, AppTheme.darkTheme]) {
      await tester.pumpWidget(
        MaterialApp(theme: theme, home: const HomeScreen()),
      );

      expect(find.text('아직 기록이 없어요'), findsOneWidget);
      expect(tester.takeException(), isNull);
    }
  });
}
