import 'package:hooks_riverpod/hooks_riverpod.dart';

/// 하단 탭
enum MainTab {
  /// 홈
  home,

  /// 내역
  history,

  /// 분석
  report,

  /// 프로젝트
  projects,

  /// 설정
  settings,
}

/// 선택된 하단 탭 Provider
final mainTabProvider = NotifierProvider<MainTabController, MainTab>(
  MainTabController.new,
);

/// 하단 탭 선택을 관리하는 컨트롤러. 홈의 "전체보기"처럼 다른 화면에서도 탭을 옮깁니다.
class MainTabController extends Notifier<MainTab> {
  @override
  MainTab build() => MainTab.home;

  // 탭 이동은 값 대입이 아니라 화면 전환이라 메서드로 둡니다.
  // ignore: use_setters_to_change_properties
  void select(MainTab tab) {
    state = tab;
  }
}
