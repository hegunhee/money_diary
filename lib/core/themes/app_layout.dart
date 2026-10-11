/// 화면 폭·터치 영역에 관한 레이아웃 토큰.
class AppLayout {
  const AppLayout._();

  /// 태블릿에서 본문을 묶는 최대 폭.
  ///
  /// 시안은 폰 폭 기준으로만 그려져 있어, 넓은 화면에서는 늘리지 않고 가운데로 묶습니다.
  static const contentMaxWidth = 600.0;

  /// 바텀 시트의 최대 폭.
  static const sheetMaxWidth = 480.0;

  /// 탭 대상의 최소 크기.
  static const minTouchTarget = 44.0;
}
