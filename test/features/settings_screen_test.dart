import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:money_diary/features/settings/screens/settings_screen.dart';

import '../helpers/pump_app.dart';

void main() {
  testWidgets('자산을 더하면 순자산에 반영되고, 거래에 쓰인 자산은 지워지지 않는다', (tester) async {
    tester.view.physicalSize = const Size(430, 1800);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    await pumpApp(tester, const SettingsScreen());
    expect(find.text('18,450,200'), findsOneWidget);

    await tester.tap(find.text('자산 추가'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('저장'));
    await tester.pumpAndSettle();
    expect(find.text('이름을 입력해 주세요.'), findsOneWidget);

    await tester.enterText(find.byType(TextField).first, '비상금 통장');
    await tester.enterText(find.byType(TextField).last, '1000000');
    await tester.tap(find.text('저장'));
    await tester.pumpAndSettle();
    expect(find.text('비상금 통장'), findsOneWidget);
    expect(find.text('19,450,200'), findsOneWidget);

    await tester.tap(find.text('현대카드 ZERO'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('이 자산 삭제'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('삭제'));
    await tester.pumpAndSettle();
    expect(find.text('이 자산을 쓴 거래가 있어 지울 수 없어요.'), findsOneWidget);
  });
}
