import 'package:money_diary/shared/models/asset_account.dart';
import 'package:money_diary/shared/models/ledger_entry.dart';
import 'package:money_diary/shared/models/ledger_summary.dart';

/// [month]가 속한 달의 거래만 고릅니다.
List<LedgerEntry> entriesInMonth(List<LedgerEntry> entries, DateTime month) => [
  for (final entry in entries)
    if (entry.occurredAt.year == month.year &&
        entry.occurredAt.month == month.month)
      entry,
];

/// 수입·지출 합계를 냅니다. 이체는 자산 간 이동이라 어느 쪽에도 더하지 않습니다.
LedgerTotals totalsOf(Iterable<LedgerEntry> entries) {
  var income = 0;
  var expense = 0;
  var transfer = 0;
  var transferCount = 0;
  for (final entry in entries) {
    switch (entry.type) {
      case EntryType.income:
        income += entry.amount;
      case EntryType.expense:
        expense += entry.amount;
      case EntryType.transfer:
        transfer += entry.amount;
        transferCount++;
    }
  }
  return LedgerTotals(
    income: income,
    expense: expense,
    transfer: transfer,
    transferCount: transferCount,
  );
}

/// 거래를 날짜별로 묶습니다. 최근 날짜, 늦은 시각이 먼저 옵니다.
List<DailyLedger> groupByDay(Iterable<LedgerEntry> entries) {
  final byDay = <DateTime, List<LedgerEntry>>{};
  for (final entry in entries) {
    final at = entry.occurredAt;
    byDay.putIfAbsent(DateTime(at.year, at.month, at.day), () => []).add(entry);
  }
  final days = byDay.keys.toList()..sort((a, b) => b.compareTo(a));
  return [
    for (final day in days)
      DailyLedger(
        date: day,
        entries: byDay[day]!
          ..sort((a, b) => b.occurredAt.compareTo(a.occurredAt)),
        totals: totalsOf(byDay[day]!),
      ),
  ];
}

/// 카테고리별 지출 몫을 금액이 큰 순서로 냅니다. 수입·이체는 세지 않습니다.
List<CategoryShare> categoryShares(Iterable<LedgerEntry> entries) {
  final amounts = <LedgerCategory, int>{};
  for (final entry in entries) {
    if (entry.type == EntryType.expense) {
      final category = entry.category ?? LedgerCategory.etc;
      amounts[category] = (amounts[category] ?? 0) + entry.amount;
    }
  }
  final total = amounts.values.fold(0, (sum, amount) => sum + amount);
  return [
    for (final item in amounts.entries)
      CategoryShare(
        category: item.key,
        amount: item.value,
        ratio: total == 0 ? 0 : item.value / total,
      ),
  ]..sort((a, b) => b.amount.compareTo(a.amount));
}

/// 결제 수단별 지출 몫을 금액이 큰 순서로 냅니다. 수입·이체는 세지 않습니다.
List<AssetShare> assetShares(
  Iterable<LedgerEntry> entries,
  List<AssetAccount> assets,
) {
  final amounts = <String, int>{};
  for (final entry in entries) {
    if (entry.type == EntryType.expense) {
      amounts[entry.assetId] = (amounts[entry.assetId] ?? 0) + entry.amount;
    }
  }
  final total = amounts.values.fold(0, (sum, amount) => sum + amount);
  return [
    for (final asset in assets)
      if (amounts.containsKey(asset.id))
        AssetShare(
          asset: asset,
          amount: amounts[asset.id]!,
          ratio: total == 0 ? 0 : amounts[asset.id]! / total,
        ),
  ]..sort((a, b) => b.amount.compareTo(a.amount));
}

/// 프로젝트에 묶인 지출의 합입니다. 기간과 상관없이 전체를 셉니다.
int projectSpent(Iterable<LedgerEntry> entries, String projectId) {
  var spent = 0;
  for (final entry in entries) {
    if (entry.projectId == projectId && entry.type == EntryType.expense) {
      spent += entry.amount;
    }
  }
  return spent;
}

/// [today]까지 하루도 빠지지 않고 기록한 날 수입니다. 오늘 기록이 없으면 0입니다.
int recordStreak(Iterable<LedgerEntry> entries, DateTime today) {
  final days = {
    for (final entry in entries)
      DateTime(
        entry.occurredAt.year,
        entry.occurredAt.month,
        entry.occurredAt.day,
      ),
  };
  var streak = 0;
  while (days.contains(DateTime(today.year, today.month, today.day - streak))) {
    streak++;
  }
  return streak;
}

/// 순자산. 카드·간편결제의 결제 예정 금액은 더하지 않습니다.
int netWorth(Iterable<AssetAccount> assets) => assetTotal(
  assets.where((asset) => asset.kind.countsTowardNetWorth),
);

/// 자산 잔액의 합
int assetTotal(Iterable<AssetAccount> assets) =>
    assets.fold(0, (sum, asset) => sum + asset.balance);

/// [month]의 날 수로 나눈 하루 평균 지출입니다.
int dailyAverage(int expense, DateTime month) =>
    expense ~/ DateTime(month.year, month.month + 1, 0).day;

/// 예산에서 쓴 비율 (0 이상). 예산이 없으면 0입니다.
double budgetUsage(int expense, int budget) =>
    budget <= 0 ? 0 : expense / budget;

/// 거래 한 건을 반영한 자산 목록을 냅니다.
///
/// 지출은 결제 자산에서 빠지고(카드·간편결제는 결제 예정 금액이 늘고), 수입은 더해지며,
/// 이체는 보내는 자산에서 빠져 받는 자산에 더해집니다.
List<AssetAccount> applyEntry(List<AssetAccount> assets, LedgerEntry entry) {
  int delta(AssetAccount asset) {
    final outflow = asset.kind.countsTowardNetWorth
        ? -entry.amount
        : entry.amount;
    if (asset.id == entry.assetId) {
      return switch (entry.type) {
        EntryType.expense || EntryType.transfer => outflow,
        EntryType.income => -outflow,
      };
    }
    if (entry.type == EntryType.transfer && asset.id == entry.toAssetId) {
      return -outflow;
    }
    return 0;
  }

  return [
    for (final asset in assets) asset.withBalance(asset.balance + delta(asset)),
  ];
}
