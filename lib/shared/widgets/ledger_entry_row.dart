import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:money_diary/core/themes/app_colors.dart';
import 'package:money_diary/core/themes/app_spacing.dart';
import 'package:money_diary/core/themes/app_typography.dart';
import 'package:money_diary/shared/models/ledger_book.dart';
import 'package:money_diary/shared/models/ledger_entry.dart';
import 'package:money_diary/shared/util/ledger_labels.dart';
import 'package:money_diary/shared/widgets/app_badge.dart';

/// 거래 한 건을 보여 주는 줄. 홈과 내역이 함께 씁니다.
///
/// 종류는 아이콘 바탕·금액 색·부호로 구분합니다. 이체는 수입·지출 색을 쓰지 않습니다.
class LedgerEntryRow extends StatelessWidget {
  const LedgerEntryRow({required this.entry, required this.book, super.key});

  final LedgerEntry entry;

  /// 자산·프로젝트 이름을 찾을 가계부
  final LedgerBook book;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final (tint, accent) = switch (entry.type) {
      EntryType.expense => (colors.expenseTint, colors.expense),
      EntryType.income => (colors.incomeTint, colors.income),
      EntryType.transfer => (colors.transferTint, colors.transfer),
    };
    final project = book.projectById(entry.projectId);
    final badge = switch (entry.type) {
      EntryType.transfer => 'ledger.transfer_badge'.tr(),
      _ when project != null => project.name,
      _ when entry.isRecurring => 'ledger.recurring_badge'.tr(),
      _ => null,
    };
    final category = entry.category;
    final subtitle = [
      if (entry.type == EntryType.transfer)
        'ledger.asset_move'.tr()
      else if (category != null)
        entry.detail == null
            ? category.label
            : '${category.label}/${entry.detail}',
      if (entry.type == EntryType.transfer)
        ?entry.memo
      else
        ?book.assetById(entry.assetId)?.name,
    ].join(' · ');

    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.lg,
        vertical: AppSpacing.md,
      ),
      child: Row(
        children: [
          DecoratedBox(
            decoration: BoxDecoration(color: tint, shape: BoxShape.circle),
            child: SizedBox.square(
              dimension: 44,
              child: Icon(
                entry.type == EntryType.transfer
                    ? Icons.swap_horiz
                    : (category ?? LedgerCategory.etc).icon,
                size: 22,
                color: accent,
              ),
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        entry.title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AppTypography.bodyLg.copyWith(
                          color: colors.textPrimary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    if (badge != null) ...[
                      const SizedBox(width: 6),
                      AppBadge(
                        badge,
                        background: entry.type == EntryType.transfer
                            ? colors.transferTint
                            : null,
                        foreground: entry.type == EntryType.transfer
                            ? colors.transfer
                            : null,
                      ),
                    ],
                  ],
                ),
                Text(
                  subtitle,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTypography.bodySm.copyWith(
                    color: colors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                signedWonLabel(entry.type, entry.amount),
                style: AppTypography.amountLg.copyWith(
                  color: entry.type == EntryType.transfer
                      ? colors.textPrimary
                      : accent,
                ),
              ),
              Text(
                timeLabel(entry.occurredAt),
                style: AppTypography.labelMd.copyWith(
                  color: colors.textSecondary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
