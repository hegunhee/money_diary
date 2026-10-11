import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:money_diary/core/themes/app_colors.dart';
import 'package:money_diary/core/themes/app_spacing.dart';
import 'package:money_diary/core/themes/app_typography.dart';
import 'package:money_diary/shared/controllers/ledger_controller.dart';
import 'package:money_diary/shared/util/won_format.dart';
import 'package:money_diary/shared/util/won_input.dart';
import 'package:money_diary/shared/widgets/app_fill_button.dart';
import 'package:money_diary/shared/widgets/app_sheet.dart';
import 'package:money_diary/shared/widgets/inline_error_text.dart';

/// 한 달 지출 예산을 고치는 시트. 비우고 저장하면 예산을 없앱니다.
class BudgetEditSheet extends HookConsumerWidget {
  const BudgetEditSheet({required this.monthlyBudget, super.key});

  final int monthlyBudget;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final budget = useTextEditingController(
      text: monthlyBudget == 0 ? '' : formatWon(monthlyBudget),
    );
    final busy = useState(false);
    final failed = useState(false);

    Future<void> save() async {
      busy.value = true;
      failed.value = false;
      try {
        await ref
            .read(ledgerProvider.notifier)
            .saveMonthlyBudget(parseWon(budget.text));
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
          style: AppTypography.bodySm.copyWith(
            color: context.colors.textSecondary,
          ),
        ),
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
