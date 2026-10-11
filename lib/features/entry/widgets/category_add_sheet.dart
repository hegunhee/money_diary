import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:money_diary/core/themes/app_spacing.dart';
import 'package:money_diary/shared/controllers/ledger_controller.dart';
import 'package:money_diary/shared/models/ledger_entry.dart';
import 'package:money_diary/shared/widgets/app_fill_button.dart';
import 'package:money_diary/shared/widgets/app_sheet.dart';
import 'package:money_diary/shared/widgets/inline_error_text.dart';

/// 카테고리 이름을 받아 더하는 시트. 더한 카테고리를 돌려주며 닫힙니다.
class CategoryAddSheet extends HookConsumerWidget {
  const CategoryAddSheet({required this.type, super.key});

  /// 지출 카테고리인지 수입 카테고리인지
  final EntryType type;

  /// 카테고리 칸에 한 줄로 들어가는 이름 길이
  static const _maxLength = 12;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final name = useTextEditingController();
    final error = useState<String?>(null);
    final busy = useState(false);

    Future<void> save() async {
      final text = name.text.trim();
      if (text.isEmpty) {
        error.value = 'entry.category_name_required'.tr();
        return;
      }
      busy.value = true;
      try {
        final added = await ref
            .read(ledgerProvider.notifier)
            .addCategory(text, type);
        if (!context.mounted) {
          return;
        }
        if (added == null) {
          busy.value = false;
          error.value = 'entry.category_duplicate'.tr();
        } else {
          Navigator.of(context).pop(added);
        }
      } on Object {
        if (context.mounted) {
          busy.value = false;
          error.value = 'entry.error.save'.tr();
        }
      }
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        TextField(
          controller: name,
          autofocus: true,
          maxLength: _maxLength,
          textInputAction: TextInputAction.done,
          onSubmitted: (_) => save(),
          decoration: appInputDecoration(
            context,
            label: 'entry.category_name'.tr(),
          ),
        ),
        if (error.value != null) ...[
          InlineErrorText(error.value!),
          const SizedBox(height: AppSpacing.sm),
        ],
        const SizedBox(height: AppSpacing.sm),
        AppFillButton(
          label: 'common.save'.tr(),
          onPressed: busy.value ? null : save,
        ),
      ],
    );
  }
}
