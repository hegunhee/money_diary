import 'package:flutter/painting.dart';

/// 앱 전체에서 사용되는 텍스트 스타일을 정의하는 클래스
///
/// `docs/design/DESIGN.md` 의 타이포 토큰을 그대로 옮겼습니다. 시안의 Inter 는 한글
/// 대체 글꼴로 Pretendard 를 지정하는데, Pretendard 의 라틴·숫자가 Inter 기반이라
/// Pretendard 하나만 번들합니다. 금액 토큰(display·amount)은 자릿수가 세로로 맞도록
/// 고정폭 숫자(tnum)를 켭니다.
class AppTypography {
  const AppTypography._();

  /// 기본 폰트 패밀리
  static const fontFamily = 'Pretendard';

  static const _tabular = [FontFeature.tabularFigures()];

  /// Display/Currency — 최상위 잔액 (34px, Bold, 줄 높이 42)
  static const displayCurrency = TextStyle(
    fontSize: 34,
    fontWeight: FontWeight.w700,
    height: 42 / 34,
    letterSpacing: -0.68,
    fontFeatures: _tabular,
    fontFamily: fontFamily,
  );

  /// Display/Currency-Mobile — 카드 안의 큰 금액 (28px, Bold, 줄 높이 36)
  static const displayCurrencyMobile = TextStyle(
    fontSize: 28,
    fontWeight: FontWeight.w700,
    height: 36 / 28,
    letterSpacing: -0.56,
    fontFeatures: _tabular,
    fontFamily: fontFamily,
  );

  /// Headline/LG (24px, Bold, 줄 높이 32)
  static const headlineLg = TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.w700,
    height: 32 / 24,
    letterSpacing: -0.36,
    fontFamily: fontFamily,
  );

  /// Headline/MD (20px, SemiBold, 줄 높이 28)
  static const headlineMd = TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.w600,
    height: 28 / 20,
    letterSpacing: -0.2,
    fontFamily: fontFamily,
  );

  /// Headline/SM — 카드 제목·버튼 라벨 (17px, SemiBold, 줄 높이 24)
  static const headlineSm = TextStyle(
    fontSize: 17,
    fontWeight: FontWeight.w600,
    height: 24 / 17,
    letterSpacing: -0.085,
    fontFamily: fontFamily,
  );

  /// Body/LG — 거래 이름 (16px, Regular, 줄 높이 24)
  static const bodyLg = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w400,
    height: 24 / 16,
    letterSpacing: -0.08,
    fontFamily: fontFamily,
  );

  /// Body/MD (14px, Regular, 줄 높이 20)
  static const bodyMd = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w400,
    height: 20 / 14,
    fontFamily: fontFamily,
  );

  /// Body/SM — 자산·메모 같은 보조 정보 (13px, Regular, 줄 높이 18)
  static const bodySm = TextStyle(
    fontSize: 13,
    fontWeight: FontWeight.w400,
    height: 18 / 13,
    letterSpacing: 0.065,
    fontFamily: fontFamily,
  );

  /// Amount/LG — 목록의 금액 (18px, SemiBold, 줄 높이 24)
  static const amountLg = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.w600,
    height: 24 / 18,
    letterSpacing: -0.18,
    fontFeatures: _tabular,
    fontFamily: fontFamily,
  );

  /// Amount/MD — 일별 합계·작은 금액 (15px, SemiBold, 줄 높이 20)
  static const amountMd = TextStyle(
    fontSize: 15,
    fontWeight: FontWeight.w600,
    height: 20 / 15,
    fontFeatures: _tabular,
    fontFamily: fontFamily,
  );

  /// Label/MD (12px, Medium, 줄 높이 16)
  static const labelMd = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w500,
    height: 16 / 12,
    letterSpacing: 0.12,
    fontFamily: fontFamily,
  );

  /// Label/SM — 배지 (11px, SemiBold, 줄 높이 14)
  static const labelSm = TextStyle(
    fontSize: 11,
    fontWeight: FontWeight.w600,
    height: 14 / 11,
    letterSpacing: 0.22,
    fontFamily: fontFamily,
  );
}
