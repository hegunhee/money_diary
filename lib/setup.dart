import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart';
import 'package:money_diary/firebase_options.dart';

/// 앱 초기화 및 외부 서비스 설정
///
/// Firebase·Crashlytics 등 앱에서 사용하는 외부 서비스를 초기화합니다.
///
/// ## Firebase 설정
/// [enableFirebase]가 false면 Firebase를 초기화하지 않습니다.
/// `firebase_options.dart` 는 아직 자리표시자이므로, Firebase 프로젝트를 연결하려면:
/// 1. `flutterfire configure` 명령어 실행
/// 2. [enableFirebase] 상수를 true로 변경
class AppSetup {
  /// Firebase 활성화 여부
  static const enableFirebase = false;

  /// Firebase 초기화가 실제로 끝났는지 여부
  ///
  /// 초기화에 실패한 상태에서 Crashlytics를 부르면 2차 예외가 나므로, 기록
  /// 계열 호출 앞에서 이 값을 확인합니다.
  static var isFirebaseReady = false;

  /// 앱 초기화
  static Future<void> initialize() async {
    await _initializeFirebase();
  }

  /// Firebase 초기화
  static Future<void> _initializeFirebase() async {
    if (!enableFirebase) {
      if (kDebugMode) {
        print('Firebase가 비활성화되어 있습니다(enableFirebase = false)');
      }
      return;
    }

    try {
      try {
        await Firebase.initializeApp(
          options: DefaultFirebaseOptions.currentPlatform,
        );
      } on FirebaseException catch (error) {
        // iOS는 번들에 GoogleService-Info.plist가 있으면 네이티브가 실행 시점에
        // [DEFAULT] 앱을 먼저 만듭니다. 그 뒤 여기서 같은 이름으로 또 만들려 하면
        // duplicate-app이 되므로, 이미 만들어진 앱을 그대로 씁니다.
        if (error.code != 'duplicate-app') {
          rethrow;
        }
      }
      isFirebaseReady = true;

      // Crashlytics 설정
      FlutterError.onError = (errorDetails) {
        FirebaseCrashlytics.instance.recordFlutterFatalError(errorDetails);
      };

      // 비동기 에러 처리
      PlatformDispatcher.instance.onError = (error, stack) {
        FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);
        return true;
      };

      if (kDebugMode) {
        print('Firebase 초기화 완료');
      }
    } catch (e, stack) {
      if (kDebugMode) {
        print('Firebase 초기화 실패: $e');
        print('Stack trace: $stack');
      }
      rethrow;
    }
  }

  /// Zone 에러 핸들러
  ///
  /// runZonedGuarded의 onError 콜백으로 사용
  static void handleZoneError(Object error, StackTrace stack) {
    if (kDebugMode) {
      print('Uncaught error: $error');
      print('Stack trace: $stack');
    }
    if (!isFirebaseReady) {
      return;
    }
    FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);
  }
}
