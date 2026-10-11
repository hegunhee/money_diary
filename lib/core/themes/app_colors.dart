import 'package:flutter/material.dart';
import 'package:money_diary/core/themes/app_palette.dart';

/// 앱 전체에서 사용되는 색상을 정의하는 ThemeExtension
///
/// 화면은 `context.colors` 로만 색을 읽습니다. 원시 값은 [AppPalette]에 있습니다.
@immutable
class AppColors extends ThemeExtension<AppColors> {
  const AppColors({
    required this.background,
    required this.surface,
    required this.surfaceLow,
    required this.surfaceContainer,
    required this.surfaceHigh,
    required this.surfaceHighest,
    required this.textPrimary,
    required this.textSecondary,
    required this.primary,
    required this.onPrimary,
    required this.primaryTint,
    required this.onPrimaryTint,
    required this.expense,
    required this.expenseTint,
    required this.income,
    required this.incomeTint,
    required this.transfer,
    required this.transferTint,
    required this.error,
    required this.outline,
    required this.divider,
    required this.inverseSurface,
    required this.onInverseSurface,
    required this.scrim,
  });

  /// 화면 바탕
  final Color background;

  /// 카드·시트 바탕
  final Color surface;

  /// 카드 안의 묶음·입력칸 바탕
  final Color surfaceLow;

  /// 강조 줄·세그먼트 레일 바탕
  final Color surfaceContainer;

  /// 알약 배지·누름 표현 바탕
  final Color surfaceHigh;

  /// 진행 바 트랙 등 가장 짙은 바탕
  final Color surfaceHighest;

  /// 기본 텍스트 색상
  final Color textPrimary;

  /// 보조 텍스트 색상 (메타 정보·시각·자산명)
  final Color textSecondary;

  /// 주요 강조 색상
  final Color primary;

  /// primary 배경 위의 텍스트·아이콘 색
  final Color onPrimary;

  /// primary 옅은 바탕 (배지·아이콘 원)
  final Color primaryTint;

  /// [primaryTint] 위의 텍스트 색
  final Color onPrimaryTint;

  /// 지출 금액·표시 색
  final Color expense;

  /// 지출 옅은 바탕
  final Color expenseTint;

  /// 수입 금액·표시 색
  final Color income;

  /// 수입 옅은 바탕
  final Color incomeTint;

  /// 이체 표시 색. 수입·지출과 섞이지 않게 중립색을 씁니다.
  final Color transfer;

  /// 이체 옅은 바탕
  final Color transferTint;

  /// 오류 상태 표시 색상
  final Color error;

  /// 테두리·비활성 아이콘 색
  final Color outline;

  /// 구분선 색상
  final Color divider;

  /// 선택된 필터 칩처럼 뒤집힌 바탕
  final Color inverseSurface;

  /// [inverseSurface] 위의 텍스트 색
  final Color onInverseSurface;

  /// 모달 뒤를 덮는 dim
  final Color scrim;

  /// 밝은 테마용 기본 컬러 정의
  static const light = AppColors(
    background: AppPalette.surface,
    surface: AppPalette.surfaceContainerLowest,
    surfaceLow: AppPalette.surfaceContainerLow,
    surfaceContainer: AppPalette.surfaceContainer,
    surfaceHigh: AppPalette.surfaceContainerHigh,
    surfaceHighest: AppPalette.surfaceContainerHighest,
    textPrimary: AppPalette.onSurface,
    textSecondary: AppPalette.onSurfaceVariant,
    primary: AppPalette.primary,
    onPrimary: AppPalette.onPrimary,
    primaryTint: AppPalette.primaryFixed,
    onPrimaryTint: AppPalette.onPrimaryFixed,
    expense: AppPalette.expense,
    expenseTint: AppPalette.expenseFixed,
    income: AppPalette.income,
    incomeTint: AppPalette.incomeFixed,
    transfer: AppPalette.onSurfaceVariant,
    transferTint: AppPalette.surfaceContainerHigh,
    error: AppPalette.error,
    outline: AppPalette.outline,
    divider: AppPalette.outlineVariant,
    inverseSurface: AppPalette.inverseSurface,
    onInverseSurface: AppPalette.inverseOnSurface,
    scrim: AppPalette.scrim,
  );

  /// 다크 테마용 기본 컬러 정의
  ///
  /// 시안에 다크 화면이 없어 디자인 토큰의 fixed-dim · inverse 값에서 유도했습니다.
  static const dark = AppColors(
    background: AppPalette.darkSurface,
    surface: AppPalette.darkSurfaceContainerLowest,
    surfaceLow: AppPalette.darkSurfaceContainerLow,
    surfaceContainer: AppPalette.darkSurfaceContainer,
    surfaceHigh: AppPalette.darkSurfaceContainerHigh,
    surfaceHighest: AppPalette.darkSurfaceContainerHighest,
    textPrimary: AppPalette.inverseOnSurface,
    textSecondary: AppPalette.outlineVariant,
    primary: AppPalette.primaryFixedDim,
    onPrimary: AppPalette.darkOnPrimary,
    primaryTint: AppPalette.onPrimaryFixedVariant,
    onPrimaryTint: AppPalette.primaryFixed,
    expense: AppPalette.expenseFixedDim,
    expenseTint: AppPalette.onExpenseFixedVariant,
    income: AppPalette.incomeFixedDim,
    incomeTint: AppPalette.onIncomeFixedVariant,
    transfer: AppPalette.outlineVariant,
    transferTint: AppPalette.darkSurfaceContainerHigh,
    error: AppPalette.errorDark,
    outline: AppPalette.darkOutline,
    divider: AppPalette.onSurfaceVariant,
    inverseSurface: AppPalette.inverseOnSurface,
    onInverseSurface: AppPalette.inverseSurface,
    scrim: AppPalette.darkScrim,
  );

