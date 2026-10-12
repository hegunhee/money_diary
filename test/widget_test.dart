import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:money_diary/core/themes/app_theme.dart';
import 'package:money_diary/features/main/screens/main_screen.dart';
import 'package:money_diary/shared/controllers/ledger_controller.dart';
import 'package:money_diary/shared/controllers/today_controller.dart';
import 'package:money_diary/shared/models/asset_account.dart';
import 'package:money_diary/shared/models/ledger_book.dart';
import 'package:money_diary/shared/models/ledger_category.dart';
import 'package:money_diary/shared/models/ledger_entry.dart';
import 'package:money_diary/shared/repositories/ledger_repository.dart';
import 'package:money_diary/shared/util/ledger_calculator.dart';

import 'helpers/pump_app.dart';

void main() {
  testWidgets('홈은 이체를 뺀 합계를 보여 주고 다크 테마에서도 넘치지 않는다', (tester) async {
    for (final theme in [AppTheme.lightTheme, AppTheme.darkTheme]) {
      await pumpApp(tester, const MainScreen(), theme: theme);

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

  test('처음 실행하면 0원인 현금 자산 하나만 있는 빈 가계부로 시작한다', () async {
    final repository = _FirstRunRepository();
    final container = ProviderContainer(
      overrides: [ledgerRepositoryProvider.overrideWithValue(repository)],
    );
    addTearDown(container.dispose);

    final book = await container.read(ledgerProvider.future);

    expect(book.entries, isEmpty);
    expect(book.projects, isEmpty);
    expect(book.monthlyBudget, 0);
    expect(book.assets.single.balance, 0);
    expect(netWorth(book.assets), 0);
  });

  test('앱을 열면 밀린 반복 거래가 등록되고 잔액에 한 번만 반영된다', () async {
    final salary = LedgerEntry(
      id: 'salary',
      type: EntryType.income,
      amount: 3000000,
      title: '급여',
      occurredAt: DateTime(2026, 2, 10, 9),
      assetId: 'bank',
      category: LedgerCategory.salary,
      isRecurring: true,
    );
    final repository = FakeLedgerRepository(
      LedgerBook(
        entries: [salary],
        assets: const [
          AssetAccount(
            id: 'bank',
            name: '통장',
            kind: AssetKind.bank,
            balance: 3000000,
          ),
        ],
      ),
    );
    final container = ProviderContainer(
      overrides: [
        ledgerRepositoryProvider.overrideWithValue(repository),
        todayProvider.overrideWithValue(designToday),
      ],
    );
    addTearDown(container.dispose);

    final book = await container.read(ledgerProvider.future);
    await container.read(ledgerProvider.notifier).registerDueRecurring();

    // 2월 10일 급여 → 3월 10일에 한 건. 오늘은 3월 18일입니다.
    final after = container.read(ledgerProvider).requireValue;
    expect(book.entries, hasLength(2));
    expect(after.entries, hasLength(2));
    expect(after.entries.last.occurredAt, DateTime(2026, 3, 10, 9));
    expect(after.assetById('bank')!.balance, 6000000);
  });
}

class _FirstRunRepository extends FakeLedgerRepository {
  _FirstRunRepository() : super(const LedgerBook());

  @override
  Future<bool> isInitialized() async => false;
}
