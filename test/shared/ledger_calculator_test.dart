import 'package:flutter_test/flutter_test.dart';
import 'package:money_diary/shared/models/asset_account.dart';
import 'package:money_diary/shared/models/ledger_category.dart';
import 'package:money_diary/shared/models/ledger_entry.dart';
import 'package:money_diary/shared/util/ledger_calculator.dart';

import '../helpers/sample_ledger.dart';

LedgerEntry _entry(EntryType type, int amount, {String to = 'bank'}) =>
    LedgerEntry(
      id: '$type-$amount',
      type: type,
      amount: amount,
      title: '거래',
      occurredAt: DateTime(2026, 3, 18, 12),
      assetId: type == EntryType.transfer ? 'toss' : to,
      toAssetId: type == EntryType.transfer ? to : null,
      category: type == EntryType.expense ? LedgerCategory.food : null,
    );

void main() {
  final book = buildSampleLedger(DateTime(2026, 3, 18));

  test('걸러 본 목록에서 자산을 옮겨도 가려진 자산은 제자리에 남는다', () {
    const assets = [
      AssetAccount(id: 'a', name: 'a', kind: AssetKind.bank, balance: 0),
      AssetAccount(id: 'x', name: 'x', kind: AssetKind.cash, balance: 0),
      AssetAccount(id: 'b', name: 'b', kind: AssetKind.bank, balance: 0),
      AssetAccount(id: 'c', name: 'c', kind: AssetKind.bank, balance: 0),
    ];

    final moved = moveAsset(assets, (a) => a.kind == AssetKind.bank, 0, 2);

    expect([for (final asset in moved) asset.id], ['b', 'x', 'c', 'a']);
  });
  final march = entriesInMonth(book.entries, DateTime(2026, 3));

  test('이체는 수입·지출 합계와 카테고리·결제 수단 통계에 들어가지 않는다', () {
    final totals = totalsOf(march);

    expect(totals.income, 4250000);
    expect(totals.expense, 2184500);
    expect(totals.net, 2065500);
    expect(totals.transfer, 700000);
    expect(totals.transferCount, 2);
    expect(
      categoryShares(march).fold(0, (sum, share) => sum + share.amount),
      totals.expense,
    );
    expect(
      assetShares(march, book.assets).fold(0, (sum, s) => sum + s.amount),
      totals.expense,
    );
  });

  test('카테고리 몫은 금액이 큰 순서이고 비율의 합이 1이다', () {
    final shares = categoryShares(march);

    expect(shares.first.category, LedgerCategory.food);
    expect(shares.first.amount, 820000);
    expect(shares.fold<double>(0, (sum, s) => sum + s.ratio), closeTo(1, 1e-9));
  });

  test('날짜별 묶음은 최근 날짜가 먼저이고 그날의 순지출에 이체를 빼고 센다', () {
    final days = groupByDay(march);

    expect(days.first.date, DateTime(2026, 3, 18));
    expect(days.first.totals.expense, 24700);
    expect(days.first.totals.income, 0);
    expect(days.first.totals.transferCount, 1);
    expect(days.first.entries.first.title, '스타벅스 리저브');
  });

  test('프로젝트 지출은 달을 넘겨서도 모두 세고 순자산에 카드를 더하지 않는다', () {
    expect(projectSpent(book.entries, 'japan-trip'), 680000);
    expect(netWorth(book.assets), 18450200);
  });

  test('수입이 없으면 저축률은 0이고 예산이 없으면 사용률은 0이다', () {
    expect(totalsOf([_entry(EntryType.expense, 1000)]).savingsRate, 0);
    expect(budgetUsage(1000, 0), 0);
  });

  test('연속 기록은 오늘부터 거슬러 세고 하루라도 비면 거기서 끊는다', () {
    final entries = [
      for (final day in [18, 17, 16, 14])
        LedgerEntry(
          id: '$day',
          type: EntryType.expense,
          amount: 1000,
          title: '거래',
          occurredAt: DateTime(2026, 3, day, 9),
          assetId: 'bank',
        ),
    ];

    expect(recordStreak(entries, DateTime(2026, 3, 18, 23)), 3);
    expect(recordStreak(entries, DateTime(2026, 3, 19)), 0);
  });

  group('매달 반복', () {
    final rent = LedgerEntry(
      id: 'rent',
      type: EntryType.expense,
      amount: 500000,
      title: '월세',
      occurredAt: DateTime(2026, 1, 31, 9),
      assetId: 'bank',
      isRecurring: true,
      recurringDay: 31,
    );

    test('한 달이 지나기 전에는 아무것도 만들지 않는다', () {
      expect(dueRecurringEntries([rent], DateTime(2026, 2, 27)), isEmpty);
    });

    test('건너뛴 달을 모두 만들고, 31일 반복은 2월 말일을 지나 다시 31일로 돌아온다', () {
      final changed = dueRecurringEntries([rent], DateTime(2026, 4));
      final byId = {for (final entry in changed) entry.id: entry};

      expect(byId.keys, {'rent', 'rent-r202602', 'rent-r202603'});
      expect(byId['rent-r202602']!.occurredAt, DateTime(2026, 2, 28, 9));
      expect(byId['rent-r202603']!.occurredAt, DateTime(2026, 3, 31, 9));
      expect(byId['rent']!.recurrenceHandled, isTrue);
      expect(byId['rent-r202602']!.recurrenceHandled, isTrue);
      expect(byId['rent-r202603']!.recurrenceHandled, isFalse);
      expect(byId['rent-r202603']!.amount, 500000);
    });

    test('이미 만든 달은 다시 만들지 않는다', () {
      final now = DateTime(2026, 4);
      final once = dueRecurringEntries([rent], now);

      expect(dueRecurringEntries(once, now), isEmpty);
    });
  });

  group('applyEntry', () {
    const assets = [
      AssetAccount(id: 'bank', name: '통장', kind: AssetKind.bank, balance: 1000),
      AssetAccount(id: 'toss', name: '토스', kind: AssetKind.bank, balance: 500),
      AssetAccount(
        id: 'card',
        name: '카드',
        kind: AssetKind.creditCard,
        balance: 300,
      ),
    ];
    Map<String, int> balances(LedgerEntry entry) => {
      for (final asset in applyEntry(assets, entry)) asset.id: asset.balance,
    };

    test('지출은 통장에서 빠지고 카드에서는 결제 예정 금액이 늘어난다', () {
      expect(balances(_entry(EntryType.expense, 200))['bank'], 800);
      expect(balances(_entry(EntryType.expense, 200, to: 'card'))['card'], 500);
    });

    test('반영한 거래를 되돌리면 잔액이 처음으로 돌아온다', () {
      for (final entry in [
        _entry(EntryType.expense, 200),
        _entry(EntryType.expense, 200, to: 'card'),
        _entry(EntryType.income, 200),
        _entry(EntryType.transfer, 200, to: 'card'),
      ]) {
        final restored = revertEntry(applyEntry(assets, entry), entry);
        expect([for (final a in restored) a.balance], [1000, 500, 300]);
      }
    });

    test('이체는 순자산을 바꾸지 않고 카드로 보내면 결제 예정 금액이 줄어든다', () {
      final moved = applyEntry(assets, _entry(EntryType.transfer, 200));
      expect(netWorth(moved), netWorth(assets));
      expect(balances(_entry(EntryType.transfer, 200))['toss'], 300);
      expect(
        balances(_entry(EntryType.transfer, 200, to: 'card'))['card'],
        100,
      );
    });
  });
}
