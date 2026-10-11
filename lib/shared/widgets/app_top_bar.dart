import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:money_diary/core/themes/app_colors.dart';
import 'package:money_diary/core/themes/app_spacing.dart';
import 'package:money_diary/core/themes/app_typography.dart';
import 'package:money_diary/shared/widgets/app_badge.dart';

/// 탭 화면 위의 브랜드 바. 로고·앱 이름과 지금 화면의 이름표를 보여 줍니다.
class AppTopBar extends StatelessWidget implements PreferredSizeWidget {
  const AppTopBar({required this.section, this.actions = const [], super.key});

  /// 앱 이름 옆 배지에 적는 화면 이름 (번역된 문자열)
  final String section;

  /// 오른쪽에 놓는 버튼들
  final List<Widget> actions;

  @override
  Size get preferredSize => const Size.fromHeight(64);

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return AppBar(
      toolbarHeight: 64,
      automaticallyImplyLeading: false,
      titleSpacing: AppSpacing.gutter,
      title: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(AppRadius.md),
            child: Image.asset(
              'assets/images/app_logo.png',
              width: 32,
              height: 32,
              excludeFromSemantics: true,
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          Flexible(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Flexible(
                      child: Text(
                        'common.app_name'.tr(),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AppTypography.headlineSm.copyWith(
                          color: colors.textPrimary,
                        ),
                      ),
                    ),
                    const SizedBox(width: 6),
                    AppBadge(section),
                  ],
                ),
                Text(
                  'common.app_subtitle'.tr(),
                  style: AppTypography.labelMd.copyWith(
                    color: colors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      actions: [
        ...actions,
        const SizedBox(width: AppSpacing.sm),
      ],
    );
  }
}
