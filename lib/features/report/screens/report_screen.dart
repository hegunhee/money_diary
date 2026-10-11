import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:money_diary/core/themes/app_colors.dart';
import 'package:money_diary/core/themes/app_layout.dart';
import 'package:money_diary/core/themes/app_palette.dart';
import 'package:money_diary/core/themes/app_spacing.dart';
import 'package:money_diary/core/themes/app_typography.dart';
import 'package:money_diary/features/report/models/report_tab.dart';
import 'package:money_diary/features/report/widgets/report_summary_card.dart';
import 'package:money_diary/features/report/widgets/share_donut_chart.dart';
import 'package:money_diary/features/report/widgets/share_row.dart';
import 'package:money_diary/shared/controllers/ledger_controller.dart';
import 'package:money_diary/shared/controllers/main_tab_controller.dart';
import 'package:money_diary/shared/controllers/today_controller.dart';
import 'package:money_diary/shared/models/ledger_entry.dart';
import 'package:money_diary/shared/util/ledger_calculator.dart';
import 'package:money_diary/shared/util/ledger_labels.dart';
import 'package:money_diary/shared/widgets/app_badge.dart';
import 'package:money_diary/shared/widgets/app_card.dart';
import 'package:money_diary/shared/widgets/app_content_width.dart';
import 'package:money_diary/shared/widgets/app_error_view.dart';
import 'package:money_diary/shared/widgets/app_fill_button.dart';
import 'package:money_diary/shared/widgets/app_top_bar.dart';
import 'package:money_diary/shared/widgets/month_selector.dart';

/// 월간 분석 리포트 — 저축액과 카테고리·자산·프로젝트별 지출 비중
class ReportScreen extends HookConsumerWidget {
  const ReportScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = context.colors;
    final tab = useState(ReportTab.category);
    final ledger = ref.watch(ledgerProvider);
    final month = ref.watch(selectedMonthProvider);

