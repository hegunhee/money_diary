# CLAUDE.md

Claude Code(claude.ai/code)가 이 레포에서 작업할 때 따르는 가이드입니다.

## 프로젝트 개요

**포켓가계부(Pocket Ledger)** — 수입·지출·이체를 기록하는 가계부 앱(iOS · Android).
Flutter 단일 모듈이며 패키지 이름은 `money_diary` 입니다. **서버 없이 기기의 로컬 DB**에
저장합니다.

- **Flutter 3.41.9**. 로컬은 FVM(`.fvmrc`), CI는 `subosito/flutter-action` 의
  `flutter-version`. 버전을 올릴 땐 `.fvmrc` 와 모든 워크플로의 `flutter-version` 을 함께 수정.
- 상태관리 **Riverpod 3** + **flutter_hooks** (`HookConsumerWidget`, `hooks_riverpod`).
- 다국어 easy_localization (`ko` 기본 · `en`).
- 엔트리포인트는 `lib/main.dart` 하나.
- 언어: 문서·주석 모두 **한국어**.
- 구조·패턴 상세는 [ARCHITECTURE.md](ARCHITECTURE.md), 실행 방법은 [README.md](README.md).
- 디자인 기준은 [docs/design/DESIGN.md](docs/design/DESIGN.md) 와 `docs/design/screens/`
  의 화면별 시안(`screen.png` · `code.html`).

## 구조 (feature-first)

```
lib/
├── core/                 # 의존성 없이 앱 전체 적용되는 leaf 코드
│   └── themes/           # AppPalette · AppColors · AppTypography · AppSpacing · AppRadius · AppLayout · AppTheme
├── shared/               # 여러 feature에서 중복되는 컴포넌트·코드
│   └── widgets/          # 공용 UI
└── features/<feature>/
    ├── models/           # 데이터 모델
    ├── repositories/     # 로컬 DB 읽기·쓰기
    ├── controllers/      # 상태 (Riverpod)
    ├── screens/
    └── widgets/          # 이 feature 전용
```

의존은 `features → shared → core` 한 방향(역방향 금지). **core** = 의존성 없이 앱 전체
적용되는 기능, **shared** = 여러 feature에서 중복되는 컴포넌트·코드. 폴더는 필요해질 때
만듭니다(빈 폴더를 미리 두지 않음).

## Provider 규칙

- 동기 상태 → `NotifierProvider`, 비동기 상태 → `AsyncNotifierProvider`.
- 컨트롤러 상태는 **모델 그대로** — `LedgerEntry` · `List<LedgerEntry>` ·
  `AsyncValue<List<LedgerEntry>>`.
  감싸는 State 클래스 금지(예외는 아래 모델 참고).
- 화면에서만 쓰는 값(탭 · 입력값 · 펼침 · 임시 편집값 · 진행 중 플래그 · 애니메이션)은
  `HookConsumerWidget`(ref 불필요하면 `HookWidget`)의 `useState` ·
  `useTextEditingController` · `useAnimationController` 등 훅으로.
- ❌ `StateNotifierProvider`(구식) · `FutureProvider`(단순한 경우 외) · `setState` ·
  `StatefulWidget`(훅으로 대체) · `provider` 패키지 금지.
- Provider 변수명은 camelCase + `Provider` 접미사.

```dart
final ledgerProvider =
    AsyncNotifierProvider<LedgerController, List<LedgerEntry>>(LedgerController.new);
```

## 디자인 시스템

- 색: `context.colors` (ThemeExtension 기반 `AppColors`). 하드코딩 색 금지. 원시 hex 는
  `AppPalette` 에만 둡니다. 투명도는 `withValues(alpha:)` (`withOpacity` 금지).
- 수입·지출·이체는 색으로 구분합니다: `colors.income` · `colors.expense` · `colors.transfer`
  (옅은 바탕은 `*Tint`). 금액에는 부호(`+` · `-`)를 함께 적고, 이체는 수입·지출 색을 쓰지 않습니다.
- 타이포: `AppTypography` (`displayCurrency*` · `headlineLg/Md/Sm` · `bodyLg/Md/Sm` ·
  `amountLg/Md` · `labelMd/Sm`). 직접 `fontSize` 금지. 금액은 고정폭 숫자가 켜진
  `displayCurrency*` · `amount*` 토큰으로 적습니다. 폰트는 Pretendard.
- 간격: `AppSpacing` (`xs`=4 · `sm`=8 · `md`=12 · `lg`=16 · `xl`=24 · `xxl`=32), 모서리는
  `AppRadius`. 탭 대상은 최소 44×44(`AppLayout.minTouchTarget`). 태블릿 폭은
  `AppContentWidth`.
- 문자열: `'key'.tr()` (하드코딩 문자열 금지). 키는 `feature.component.text`. 키를 더하면
  `ko.json` · `en.json` 양쪽에 넣습니다(`test/translations_parity_test.dart` 가 확인).
