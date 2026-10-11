import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:money_diary/features/entry/models/entry_form_error.dart';
import 'package:money_diary/features/entry/screens/entry_screen.dart';
import 'package:money_diary/shared/controllers/ledger_controller.dart';
import 'package:money_diary/shared/models/ledger_category.dart';
import 'package:money_diary/shared/models/ledger_entry.dart';

import '../helpers/pump_app.dart';
import '../helpers/sample_ledger.dart';

void main() {
  test('이체는 받는 자산이 없거나 보내는 자산과 같으면 저장할 수 없다', () {
    Set<EntryFormError> check(String? to) => validateEntry(
      type: EntryType.transfer,
      amount: 1000,
      assetId: 'a',
      toAssetId: to,
    );

    expect(check(null), {EntryFormError.toAsset});
    expect(check('a'), {EntryFormError.sameAsset});
    expect(check('b'), isEmpty);
  });

  testWidgets('금액 없이는 저장되지 않고, 금액을 적으면 고른 값대로 저장된다', (tester) async {
    tester.view.physicalSize = const Size(430, 2400);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    final repository = await pumpApp(tester, const EntryScreen());

    await tester.tap(find.text('저장 후 계속 추가'));
    await tester.pumpAndSettle();
    expect(find.text('금액을 입력해 주세요.'), findsOneWidget);
    expect(repository.saved, isEmpty);

    await tester.enterText(find.byType(TextField).first, '35000');
    expect(find.text('35,000'), findsOneWidget);
    await tester.tap(find.text('+5천'));
    await tester.pump();
    await tester.tap(find.text('교통/차량'));
    await tester.pump();
    await tester.tap(find.text('2026 일본 여행'));
    await tester.pump();
    await tester.tap(find.text('저장 후 계속 추가'));
    await tester.pumpAndSettle();

    final saved = repository.saved.single;
    expect(saved.type, EntryType.expense);
    expect(saved.amount, 40000);
    expect(saved.category, LedgerCategory.transport);
    expect(saved.projectId, 'japan-trip');
    expect(saved.occurredAt, designToday);
    // 내용을 비우면 카테고리 이름이 거래 이름이 됩니다.
    expect(saved.title, '교통/차량');
    expect(find.text('금액을 입력해 주세요.'), findsNothing);
    expect(find.text('40,000'), findsNothing);
  });

  testWidgets('입력 화면에서 카테고리를 더하면 바로 골라지고 그 이름으로 저장된다', (tester) async {
    tester.view.physicalSize = const Size(430, 2400);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    final repository = await pumpApp(tester, const EntryScreen());

    await tester.tap(find.text('추가'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField).last, '식비');
    await tester.tap(find.text('저장'));
    await tester.pumpAndSettle();
    expect(find.text('이미 있는 카테고리예요.'), findsOneWidget);

    await tester.enterText(find.byType(TextField).last, '반려동물');
    await tester.tap(find.text('저장'));
    await tester.pumpAndSettle();
    expect(find.text('반려동물'), findsOneWidget);

    await tester.enterText(find.byType(TextField).first, '45000');
    await tester.pump();
    await tester.tap(find.text('저장 후 계속 추가'));
    await tester.pumpAndSettle();

    expect(repository.saved.single.category?.customName, '반려동물');
    expect(repository.saved.single.title, '반려동물');

    // 수입으로 바꾸면 지출 카테고리는 보이지 않습니다.
    await tester.tap(find.text('수입'));
    await tester.pumpAndSettle();
    expect(find.text('반려동물'), findsNothing);
    expect(find.text('급여'), findsOneWidget);
  });

  testWidgets('거래를 고치면 예전 잔액을 되돌리고 새 금액으로 다시 반영한다', (tester) async {
    tester.view.physicalSize = const Size(430, 2400);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    final book = buildSampleLedger(designToday);
    // 삼진어묵 18,200원 · 카카오뱅크(잔액 1,500,000)
    final target = book.entries.firstWhere((entry) => entry.title == '삼진어묵');
    final repository = await pumpApp(
      tester,
      Consumer(
        builder: (context, ref, _) => Column(
          children: [
            Text(
              'kakao ${ref.watch(ledgerProvider).value?.assetById('kakao-bank')?.balance}',
            ),
            Expanded(child: EntryScreen(entry: target)),
          ],
        ),
      ),
    );
    expect(find.text('내역 수정'), findsOneWidget);
    expect(find.text('18,200'), findsOneWidget);

    await tester.enterText(find.byType(TextField).first, '20000');
    await tester.pump();
    await tester.tap(find.text('저장하기'));
    await tester.pump();

    expect(repository.saved.single.id, target.id);
    expect(repository.saved.single.amount, 20000);
    expect(repository.saved.single.detail, '외식');
    expect(find.text('kakao ${1500000 + 18200 - 20000}'), findsOneWidget);
  });
}
