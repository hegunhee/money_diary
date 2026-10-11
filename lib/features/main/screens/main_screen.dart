import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:money_diary/core/themes/app_colors.dart';
import 'package:money_diary/core/themes/app_typography.dart';
import 'package:money_diary/features/home/screens/home_screen.dart';
import 'package:money_diary/shared/controllers/main_tab_controller.dart';
import 'package:money_diary/shared/widgets/app_bottom_navigation.dart';
import 'package:money_diary/shared/widgets/app_top_bar.dart';

/// 하단 탭으로 화면을 오가는 앱의 뼈대
class MainScreen extends ConsumerWidget {
  const MainScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tab = ref.watch(mainTabProvider);
    return Scaffold(
      body: IndexedStack(
        index: tab.index,
        children: [
          for (final tab in MainTab.values)
            switch (tab) {
              MainTab.home => const HomeScreen(),
              _ => _ComingSoonScreen(tab),
            },
        ],
      ),
      bottomNavigationBar: const AppBottomNavigation(),
    );
  }
}

/// 아직 만들지 않은 탭의 자리
class _ComingSoonScreen extends StatelessWidget {
  const _ComingSoonScreen(this.tab);

  final MainTab tab;

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppTopBar(section: 'nav.${tab.name}'.tr()),
    body: Center(
      child: Text(
        'common.coming_soon'.tr(),
        style: AppTypography.bodyLg.copyWith(
          color: context.colors.textSecondary,
        ),
      ),
    ),
  );
}
