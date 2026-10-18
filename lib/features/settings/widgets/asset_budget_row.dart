import 'package:flutter/material.dart';
import 'package:money_diary/core/themes/app_colors.dart';
import 'package:money_diary/core/themes/app_spacing.dart';
import 'package:money_diary/core/themes/app_typography.dart';
import 'package:money_diary/shared/models/asset_account.dart';
import 'package:money_diary/shared/util/ledger_calculator.dart';
import 'package:money_diary/shared/util/ledger_labels.dart';
import 'package:money_diary/shared/widgets/app_progress_bar.dart';

/// 자산 하나의 이번 달 지출을 그 자산의 예산과 견줘 보여 주는 줄
class AssetBudgetRow extends StatelessWidget {
  const AssetBudgetRow({required this.asset, required this.spent, super.key});

  final AssetAccount asset;

  /// 이번 달 이 자산으로 쓴 지출(원)
  final int spent;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final over = spent > asset.monthlyBudget;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Icon(asset.kind.icon, size: 18, color: colors.textSecondary),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: Text(
                asset.name,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: AppTypography.bodyMd.copyWith(
                  color: colors.textPrimary,
                ),
              ),
            ),
            Text(
              '${wonSymbolLabel(spent)} / ${wonSymbolLabel(asset.monthlyBudget)}',
              style: AppTypography.labelMd.copyWith(
                color: over ? colors.expense : colors.textSecondary,
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.xs),
        AppProgressBar(
          value: budgetUsage(spent, asset.monthlyBudget),
          color: colors.expense,
          height: 4,
        ),
      ],
    );
  }
}
