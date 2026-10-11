import 'package:flutter/material.dart';
import 'package:money_diary/core/themes/app_colors.dart';
import 'package:money_diary/core/themes/app_spacing.dart';
import 'package:money_diary/core/themes/app_typography.dart';
import 'package:money_diary/shared/models/ledger_summary.dart';
import 'package:money_diary/shared/util/ledger_labels.dart';

/// 하루의 수입·지출 합계. 이체는 세지 않으며, 둘 다 있으면 나란히 적습니다.
class DailyNetText extends StatelessWidget {
  const DailyNetText(this.totals, {this.style, super.key});

  final LedgerTotals totals;

  /// 글자 스타일. null이면 `amountMd`
  final TextStyle? style;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final base = style ?? AppTypography.amountMd;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (totals.income > 0)
          Text(
            '+ ${wonLabel(totals.income)}',
            style: base.copyWith(color: colors.income),
          ),
        if (totals.income > 0 && totals.expense > 0)
          const SizedBox(width: AppSpacing.sm),
        if (totals.expense > 0)
          Text(
            '- ${wonLabel(totals.expense)}',
            style: base.copyWith(color: colors.expense),
          ),
      ],
    );
  }
}
