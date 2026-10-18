/// 자산의 종류
enum AssetKind {
  /// 보통예금
  bank,

  /// 투자·청약
  investment,

  /// 현금
  cash,

  /// 신용카드
  creditCard,

  /// 간편결제
  pay
  ;

  /// 순자산에 더하는 자산인지 여부. 카드·간편결제는 결제 수단이라 더하지 않습니다.
  bool get countsTowardNetWorth =>
      this == bank || this == investment || this == cash;
}

/// 계좌·카드·현금 같은 자산 하나
class AssetAccount {
  const AssetAccount({
    required this.id,
    required this.name,
    required this.kind,
    required this.balance,
    this.monthlyBudget = 0,
  });

  factory AssetAccount.fromJson(Map<String, dynamic> json) => AssetAccount(
    id: json['id'] as String,
    name: json['name'] as String,
    kind: AssetKind.values.byName(json['kind'] as String),
    balance: json['balance'] as int,
    monthlyBudget: json['monthlyBudget'] as int? ?? 0,
  );

  final String id;

  final String name;

  final AssetKind kind;

  /// 잔액(원). 신용카드·간편결제는 결제 예정 금액입니다.
  final int balance;

  /// 이 자산으로 한 달에 쓸 지출 예산(원). 정하지 않았으면 0입니다.
  final int monthlyBudget;

  AssetAccount withBalance(int balance) => AssetAccount(
    id: id,
    name: name,
    kind: kind,
    balance: balance,
    monthlyBudget: monthlyBudget,
  );

  AssetAccount withMonthlyBudget(int monthlyBudget) => AssetAccount(
    id: id,
    name: name,
    kind: kind,
    balance: balance,
    monthlyBudget: monthlyBudget,
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'kind': kind.name,
    'balance': balance,
    'monthlyBudget': monthlyBudget,
  };
}
