import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:money_diary/features/history/screens/history_screen.dart';
import 'package:money_diary/features/home/screens/home_screen.dart';
import 'package:money_diary/features/projects/screens/projects_screen.dart';
import 'package:money_diary/features/report/screens/report_screen.dart';
import 'package:money_diary/features/settings/screens/settings_screen.dart';
import 'package:money_diary/shared/controllers/main_tab_controller.dart';
import 'package:money_diary/shared/widgets/app_bottom_navigation.dart';

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
              MainTab.history => const HistoryScreen(),
              MainTab.report => const ReportScreen(),
              MainTab.projects => const ProjectsScreen(),
              MainTab.settings => const SettingsScreen(),
            },
        ],
      ),
      bottomNavigationBar: const AppBottomNavigation(),
    );
  }
}
