import 'package:money_diary/shared/models/ledger_category.dart';

/// 거래의 종류
enum EntryType {
  /// 지출
  expense,

  /// 수입
  income,

  /// 이체 — 자산 간 이동이라 수입·지출 통계에 넣지 않습니다.
  transfer,
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
    this.recurringDay,
    this.recurrenceHandled = false,
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
        : LedgerCategory.restore(
            id: json['category'] as String,
            type: EntryType.values.byName(json['type'] as String),
            name: json['categoryName'] as String?,
          ),
    detail: json['detail'] as String?,
    projectId: json['projectId'] as String?,
    memo: json['memo'] as String?,
    isRecurring: json['isRecurring'] as bool? ?? false,
    recurringDay: json['recurringDay'] as int?,
    recurrenceHandled: json['recurrenceHandled'] as bool? ?? false,
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

  /// 반복을 처음 건 날의 일(日). 31일에 건 반복이 2월을 지나도 다시 31일로 돌아오게 합니다.
  final int? recurringDay;

  /// 이 거래의 다음 달 거래를 이미 만들었는지 여부. 같은 달을 두 번 만들지 않게 합니다.
  final bool recurrenceHandled;

  /// 프로젝트 태그를 뗀 거래
  LedgerEntry withoutProject() => _copy(keepProject: false);

  /// 다음 달 거래를 만들었다고 표시한 거래
  LedgerEntry asRecurrenceHandled() => _copy(recurrenceHandled: true);

  /// 반복으로 만들어지는 다음 거래. 내용은 같고 id와 일시만 다릅니다.
  LedgerEntry asNextOccurrence({
    required String id,
    required DateTime occurredAt,
  }) => _copy(id: id, occurredAt: occurredAt, recurrenceHandled: false);

  LedgerEntry _copy({
    String? id,
    DateTime? occurredAt,
    bool? recurrenceHandled,
    bool keepProject = true,
  }) => LedgerEntry(
    id: id ?? this.id,
    type: type,
    amount: amount,
    title: title,
    occurredAt: occurredAt ?? this.occurredAt,
    assetId: assetId,
    toAssetId: toAssetId,
    category: category,
    detail: detail,
    projectId: keepProject ? projectId : null,
    memo: memo,
    isRecurring: isRecurring,
    recurringDay: recurringDay,
    recurrenceHandled: recurrenceHandled ?? this.recurrenceHandled,
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'type': type.name,
    'amount': amount,
    'title': title,
    'occurredAt': occurredAt.toIso8601String(),
    'assetId': assetId,
    'toAssetId': toAssetId,
    'category': category?.id,
    'categoryName': category?.customName,
    'detail': detail,
    'projectId': projectId,
    'memo': memo,
    'isRecurring': isRecurring,
    'recurringDay': recurringDay,
    'recurrenceHandled': recurrenceHandled,
  };
}
