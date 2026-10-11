import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:money_diary/core/themes/app_colors.dart';
import 'package:money_diary/core/themes/app_spacing.dart';
import 'package:money_diary/core/themes/app_typography.dart';
import 'package:money_diary/shared/models/ledger_summary.dart';
import 'package:money_diary/shared/util/ledger_calculator.dart';
import 'package:money_diary/shared/util/ledger_labels.dart';
import 'package:money_diary/shared/util/won_format.dart';
import 'package:money_diary/shared/widgets/app_card.dart';
import 'package:money_diary/shared/widgets/app_progress_bar.dart';

/// 한 달의 수입·지출·잔액과 예산 사용률을 한 줄로 보여 주는 카드
class HistorySummaryCard extends StatelessWidget {
  const HistorySummaryCard({
    required this.totals,
    required this.monthlyBudget,
    super.key,
  });

  final LedgerTotals totals;

  final int monthlyBudget;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final columns = [
      ('history.income'.tr(), totals.income, colors.income, colors.income),
      ('history.expense'.tr(), totals.expense, colors.expense, colors.expense),
      ('history.balance'.tr(), totals.net, null, colors.textPrimary),
    ];
    return AppCard(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        children: [
          IntrinsicHeight(
            child: Row(
              children: [
                for (final (index, (label, amount, dot, color))
                    in columns.indexed) ...[
                  if (index > 0)
                    VerticalDivider(
                      width: AppSpacing.md,
                      color: colors.divider.withValues(alpha: 0.4),
                    ),
                  Expanded(
                    child: Column(
                      children: [
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            if (dot != null) ...[
                              DecoratedBox(
                                decoration: BoxDecoration(
                                  color: dot,
                                  shape: BoxShape.circle,
                                ),
                                child: const SizedBox.square(dimension: 6),
                              ),
                              const SizedBox(width: AppSpacing.xs),
                            ],
                            Text(
                              label,
                              style: AppTypography.labelMd.copyWith(
                                color: colors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: AppSpacing.xs),
                        FittedBox(
                          fit: BoxFit.scaleDown,
                          child: Text(
                            '${amount < 0 ? '-' : ''}₩${formatWon(amount.abs())}',
                            style: AppTypography.amountLg.copyWith(
                              color: amount < 0 ? colors.expense : color,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
          if (monthlyBudget > 0) ...[
            const SizedBox(height: AppSpacing.md),
            AppProgressBar(
              value: budgetUsage(totals.expense, monthlyBudget),
              color: colors.expense,
              height: 6,
            ),
            const SizedBox(height: AppSpacing.sm),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'history.budget_usage'.tr(
                    args: [
                      percentLabel(budgetUsage(totals.expense, monthlyBudget)),
                    ],
                  ),
                  style: AppTypography.labelMd.copyWith(
                    color: colors.textPrimary,
                  ),
                ),
                Text(
                  monthlyBudget >= totals.expense
                      ? 'history.budget_left'.tr(
                          args: [
                            wonSymbolLabel(monthlyBudget - totals.expense),
                          ],
                        )
                      : 'history.budget_over'.tr(
                          args: [
                            wonSymbolLabel(totals.expense - monthlyBudget),
                          ],
                        ),
                  style: AppTypography.labelMd.copyWith(
                    color: monthlyBudget >= totals.expense
                        ? colors.textSecondary
                        : colors.expense,
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}