  @override
  AppColors copyWith({
    Color? background,
    Color? surface,
    Color? surfaceLow,
    Color? surfaceContainer,
    Color? surfaceHigh,
    Color? surfaceHighest,
    Color? textPrimary,
    Color? textSecondary,
    Color? primary,
    Color? onPrimary,
    Color? primaryTint,
    Color? onPrimaryTint,
    Color? expense,
    Color? expenseTint,
    Color? income,
    Color? incomeTint,
    Color? transfer,
    Color? transferTint,
    Color? error,
    Color? outline,
    Color? divider,
    Color? inverseSurface,
    Color? onInverseSurface,
    Color? scrim,
  }) => AppColors(
    background: background ?? this.background,
    surface: surface ?? this.surface,
    surfaceLow: surfaceLow ?? this.surfaceLow,
    surfaceContainer: surfaceContainer ?? this.surfaceContainer,
    surfaceHigh: surfaceHigh ?? this.surfaceHigh,
    surfaceHighest: surfaceHighest ?? this.surfaceHighest,
    textPrimary: textPrimary ?? this.textPrimary,
    textSecondary: textSecondary ?? this.textSecondary,
    primary: primary ?? this.primary,
    onPrimary: onPrimary ?? this.onPrimary,
    primaryTint: primaryTint ?? this.primaryTint,
    onPrimaryTint: onPrimaryTint ?? this.onPrimaryTint,
    expense: expense ?? this.expense,
    expenseTint: expenseTint ?? this.expenseTint,
    income: income ?? this.income,
    incomeTint: incomeTint ?? this.incomeTint,
    transfer: transfer ?? this.transfer,
    transferTint: transferTint ?? this.transferTint,
    error: error ?? this.error,
    outline: outline ?? this.outline,
    divider: divider ?? this.divider,
    inverseSurface: inverseSurface ?? this.inverseSurface,
    onInverseSurface: onInverseSurface ?? this.onInverseSurface,
    scrim: scrim ?? this.scrim,
  );

  @override
  AppColors lerp(ThemeExtension<AppColors>? other, double t) {
    if (other is! AppColors) {
      return this;
    }
    return AppColors(
      background: Color.lerp(background, other.background, t)!,
      surface: Color.lerp(surface, other.surface, t)!,
      surfaceLow: Color.lerp(surfaceLow, other.surfaceLow, t)!,
      surfaceContainer: Color.lerp(
        surfaceContainer,
        other.surfaceContainer,
        t,
      )!,
      surfaceHigh: Color.lerp(surfaceHigh, other.surfaceHigh, t)!,
      surfaceHighest: Color.lerp(surfaceHighest, other.surfaceHighest, t)!,
      textPrimary: Color.lerp(textPrimary, other.textPrimary, t)!,
      textSecondary: Color.lerp(textSecondary, other.textSecondary, t)!,
      primary: Color.lerp(primary, other.primary, t)!,
      onPrimary: Color.lerp(onPrimary, other.onPrimary, t)!,
      primaryTint: Color.lerp(primaryTint, other.primaryTint, t)!,
      onPrimaryTint: Color.lerp(onPrimaryTint, other.onPrimaryTint, t)!,
      expense: Color.lerp(expense, other.expense, t)!,
      expenseTint: Color.lerp(expenseTint, other.expenseTint, t)!,
      income: Color.lerp(income, other.income, t)!,
      incomeTint: Color.lerp(incomeTint, other.incomeTint, t)!,
      transfer: Color.lerp(transfer, other.transfer, t)!,
      transferTint: Color.lerp(transferTint, other.transferTint, t)!,
      error: Color.lerp(error, other.error, t)!,
      outline: Color.lerp(outline, other.outline, t)!,
      divider: Color.lerp(divider, other.divider, t)!,
      inverseSurface: Color.lerp(inverseSurface, other.inverseSurface, t)!,
      onInverseSurface: Color.lerp(
        onInverseSurface,
        other.onInverseSurface,
        t,
      )!,
      scrim: Color.lerp(scrim, other.scrim, t)!,
    );
  }
}

/// BuildContext 확장을 통해 AppColors에 쉽게 접근할 수 있도록 합니다.
extension AppColorsExtension on BuildContext {
  /// AppColors에 쉽게 접근하기 위한 getter
  AppColors get colors {
    return Theme.of(this).extension<AppColors>() ?? AppColors.light;
  }
}
