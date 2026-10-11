import 'package:flutter/material.dart';

/// 디자인 가이드(`docs/design/DESIGN.md`)의 색을 그대로 옮긴 원시 토큰 모음.
///
/// 시맨틱 색상(AppColors)이 참조하는 색의 단일 출처입니다.
/// 원시 hex 리터럴은 이 파일에만 둡니다.
class AppPalette {
  const AppPalette._();

  /// Primary — 주요 동작·확정 버튼·앵커
  static const primary = Color(0xFF4F46E5);

  /// On-Primary
  static const onPrimary = Color(0xFFFFFFFF);

  /// Primary-Fixed — primary 옅은 바탕(배지·아이콘 원)
  static const primaryFixed = Color(0xFFE2DFFF);

  /// Primary-Fixed-Dim
  static const primaryFixedDim = Color(0xFFC3C0FF);

  /// On-Primary-Fixed
  static const onPrimaryFixed = Color(0xFF0F0069);

  /// On-Primary-Fixed-Variant
  static const onPrimaryFixedVariant = Color(0xFF3323CC);

  /// 지출
  static const expense = Color(0xFFEF4444);

  /// 지출 옅은 바탕 (Secondary-Fixed)
  static const expenseFixed = Color(0xFFFFDADB);

  /// Secondary-Fixed-Dim
  static const expenseFixedDim = Color(0xFFFFB2B7);

  /// On-Secondary-Fixed-Variant
  static const onExpenseFixedVariant = Color(0xFF92002A);

  /// 수입
  static const income = Color(0xFF2563EB);

  /// 수입 옅은 바탕 (Tertiary-Fixed)
  static const incomeFixed = Color(0xFFDBE1FF);

  /// Tertiary-Fixed-Dim
  static const incomeFixedDim = Color(0xFFB4C5FF);

  /// On-Tertiary-Fixed-Variant
  static const onIncomeFixedVariant = Color(0xFF003EA8);

  /// Surface — 화면 바탕
  static const surface = Color(0xFFFAF8FF);

  /// Surface-Container-Lowest — 카드
  static const surfaceContainerLowest = Color(0xFFFFFFFF);

  /// Surface-Container-Low
  static const surfaceContainerLow = Color(0xFFF2F3FF);

  /// Surface-Container
  static const surfaceContainer = Color(0xFFEAEDFF);

  /// Surface-Container-High
  static const surfaceContainerHigh = Color(0xFFE2E7FF);

  /// Surface-Container-Highest
  static const surfaceContainerHighest = Color(0xFFDAE2FD);

  /// On-Surface
  static const onSurface = Color(0xFF131B2E);

  /// On-Surface-Variant
  static const onSurfaceVariant = Color(0xFF464555);

  /// Inverse-Surface
  static const inverseSurface = Color(0xFF283044);

  /// Inverse-On-Surface
  static const inverseOnSurface = Color(0xFFEEF0FF);

  /// Outline
  static const outline = Color(0xFF777587);

  /// Outline-Variant
  static const outlineVariant = Color(0xFFC7C4D8);

  /// Error
  static const error = Color(0xFFBA1A1A);

  /// 다크 테마 Error
  static const errorDark = Color(0xFFFFB4AB);

  // --- 다크 테마 표면 (시안에 다크가 없어 On-Surface 색조에서 유도한 값) ---

  /// 다크 화면 바탕
  static const darkSurface = Color(0xFF0E1525);

  /// 다크 카드
  static const darkSurfaceContainerLowest = Color(0xFF182036);

  /// 다크 Surface-Container-Low
  static const darkSurfaceContainerLow = Color(0xFF1E2740);

  /// 다크 Surface-Container
  static const darkSurfaceContainer = Color(0xFF242E4A);

  /// 다크 Surface-Container-High
  static const darkSurfaceContainerHigh = Color(0xFF2B3655);

  /// 다크 Surface-Container-Highest
  static const darkSurfaceContainerHighest = Color(0xFF333F60);

  /// 다크 On-Primary
  static const darkOnPrimary = Color(0xFF1D00A5);

  /// 다크 Outline
  static const darkOutline = Color(0xFF918FA1);

  // --- 투명도가 들어간 색 ---

  /// 모달 뒤를 덮는 dim (#0F172A 40%)
  static const scrim = Color(0x660F172A);

  /// 다크 테마의 dim (검정 60%)
  static const darkScrim = Color(0x99000000);

  /// 카드가 바닥에서 살짝 뜬 느낌을 주는 그림자 (#0F172A 6%)
  static const shadow = Color(0x0F0F172A);
}
