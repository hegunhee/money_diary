import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:money_diary/core/themes/app_spacing.dart';
import 'package:money_diary/shared/controllers/ledger_controller.dart';
import 'package:money_diary/shared/models/asset_account.dart';
import 'package:money_diary/shared/util/ledger_labels.dart';
import 'package:money_diary/shared/util/won_format.dart';
import 'package:money_diary/shared/util/won_input.dart';
import 'package:money_diary/shared/widgets/app_fill_button.dart';
import 'package:money_diary/shared/widgets/app_filter_chip.dart';
import 'package:money_diary/shared/widgets/app_sheet.dart';
import 'package:money_diary/shared/widgets/inline_error_text.dart';

/// 자산을 더하거나 고치는 시트. [asset]이 null이면 새 자산을 만듭니다.
class AssetEditSheet extends HookConsumerWidget {
  const AssetEditSheet({this.asset, super.key});

  final AssetAccount? asset;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final editing = asset;
    final name = useTextEditingController(text: editing?.name);
    final balance = useTextEditingController(
      text: editing == null || editing.balance == 0
          ? ''
          : formatWon(editing.balance),
    );
    final kind = useState(editing?.kind ?? AssetKind.bank);
    final error = useState<String?>(null);
    final busy = useState(false);

    Future<void> run(Future<String?> Function() action) async {
      if (busy.value) {
        return;
      }
      busy.value = true;
      String? failure;
      try {
        failure = await action();
      } on Object {
        failure = 'settings.save_failed'.tr();
      }
      if (!context.mounted) {
        return;
      }
      busy.value = false;
      error.value = failure;
      if (failure == null) {
        Navigator.of(context).pop();
      }
    }

    Future<String?> save() async {
      if (name.text.trim().isEmpty) {
        return 'settings.asset_name_required'.tr();
      }
      await ref
          .read(ledgerProvider.notifier)
          .saveAsset(
            AssetAccount(
              id:
                  editing?.id ??
                  'asset-${DateTime.now().microsecondsSinceEpoch}',
              name: name.text.trim(),
              kind: kind.value,
              balance: parseWon(balance.text),
            ),
          );
      return null;
    }

    Future<void> delete() async {
      final confirmed = await confirmDelete(
        context,
        message: 'settings.asset_delete_confirm'.tr(args: [editing!.name]),
        confirmLabel: 'common.delete'.tr(),
        cancelLabel: 'common.cancel'.tr(),
      );
      if (!confirmed) {
        return;
      }
      await run(
        () async =>
            await ref.read(ledgerProvider.notifier).deleteAsset(editing.id)
            ? null
            : 'settings.asset_in_use'.tr(),
      );
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        TextField(
          controller: name,
          textInputAction: TextInputAction.next,
          decoration: appInputDecoration(
            context,
            label: 'settings.asset_name'.tr(),
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        Wrap(
          spacing: AppSpacing.sm,
          runSpacing: AppSpacing.sm,
          children: [
            for (final item in AssetKind.values)
              AppFilterChip(
                label: item.label,
                icon: item.icon,
                selected: item == kind.value,
                onTap: () => kind.value = item,
              ),
          ],
        ),
        const SizedBox(height: AppSpacing.md),
        TextField(
          controller: balance,
          keyboardType: TextInputType.number,
          inputFormatters: [WonInputFormatter()],
          decoration: appInputDecoration(
            context,
            label: kind.value.countsTowardNetWorth
                ? 'settings.asset_balance'.tr()
                : 'settings.asset_due'.tr(),
            prefix: '₩ ',
          ),
        ),
        if (error.value != null) ...[
          const SizedBox(height: AppSpacing.sm),
          InlineErrorText(error.value!),
        ],
        const SizedBox(height: AppSpacing.lg),
        AppFillButton(
          label: 'common.save'.tr(),
          onPressed: busy.value ? null : () => run(save),
        ),
        if (editing != null)
          TextButton(
            onPressed: busy.value ? null : delete,
            child: Text('settings.asset_delete'.tr()),
          ),
      ],
    );
  }
}
