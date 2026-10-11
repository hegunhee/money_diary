import 'package:flutter_test/flutter_test.dart';
import 'package:money_diary/features/history/screens/history_screen.dart';

import '../helpers/pump_app.dart';

void main() {
  testWidgets('거르기를 바꿔도 위쪽 월 합계는 그대로이고 목록만 걸러진다', (tester) async {
    await pumpApp(tester, const HistoryScreen());

    expect(find.text('총 26건 내역'), findsNothing);
    expect(find.text('총 25건 내역'), findsOneWidget);
    expect(find.text('₩2,184,500'), findsOneWidget);

    await tester.tap(find.text('이체만'));
    await tester.pumpAndSettle();

    expect(find.text('총 2건 내역'), findsOneWidget);
    expect(find.text('토스뱅크 → 카카오뱅크'), findsOneWidget);
    expect(find.text('스타벅스 리저브'), findsNothing);
    // 이체만 보는 날에는 수입·지출 합계가 0이라 금액을 적지 않습니다.
    expect(find.text('(이체 1건)'), findsNWidgets(2));
    expect(find.text('₩2,184,500'), findsOneWidget);
  });

  testWidgets('거래를 꾹 누르면 지울지 묻고, 취소하면 남고 삭제하면 합계에서 빠진다', (tester) async {
    final repository = await pumpApp(tester, const HistoryScreen());

    await tester.longPress(find.text('삼진어묵'));
    await tester.pumpAndSettle();
    expect(find.textContaining('-18,200원 내역을 지울까요?'), findsOneWidget);
    await tester.tap(find.text('취소'));
    await tester.pumpAndSettle();
    expect(repository.deleted, isEmpty);
    expect(find.text('삼진어묵'), findsOneWidget);

    await tester.longPress(find.text('삼진어묵'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('삭제'));
    await tester.pumpAndSettle();

    expect(repository.deleted, hasLength(1));
    expect(find.text('삼진어묵'), findsNothing);
    expect(find.text('총 24건 내역'), findsOneWidget);
    expect(find.text('₩2,166,300'), findsOneWidget);
  });
}
