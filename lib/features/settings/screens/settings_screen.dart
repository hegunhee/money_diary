import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:money_diary/core/themes/app_colors.dart';
import 'package:money_diary/core/themes/app_spacing.dart';
import 'package:money_diary/core/themes/app_typography.dart';
import 'package:money_diary/features/settings/widgets/asset_reorderable_list.dart';
import 'package:money_diary/features/settings/widgets/budget_edit_sheet.dart';
import 'package:money_diary/features/settings/widgets/net_worth_card.dart';
import 'package:money_diary/shared/controllers/ledger_controller.dart';
import 'package:money_diary/shared/controllers/today_controller.dart';
import 'package:money_diary/shared/models/asset_account.dart';
import 'package:money_diary/shared/models/ledger_book.dart';
import 'package:money_diary/shared/util/ledger_calculator.dart';
import 'package:money_diary/shared/util/ledger_labels.dart';
import 'package:money_diary/shared/widgets/app_card.dart';
import 'package:money_diary/shared/widgets/app_content_width.dart';
import 'package:money_diary/shared/widgets/app_error_view.dart';
import 'package:money_diary/shared/widgets/app_filter_chip.dart';
import 'package:money_diary/shared/widgets/app_sheet.dart';
import 'package:money_diary/shared/widgets/app_tap_row.dart';
import 'package:money_diary/shared/widgets/asset_edit_sheet.dart';

/// 설정 — 한 달 예산과 자산(계좌·카드·현금)을 관리합니다.
class SettingsScreen extends HookConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = context.colors;
    // 자산 목록을 거르는 탭. null이면 전체를 보여 줍니다.
    final kind = useState<AssetKind?>(null);
    bool inTab(AssetAccount asset) =>
        kind.value == null || asset.kind == kind.value;
    final ledger = ref.watch(ledgerProvider);
    final today = ref.watch(todayProvider);

    void editAsset([AssetAccount? asset]) => showAppSheet<void>(
      context,
      title: asset == null
          ? 'settings.asset_add'.tr()
          : 'settings.asset_edit'.tr(),
      child: AssetEditSheet(asset: asset),
    );

    Future<void> deleteAsset(AssetAccount asset) async {
      final confirmed = await confirmDelete(
        context,
        message: 'settings.asset_delete_confirm'.tr(args: [asset.name]),
        confirmLabel: 'common.delete'.tr(),
        cancelLabel: 'common.cancel'.tr(),
      );
      if (!confirmed) {
        return;
      }
      var message = 'common.delete_failed'.tr();
      try {
        if (await ref.read(ledgerProvider.notifier).deleteAsset(asset.id)) {
          return;
        }
        message = 'settings.asset_in_use'.tr();
      } on Object {
        // 아래에서 실패를 알립니다.
      }
      if (context.mounted) {
        await showNotice(
          context,
          message: message,
          closeLabel: 'common.close'.tr(),
        );
      }
    }

    Future<void> reorderAsset(LedgerBook book, int from, int to) async {
      try {
        await ref
            .read(ledgerProvider.notifier)
            .reorderAssets(moveAsset(book.assets, inTab, from, to));
      } on Object {
        if (context.mounted) {
          await showNotice(
            context,
            message: 'settings.save_failed'.tr(),
            closeLabel: 'common.close'.tr(),
          );
        }
      }
    }

    return Scaffold(
      body: ledger.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => AppErrorView(
          message: 'common.load_failed'.tr(),
          onRetry: () => ref.invalidate(ledgerProvider),
        ),
        data: (book) => AppContentWidth(
          child: CustomScrollView(
            slivers: [
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.gutter,
                  AppSpacing.gutter,
                  AppSpacing.gutter,
                  0,
                ),
                sliver: SliverList.list(
                  children: [
                    AppCard(
                      padding: EdgeInsets.zero,
                      child: AppTapRow(
                        onTap: () => showAppSheet<void>(
                          context,
                          title: 'settings.budget'.tr(),
                          child: BudgetEditSheet(
                            monthlyBudget: book.monthlyBudget,
                          ),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(AppSpacing.lg),
                          child: Row(
                            children: [
                              Icon(Icons.tune, size: 20, color: colors.primary),
                              const SizedBox(width: AppSpacing.md),
                              Expanded(
                                child: Text(
                                  'settings.budget'.tr(),
                                  style: AppTypography.bodyLg.copyWith(
                                    color: colors.textPrimary,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                              Text(
                                book.monthlyBudget > 0
                                    ? wonSymbolLabel(book.monthlyBudget)
                                    : 'settings.budget_unset'.tr(),
                                style: AppTypography.amountMd.copyWith(
                                  color: book.monthlyBudget > 0
                                      ? colors.textPrimary
                                      : colors.textSecondary,
                                ),
                              ),
                              Icon(
                                Icons.chevron_right,
                                size: 20,
                                color: colors.textSecondary,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xl),
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            'settings.assets'.tr(),
                            style: AppTypography.headlineSm.copyWith(
                              color: colors.textPrimary,
                            ),
                          ),
                        ),
                        TextButton.icon(
                          onPressed: editAsset,
                          icon: const Icon(Icons.add, size: 18),
                          label: Text('settings.asset_add'.tr()),
                        ),
                      ],
                    ),
                    NetWorthCard(
                      assets: book.assets,
                      monthlyChange: totalsOf(
                        entriesInMonth(book.entries, today),
                      ).net,
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    if (book.assets.isNotEmpty) ...[
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: [
                            AppFilterChip(
                              label: 'settings.asset_tab_all'.tr(),
                              selected: kind.value == null,
                              onTap: () => kind.value = null,
                            ),
                            for (final item in AssetKind.values) ...[
                              const SizedBox(width: AppSpacing.sm),
                              AppFilterChip(
                                label: item.label,
                                selected: item == kind.value,
                                onTap: () => kind.value = item,
                              ),
                            ],
                          ],
                        ),
                      ),
                      const SizedBox(height: AppSpacing.md),
                    ],
                    if (!book.assets.any(inTab))
                      AppCard(
                        child: Text(
                          book.assets.isEmpty
                              ? 'settings.assets_empty'.tr()
                              : 'settings.asset_tab_empty'.tr(),
                          textAlign: TextAlign.center,
                          style: AppTypography.bodyMd.copyWith(
                            color: colors.textSecondary,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              if (book.assets.any(inTab))
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(
                    AppSpacing.gutter,
                    0,
                    AppSpacing.gutter,
                    AppSpacing.gutter,
                  ),
                  sliver: AssetReorderableList(
                    assets: book.assets.where(inTab).toList(),
                    onTap: editAsset,
                    onDelete: deleteAsset,
                    onReorder: (from, to) => reorderAsset(book, from, to),
                  ),
                )
              else
                const SliverPadding(
                  padding: EdgeInsets.only(bottom: AppSpacing.gutter),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
