import 'package:money_diary/shared/models/ledger_entry.dart';

/// 내역 목록을 거르는 기준
enum LedgerFilter {
  /// 전체
  all,

  /// 지출만
  expense,

  /// 수입만
  income,

  /// 이체만
  transfer,

  /// 프로젝트에 묶인 거래만
  project
  ;

  bool matches(LedgerEntry entry) => switch (this) {
    all => true,
    expense => entry.type == EntryType.expense,
    income => entry.type == EntryType.income,
    transfer => entry.type == EntryType.transfer,
    project => entry.projectId != null,
  };
}
