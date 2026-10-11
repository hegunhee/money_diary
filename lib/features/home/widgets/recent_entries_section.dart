import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:money_diary/core/themes/app_colors.dart';
import 'package:money_diary/core/themes/app_spacing.dart';
import 'package:money_diary/core/themes/app_typography.dart';
import 'package:money_diary/shared/models/ledger_book.dart';
import 'package:money_diary/shared/models/ledger_summary.dart';
import 'package:money_diary/shared/util/ledger_labels.dart';
import 'package:money_diary/shared/widgets/app_badge.dart';
import 'package:money_diary/shared/widgets/app_card.dart';
import 'package:money_diary/shared/widgets/daily_net_text.dart';
import 'package:money_diary/shared/widgets/ledger_entry_row.dart';

/// 최근 며칠의 거래를 날짜별 카드로 보여 주는 구역
class RecentEntriesSection extends StatelessWidget {
  const RecentEntriesSection({
    required this.days,
    required this.book,
    required this.today,
    required this.onSeeAll,
    super.key,
  });

  /// 보여 줄 날짜 묶음. 최근 날짜가 먼저 옵니다.
  final List<DailyLedger> days;

  final LedgerBook book;

  final DateTime today;

  final VoidCallback onSeeAll;

  String _dayLabel(DateTime date) {
    final gap = DateTime(
      today.year,
      today.month,
      today.day,
    ).difference(date).inDays;
    final label = '${monthDayLabel(date)} ${weekdayShortLabel(date)}';
    return switch (gap) {
      0 => '${'common.today'.tr()} · $label',
      1 => '${'common.yesterday'.tr()} · $label',
      _ => label,
    };
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final count = days.fold(0, (sum, day) => sum + day.entries.length);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Text(
              'home.recent_title'.tr(),
              style: AppTypography.headlineSm.copyWith(
                color: colors.textPrimary,
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            AppBadge(
              '$count',
              background: colors.surfaceHigh,
              foreground: colors.textSecondary,
            ),
            const Spacer(),
            TextButton(
              onPressed: onSeeAll,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'home.see_all'.tr(),
                    style: AppTypography.labelMd.copyWith(
                      color: colors.textSecondary,
                    ),
                  ),
                  Icon(
                    Icons.chevron_right,
                    size: 18,
                    color: colors.textSecondary,
                  ),
                ],
              ),
            ),
          ],
        ),
        if (days.isEmpty)
          AppCard(
            child: Column(
              children: [
                Text(
                  'home.empty_title'.tr(),
                  style: AppTypography.headlineSm.copyWith(
                    color: colors.textPrimary,
                  ),
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  'home.empty_description'.tr(),
                  textAlign: TextAlign.center,
                  style: AppTypography.bodyMd.copyWith(
                    color: colors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        for (final (index, day) in days.indexed) ...[
          if (index > 0) const SizedBox(height: AppSpacing.md),
          AppCard(
            padding: const EdgeInsets.only(bottom: AppSpacing.xs),
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(AppSpacing.sm),
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      color: colors.surfaceLow,
                      borderRadius: BorderRadius.circular(AppRadius.md),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.md,
                        vertical: AppSpacing.sm,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            _dayLabel(day.date),
                            style: AppTypography.labelMd.copyWith(
                              color: colors.textPrimary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          DailyNetText(day.totals),
                        ],
                      ),
                    ),
                  ),
                ),
                for (final (row, entry) in day.entries.indexed) ...[
                  if (row > 0)
                    Divider(
                      height: 1,
                      indent: AppSpacing.lg,
                      endIndent: AppSpacing.lg,
                      color: colors.divider.withValues(alpha: 0.3),
                    ),
                  LedgerEntryRow(entry: entry, book: book),
                ],
              ],
            ),
          ),
        ],
      ],
    );
  }
}
