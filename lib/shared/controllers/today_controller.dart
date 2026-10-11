import 'package:hooks_riverpod/hooks_riverpod.dart';

/// 오늘 날짜 Provider. 테스트에서 날짜를 고정할 때 바꿔 끼웁니다.
final todayProvider = Provider<DateTime>((ref) => DateTime.now());

/// 화면들이 함께 보는 달 Provider
final selectedMonthProvider =
    NotifierProvider<SelectedMonthController, DateTime>(
      SelectedMonthController.new,
    );

/// 홈·내역·분석이 함께 보는 달을 관리하는 컨트롤러
class SelectedMonthController extends Notifier<DateTime> {
  @override
  DateTime build() {
    final today = ref.watch(todayProvider);
    return DateTime(today.year, today.month);
  }

  /// 달을 [offset]만큼 옮깁니다. (-1 이전 달, +1 다음 달)
  void shift(int offset) {
    state = DateTime(state.year, state.month + offset);
  }
}
