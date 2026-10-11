import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:money_diary/features/entry/screens/entry_screen.dart';
import 'package:money_diary/features/projects/screens/projects_screen.dart';
import 'package:money_diary/shared/controllers/ledger_controller.dart';
import 'package:money_diary/shared/controllers/today_controller.dart';
import 'package:money_diary/shared/repositories/ledger_repository.dart';
import 'package:money_diary/shared/util/ledger_calculator.dart';

import '../helpers/pump_app.dart';

void main() {
  test('프로젝트를 지우면 묶여 있던 거래는 남고 태그만 떼어진다', () async {
    final container = ProviderContainer(
      overrides: [
        ledgerRepositoryProvider.overrideWithValue(FakeLedgerRepository()),
        todayProvider.overrideWithValue(designToday),
      ],
    );
    addTearDown(container.dispose);
    final before = await container.read(ledgerProvider.future);

    await container.read(ledgerProvider.notifier).deleteProject('japan-trip');

    final after = container.read(ledgerProvider).requireValue;
    expect(after.projects, isEmpty);
    expect(after.entries, hasLength(before.entries.length));
    expect(after.entries.where((entry) => entry.projectId != null), isEmpty);
    expect(totalsOf(after.entries).expense, totalsOf(before.entries).expense);
  });

  testWidgets('프로젝트를 더하면 진행 중에 나타나고 이름 없이는 저장되지 않는다', (tester) async {
    tester.view.physicalSize = const Size(430, 1800);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    await pumpApp(tester, const ProjectsScreen());
    expect(find.text('진행 중 1'), findsOneWidget);

    await tester.tap(find.text('프로젝트 추가'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('저장'));
    await tester.pumpAndSettle();
    expect(find.text('이름을 입력해 주세요.'), findsOneWidget);

    await tester.enterText(find.byType(TextField).first, '이사 준비');
    await tester.enterText(find.byType(TextField).last, '3000000');
    await tester.tap(find.text('저장'));
    await tester.pumpAndSettle();

    expect(find.text('진행 중 2'), findsOneWidget);
    expect(find.text('이사 준비'), findsOneWidget);
    expect(find.text('남은 예산 ₩ 3,000,000'), findsOneWidget);
  });

  testWidgets('보관한 프로젝트는 보관됨으로 내려가고 거래 입력의 태그에서 빠진다', (tester) async {
    tester.view.physicalSize = const Size(430, 2400);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    await pumpApp(
      tester,
      const Column(
        children: [
          Expanded(child: ProjectsScreen()),
          Expanded(child: EntryScreen()),
        ],
      ),
    );
    // 목록의 카드와 입력 화면의 태그, 두 군데에 보입니다.
    expect(find.text('2026 일본 여행'), findsNWidgets(2));

    await tester.tap(find.text('2026 일본 여행').first);
    await tester.pumpAndSettle();
    await tester.tap(find.text('보관하기'));
    await tester.pumpAndSettle();

    expect(find.text('보관됨 1'), findsOneWidget);
    expect(find.text('진행 중 1'), findsNothing);
    expect(find.text('2026 일본 여행'), findsOneWidget);
    // 기록은 그대로 남아 합계가 보입니다.
    expect(find.textContaining('₩ 680,000'), findsOneWidget);
  });
}
