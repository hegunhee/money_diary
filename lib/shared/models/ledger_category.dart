import 'package:money_diary/shared/models/ledger_entry.dart';

/// 거래 카테고리
///
/// 기본 카테고리는 아래 상수이고 이름을 번역 파일에서 읽습니다. 사용자가 더한 카테고리는
/// [customName]에 이름을 들고 있습니다. 같은 [id]면 같은 카테고리입니다.
class LedgerCategory {
  const LedgerCategory({
    required this.id,
    required this.type,
    this.customName,
  });

  factory LedgerCategory.fromJson(Map<String, dynamic> json) => LedgerCategory(
    id: json['id'] as String,
    type: EntryType.values.byName(json['type'] as String),
    customName: json['name'] as String?,
  );

  /// 거래에 저장된 id와 이름으로 카테고리를 되살립니다.
  ///
  /// 기본 카테고리는 id로 찾고, 그 밖에는 사용자가 더한 카테고리로 봅니다. 그 카테고리가
  /// 나중에 지워졌어도 거래에는 이름이 남아 그대로 보입니다.
  factory LedgerCategory.restore({
    required String id,
    required EntryType type,
    String? name,
  }) {
    for (final category in builtIns) {
      if (category.id == id) {
        return category;
      }
    }
    return LedgerCategory(id: id, type: type, customName: name ?? id);
  }

  final String id;

  /// 지출 카테고리인지 수입 카테고리인지
  final EntryType type;

  /// 사용자가 더한 카테고리의 이름. 기본 카테고리는 null입니다.
  final String? customName;

  bool get isCustom => customName != null;

  /// 식비
  static const food = LedgerCategory(id: 'food', type: EntryType.expense);

  /// 주거/통신
  static const housing = LedgerCategory(id: 'housing', type: EntryType.expense);

  /// 교통/차량
  static const transport = LedgerCategory(
    id: 'transport',
    type: EntryType.expense,
  );

  /// 쇼핑/생활
  static const shopping = LedgerCategory(
    id: 'shopping',
    type: EntryType.expense,
  );

  /// 여가/문화
  static const culture = LedgerCategory(id: 'culture', type: EntryType.expense);

  /// 의료
  static const medical = LedgerCategory(id: 'medical', type: EntryType.expense);

  /// 기타 지출
  static const etc = LedgerCategory(id: 'etc', type: EntryType.expense);

  /// 급여
  static const salary = LedgerCategory(id: 'salary', type: EntryType.income);

  /// 급여 외 수입
  static const otherIncome = LedgerCategory(
    id: 'otherIncome',
    type: EntryType.income,
  );

  /// 기본 카테고리. 입력 화면에 보이는 순서입니다.
  static const List<LedgerCategory> builtIns = [
    food,
    transport,
    shopping,
    housing,
    medical,
    culture,
    etc,
    salary,
    otherIncome,
  ];

  Map<String, dynamic> toJson() => {
    'id': id,
    'type': type.name,
    'name': customName,
  };

  @override
  bool operator ==(Object other) => other is LedgerCategory && other.id == id;

  @override
  int get hashCode => id.hashCode;
}
