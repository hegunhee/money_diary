# 포켓가계부 (Pocket Ledger)

수입·지출·이체를 기록하는 가계부 Flutter 앱(iOS · Android)입니다. 서버 없이 기기의 로컬
DB에 저장합니다.

- Flutter 3.41.9 — 로컬은 FVM(`.fvmrc`), CI는 워크플로의 `flutter-version`
- 상태관리 Riverpod 3 + flutter_hooks (`HookConsumerWidget`)
- 다국어 easy_localization (`ko` 기본 · `en`)

내부 구조·디자인 시스템은 [ARCHITECTURE.md](ARCHITECTURE.md), 코딩 규약은
[CLAUDE.md](CLAUDE.md), 디자인 시안은 [docs/design/](docs/design/)을 보세요.

## 실행

```bash
fvm install                 # .fvmrc 버전 설치
fvm flutter pub get
fvm flutter run
```

## 자주 쓰는 명령

```bash
fvm flutter analyze                 # 정적 분석
fvm flutter test                    # 테스트
fvm dart format .                   # 포맷
fvm flutter pub add <package>       # 패키지 추가 (pubspec 직접 수정 금지)
fvm flutter build apk               # Android 빌드
```

## 환경 설정

- Flutter·FVM 설치: [docs/setup/FLUTTER_SETUP.md](docs/setup/FLUTTER_SETUP.md)
  ([Windows](docs/setup/FLUTTER_SETUP_WINDOWS.md) · [macOS](docs/setup/FLUTTER_SETUP_MACOS.md) ·
  [FVM](docs/setup/FLUTTER_SETUP_FVM.md) · [문제 해결](docs/setup/FLUTTER_TROUBLESHOOTING.md))
- Firebase: 아직 연결하지 않았습니다(`lib/setup.dart` 의 `enableFirebase = false`).
  연결 방법은 [docs/setup/FIREBASE_SETUP.md](docs/setup/FIREBASE_SETUP.md).
- Claude Code MCP: [docs/setup/CLAUDE_CODE_MCP_SETUP.md](docs/setup/CLAUDE_CODE_MCP_SETUP.md)

## 라이선스

- 코드: MIT ([LICENSE.txt](LICENSE.txt))
- 폰트 Pretendard: SIL Open Font License 1.1 ([assets/fonts/OFL.txt](assets/fonts/OFL.txt))
