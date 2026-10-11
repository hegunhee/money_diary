import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:money_diary/core/themes/app_colors.dart';
import 'package:money_diary/core/themes/app_spacing.dart';
import 'package:money_diary/core/themes/app_typography.dart';
import 'package:money_diary/features/settings/widgets/budget_edit_sheet.dart';
import 'package:money_diary/shared/controllers/ledger_controller.dart';
import 'package:money_diary/shared/models/asset_account.dart';
import 'package:money_diary/shared/util/ledger_calculator.dart';
import 'package:money_diary/shared/util/ledger_labels.dart';
import 'package:money_diary/shared/widgets/app_card.dart';
import 'package:money_diary/shared/widgets/app_content_width.dart';
import 'package:money_diary/shared/widgets/app_error_view.dart';
import 'package:money_diary/shared/widgets/app_sheet.dart';
import 'package:money_diary/shared/widgets/app_tap_row.dart';
import 'package:money_diary/shared/widgets/app_top_bar.dart';
import 'package:money_diary/shared/widgets/asset_edit_sheet.dart';

/// 설정 — 한 달 예산과 자산(계좌·카드·현금)을 관리합니다.
class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = context.colors;
    final ledger = ref.watch(ledgerProvider);

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

    return Scaffold(
      appBar: AppTopBar(section: 'nav.settings'.tr()),
      body: ledger.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => AppErrorView(
          message: 'common.load_failed'.tr(),
          onRetry: () => ref.invalidate(ledgerProvider),
        ),
        data: (book) => AppContentWidth(
          child: ListView(
            padding: const EdgeInsets.all(AppSpacing.gutter),
            children: [
              AppCard(
                padding: EdgeInsets.zero,
                child: AppTapRow(
                  onTap: () => showAppSheet<void>(
                    context,
                    title: 'settings.budget'.tr(),
                    child: BudgetEditSheet(monthlyBudget: book.monthlyBudget),
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
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'settings.assets'.tr(),
                          style: AppTypography.headlineSm.copyWith(
                            color: colors.textPrimary,
                          ),
                        ),
                        Text(
                          'settings.net_worth'.tr(
                            args: [wonSymbolLabel(netWorth(book.assets))],
                          ),
                          style: AppTypography.labelMd.copyWith(
                            color: colors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  TextButton.icon(
                    onPressed: editAsset,
                    icon: const Icon(Icons.add, size: 18),
                    label: Text('settings.asset_add'.tr()),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.sm),
              if (book.assets.isEmpty)
                AppCard(
                  child: Text(
                    'settings.assets_empty'.tr(),
                    textAlign: TextAlign.center,
                    style: AppTypography.bodyMd.copyWith(
                      color: colors.textSecondary,
                    ),
                  ),
                )
              else
                AppCard(
                  padding: EdgeInsets.zero,
                  child: Column(
                    children: [
                      for (final (index, asset) in book.assets.indexed) ...[
                        if (index > 0)
                          Divider(
                            height: 1,
                            color: colors.divider.withValues(alpha: 0.3),
                          ),
                        AppTapRow(
                          onTap: () => editAsset(asset),
                          onLongPress: () => deleteAsset(asset),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: AppSpacing.lg,
                              vertical: AppSpacing.md,
                            ),
                            child: Row(
                              children: [
                                DecoratedBox(
                                  decoration: BoxDecoration(
                                    color: colors.surfaceContainer,
                                    borderRadius: BorderRadius.circular(
                                      AppRadius.md,
                                    ),
                                  ),
                                  child: SizedBox.square(
                                    dimension: 40,
                                    child: Icon(
                                      asset.kind.icon,
                                      size: 20,
                                      color: colors.primary,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: AppSpacing.md),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        asset.name,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: AppTypography.bodyLg.copyWith(
                                          color: colors.textPrimary,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                      Text(
                                        asset.kind.countsTowardNetWorth
                                            ? asset.kind.label
                                            : 'settings.asset_due_caption'.tr(
                                                args: [asset.kind.label],
                                              ),
                                        style: AppTypography.bodySm.copyWith(
                                          color: colors.textSecondary,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Text(
                                  wonLabel(asset.balance),
                                  style: AppTypography.amountMd.copyWith(
                                    color: colors.textPrimary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
