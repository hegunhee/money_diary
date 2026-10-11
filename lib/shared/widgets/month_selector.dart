import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:money_diary/core/themes/app_colors.dart';
import 'package:money_diary/core/themes/app_spacing.dart';
import 'package:money_diary/core/themes/app_typography.dart';
import 'package:money_diary/shared/controllers/today_controller.dart';
import 'package:money_diary/shared/util/ledger_labels.dart';

/// 홈·내역·분석이 함께 보는 달을 앞뒤로 옮기는 선택기
class MonthSelector extends ConsumerWidget {
  const MonthSelector({this.style, super.key});

  /// 달 글자 스타일. null이면 `headlineSm`
  final TextStyle? style;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = context.colors;
    final month = ref.watch(selectedMonthProvider);
    final controller = ref.read(selectedMonthProvider.notifier);
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        IconButton(
          tooltip: 'common.previous_month'.tr(),
          onPressed: () => controller.shift(-1),
          icon: Icon(Icons.chevron_left, color: colors.textSecondary),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xs),
          child: Text(
            yearMonthLabel(month),
            style: (style ?? AppTypography.headlineSm).copyWith(
              color: colors.textPrimary,
            ),
          ),
        ),
        IconButton(
          tooltip: 'common.next_month'.tr(),
          onPressed: () => controller.shift(1),
          icon: Icon(Icons.chevron_right, color: colors.textSecondary),
        ),
      ],
    );
  }
}
