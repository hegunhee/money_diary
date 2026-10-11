import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:money_diary/core/themes/app_colors.dart';
import 'package:money_diary/core/themes/app_spacing.dart';
import 'package:money_diary/core/themes/app_typography.dart';
import 'package:money_diary/shared/models/ledger_entry.dart';
import 'package:money_diary/shared/widgets/app_card.dart';
import 'package:money_diary/shared/widgets/app_press_scale.dart';

/// 지출·수입·이체 입력으로 바로 가는 버튼 줄
class QuickActionRow extends StatelessWidget {
  const QuickActionRow({required this.onAdd, super.key});

  /// 고른 종류로 거래 입력을 엽니다. null이면 누를 수 없습니다.
  final ValueChanged<EntryType>? onAdd;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final actions = [
      (EntryType.expense, Icons.remove, colors.expenseTint, colors.expense),
      (EntryType.income, Icons.add, colors.incomeTint, colors.income),
      (
        EntryType.transfer,
        Icons.sync_alt,
        colors.transferTint,
        colors.transfer,
      ),
    ];
    final onAdd = this.onAdd;
    return Row(
      children: [
        for (final (index, (type, icon, tint, color)) in actions.indexed) ...[
          if (index > 0) const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: AppPressScale(
              onTap: onAdd == null ? null : () => onAdd(type),
              child: AppCard(
                padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
                child: Column(
                  children: [
                    DecoratedBox(
                      decoration: BoxDecoration(
                        color: tint,
                        shape: BoxShape.circle,
                      ),
                      child: SizedBox.square(
                        dimension: 40,
                        child: Icon(icon, size: 20, color: color),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'home.quick_action.${type.name}'.tr(),
                      style: AppTypography.labelMd.copyWith(
                        color: colors.textPrimary,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ],
    );
  }
}
