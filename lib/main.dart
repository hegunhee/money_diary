import 'dart:async';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:marionette_flutter/marionette_flutter.dart';
import 'package:money_diary/core/themes/app_theme.dart';
import 'package:money_diary/features/home/screens/home_screen.dart';
import 'package:money_diary/setup.dart';

/// 테스트 실행 여부 (flutter test 환경에서 true)
const _isFlutterTest = bool.fromEnvironment('FLUTTER_TEST');

/// 앱 시작점
void main() {
  runZonedGuarded<Future<void>>(
    () async {
      // Flutter 바인딩 초기화 (debug + non-test 환경에서만 Marionette 사용)
      if (kDebugMode && !_isFlutterTest) {
        MarionetteBinding.ensureInitialized();
      } else {
        WidgetsFlutterBinding.ensureInitialized();
      }
      await _initializeExternalServices();
      // 다국어 지원 초기화
      await EasyLocalization.ensureInitialized();

      runApp(
        // Riverpod 및 EasyLocalization 설정
        EasyLocalization(
          supportedLocales: const [Locale('ko'), Locale('en')],
          path: 'assets/translations',
          fallbackLocale: const Locale('ko'),
          child: const ProviderScope(child: MyApp()),
        ),
      );
    },
    AppSetup.handleZoneError,
  );
}

/// 외부 서비스를 초기화합니다.
///
/// 실패해도 예외를 밖으로 내보내지 않습니다. runApp 앞에서 예외가 나면 첫 프레임이
/// 그려지지 않아 화면이 흰 채로 멈추기 때문입니다. 실패는 기록만 합니다.
Future<void> _initializeExternalServices() async {
  try {
    await AppSetup.initialize();
  } on Object catch (error, stack) {
    AppSetup.handleZoneError(error, stack);
  }
}

/// 앱의 루트 위젯
class MyApp extends StatelessWidget {
  /// MyApp 생성자
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'common.app_name'.tr(),
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      locale: context.locale,
      supportedLocales: context.supportedLocales,
      localizationsDelegates: context.localizationDelegates,
      builder: AppTheme.withSystemOverlay,
      home: const HomeScreen(),
    );
  }
}
