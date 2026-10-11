import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:money_diary/shared/models/asset_account.dart';
import 'package:money_diary/shared/models/ledger_category.dart';
import 'package:money_diary/shared/models/ledger_entry.dart';
import 'package:money_diary/shared/util/won_format.dart';

/// 금액에 통화 단위를 붙입니다. (예: 6,500원)
String wonLabel(int amount) => 'common.won'.tr(args: [formatWon(amount)]);

/// 거래 종류에 맞는 부호를 붙인 금액입니다. 이체는 부호를 붙이지 않습니다.
String signedWonLabel(EntryType type, int amount) => switch (type) {
  EntryType.expense => '-${wonLabel(amount)}',
  EntryType.income => '+${wonLabel(amount)}',
  EntryType.transfer => wonLabel(amount),
};

/// 통화 기호를 앞에 붙인 금액입니다. (예: ₩ 2,065,500)
String wonSymbolLabel(int amount) => '₩ ${formatWon(amount)}';

/// 비율을 소수 첫째 자리 백분율로 적습니다. (예: 48.6%)
String percentLabel(double ratio) => '${(ratio * 100).toStringAsFixed(1)}%';

/// 2026년 3월
String yearMonthLabel(DateTime date) => 'common.year_month'.tr(
  namedArgs: {'year': '${date.year}', 'month': '${date.month}'},
);

/// 3월 18일
String monthDayLabel(DateTime date) => 'common.month_day'.tr(
  namedArgs: {'month': '${date.month}', 'day': '${date.day}'},
);

/// 요일 한 글자 (월 … 일)
String weekdayShortLabel(DateTime date) =>
    'common.weekday_short.${date.weekday}'.tr();

/// 요일 (월요일 … 일요일)
String weekdayLabel(DateTime date) => 'common.weekday.${date.weekday}'.tr();

/// 14:28
String timeLabel(DateTime at) =>
    '${at.hour.toString().padLeft(2, '0')}:${at.minute.toString().padLeft(2, '0')}';

/// 2026.04.10
String dottedDateLabel(DateTime date) =>
    '${date.year}.${date.month.toString().padLeft(2, '0')}.${date.day.toString().padLeft(2, '0')}';

/// 카테고리의 이름과 아이콘
extension LedgerCategoryLabel on LedgerCategory {
  String get label => customName ?? 'category.$id'.tr();

  IconData get icon => switch (id) {
    'food' => Icons.restaurant_outlined,
    'housing' => Icons.home_outlined,
    'transport' => Icons.directions_bus_outlined,
    'shopping' => Icons.shopping_bag_outlined,
    'culture' => Icons.movie_outlined,
    'medical' => Icons.medication_outlined,
    'etc' => Icons.more_horiz,
    'salary' => Icons.payments_outlined,
    'otherIncome' => Icons.savings_outlined,
    _ => Icons.label_outline,
  };
}

/// 자산 종류의 이름과 아이콘
extension AssetKindLabel on AssetKind {
  String get label => 'asset.kind.$name'.tr();

  IconData get icon => switch (this) {
    AssetKind.bank => Icons.account_balance_outlined,
    AssetKind.investment => Icons.trending_up,
    AssetKind.cash => Icons.payments_outlined,
    AssetKind.creditCard => Icons.credit_card,
    AssetKind.pay => Icons.account_balance_wallet_outlined,
  };
}
