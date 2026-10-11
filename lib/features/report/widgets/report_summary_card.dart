import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:money_diary/core/themes/app_colors.dart';
import 'package:money_diary/core/themes/app_spacing.dart';
import 'package:money_diary/core/themes/app_typography.dart';
import 'package:money_diary/shared/models/ledger_summary.dart';
import 'package:money_diary/shared/util/ledger_calculator.dart';
import 'package:money_diary/shared/util/ledger_labels.dart';
import 'package:money_diary/shared/widgets/app_card.dart';
import 'package:money_diary/shared/widgets/app_progress_bar.dart';

/// 한 달의 순 저축액·저축률과 수입·지출, 이체 제외 안내를 보여 주는 카드
class ReportSummaryCard extends StatelessWidget {
  const ReportSummaryCard({
    required this.totals,
    required this.incomeCount,
    required this.monthlyBudget,
    super.key,
  });

  final LedgerTotals totals;

  /// 수입 거래 건수
  final int incomeCount;

  final int monthlyBudget;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final saved = totals.net >= 0;
    Widget tile(String label, int amount, String caption, Color color) =>
        Expanded(
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: colors.surfaceLow,
              borderRadius: BorderRadius.circular(AppRadius.md),
            ),
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.md),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: AppTypography.labelMd.copyWith(color: color),
                  ),
                  FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text(
                      wonSymbolLabel(amount),
                      style: AppTypography.amountLg.copyWith(
                        color: color == colors.income
                            ? colors.textPrimary
                            : color,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  Text(
                    caption,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTypography.labelSm.copyWith(
                      color: colors.textSecondary,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );

    return AppCard(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'report.net_saving'.tr(),
                      style: AppTypography.labelMd.copyWith(
                        color: colors.textSecondary,
                      ),
                    ),
                    Wrap(
                      crossAxisAlignment: WrapCrossAlignment.end,
                      spacing: AppSpacing.sm,
                      children: [
                        Text(
                          saved
                              ? wonSymbolLabel(totals.net)
                              : '- ${wonSymbolLabel(-totals.net)}',
                          style: AppTypography.displayCurrencyMobile.copyWith(
                            color: saved ? colors.primary : colors.expense,
                          ),
                        ),
                        if (totals.income > 0)
                          Padding(
                            padding: const EdgeInsets.only(bottom: 6),
                            child: Text(
                              'report.savings_rate'.tr(
                                args: [percentLabel(totals.savingsRate)],
                              ),
                              style: AppTypography.labelSm.copyWith(
                                color: saved ? colors.primary : colors.expense,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ],
                ),
              ),
              DecoratedBox(
                decoration: BoxDecoration(
                  color: colors.primaryTint,
                  shape: BoxShape.circle,
                ),
                child: SizedBox.square(
                  dimension: 44,
                  child: Icon(
                    Icons.savings_outlined,
                    size: 22,
                    color: colors.primary,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          AppProgressBar(value: totals.savingsRate, height: 6),
          const SizedBox(height: AppSpacing.md),
          Row(
            children: [
              tile(
                'report.total_income'.tr(),
                totals.income,
                'report.income_count'.tr(args: ['$incomeCount']),
                colors.income,
              ),
              const SizedBox(width: AppSpacing.sm),
              tile(
                'report.total_expense'.tr(),
                totals.expense,
                monthlyBudget > 0
                    ? 'report.budget_usage'.tr(
                        args: [
                          percentLabel(
                            budgetUsage(totals.expense, monthlyBudget),
                          ),
                        ],
                      )
                    : 'report.transfer_excluded'.tr(),
                colors.expense,
              ),
            ],
          ),
          if (totals.transferCount > 0) ...[
            const SizedBox(height: AppSpacing.md),
            DecoratedBox(
              decoration: BoxDecoration(
                color: colors.surfaceContainer,
                borderRadius: BorderRadius.circular(AppRadius.md),
              ),
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.md),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(Icons.info_outline, size: 16, color: colors.primary),
                    const SizedBox(width: AppSpacing.sm),
                    Expanded(
                      child: Text(
                        'report.transfer_notice'.tr(
                          args: [wonSymbolLabel(totals.transfer)],
                        ),
                        style: AppTypography.labelMd.copyWith(
                          color: colors.textSecondary,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
