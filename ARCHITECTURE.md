# 앱 아키텍처

Flutter · Riverpod 3 · flutter_hooks · easy_localization. 기능(feature) 단위로 나눈
feature-first 구조입니다. 서버 없이 기기의 로컬 DB에 저장합니다.

## 디렉토리

```
lib/
├── main.dart             # 유일한 엔트리포인트 (플레이버 없음)
├── setup.dart            # Firebase·Crashlytics 초기화
├── core/                 # 의존성 없이 앱 전체에 적용되는 leaf 코드
│   └── themes/           # app_palette · app_colors · app_typography · app_spacing · app_layout · app_theme
├── shared/               # 여러 feature에서 중복되는 컴포넌트·코드
│   ├── models/           # 가계부 모델 (LedgerEntry · LedgerCategory · AssetAccount · Project · LedgerBook)
│   ├── repositories/     # 로컬 DB(Hive) 읽기·쓰기 (ledger_repository)
│   ├── controllers/      # 여러 화면이 쓰는 상태 (가계부 · 보는 달 · 하단 탭)
│   ├── util/             # 계산(ledger_calculator) · 표기(ledger_labels · won_format) · 금액 입력(won_input)
│   └── widgets/          # 공용 UI (카드 · 배지 · 거래 줄 · 버튼 · 하단 탭)
└── features/<feature>/
    ├── models/           # 데이터 모델
    ├── repositories/     # 로컬 DB 읽기·쓰기
    ├── controllers/      # 상태 (Riverpod)
    ├── screens/          # 화면
    └── widgets/          # 이 feature 전용 위젯
```

- 의존은 **`features → shared → core`** 한 방향(역방향 금지).
  - **core** : 의존성 없이 앱 전체에 적용되는 기능(테마·순수 유틸).
  - **shared** : 여러 feature에서 중복되는 컴포넌트·코드(공용 위젯 등).
- feature: `main`(하단 탭 뼈대) · `home`(대시보드) · `history`(가계부 내역) · `entry`(거래 입력) · `report`(월간 분석) · `projects`(프로젝트 관리) · `settings`(예산·자산 관리). 하위 폴더는 필요해질 때 만듭니다.

## 로컬 저장

