/// 디자인 가이드의 spacing 스케일을 그대로 옮긴 간격 토큰.
class AppSpacing {
  const AppSpacing._();

  /// 4px
  static const xs = 4.0;

  /// 8px
  static const sm = 8.0;

  /// 12px
  static const md = 12.0;

  /// 16px
  static const lg = 16.0;

  /// 24px
  static const xl = 24.0;

  /// 32px
  static const xxl = 32.0;

  /// 화면 좌우 여백 (16px)
  static const gutter = 16.0;
}

/// 디자인 가이드의 모서리 반경 토큰.
class AppRadius {
  const AppRadius._();

  /// 4px
  static const sm = 4.0;

  /// 8px — 입력칸·세그먼트·카드 안의 묶음
  static const md = 8.0;

  /// 12px — 카드
  static const lg = 12.0;

  /// 16px — 큰 카드·시트
  static const xl = 16.0;

  /// 알약 — 배지·칩·떠 있는 버튼
  static const full = 999.0;
}
