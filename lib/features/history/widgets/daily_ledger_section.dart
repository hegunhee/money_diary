import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:money_diary/core/themes/app_colors.dart';
import 'package:money_diary/core/themes/app_spacing.dart';
import 'package:money_diary/core/themes/app_typography.dart';
import 'package:money_diary/shared/models/ledger_book.dart';
import 'package:money_diary/shared/models/ledger_entry.dart';
import 'package:money_diary/shared/models/ledger_summary.dart';
import 'package:money_diary/shared/util/ledger_labels.dart';
import 'package:money_diary/shared/widgets/app_badge.dart';
import 'package:money_diary/shared/widgets/app_card.dart';
import 'package:money_diary/shared/widgets/daily_net_text.dart';
import 'package:money_diary/shared/widgets/ledger_entry_row.dart';

/// 하루치 거래를 날짜 머리줄과 카드로 보여 주는 구역
class DailyLedgerSection extends StatelessWidget {
  const DailyLedgerSection({
    required this.day,
    required this.book,
    required this.onEntryTap,
    required this.onEntryLongPress,
    super.key,
  });

  final DailyLedger day;

  final LedgerBook book;

  /// 거래 줄을 눌렀을 때의 동작
  final ValueChanged<LedgerEntry> onEntryTap;

  /// 거래 줄을 꾹 눌렀을 때의 동작
  final ValueChanged<LedgerEntry> onEntryLongPress;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: AppSpacing.sm),
          child: Row(
            children: [
              Text(
                monthDayLabel(day.date),
                style: AppTypography.headlineSm.copyWith(
                  color: colors.textPrimary,
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              AppBadge(
                weekdayLabel(day.date),
                background: colors.surfaceHigh,
                foreground: colors.textSecondary,
              ),
              const Spacer(),
              DailyNetText(day.totals),
              if (day.totals.transferCount > 0) ...[
                const SizedBox(width: AppSpacing.xs),
                Text(
                  'history.transfer_count'.tr(
                    args: ['${day.totals.transferCount}'],
                  ),
                  style: AppTypography.labelSm.copyWith(
                    color: colors.textSecondary,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ],
            ],
          ),
        ),
        AppCard(
          padding: EdgeInsets.zero,
          child: Column(
            children: [
              for (final (index, entry) in day.entries.indexed) ...[
                if (index > 0)
                  Divider(
                    height: 1,
                    color: colors.divider.withValues(alpha: 0.3),
                  ),
                // 이체는 지출로 읽히지 않게 줄 바탕을 달리합니다.
                ColoredBox(
                  color: entry.type == EntryType.transfer
                      ? colors.surfaceLow
                      : colors.surface,
                  child: LedgerEntryRow(
                    entry: entry,
                    book: book,
                    onTap: () => onEntryTap(entry),
                    onLongPress: () => onEntryLongPress(entry),
                  ),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }
}
