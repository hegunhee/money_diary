import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:money_diary/features/history/models/ledger_filter.dart';

/// 내역 목록을 거르는 기준 Provider
final historyFilterProvider =
    NotifierProvider<HistoryFilterController, LedgerFilter>(
      HistoryFilterController.new,
    );

/// 내역의 거르기를 관리하는 컨트롤러. 홈의 총 수입·총 지출을 눌러 내역으로 옮길 때도 씁니다.
class HistoryFilterController extends Notifier<LedgerFilter> {
  @override
  LedgerFilter build() => LedgerFilter.all;

  // 다른 화면에서도 부르는 동작이라 메서드로 둡니다.
  // ignore: use_setters_to_change_properties
  void select(LedgerFilter filter) {
    state = filter;
  }
}
