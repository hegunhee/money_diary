import 'package:money_diary/shared/models/asset_account.dart';
import 'package:money_diary/shared/models/ledger_entry.dart';

/// 한 기간의 수입·지출 합계. 이체는 들어가지 않습니다.
class LedgerTotals {
  const LedgerTotals({
    required this.income,
    required this.expense,
    required this.transfer,
    required this.transferCount,
  });

  final int income;

  final int expense;

  /// 이체 금액의 합. 수입·지출과 따로 안내할 때만 씁니다.
  final int transfer;

  final int transferCount;

  /// 모은 돈 (수입 − 지출)
  int get net => income - expense;

  /// 저축률 (모은 돈 ÷ 수입). 수입이 없으면 0입니다.
  double get savingsRate => income <= 0 ? 0 : net / income;
}

/// 하루치 거래 묶음
class DailyLedger {
  const DailyLedger({
    required this.date,
    required this.entries,
    required this.totals,
  });

  /// 시각을 뗀 날짜
  final DateTime date;

  /// 그날의 거래. 늦은 시각이 먼저 옵니다.
  final List<LedgerEntry> entries;

  final LedgerTotals totals;
}

/// 카테고리 하나가 지출에서 차지하는 몫
class CategoryShare {
  const CategoryShare({
    required this.category,
    required this.amount,
    required this.ratio,
  });

  final LedgerCategory category;

  final int amount;

  /// 전체 지출 대비 비율 (0~1)
  final double ratio;
}

/// 결제 수단 하나가 지출에서 차지하는 몫
class AssetShare {
  const AssetShare({
    required this.asset,
    required this.amount,
    required this.ratio,
  });

  final AssetAccount asset;

  final int amount;

  /// 전체 지출 대비 비율 (0~1)
  final double ratio;
}
