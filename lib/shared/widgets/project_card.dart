import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:money_diary/core/themes/app_colors.dart';
import 'package:money_diary/core/themes/app_spacing.dart';
import 'package:money_diary/core/themes/app_typography.dart';
import 'package:money_diary/shared/models/project.dart';
import 'package:money_diary/shared/util/ledger_calculator.dart';
import 'package:money_diary/shared/util/ledger_labels.dart';
import 'package:money_diary/shared/widgets/app_badge.dart';
import 'package:money_diary/shared/widgets/app_card.dart';
import 'package:money_diary/shared/widgets/app_press_scale.dart';
import 'package:money_diary/shared/widgets/app_progress_bar.dart';

/// 프로젝트의 기간과 예산 사용을 보여 주는 카드
class ProjectCard extends StatelessWidget {
  const ProjectCard({
    required this.project,
    required this.spent,
    required this.today,
    this.onTap,
    this.onLongPress,
    super.key,
  });

  final Project project;

  /// 프로젝트에 묶인 지출의 합
  final int spent;

  final DateTime today;

  /// 카드를 눌렀을 때의 동작. null이면 누를 수 없습니다.
  final VoidCallback? onTap;

  /// 카드를 꾹 눌렀을 때의 동작 (선택)
  final VoidCallback? onLongPress;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final remaining = project.budget - spent;
    final ended = project.endDate.isBefore(
      DateTime(today.year, today.month, today.day),
    );
    final days = project.endDate.difference(project.startDate).inDays;
    final daysLeft = DateTime(
      project.startDate.year,
      project.startDate.month,
      project.startDate.day,
    ).difference(DateTime(today.year, today.month, today.day)).inDays;
    final period = [
      '${dottedDateLabel(project.startDate)} ~ ${dottedDateLabel(project.endDate).substring(5)}',
      if (daysLeft > 0) '(D-$daysLeft)',
    ].join(' ');
    TextStyle small(Color color) =>
        AppTypography.labelMd.copyWith(color: color);

    return AppPressScale(
      onTap: onTap,
      onLongPress: onLongPress,
      child: AppCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                DecoratedBox(
                  decoration: BoxDecoration(
                    color: colors.primaryTint,
                    borderRadius: BorderRadius.circular(AppRadius.md),
                  ),
                  child: SizedBox.square(
                    dimension: 32,
                    child: Icon(
                      Icons.flight_takeoff,
                      size: 18,
                      color: colors.primary,
                    ),
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Flexible(
                            child: Text(
                              project.name,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: AppTypography.headlineSm.copyWith(
                                color: colors.textPrimary,
                              ),
                            ),
                          ),
                          const SizedBox(width: 6),
                          AppBadge(
                            ended
                                ? 'project.ended'.tr()
                                : 'project.active'.tr(),
                            background: ended ? colors.surfaceHigh : null,
                            foreground: ended ? colors.textSecondary : null,
                          ),
                        ],
                      ),
                      Text(period, style: small(colors.textSecondary)),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.md),
            Wrap(
              alignment: WrapAlignment.spaceBetween,
              spacing: AppSpacing.sm,
              children: [
                Text(
                  'project.used'.tr(
                    args: [percentLabel(budgetUsage(spent, project.budget))],
                  ),
                  style: small(colors.textSecondary),
                ),
                Text(
                  '${wonSymbolLabel(spent)} / ${wonSymbolLabel(project.budget)}',
                  style: AppTypography.labelMd.copyWith(
                    color: colors.textPrimary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            AppProgressBar(
              value: budgetUsage(spent, project.budget),
              color: remaining < 0 ? colors.expense : null,
            ),
            const SizedBox(height: 6),
            Wrap(
              alignment: WrapAlignment.spaceBetween,
              spacing: AppSpacing.sm,
              children: [
                Text(
                  remaining < 0
                      ? 'project.over'.tr(args: [wonSymbolLabel(-remaining)])
                      : 'project.remaining'.tr(
                          args: [wonSymbolLabel(remaining)],
                        ),
                  style: small(
                    remaining < 0 ? colors.expense : colors.textPrimary,
                  ),
                ),
                if (remaining > 0 && days > 0 && !ended)
                  Text(
                    'project.daily'.tr(
                      args: [wonSymbolLabel(remaining ~/ days)],
                    ),
                    style: small(colors.textPrimary),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
