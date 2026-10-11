import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:money_diary/core/themes/app_colors.dart';
import 'package:money_diary/core/themes/app_typography.dart';
import 'package:money_diary/shared/controllers/main_tab_controller.dart';

/// 하단 탭 바 (홈 · 내역 · 분석 · 프로젝트 · 설정)
class AppBottomNavigation extends ConsumerWidget {
  const AppBottomNavigation({super.key});

  static const _height = 64.0;

  static IconData _icon(MainTab tab) => switch (tab) {
    MainTab.home => Icons.home_outlined,
    MainTab.history => Icons.receipt_long_outlined,
    MainTab.report => Icons.pie_chart_outline,
    MainTab.projects => Icons.folder_outlined,
    MainTab.settings => Icons.settings_outlined,
  };

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = context.colors;
    final selected = ref.watch(mainTabProvider);
    return DecoratedBox(
      decoration: BoxDecoration(
        color: colors.surface,
        border: Border(
          top: BorderSide(color: colors.divider.withValues(alpha: 0.4)),
        ),
      ),
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: _height,
          child: Row(
            children: [
              for (final tab in MainTab.values)
                Expanded(
                  child: Semantics(
                    button: true,
                    selected: tab == selected,
                    child: InkResponse(
                      onTap: () =>
                          ref.read(mainTabProvider.notifier).select(tab),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            _icon(tab),
                            size: 24,
                            color: tab == selected
                                ? colors.primary
                                : colors.textSecondary,
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'nav.${tab.name}'.tr(),
                            style: AppTypography.labelSm.copyWith(
                              color: tab == selected
                                  ? colors.primary
                                  : colors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
