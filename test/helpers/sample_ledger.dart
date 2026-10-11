import 'package:money_diary/shared/models/asset_account.dart';
import 'package:money_diary/shared/models/ledger_book.dart';
import 'package:money_diary/shared/models/ledger_category.dart';
import 'package:money_diary/shared/models/ledger_entry.dart';
import 'package:money_diary/shared/models/project.dart';

/// 시안(`docs/design/screens`)에 그려진 예시 가계부를 만듭니다.
///
/// [today]가 속한 달에 거래를 놓습니다. 시안은 2026-03-18 을 오늘로 그렸습니다.
/// 테스트에서만 씁니다. 앱은 빈 가계부로 시작합니다.
LedgerBook buildSampleLedger(DateTime today) {
  const hyundai = 'hyundai-card';
  const naverPay = 'naver-pay';
  const kakao = 'kakao-bank';
  const shinhan = 'shinhan-bank';
  const toss = 'toss-bank';
  const cash = 'cash';
  const japan = 'japan-trip';

  var sequence = 0;
  LedgerEntry entry(
    int daysAgo,
    int hour,
    int minute,
    String title,
    int amount,
    String assetId, {
    EntryType type = EntryType.expense,
    LedgerCategory? category,
    String? detail,
    String? toAssetId,
    String? projectId,
    String? memo,
    bool isRecurring = false,
  }) => LedgerEntry(
    id: 'sample-${sequence++}',
    type: type,
    amount: amount,
    title: title,
    occurredAt: DateTime(
      today.year,
      today.month,
      today.day - daysAgo,
      hour,
      minute,
    ),
    assetId: assetId,
    toAssetId: toAssetId,
    category: category,
    detail: detail,
    projectId: projectId,
    memo: memo,
    isRecurring: isRecurring,
  );

  const food = LedgerCategory.food;
  const housing = LedgerCategory.housing;
  const transport = LedgerCategory.transport;
  const shopping = LedgerCategory.shopping;
  const culture = LedgerCategory.culture;

  return LedgerBook(
    monthlyBudget: 4000000,
    assets: const [
      AssetAccount(
        id: shinhan,
        name: '신한 주거래통장',
        kind: AssetKind.bank,
        balance: 8200000,
      ),
      AssetAccount(
        id: toss,
        name: '토스뱅크',
        kind: AssetKind.bank,
        balance: 2600000,
      ),
      AssetAccount(
        id: kakao,
        name: '카카오뱅크',
        kind: AssetKind.bank,
        balance: 1500000,
      ),
      AssetAccount(
        id: 'stock',
        name: '증권 계좌',
        kind: AssetKind.investment,
        balance: 3650000,
      ),
      AssetAccount(
        id: 'housing-savings',
        name: '주택청약',
        kind: AssetKind.investment,
        balance: 1200000,
      ),
      AssetAccount(
        id: cash,
        name: '현금',
        kind: AssetKind.cash,
        balance: 1300200,
      ),
      AssetAccount(
        id: hyundai,
        name: '현대카드 ZERO',
        kind: AssetKind.creditCard,
        balance: 1240000,
      ),
      AssetAccount(
        id: naverPay,
        name: '네이버페이',
        kind: AssetKind.pay,
        balance: 697300,
      ),
    ],
    projects: [
      Project(
        id: japan,
        name: '2026 일본 여행',
        startDate: DateTime(today.year, today.month, today.day + 23),
        endDate: DateTime(today.year, today.month, today.day + 28),
        budget: 1500000,
      ),
    ],
    entries: [
      entry(
        0,
        14,
        28,
        '스타벅스 리저브',
        6500,
        hyundai,
        category: food,
        detail: '카페',
        projectId: japan,
      ),
      entry(0, 12, 15, '삼진어묵', 18200, kakao, category: food, detail: '외식'),
      entry(
        0,
        9,
        10,
        '토스뱅크 → 카카오뱅크',
        200000,
        toss,
        type: EntryType.transfer,
        toAssetId: kakao,
        memo: '생활비 통장 충전',
      ),
      entry(
        1,
        10,
        0,
        '주식회사 넥스트',
        3850000,
        shinhan,
        type: EntryType.income,
        category: LedgerCategory.salary,
        isRecurring: true,
      ),
      entry(
        1,
        13,
        45,
        'GS25 편의점',
        15000,
        cash,
        category: shopping,
        detail: '잡화',
      ),
      entry(
        1,
        11,
        20,
        '올리브영',
        30000,
        hyundai,
        category: shopping,
        detail: '미용',
      ),
      entry(
        2,
        8,
        15,
        'KTX 서울-부산 왕복',
        129000,
        hyundai,
        category: transport,
        detail: '기차',
        projectId: japan,
      ),
      entry(3, 19, 30, '경조사비', 100000, cash, category: LedgerCategory.etc),
      entry(
        4,
        20,
        5,
        '이마트 장보기',
        185300,
        naverPay,
        category: food,
        detail: '장보기',
      ),
      entry(
        5,
        21,
        10,
        '일본 여행 숙소 예약금',
        150000,
        hyundai,
        category: culture,
        detail: '여행',
        projectId: japan,
      ),
      entry(6, 19, 40, '배달의민족', 42000, naverPay, category: food, detail: '배달'),
      entry(
        7,
        16,
        20,
        '무신사',
        139500,
        hyundai,
        category: shopping,
        detail: '의류',
      ),
      entry(8, 20, 30, '팀 회식', 68000, hyundai, category: food, detail: '외식'),
      entry(
        8,
        9,
        0,
        '신한 주거래통장 → 토스뱅크',
        500000,
        shinhan,
        type: EntryType.transfer,
        toAssetId: toss,
        memo: '비상금 모으기',
      ),
      entry(
        9,
        18,
        15,
        'GS칼텍스 주유',
        121000,
        hyundai,
        category: transport,
        detail: '주유',
      ),
      entry(10, 15, 0, '교보문고', 53000, hyundai, category: culture, detail: '도서'),
      entry(
        10,
        11,
        30,
        '중고거래 판매',
        400000,
        toss,
        type: EntryType.income,
        category: LedgerCategory.otherIncome,
      ),
      entry(
        11,
        22,
        0,
        '쿠팡 로켓프레시',
        120000,
        naverPay,
        category: food,
        detail: '장보기',
      ),
      entry(
        12,
        10,
        10,
        '쿠팡 생활용품',
        100000,
        naverPay,
        category: shopping,
        detail: '생필품',
      ),
      entry(13, 12, 0, '주간 장보기', 150000, kakao, category: food, detail: '장보기'),
      entry(
        13,
        9,
        30,
        'KT 통신비',
        100000,
        hyundai,
        category: housing,
        detail: '통신',
        isRecurring: true,
      ),
      entry(
        14,
        8,
        0,
        '넷플릭스',
        17000,
        hyundai,
        category: culture,
        detail: 'OTT',
        isRecurring: true,
      ),
      entry(15, 19, 0, '가족 외식', 230000, hyundai, category: food, detail: '외식'),
      entry(
        16,
        7,
        50,
        '교통카드 충전',
        60000,
        kakao,
        category: transport,
        detail: '대중교통',
      ),
      entry(
        17,
        9,
        0,
        '월세·관리비',
        350000,
        shinhan,
        category: housing,
        detail: '월세',
        isRecurring: true,
      ),
      entry(
        21,
        20,
        0,
        '일본 항공권 발권',
        394500,
        hyundai,
        category: culture,
        detail: '여행',
        projectId: japan,
      ),
    ],
  );
}
