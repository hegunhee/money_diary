import 'package:flutter/material.dart';
import 'package:money_diary/core/themes/app_colors.dart';
import 'package:money_diary/core/themes/app_spacing.dart';
import 'package:money_diary/core/themes/app_typography.dart';
import 'package:money_diary/shared/widgets/app_card.dart';

/// 거래 입력의 한 묶음(일시 · 자산 · 카테고리 …)을 담는 카드
class EntrySectionCard extends StatelessWidget {
  const EntrySectionCard({
    required this.icon,
    required this.label,
    required this.child,
    this.trailing,
    super.key,
  });

  final IconData icon;

  final String label;

  /// 머리줄 오른쪽에 놓는 위젯
  final Widget? trailing;

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return AppCard(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Icon(icon, size: 16, color: colors.textSecondary),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  label,
                  style: AppTypography.labelMd.copyWith(
                    color: colors.textSecondary,
                  ),
                ),
              ),
              ?trailing,
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          child,
        ],
      ),
    );
  }
}
