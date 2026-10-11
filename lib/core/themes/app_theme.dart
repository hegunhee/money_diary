import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:money_diary/core/themes/app_colors.dart';
import 'package:money_diary/core/themes/app_typography.dart';

/// 앱 전체에서 사용되는 테마 설정을 정의하는 클래스
class AppTheme {
  /// 라이트 모드 테마 설정을 반환합니다.
  static ThemeData get lightTheme => _theme(Brightness.light, AppColors.light);

  /// 다크 모드 테마 설정을 반환합니다.
  static ThemeData get darkTheme => _theme(Brightness.dark, AppColors.dark);

  static ThemeData _theme(Brightness brightness, AppColors colors) {
    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      fontFamily: AppTypography.fontFamily,
      colorScheme: ColorScheme(
        brightness: brightness,
        primary: colors.primary,
        onPrimary: colors.onPrimary,
        secondary: colors.expense,
        onSecondary: colors.onPrimary,
        tertiary: colors.income,
        onTertiary: colors.onPrimary,
        error: colors.error,
        onError: colors.onPrimary,
        surface: colors.background,
        onSurface: colors.textPrimary,
        onSurfaceVariant: colors.textSecondary,
        outline: colors.outline,
        outlineVariant: colors.divider,
      ),
      scaffoldBackgroundColor: colors.background,
      appBarTheme: _appBarTheme(colors.background),
      dividerColor: colors.divider,
      extensions: <ThemeExtension<dynamic>>[colors],
    );
  }

  /// 본문이 앱바 아래로 스크롤돼도 앱바 색이 변하지 않게 하는 앱바 테마입니다.
  ///
  /// Material 3 기본값은 스크롤 시 브랜드 색 틴트를 덧입히고, 배경색을 정하지 않은
  /// 앱바는 배경까지 바꿉니다. 여기서 한 번 꺼 두어 화면마다 따로 끄지 않습니다.
  static AppBarThemeData _appBarTheme(Color backgroundColor) {
    return AppBarThemeData(
      backgroundColor: backgroundColor,
      surfaceTintColor: Colors.transparent,
      scrolledUnderElevation: 0,
    );
  }

  /// 테마 밝기에 맞는 상태바·내비게이션 바 스타일을 반환합니다.
  ///
  /// 앱바가 없는 화면은 스스로 스타일을 정하지 않아, 앞 화면(튜토리얼·스플래시)이 남긴
  /// 흰 아이콘이 흰 배경 위에 그대로 남습니다. 앱 루트에 이 스타일을 깔아 두면
  /// 앱바·[AnnotatedRegion]이 없는 화면은 언제나 이 값으로 돌아옵니다.
  static SystemUiOverlayStyle overlayStyleFor(Brightness brightness) {
    final iconBrightness = brightness == Brightness.dark
        ? Brightness.light
        : Brightness.dark;
    return SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      // 안드로이드는 아이콘 밝기를 받습니다.
      statusBarIconBrightness: iconBrightness,
      // iOS는 배경 밝기를 받아 반대색 글자를 그립니다.
      statusBarBrightness: brightness,
      systemNavigationBarIconBrightness: iconBrightness,
    );
  }

  /// [MaterialApp.builder]에 넣어 앱 루트에 [overlayStyleFor]를 까는 빌더입니다.
  ///
  /// 스플래시처럼 안쪽 [AnnotatedRegion]·앱바가 정한 스타일이 있으면 그쪽이 우선합니다.
  static Widget withSystemOverlay(BuildContext context, Widget? child) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: overlayStyleFor(Theme.of(context).brightness),
      child: child!,
    );
  }
}
