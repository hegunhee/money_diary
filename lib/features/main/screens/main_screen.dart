import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:money_diary/features/history/screens/history_screen.dart';
import 'package:money_diary/features/home/screens/home_screen.dart';
import 'package:money_diary/features/projects/screens/projects_screen.dart';
import 'package:money_diary/features/report/screens/report_screen.dart';
import 'package:money_diary/features/settings/screens/settings_screen.dart';
import 'package:money_diary/shared/controllers/ledger_controller.dart';
import 'package:money_diary/shared/controllers/main_tab_controller.dart';
import 'package:money_diary/shared/controllers/today_controller.dart';
import 'package:money_diary/shared/widgets/app_bottom_navigation.dart';

/// 하단 탭으로 화면을 오가는 앱의 뼈대
class MainScreen extends HookConsumerWidget {
  const MainScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tab = ref.watch(mainTabProvider);
    // 앱을 켜 둔 채 날짜가 바뀌었을 수 있어, 돌아올 때 오늘을 새로 읽고 밀린 반복 거래를 등록합니다.
    useOnAppLifecycleStateChange((_, state) {
      if (state == AppLifecycleState.resumed) {
        ref.invalidate(todayProvider);
        ref.read(ledgerProvider.notifier).registerDueRecurring();
      }
    });
    // 홈이 아닌 탭에서 뒤로 가면 앱을 닫지 않고 홈으로 돌아갑니다.
    return PopScope(
      canPop: tab == MainTab.home,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) {
          ref.read(mainTabProvider.notifier).select(MainTab.home);
        }
      },
      child: Scaffold(
        // 탭 화면에는 앱바가 없어 상태바에 가리지 않게 위쪽만 비웁니다.
        body: SafeArea(
          bottom: false,
          child: IndexedStack(
            index: tab.index,
            children: [
              for (final tab in MainTab.values)
                switch (tab) {
                  MainTab.home => const HomeScreen(),
                  MainTab.history => const HistoryScreen(),
                  MainTab.report => const ReportScreen(),
                  MainTab.projects => const ProjectsScreen(),
                  MainTab.settings => const SettingsScreen(),
                },
            ],
          ),
        ),
        bottomNavigationBar: const AppBottomNavigation(),
      ),
    );
  }
}
