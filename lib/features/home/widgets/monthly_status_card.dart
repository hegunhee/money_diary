import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:money_diary/core/themes/app_colors.dart';
import 'package:money_diary/core/themes/app_spacing.dart';
import 'package:money_diary/core/themes/app_typography.dart';
import 'package:money_diary/shared/models/ledger_summary.dart';
import 'package:money_diary/shared/util/ledger_calculator.dart';
import 'package:money_diary/shared/util/ledger_labels.dart';
import 'package:money_diary/shared/util/won_format.dart';
import 'package:money_diary/shared/widgets/app_badge.dart';
import 'package:money_diary/shared/widgets/app_card.dart';
import 'package:money_diary/shared/widgets/app_press_scale.dart';

/// 한 달의 수입·지출·모은 돈을 요약하는 카드
class MonthlyStatusCard extends StatelessWidget {
  const MonthlyStatusCard({
    required this.month,
    required this.totals,
    required this.monthlyBudget,
    required this.onIncomeTap,
    required this.onExpenseTap,
    this.dayOfMonth,
    super.key,
  });

  final DateTime month;

  final LedgerTotals totals;

  final int monthlyBudget;

  /// 총 수입을 눌렀을 때. 수입만 걸러 봅니다.
  final VoidCallback onIncomeTap;

  /// 총 지출을 눌렀을 때. 지출만 걸러 봅니다.
  final VoidCallback onExpenseTap;

  /// 이번 달의 며칠째인지. 이번 달을 보고 있지 않으면 null입니다.
  final int? dayOfMonth;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Text(
                'home.month_status'.tr(args: ['${month.month}']),
                style: AppTypography.headlineSm.copyWith(
                  color: colors.textPrimary,
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              if (dayOfMonth != null)
                Text(
                  'home.day_count'.tr(args: ['$dayOfMonth']),
                  style: AppTypography.labelSm.copyWith(
                    color: colors.textSecondary,
                  ),
                ),
              const Spacer(),
              if (totals.income > 0)
                AppBadge(
                  'home.savings_rate'.tr(
                    args: [percentLabel(totals.savingsRate)],
                  ),
                ),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),
          Row(
            children: [
              Expanded(
                child: _FlowTile(
                  label: 'home.total_income'.tr(),
                  amount: '+ ${formatWon(totals.income)}',
                  caption: 'home.transfer_excluded'.tr(),
                  icon: Icons.arrow_downward,
                  color: colors.income,
                  tint: colors.incomeTint,
                  onTap: onIncomeTap,
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: _FlowTile(
                  label: 'home.total_expense'.tr(),
                  amount: '- ${formatWon(totals.expense)}',
                  caption: monthlyBudget > 0
                      ? 'home.budget_usage'.tr(
                          args: [
                            percentLabel(
                              budgetUsage(totals.expense, monthlyBudget),
                            ),
                          ],
                        )
                      : 'home.transfer_excluded'.tr(),
                  icon: Icons.arrow_upward,
                  color: colors.expense,
                  tint: colors.expenseTint,
                  onTap: onExpenseTap,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          DecoratedBox(
            decoration: BoxDecoration(
              color: colors.surfaceContainer,
              borderRadius: BorderRadius.circular(AppRadius.md),
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.md,
                vertical: 10,
              ),
              child: Row(
                children: [
                  Icon(Icons.savings_outlined, size: 18, color: colors.primary),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: Text(
                      'home.month_saved'.tr(),
                      style: AppTypography.bodyMd.copyWith(
                        color: colors.textPrimary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  Text(
                    totals.net < 0
                        ? '- ${wonSymbolLabel(-totals.net)}'
                        : wonSymbolLabel(totals.net),
                    style: AppTypography.amountLg.copyWith(
                      color: totals.net < 0 ? colors.expense : colors.primary,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _FlowTile extends StatelessWidget {
  const _FlowTile({
    required this.label,
    required this.amount,
    required this.caption,
    required this.icon,
    required this.color,
    required this.tint,
    required this.onTap,
  });

  final String label;
  final String amount;
  final String caption;
  final IconData icon;
  final Color color;
  final Color tint;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Semantics(
      button: true,
      child: AppPressScale(
        onTap: onTap,
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
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      label,
                      style: AppTypography.labelMd.copyWith(
                        color: colors.textSecondary,
                      ),
                    ),
                    DecoratedBox(
                      decoration: BoxDecoration(
                        color: tint,
                        shape: BoxShape.circle,
                      ),
                      child: SizedBox.square(
                        dimension: 20,
                        child: Icon(icon, size: 14, color: color),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.xs),
                FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'common.won'.tr(args: [amount]),
                    style: AppTypography.amountLg.copyWith(
                      color: color,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  caption,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTypography.labelSm.copyWith(
                    color: colors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
