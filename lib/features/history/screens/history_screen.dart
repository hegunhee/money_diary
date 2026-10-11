import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:money_diary/core/themes/app_colors.dart';
import 'package:money_diary/core/themes/app_spacing.dart';
import 'package:money_diary/core/themes/app_typography.dart';
import 'package:money_diary/features/entry/screens/entry_screen.dart';
import 'package:money_diary/features/history/models/ledger_filter.dart';
import 'package:money_diary/features/history/widgets/daily_ledger_section.dart';
import 'package:money_diary/features/history/widgets/history_summary_card.dart';
import 'package:money_diary/shared/controllers/ledger_controller.dart';
import 'package:money_diary/shared/controllers/today_controller.dart';
import 'package:money_diary/shared/util/ledger_calculator.dart';
import 'package:money_diary/shared/widgets/app_card.dart';
import 'package:money_diary/shared/widgets/app_content_width.dart';
import 'package:money_diary/shared/widgets/app_error_view.dart';
import 'package:money_diary/shared/widgets/app_filter_chip.dart';
import 'package:money_diary/shared/widgets/app_top_bar.dart';
import 'package:money_diary/shared/widgets/month_selector.dart';

/// 가계부 내역 — 한 달의 거래를 날짜별로 묶어 보여 줍니다.
class HistoryScreen extends HookConsumerWidget {
  const HistoryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = context.colors;
    final filter = useState(LedgerFilter.all);
    final newestFirst = useState(true);
    final ledger = ref.watch(ledgerProvider);
    final month = ref.watch(selectedMonthProvider);
    final today = ref.watch(todayProvider);

    return Scaffold(
      appBar: AppTopBar(section: 'nav.history'.tr()),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Navigator.of(context).push(EntryScreen.route()),
        backgroundColor: colors.primary,
        foregroundColor: colors.onPrimary,
        shape: const StadiumBorder(),
        icon: const Icon(Icons.add),
        label: Text('history.write'.tr(), style: AppTypography.headlineSm),
      ),
      body: ledger.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => AppErrorView(
          message: 'common.load_failed'.tr(),
          onRetry: () => ref.invalidate(ledgerProvider),
        ),
        data: (book) {
          final monthEntries = entriesInMonth(book.entries, month);
          final shown = monthEntries.where(filter.value.matches).toList();
          final days = groupByDay(shown);
          final streak = recordStreak(book.entries, today);
          return AppContentWidth(
            child: ListView(
              padding: const EdgeInsets.only(bottom: 96),
              children: [
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: AppSpacing.gutter),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: MonthSelector(style: AppTypography.headlineMd),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.gutter,
                  ),
                  // 요약은 거르기와 상관없이 그 달 전체를 보여 줍니다.
                  child: HistorySummaryCard(
                    totals: totalsOf(monthEntries),
                    monthlyBudget: book.monthlyBudget,
                  ),
                ),
                const SizedBox(height: AppSpacing.md),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.gutter,
                  ),
                  child: Row(
                    children: [
                      for (final item in LedgerFilter.values) ...[
                        if (item != LedgerFilter.all)
                          const SizedBox(width: AppSpacing.sm),
                        AppFilterChip(
                          label: 'history.filter.${item.name}'.tr(),
                          icon: item == LedgerFilter.project
                              ? Icons.folder_outlined
                              : null,
                          selected: item == filter.value,
                          onTap: () => filter.value = item,
                        ),
                      ],
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.gutter,
                  ),
                  child: Row(
                    children: [
                      TextButton.icon(
                        onPressed: () => newestFirst.value = !newestFirst.value,
                        style: TextButton.styleFrom(
                          padding: EdgeInsets.zero,
                          foregroundColor: colors.textSecondary,
                        ),
                        icon: const Icon(Icons.swap_vert, size: 16),
                        label: Text(
                          newestFirst.value
                              ? 'history.sort_newest'.tr()
                              : 'history.sort_oldest'.tr(),
                          style: AppTypography.labelMd,
                        ),
                      ),
                      const Spacer(),
                      Text(
                        'history.count'.tr(args: ['${shown.length}']),
                        style: AppTypography.labelMd.copyWith(
                          color: colors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                if (days.isEmpty)
                  Padding(
                    padding: const EdgeInsets.all(AppSpacing.xl),
                    child: Text(
                      'history.empty'.tr(),
                      textAlign: TextAlign.center,
                      style: AppTypography.bodyMd.copyWith(
                        color: colors.textSecondary,
                      ),
                    ),
                  ),
                for (final day in newestFirst.value ? days : days.reversed)
                  Padding(
                    padding: const EdgeInsets.fromLTRB(
                      AppSpacing.gutter,
                      0,
                      AppSpacing.gutter,
                      AppSpacing.xl,
                    ),
                    child: DailyLedgerSection(day: day, book: book),
                  ),
                if (streak >= 2)
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.gutter,
                    ),
                    child: AppCard(
                      color: colors.surfaceContainer,
                      padding: const EdgeInsets.all(AppSpacing.lg),
                      child: Row(
                        children: [
                          DecoratedBox(
                            decoration: BoxDecoration(
                              color: colors.primaryTint,
                              shape: BoxShape.circle,
                            ),
                            child: SizedBox.square(
                              dimension: 44,
                              child: Icon(
                                Icons.auto_awesome,
                                size: 22,
                                color: colors.primary,
                              ),
                            ),
                          ),
                          const SizedBox(width: AppSpacing.md),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'history.streak_title'.tr(args: ['$streak']),
                                  style: AppTypography.headlineSm.copyWith(
                                    color: colors.textPrimary,
                                  ),
                                ),
                                Text(
                                  'history.streak_description'.tr(),
                                  style: AppTypography.bodySm.copyWith(
                                    color: colors.textSecondary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }
}
