import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:money_diary/core/themes/app_colors.dart';
import 'package:money_diary/core/themes/app_spacing.dart';
import 'package:money_diary/core/themes/app_typography.dart';
import 'package:money_diary/shared/controllers/ledger_controller.dart';
import 'package:money_diary/shared/controllers/today_controller.dart';
import 'package:money_diary/shared/models/project.dart';
import 'package:money_diary/shared/util/ledger_labels.dart';
import 'package:money_diary/shared/util/won_format.dart';
import 'package:money_diary/shared/util/won_input.dart';
import 'package:money_diary/shared/widgets/app_fill_button.dart';
import 'package:money_diary/shared/widgets/app_sheet.dart';
import 'package:money_diary/shared/widgets/app_tap_row.dart';
import 'package:money_diary/shared/widgets/inline_error_text.dart';

/// 프로젝트를 더하거나 고치는 시트. [project]가 null이면 새로 만듭니다.
class ProjectEditSheet extends HookConsumerWidget {
  const ProjectEditSheet({this.project, super.key});

  final Project? project;

  /// 새 프로젝트의 기본 기간(일)
  static const _defaultDays = 7;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = context.colors;
    final editing = project;
    final today = ref.watch(todayProvider);
    final name = useTextEditingController(text: editing?.name);
    final budget = useTextEditingController(
      text: editing == null || editing.budget == 0
          ? ''
          : formatWon(editing.budget),
    );
    final period = useState(
      DateTimeRange(
        start:
            editing?.startDate ?? DateTime(today.year, today.month, today.day),
        end:
            editing?.endDate ??
            DateTime(today.year, today.month, today.day + _defaultDays),
      ),
    );
    final error = useState<String?>(null);
    final busy = useState(false);

    Future<void> run(Future<void> Function() action) async {
      if (busy.value) {
        return;
      }
      busy.value = true;
      try {
        await action();
        if (context.mounted) {
          Navigator.of(context).pop();
        }
      } on Object {
        if (context.mounted) {
          busy.value = false;
          error.value = 'project.save_failed'.tr();
        }
      }
    }

    Future<void> pickPeriod() async {
      final picked = await showDateRangePicker(
        context: context,
        initialDateRange: period.value,
        firstDate: DateTime(today.year - 10),
        lastDate: DateTime(today.year + 10, 12, 31),
      );
      if (picked != null) {
        period.value = picked;
      }
    }

    void save() {
      if (name.text.trim().isEmpty) {
        error.value = 'project.name_required'.tr();
        return;
      }
      run(
        () => ref
            .read(ledgerProvider.notifier)
            .saveProject(
              Project(
                id:
                    editing?.id ??
                    'project-${DateTime.now().microsecondsSinceEpoch}',
                name: name.text.trim(),
                startDate: period.value.start,
                endDate: period.value.end,
                budget: parseWon(budget.text),
              ),
            ),
      );
    }

    Future<void> delete() async {
      final confirmed = await confirmDelete(
        context,
        message: 'project.delete_confirm'.tr(args: [editing!.name]),
        confirmLabel: 'common.delete'.tr(),
        cancelLabel: 'common.cancel'.tr(),
      );
      if (confirmed) {
        await run(
          () => ref.read(ledgerProvider.notifier).deleteProject(editing.id),
        );
      }
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        TextField(
          controller: name,
          textInputAction: TextInputAction.next,
          decoration: appInputDecoration(context, label: 'project.name'.tr()),
        ),
        const SizedBox(height: AppSpacing.md),
        TextField(
          controller: budget,
          keyboardType: TextInputType.number,
          inputFormatters: [WonInputFormatter()],
          decoration: appInputDecoration(
            context,
            label: 'project.budget'.tr(),
            prefix: '₩ ',
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        DecoratedBox(
          decoration: BoxDecoration(
            color: colors.surfaceLow,
            borderRadius: BorderRadius.circular(AppRadius.md),
          ),
          child: AppTapRow(
            onTap: pickPeriod,
            borderRadius: BorderRadius.circular(AppRadius.md),
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: Row(
                children: [
                  Text(
                    'project.period'.tr(),
                    style: AppTypography.labelMd.copyWith(
                      color: colors.textSecondary,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: Text(
                      '${dottedDateLabel(period.value.start)} ~ '
                      '${dottedDateLabel(period.value.end)}',
                      textAlign: TextAlign.end,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTypography.bodyMd.copyWith(
                        color: colors.textPrimary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Icon(
                    Icons.calendar_today_outlined,
                    size: 16,
                    color: colors.textSecondary,
                  ),
                ],
              ),
            ),
          ),
        ),
        if (error.value != null) ...[
          const SizedBox(height: AppSpacing.sm),
          InlineErrorText(error.value!),
        ],
        const SizedBox(height: AppSpacing.lg),
        AppFillButton(
          label: 'common.save'.tr(),
          onPressed: busy.value ? null : save,
        ),
        if (editing != null)
          TextButton(
            onPressed: busy.value ? null : delete,
            child: Text('project.delete'.tr()),
          ),
      ],
    );
  }
}
