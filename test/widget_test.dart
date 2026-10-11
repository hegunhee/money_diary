import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:money_diary/core/themes/app_theme.dart';
import 'package:money_diary/features/main/screens/main_screen.dart';
import 'package:money_diary/shared/models/ledger_book.dart';

import 'helpers/pump_app.dart';

void main() {
  testWidgets('홈은 이체를 뺀 합계를 보여 주고 다크 테마에서도 넘치지 않는다', (tester) async {
    for (final theme in [AppTheme.lightTheme, AppTheme.darkTheme]) {
      await pumpApp(tester, const MainScreen(), theme: theme);

      expect(find.text('18,450,200'), findsOneWidget);
      expect(find.text('+ 4,250,000원'), findsOneWidget);
      expect(find.text('- 2,184,500원'), findsOneWidget);
      await tester.scrollUntilVisible(find.text('삼진어묵'), 300);
      // 3월 18일: 지출 6,500 + 18,200. 이체 200,000은 세지 않습니다.
      expect(find.text('- 24,700원'), findsOneWidget);
      expect(tester.takeException(), isNull);
      await tester.pumpWidget(const SizedBox());
    }
  });

  testWidgets('기록이 없는 가계부도 홈이 열린다', (tester) async {
    await pumpApp(tester, const MainScreen(), book: const LedgerBook());

    await tester.scrollUntilVisible(find.text('아직 기록이 없어요'), 300);
    expect(tester.takeException(), isNull);
  });
}