- [hive_ce](https://pub.dev/packages/hive_ce) 로 기기에 저장합니다. 거래·자산·프로젝트를 상자 하나씩에
  id 를 키로, 모델의 `toJson()` 맵을 값으로 넣습니다(코드 생성 없음).
- `LedgerRepository` 만 Hive 를 압니다. 화면 테스트는 `test/helpers/pump_app.dart` 의
  `FakeLedgerRepository` 로 바꿔 끼웁니다.
- 거래를 더하면 `applyEntry` 가 자산 잔액을 함께 고쳐 저장합니다.
- 카테고리는 기본 카테고리(코드의 상수, 이름은 번역 파일)와 사용자가 더한 카테고리(로컬 DB)로
  나뉩니다. 거래에는 카테고리 id와 이름을 함께 저장해, 더한 카테고리를 지워도 그 거래의
  카테고리는 그대로 보입니다.
- 앱은 **빈 가계부(순자산 0원)**로 시작합니다. 처음 실행하면 거래를 바로 적을 수 있게 잔액
  0원인 현금 자산 하나만 만들고, 나머지 자산·예산·프로젝트는 사용자가 더합니다.
- 시안의 예시 가계부는 테스트 전용입니다(`test/helpers/sample_ledger.dart`).

## 데이터 흐름

한 화면은 `Screen → Controller → Repository → 로컬 DB`로 흐릅니다.

- **Repository**: 로컬 DB를 읽고 써서 모델로 변환합니다. 단순 UI 상태뿐이면 두지 않습니다.
- **계산**: 합계·비율·묶기는 `shared/util/` 의 순수 함수에 둡니다. 화면과 컨트롤러는 결과만 씁니다.
- **Controller**: Riverpod. 동기 상태는 `NotifierProvider`, 비동기 상태는
  `AsyncNotifierProvider`. 상태는 **모델 그대로**(`X` · `List<X>` · `AsyncValue<X>`).
  감싸는 State 클래스 없음(예외는 아래 허가 목록).
- **Screen**: `HookConsumerWidget`. 저장된 값은 `ref.watch`, 화면에서만 쓰는 값(탭 ·
  입력값 · 펼침 · 진행 중 플래그 · 애니메이션)은 훅(`useState` ·
  `useTextEditingController` · `useAnimationController` …).

```dart
final ledgerProvider =
    AsyncNotifierProvider<LedgerController, List<LedgerEntry>>(
  LedgerController.new,
);

class LedgerHistoryScreen extends HookConsumerWidget {
  const LedgerHistoryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final filter = useState(LedgerFilter.all); // 화면 전용 값
    final entries = ref.watch(ledgerProvider);
    return entries.when(
      data: (list) => LedgerList(list, filter: filter.value),
      loading: () => const CircularProgressIndicator(),
      error: (e, _) => AppErrorView(
        message: 'ledger.load_failed'.tr(),
        onRetry: () => ref.invalidate(ledgerProvider),
      ),
    );
  }
}
```

- ❌ `StateNotifierProvider`(구식) · `FutureProvider`(단순한 경우 외) · `setState` ·
  `StatefulWidget`(훅으로 대체) · `provider` 패키지 · 허가 목록에 없는 `*State` 클래스 ·
  record typedef 상태 묶음 금지.

### 예외 상태 클래스(`*State`)

모델 하나로 안 되고 훅으로도 안 될 때(화면보다 오래 살거나 여러 화면이 공유)만 씁니다.

- `models/xxx_state.dart`에 두고 필요한 이유를 한 줄 dartdoc으로 적습니다.
- `state_allowlist.txt`에 `이름 # 이유`로 올립니다. 새로 필요하면 같은 PR에서 추가합니다.
- `test/architecture/state_allowlist_test.dart`가 목록에 없는 `*State` · record typedef ·
  StatefulWidget의 State, `models/` 밖에 둔 State, 지워졌는데 목록에 남은 항목을 막습니다.
- 시트 · 다이얼로그가 여러 값을 돌려줘야 하면 record 대신 콜백 인자로 넘깁니다.

## 디자인 시스템

기준은 [docs/design/DESIGN.md](docs/design/DESIGN.md) 와 `docs/design/screens/` 의 화면별
시안입니다. 코드에서는 `lib/core/themes/` 가 단일 출처입니다.

| 파일 | 역할 |
|---|---|
| `app_palette.dart` | 원시 색 토큰. hex 리터럴은 여기에만 둡니다 |
| `app_colors.dart` | 시맨틱 색(ThemeExtension). 라이트·다크 값을 함께 정의. 화면은 `context.colors` 로 읽음 |
| `app_typography.dart` | 글자 스타일. 폰트는 번들된 Pretendard(`assets/fonts/`) |
| `app_spacing.dart` | 간격 `AppSpacing` · 모서리 `AppRadius` |
| `app_layout.dart` | 본문·시트 최대 폭, 최소 터치 영역 |
| `app_theme.dart` | `ThemeData`(라이트·다크), 앱바 틴트 끄기, 상태바 스타일 |

### 색

| 토큰 | 라이트 값 | 쓰는 곳 |
|---|---|---|
| `primary` / `primaryTint` | `#4F46E5` / `#E2DFFF` | 주 동작, 선택 표시, 배지 |
| `expense` / `expenseTint` | `#EF4444` / `#FFDADB` | 지출 금액(`-`), 지출 아이콘 바탕 |
| `income` / `incomeTint` | `#2563EB` / `#DBE1FF` | 수입 금액(`+`), 수입 아이콘 바탕 |
| `transfer` / `transferTint` | `#464555` / `#E2E7FF` | 이체(⇄). 수입·지출과 섞이지 않는 중립색 |
| `background` / `surface` | `#FAF8FF` / `#FFFFFF` | 화면 바탕 / 카드 |
| `surfaceLow` … `surfaceHighest` | `#F2F3FF` … `#DAE2FD` | 카드 안의 묶음, 배지, 진행 바 트랙 |
| `textPrimary` / `textSecondary` | `#131B2E` / `#464555` | 본문 / 보조 정보 |
| `outline` / `divider` | `#777587` / `#C7C4D8` | 테두리 / 구분선 |

- 하드코딩 색 금지. 투명도는 `withValues(alpha:)`.
- 브랜드·수입·지출 색은 기획에서 정한 값이고, 표면·틴트는 DESIGN.md 의 토큰입니다.
  (시안 PNG 는 같은 역할에 더 짙은 `#3525CD` · `#B90538` · `#003FAC` 로 그려져 있습니다.)
- 시안에 다크 화면이 없어 다크 값은 토큰의 fixed-dim · inverse 값에서 유도했습니다.

### 타이포

직접 `fontSize` 금지. 금액은 고정폭 숫자(tnum)가 켜진 `displayCurrency*` · `amount*` 로 적습니다.

| 토큰 | 크기 / 줄 높이 · 굵기 |
|---|---|
| `displayCurrency` / `displayCurrencyMobile` | 34/42 · 28/36 · Bold |
| `headlineLg` / `headlineMd` / `headlineSm` | 24/32 Bold · 20/28 SemiBold · 17/24 SemiBold |
| `bodyLg` / `bodyMd` / `bodySm` | 16/24 · 14/20 · 13/18 · Regular |
| `amountLg` / `amountMd` | 18/24 · 15/20 · SemiBold |
| `labelMd` / `labelSm` | 12/16 Medium · 11/14 SemiBold |

### 간격·모양

- 간격 `AppSpacing`: `xs`=4 · `sm`=8 · `md`=12 · `lg`=16 · `xl`=24 · `xxl`=32, 화면 좌우 `gutter`=16.
- 모서리 `AppRadius`: `sm`=4 · `md`=8 · `lg`=12 · `xl`=16 · `full`(알약 — 배지·칩).
- 탭 대상은 최소 44×44. 태블릿에서는 본문을 `AppContentWidth`로 묶습니다.
- 문자열은 `'feature.component.text'.tr()` (하드코딩 문자열 금지).

### 공용 위젯 (`lib/shared/widgets/`)

| 위젯 | 쓰는 곳 |
|---|---|
| `AppFillButton` | 높이 52 채움 버튼 (primary · tonal) |
| `AppPressScale` | 카드·알약·아이콘의 누름 반응(살짝 줄어듦) |
| `AppTapRow` | 목록 한 줄의 누름 반응(옅게 어두워짐) |
| `AppErrorView` | 조회 실패 안내 + 다시 시도 |
| `InlineErrorText` | 입력·저장 오류를 작업 영역 안에 표시 |
| `AppContentWidth` | 태블릿에서 본문 폭 제한 |

## 다국어

- easy_localization. 번역 파일 `assets/translations/{ko,en}.json`, 기본·fallback `ko`.
- 키 네이밍 `feature.component.text`. 여러 화면이 쓰는 문구는 `common.*`.
- `test/translations_parity_test.dart` 가 두 파일의 키·자리표시자 정합성을 확인합니다.

## 네이밍

- 파일·폴더: snake_case. 클래스: PascalCase + 접미사(`Controller`/`Screen`/`Repository`).
- Provider 변수: camelCase + `Provider` 접미사.
- **위젯**: 기반이 되는 Material 3 컴포넌트명을 접미사로 (`Button`/`Chip`/`Card`/`Dialog`
  /`Sheet` …). 공용 위젯은 `App` 접두사.

코딩 규약 상세는 [CLAUDE.md](CLAUDE.md) 참고.
