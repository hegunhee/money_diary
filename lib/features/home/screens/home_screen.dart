import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:money_diary/core/themes/app_spacing.dart';
import 'package:money_diary/features/entry/screens/entry_screen.dart';
import 'package:money_diary/features/home/widgets/monthly_status_card.dart';
import 'package:money_diary/features/home/widgets/net_worth_card.dart';
import 'package:money_diary/features/home/widgets/quick_action_row.dart';
import 'package:money_diary/features/home/widgets/recent_entries_section.dart';
import 'package:money_diary/shared/controllers/ledger_controller.dart';
import 'package:money_diary/shared/controllers/main_tab_controller.dart';
import 'package:money_diary/shared/controllers/today_controller.dart';
import 'package:money_diary/shared/util/ledger_calculator.dart';
import 'package:money_diary/shared/widgets/app_content_width.dart';
import 'package:money_diary/shared/widgets/app_error_view.dart';
import 'package:money_diary/shared/widgets/app_top_bar.dart';
import 'package:money_diary/shared/widgets/month_selector.dart';
import 'package:money_diary/shared/widgets/project_card.dart';

/// 홈 대시보드 — 순자산, 이번 달 현황, 진행 중인 프로젝트, 최근 거래
class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  /// 최근 거래로 보여 주는 날짜 수
  static const _recentDays = 2;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ledger = ref.watch(ledgerProvider);
    final month = ref.watch(selectedMonthProvider);
    final today = ref.watch(todayProvider);
    final isThisMonth = month.year == today.year && month.month == today.month;

    return Scaffold(
      appBar: AppTopBar(section: 'nav.home'.tr()),
      body: ledger.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => AppErrorView(
          message: 'common.load_failed'.tr(),
          onRetry: () => ref.invalidate(ledgerProvider),
        ),
        data: (book) {
          final entries = entriesInMonth(book.entries, month);
          final totals = totalsOf(entries);
          final projects = book.projects.where(
            (project) => !project.endDate.isBefore(today),
          );
          return AppContentWidth(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.gutter,
                0,
                AppSpacing.gutter,
                AppSpacing.xl,
              ),
              children: [
                const Align(
                  alignment: Alignment.centerLeft,
                  child: MonthSelector(),
                ),
                NetWorthCard(
                  assets: book.assets,
                  monthlyChange: isThisMonth ? totals.net : null,
                ),
                const SizedBox(height: AppSpacing.lg),
                MonthlyStatusCard(
                  month: month,
                  totals: totals,
                  monthlyBudget: book.monthlyBudget,
                  dayOfMonth: isThisMonth ? today.day : null,
                ),
                const SizedBox(height: AppSpacing.lg),
                QuickActionRow(
                  onAdd: (type) =>
                      Navigator.of(context).push(EntryScreen.route(type: type)),
                ),
                for (final project in projects) ...[
                  const SizedBox(height: AppSpacing.lg),
                  ProjectCard(
                    project: project,
                    spent: projectSpent(book.entries, project.id),
                    today: today,
                    onTap: () => ref
                        .read(mainTabProvider.notifier)
                        .select(MainTab.projects),
                  ),
                ],
                const SizedBox(height: AppSpacing.sm),
                RecentEntriesSection(
                  days: groupByDay(entries).take(_recentDays).toList(),
                  book: book,
                  today: today,
                  onEntryTap: (entry) => Navigator.of(
                    context,
                  ).push(EntryScreen.route(entry: entry)),
                  onSeeAll: () => ref
                      .read(mainTabProvider.notifier)
                      .select(MainTab.history),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
