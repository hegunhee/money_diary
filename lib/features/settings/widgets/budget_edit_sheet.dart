import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:money_diary/core/themes/app_colors.dart';
import 'package:money_diary/core/themes/app_spacing.dart';
import 'package:money_diary/core/themes/app_typography.dart';
import 'package:money_diary/shared/controllers/ledger_controller.dart';
import 'package:money_diary/shared/models/asset_account.dart';
import 'package:money_diary/shared/util/won_format.dart';
import 'package:money_diary/shared/util/won_input.dart';
import 'package:money_diary/shared/widgets/app_fill_button.dart';
import 'package:money_diary/shared/widgets/app_sheet.dart';
import 'package:money_diary/shared/widgets/inline_error_text.dart';

/// 한 달 지출 예산과 자산별 예산을 고치는 시트. 비우고 저장하면 그 예산을 없앱니다.
class BudgetEditSheet extends HookConsumerWidget {
  const BudgetEditSheet({
    required this.monthlyBudget,
    required this.assets,
    super.key,
  });

  final int monthlyBudget;

  final List<AssetAccount> assets;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = context.colors;
    String initial(int amount) => amount == 0 ? '' : formatWon(amount);
    final budget = useTextEditingController(text: initial(monthlyBudget));
    // 자산 수만큼 입력칸이 필요해 훅 하나로 묶어 만들고 시트를 닫을 때 정리합니다.
    final assetBudgets = useMemoized(
      () => {
        for (final asset in assets)
          asset.id: TextEditingController(text: initial(asset.monthlyBudget)),
      },
    );
    useEffect(
      () => () {
        for (final controller in assetBudgets.values) {
          controller.dispose();
        }
      },
      const [],
    );
    final busy = useState(false);
    final failed = useState(false);

    Future<void> save() async {
      busy.value = true;
      failed.value = false;
      try {
        await ref.read(ledgerProvider.notifier).saveBudgets(
          parseWon(budget.text),
          {
            for (final MapEntry(:key, :value) in assetBudgets.entries)
              key: parseWon(value.text),
          },
        );
        if (context.mounted) {
          Navigator.of(context).pop();
        }
      } on Object {
        if (context.mounted) {
          busy.value = false;
          failed.value = true;
        }
      }
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        TextField(
          controller: budget,
          autofocus: true,
          keyboardType: TextInputType.number,
          inputFormatters: [WonInputFormatter()],
          decoration: appInputDecoration(
            context,
            label: 'settings.budget'.tr(),
            prefix: '₩ ',
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        Text(
          'settings.budget_hint'.tr(),
          style: AppTypography.bodySm.copyWith(color: colors.textSecondary),
        ),
        if (assets.isNotEmpty) ...[
          const SizedBox(height: AppSpacing.xl),
          Text(
            'settings.asset_budgets'.tr(),
            style: AppTypography.headlineSm.copyWith(
              color: colors.textPrimary,
            ),
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            'settings.asset_budgets_hint'.tr(),
            style: AppTypography.bodySm.copyWith(color: colors.textSecondary),
          ),
          for (final asset in assets) ...[
            const SizedBox(height: AppSpacing.md),
            TextField(
              controller: assetBudgets[asset.id],
              keyboardType: TextInputType.number,
              inputFormatters: [WonInputFormatter()],
              decoration: appInputDecoration(
                context,
                label: asset.name,
                prefix: '₩ ',
              ),
            ),
          ],
        ],
        if (failed.value) ...[
          const SizedBox(height: AppSpacing.sm),
          InlineErrorText('settings.save_failed'.tr()),
        ],
        const SizedBox(height: AppSpacing.lg),
        AppFillButton(
          label: 'common.save'.tr(),
          onPressed: busy.value ? null : save,
        ),
      ],
    );
  }
}
