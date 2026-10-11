import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:money_diary/features/report/screens/report_screen.dart';

import '../helpers/pump_app.dart';

void main() {
  testWidgets('이체를 뺀 지출을 카테고리로 나누고, 뺀 이체 금액을 따로 알린다', (tester) async {
    tester.view.physicalSize = const Size(430, 2400);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    await pumpApp(tester, const ReportScreen());

    expect(find.text('₩ 2,065,500'), findsOneWidget);
    expect(find.textContaining('₩ 700,000'), findsOneWidget);
    expect(find.text('₩ 820,000'), findsOneWidget);
    expect(find.text('37.5%'), findsOneWidget);
    // 3월은 31일: 2,184,500 ÷ 31
    expect(find.text('1일 평균 70,467원'), findsOneWidget);

    await tester.tap(find.text('자산별'));
    await tester.pumpAndSettle();
    expect(find.text('현대카드 ZERO'), findsOneWidget);
    expect(find.text('토스뱅크'), findsNothing);

    await tester.tap(find.text('프로젝트별'));
    await tester.pumpAndSettle();
    // 3월에 쓴 285,500원만 셉니다. 2월의 항공권은 이 달 지출이 아닙니다.
    expect(find.text('₩ 285,500'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