- 누름 반응: 목록의 줄은 `AppTapRow`, 카드·알약·아이콘은 `AppPressScale`.
- 피드백은 스낵바를 기본으로 쓰지 않습니다. 입력 오류는 필드 근처(`InlineErrorText`),
  저장 실패와 재시도는 해당 작업 영역 안(`AppErrorView`)에 표시합니다. 성공은 다음
  화면이나 저장된 상태로 충분하면 별도 메시지를 띄우지 않습니다. 다이얼로그는 명시적
  결정이 필요한 경우만 사용합니다.
- 삭제처럼 되돌릴 수 없는 동작은 확인 창을 거칩니다.
- 이미 읽은 값이 있으면 다시 읽는 동안 그대로 둡니다. 스켈레톤·로딩은 처음 읽을 때만.

## 네이밍

- 파일·폴더: snake_case. 클래스: PascalCase + 접미사(`Controller`/`Screen`/`Repository`).
- 예: `LedgerController` → `ledger_controller.dart`.
- **위젯**: 기반 Material 3 컴포넌트명을 suffix로 (`Button`/`Chip`/`Card`/`Dialog`/`Sheet` …).
  공용 위젯은 `App` 접두사(`AppFillButton`).

## 모델

- 모델은 `models/` 에 대표 클래스명(snake_case) 파일로. 저장소 파일 안에 정의하지 않습니다.
- 화면 표시만을 위한 모델 클래스는 만들지 않습니다. 저장된 값은 모델 그대로, 화면 값은
  훅으로. enum 은 허용. `Model` 접미사 · record typedef 로 상태를 묶는 우회 금지.
- 금액은 원 단위 정수(`int`)로 다룹니다. 합계·비율 같은 계산은 화면이 아니라 순수 함수
  (`shared/util/`)에 두고 테스트합니다. **이체는 자산 간 이동이므로 수입·지출 합계와
  통계에 넣지 않습니다.**
- `*State` 클래스는 **예외로만**: 모델 하나로 안 되고 훅으로도 안 될 때(화면보다 오래
  살거나 여러 화면이 공유)만. `models/xxx_state.dart` 에 두고 필요한 이유를 한 줄
  dartdoc 으로 적습니다.
- 허가 목록은 `state_allowlist.txt`(한 줄에 이름 하나 + `# 이유`).
  `test/architecture/state_allowlist_test.dart` 가 목록에 없는 `*State` · record typedef ·
  StatefulWidget 의 State 를 막습니다. 새로 필요하면 같은 PR 에서 목록에 이유와 함께 추가.

## 금지

`setState` · `StatefulWidget` · 허가 목록에 없는 `*State` 클래스 · record 상태 묶음 ·
`provider` 패키지 · 하드코딩(색/폰트/문자열) · 과도한 추상화(YAGNI) · 영어 doc comment ·
이름만 되풀이하는 doc comment.

## 패키지 추가

`pubspec.yaml` 직접 수정 금지. 반드시 명령어로:

```bash
fvm flutter pub add package_name
fvm flutter pub add package_name --dev
```

## 테스트 작성 기준

테스트는 개수를 늘리거나 단순 구현 내용을 고정하기 위해 만들지 않습니다. 테스트를 추가하기
전에 **어떤 실제 회귀를 막는지** 한 문장으로 설명할 수 있어야 하며, 설명할 수 없다면 추가하지
않습니다.

- 금액 계산·집계 같은 비즈니스 규칙, 저장 실패·롤백, 데이터 정합성처럼 실제로 깨질 수 있는
  동작과 경계를 우선 검증합니다.
- 버그 수정에는 가능하면 그 버그가 재발하면 실패하는 가장 작은 회귀 테스트 하나를 둡니다.
  같은 동작을 단위·위젯 테스트에서 의미 없이 중복 검증하지 않습니다.
- 번역 문구, 정적 파일 존재 여부, 상수값, 단순 생성자·getter, 컴파일러나 정적 분석기가
  이미 잡는 내용만 확인하는 전용 테스트는 작성하지 않습니다.
- 커버리지 수치나 테스트 개수 자체를 목표로 삼지 않습니다.

## 커밋 전 검증

```bash
fvm flutter analyze
fvm flutter test
git ls-files '*.dart' | xargs fvm dart format --output=none --set-exit-if-changed
```

- `dart format` 은 `flutter pub get` 뒤에, 바꾼 파일만 돌립니다. 의존성을 받기 전에 돌리면
  손대지 않은 파일까지 다른 스타일로 바뀝니다.
- `dart fix --apply` 같은 일괄 수정 뒤에는 `git status` 로 의도하지 않은 파일(`pubspec.yaml`
  등)을 확인하고 되돌립니다.

## 커밋·PR 규약

- 커밋·PR 제목은 **한국어 문장**. 영어 `feat:`/`fix:` 프리픽스 사용 금지.
- PR은 Ready 상태(draft 아님)로, linear 히스토리를 유지해 Rebase-and-merge 가능하게.
- 변경을 서술하는 주석(`// X 제거`, `// 이전엔…`)을 소스에 남기지 않습니다.
