/// 거래의 종류
enum EntryType {
  /// 지출
  expense,

  /// 수입
  income,

  /// 이체 — 자산 간 이동이라 수입·지출 통계에 넣지 않습니다.
  transfer,
}

/// 거래 카테고리
enum LedgerCategory {
  /// 식비
  food,

  /// 주거/통신
  housing,

  /// 교통/차량
  transport,

  /// 쇼핑/생활
  shopping,

  /// 여가/문화
  culture,

  /// 의료
  medical,

  /// 기타 지출
  etc,

  /// 급여
  salary,

  /// 급여 외 수입
  otherIncome
  ;

  /// 지출 입력에서 고를 수 있는 카테고리
  static const List<LedgerCategory> expenseValues = [
    food,
    transport,
    shopping,
    housing,
    medical,
    culture,
    etc,
  ];

  /// 수입 입력에서 고를 수 있는 카테고리
  static const List<LedgerCategory> incomeValues = [salary, otherIncome];
}

/// 가계부의 거래 한 건
class LedgerEntry {
  const LedgerEntry({
    required this.id,
    required this.type,
    required this.amount,
    required this.title,
    required this.occurredAt,
    required this.assetId,
    this.toAssetId,
    this.category,
    this.detail,
    this.projectId,
    this.memo,
    this.isRecurring = false,
  });

  factory LedgerEntry.fromJson(Map<String, dynamic> json) => LedgerEntry(
    id: json['id'] as String,
    type: EntryType.values.byName(json['type'] as String),
    amount: json['amount'] as int,
    title: json['title'] as String,
    occurredAt: DateTime.parse(json['occurredAt'] as String),
    assetId: json['assetId'] as String,
    toAssetId: json['toAssetId'] as String?,
    category: json['category'] == null
        ? null
        : LedgerCategory.values.byName(json['category'] as String),
    detail: json['detail'] as String?,
    projectId: json['projectId'] as String?,
    memo: json['memo'] as String?,
    isRecurring: json['isRecurring'] as bool? ?? false,
  );

  final String id;

  final EntryType type;

  /// 원 단위 금액. 부호 없이 항상 양수로 둡니다.
  final int amount;

  /// 거래 이름 (사용처)
  final String title;

  /// 거래 일시
  final DateTime occurredAt;

  /// 결제·입금 자산. 이체에서는 보내는 자산입니다.
  final String assetId;

  /// 이체에서 받는 자산
  final String? toAssetId;

  /// 카테고리. 이체에는 없습니다.
  final LedgerCategory? category;

  /// 카테고리 아래의 세부 분류 (예: 카페, 외식)
  final String? detail;

  /// 묶인 프로젝트. 카테고리와 별개로 붙입니다.
  final String? projectId;

  final String? memo;

  /// 매달 반복되는 거래인지 여부
  final bool isRecurring;

  Map<String, dynamic> toJson() => {
    'id': id,
    'type': type.name,
    'amount': amount,
    'title': title,
    'occurredAt': occurredAt.toIso8601String(),
    'assetId': assetId,
    'toAssetId': toAssetId,
    'category': category?.name,
    'detail': detail,
    'projectId': projectId,
    'memo': memo,
    'isRecurring': isRecurring,
  };
}