    return Scaffold(
      appBar: AppTopBar(section: 'nav.report'.tr()),
      body: ledger.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => AppErrorView(
          message: 'common.load_failed'.tr(),
          onRetry: () => ref.invalidate(ledgerProvider),
        ),
        data: (book) {
          final entries = entriesInMonth(book.entries, month);
          final totals = totalsOf(entries);
          final previous = totalsOf(
            entriesInMonth(book.entries, DateTime(month.year, month.month - 1)),
          );
          final categories = categoryShares(entries);
          final assets = assetShares(entries, book.assets);
          final projects = [
            for (final project in book.projects)
              (
                project,
                projectSpent(entries, project.id),
              ),
          ].where((item) => item.$2 > 0).toList();
          final change = previous.expense == 0
              ? null
              : (totals.expense - previous.expense) / previous.expense;

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
                if (change != null)
                  Padding(
                    padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: AppBadge(
                        (change <= 0
                                ? 'report.vs_last_month_less'
                                : 'report.vs_last_month_more')
                            .tr(args: [percentLabel(change.abs())]),
                        icon: change <= 0
                            ? Icons.trending_down
                            : Icons.trending_up,
                      ),
                    ),
                  ),
                ReportSummaryCard(
                  totals: totals,
                  incomeCount: entries
                      .where((entry) => entry.type == EntryType.income)
                      .length,
                  monthlyBudget: book.monthlyBudget,
                ),
                const SizedBox(height: AppSpacing.lg),
                _TabRail(selected: tab.value, onChanged: (v) => tab.value = v),
                const SizedBox(height: AppSpacing.lg),
                AppCard(
                  padding: const EdgeInsets.all(AppSpacing.lg),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(
                        'report.share_title.${tab.value.name}'.tr(),
                        style: AppTypography.headlineSm.copyWith(
                          color: colors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.md),
                      if (totals.expense == 0)
                        Padding(
                          padding: const EdgeInsets.all(AppSpacing.lg),
                          child: Text(
                            'report.empty'.tr(),
                            textAlign: TextAlign.center,
                            style: AppTypography.bodyMd.copyWith(
                              color: colors.textSecondary,
                            ),
                          ),
                        )
                      else
                        ...switch (tab.value) {
                          ReportTab.category => [
                            Center(
                              child: ShareDonutChart(
                                ratios: [for (final s in categories) s.ratio],
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                      'report.total_expense'.tr(),
                                      style: AppTypography.labelSm.copyWith(
                                        color: colors.textSecondary,
                                      ),
                                    ),
                                    Text(
                                      wonSymbolLabel(totals.expense),
                                      style: AppTypography.amountMd.copyWith(
                                        color: colors.textPrimary,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                    Text(
                                      'report.daily_average'.tr(
                                        args: [
                                          wonLabel(
                                            dailyAverage(totals.expense, month),
                                          ),
                                        ],
                                      ),
                                      style: AppTypography.labelSm.copyWith(
                                        color: colors.expense,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            const SizedBox(height: AppSpacing.md),
                            for (final (index, share) in categories.indexed)
                              ShareRow(
                                icon: share.category.icon,
                                name: share.category.label,
                                caption: percentLabel(share.ratio),
                                amount: share.amount,
                                ratio: share.ratio,
                                color: shareColorAt(colors, index),
                              ),
                          ],
                          ReportTab.asset => [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(
                                AppRadius.full,
                              ),
                              child: SizedBox(
                                height: 10,
                                child: Row(
                                  children: [
                                    for (final (index, share) in assets.indexed)
                                      Expanded(
                                        flex: (share.ratio * 1000)
                                            .round()
                                            .clamp(
                                              1,
                                              1000,
                                            ),
                                        child: ColoredBox(
                                          color: shareColorAt(colors, index),
                                        ),
                                      ),
                                  ],
                                ),
                              ),
                            ),
                            const SizedBox(height: AppSpacing.sm),
                            for (final (index, share) in assets.indexed)
                              ShareRow(
                                icon: share.asset.kind.icon,
                                name: share.asset.name,
                                caption:
                                    '${percentLabel(share.ratio)} · ${share.asset.kind.label}',
                                amount: share.amount,
                                ratio: share.ratio,
                                color: shareColorAt(colors, index),
                              ),
                          ],
                          ReportTab.project => [
                            if (projects.isEmpty)
                              Padding(
                                padding: const EdgeInsets.all(AppSpacing.lg),
                                child: Text(
                                  'report.project_empty'.tr(),
                                  textAlign: TextAlign.center,
                                  style: AppTypography.bodyMd.copyWith(
                                    color: colors.textSecondary,
                                  ),
                                ),
                              ),
                            for (final (index, (project, spent))
                                in projects.indexed)
                              ShareRow(
                                icon: Icons.flight_takeoff,
                                name: project.name,
                                caption: 'report.project_caption'.tr(
                                  args: [
                                    percentLabel(spent / totals.expense),
                                    percentLabel(
                                      budgetUsage(
                                        projectSpent(book.entries, project.id),
                                        project.budget,
                                      ),
                                    ),
                                  ],
                                ),
                                amount: spent,
                                ratio: spent / totals.expense,
                                color: shareColorAt(colors, index),
                              ),
                          ],
                        },
                    ],
                  ),
                ),
                if (categories.isNotEmpty) ...[
                  const SizedBox(height: AppSpacing.lg),
                  AppCard(
                    color: colors.surfaceContainer,
                    padding: const EdgeInsets.all(AppSpacing.lg),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        DecoratedBox(
                          decoration: BoxDecoration(
                            color: colors.primary,
                            shape: BoxShape.circle,
                          ),
                          child: SizedBox.square(
                            dimension: 36,
                            child: Icon(
                              Icons.auto_awesome,
                              size: 18,
                              color: colors.onPrimary,
                            ),
                          ),
                        ),
                        const SizedBox(width: AppSpacing.md),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'report.comment_title'.tr(),
                                style: AppTypography.headlineSm.copyWith(
                                  color: colors.primary,
                                ),
                              ),
                              const SizedBox(height: AppSpacing.xs),
                              Text(
                                'report.comment_top_category'.tr(
                                  namedArgs: {
                                    'category': categories.first.category.label,
                                    'percent': percentLabel(
                                      categories.first.ratio,
                                    ),
                                    'amount': wonLabel(categories.first.amount),
                                  },
                                ),
                                style: AppTypography.bodyMd.copyWith(
                                  color: colors.textPrimary,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
                const SizedBox(height: AppSpacing.lg),
                AppFillButton(
                  label: 'report.see_history'.tr(),
                  icon: Icons.receipt_long_outlined,
                  onPressed: () => ref
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

/// 카테고리별 · 자산별 · 프로젝트별을 고르는 레일
class _TabRail extends StatelessWidget {
  const _TabRail({required this.selected, required this.onChanged});

  final ReportTab selected;

  final ValueChanged<ReportTab> onChanged;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return DecoratedBox(
      decoration: BoxDecoration(
        color: colors.surfaceHigh,
        borderRadius: BorderRadius.circular(AppRadius.full),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xs),
        child: Row(
          children: [
            for (final tab in ReportTab.values)
              Expanded(
                child: Semantics(
                  button: true,
                  selected: tab == selected,
                  child: GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: () => onChanged(tab),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 150),
                      height: AppLayout.minTouchTarget,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: tab == selected ? colors.surface : null,
                        borderRadius: BorderRadius.circular(AppRadius.full),
                        boxShadow: [
                          if (tab == selected)
                            const BoxShadow(
                              color: AppPalette.shadow,
                              blurRadius: 3,
                              offset: Offset(0, 1),
                            ),
                        ],
                      ),
                      child: Text(
                        'report.tab.${tab.name}'.tr(),
                        style: AppTypography.headlineSm.copyWith(
                          color: tab == selected
                              ? colors.textPrimary
                              : colors.textSecondary,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
