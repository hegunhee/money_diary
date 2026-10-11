import 'package:flutter/material.dart';
import 'package:money_diary/core/themes/app_colors.dart';
import 'package:money_diary/core/themes/app_spacing.dart';
import 'package:money_diary/core/themes/app_typography.dart';
import 'package:money_diary/shared/util/ledger_labels.dart';
import 'package:money_diary/shared/widgets/app_progress_bar.dart';

/// 몫 하나(카테고리·자산·프로젝트)의 이름·비율·금액과 비중 바를 보여 주는 줄
class ShareRow extends StatelessWidget {
  const ShareRow({
    required this.icon,
    required this.name,
    required this.caption,
    required this.amount,
    required this.ratio,
    required this.color,
    super.key,
  });

  final IconData icon;

  final String name;

  /// 이름 아래의 보조 설명
  final String caption;

  final int amount;

  /// 비중 바를 채우는 비율 (0~1)
  final double ratio;

  /// 비중 바의 색
  final Color color;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
      child: Column(
        children: [
          Row(
            children: [
              DecoratedBox(
                decoration: BoxDecoration(
                  color: colors.surfaceContainer,
                  shape: BoxShape.circle,
                ),
                child: SizedBox.square(
                  dimension: 32,
                  child: Icon(icon, size: 18, color: color),
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTypography.bodyMd.copyWith(
                        color: colors.textPrimary,
                        fontWeight: FontWeight.w600,
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
              Text(
                wonSymbolLabel(amount),
                style: AppTypography.amountMd.copyWith(
                  color: colors.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          AppProgressBar(value: ratio, color: color, height: 4),
        ],
      ),
    );
  }
}
