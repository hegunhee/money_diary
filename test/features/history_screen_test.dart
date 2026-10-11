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
}
