import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:money_diary/shared/controllers/ledger_controller.dart';
import 'package:money_diary/shared/models/ledger_entry.dart';
import 'package:money_diary/shared/util/ledger_labels.dart';
import 'package:money_diary/shared/widgets/app_sheet.dart';

/// 거래 줄을 꾹 눌렀을 때: 지울지 묻고, 지우면 자산 잔액도 되돌립니다.
Future<void> confirmDeleteEntry(
  BuildContext context,
  WidgetRef ref,
  LedgerEntry entry,
) async {
  final confirmed = await confirmDelete(
    context,
    message: 'ledger.delete_confirm'.tr(
      namedArgs: {
        'title': entry.title,
        'amount': signedWonLabel(entry.type, entry.amount),
      },
    ),
    confirmLabel: 'common.delete'.tr(),
    cancelLabel: 'common.cancel'.tr(),
  );
  if (!confirmed) {
    return;
  }
  try {
    await ref.read(ledgerProvider.notifier).deleteEntry(entry);
  } on Object {
    if (context.mounted) {
      await showNotice(
        context,
        message: 'common.delete_failed'.tr(),
        closeLabel: 'common.close'.tr(),
      );
    }
  }
}
