import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:money_diary/core/themes/app_colors.dart';
import 'package:money_diary/core/themes/app_spacing.dart';
import 'package:money_diary/core/themes/app_typography.dart';
import 'package:money_diary/features/entry/models/entry_form_error.dart';
import 'package:money_diary/features/entry/widgets/amount_input_card.dart';
import 'package:money_diary/features/entry/widgets/asset_picker_tile.dart';
import 'package:money_diary/features/entry/widgets/category_add_sheet.dart';
import 'package:money_diary/features/entry/widgets/entry_section_card.dart';
import 'package:money_diary/features/entry/widgets/entry_type_segment.dart';
import 'package:money_diary/shared/controllers/ledger_controller.dart';
import 'package:money_diary/shared/controllers/today_controller.dart';
import 'package:money_diary/shared/models/ledger_category.dart';
import 'package:money_diary/shared/models/ledger_entry.dart';
import 'package:money_diary/shared/util/ledger_calculator.dart';
import 'package:money_diary/shared/util/ledger_labels.dart';
import 'package:money_diary/shared/util/won_format.dart';
import 'package:money_diary/shared/util/won_input.dart';
import 'package:money_diary/shared/widgets/app_content_width.dart';
import 'package:money_diary/shared/widgets/app_fill_button.dart';
import 'package:money_diary/shared/widgets/app_filter_chip.dart';
import 'package:money_diary/shared/widgets/app_sheet.dart';
import 'package:money_diary/shared/widgets/app_tap_row.dart';
import 'package:money_diary/shared/widgets/asset_edit_sheet.dart';
import 'package:money_diary/shared/widgets/inline_error_text.dart';

/// 거래 입력 — 지출·수입·이체 한 건을 적어 저장합니다. [entry]를 주면 그 거래를 고칩니다.
class EntryScreen extends HookConsumerWidget {
  const EntryScreen({
    this.initialType = EntryType.expense,
    this.entry,
    super.key,
  });

  /// 처음 골라져 있는 거래 종류
  final EntryType initialType;

  /// 고칠 거래. null이면 새 거래를 만듭니다.
  final LedgerEntry? entry;

  /// 아래에서 올라오는 전체 화면으로 여는 route
  static Route<void> route({
    EntryType type = EntryType.expense,
    LedgerEntry? entry,
  }) => MaterialPageRoute(
    fullscreenDialog: true,
    builder: (_) => EntryScreen(initialType: type, entry: entry),
  );

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = context.colors;
    final editing = entry;
    final type = useState(editing?.type ?? initialType);
    final amount = useTextEditingController(
      text: editing == null ? null : formatWon(editing.amount),
    );
    final title = useTextEditingController(text: editing?.title);
    final memo = useTextEditingController(text: editing?.memo);
    final occurredAt = useState<DateTime>(
      editing?.occurredAt ?? ref.read(todayProvider),
    );
    final assetId = useState(editing?.assetId);
    final toAssetId = useState(editing?.toAssetId);
    final category = useState(editing?.category ?? LedgerCategory.food);
    final projectId = useState(editing?.projectId);
    final recurring = useState(editing?.isRecurring ?? false);
    final errors = useState(const <EntryFormError>{});
    final saving = useState(false);
    final saveFailed = useState(false);

    final book = ref.watch(ledgerProvider).value;
    if (book == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    final isTransfer = type.value == EntryType.transfer;
    final accent = entryTypeColor(colors, type.value);
    final asset = book.assetById(assetId.value) ?? book.assets.firstOrNull;
    // 보내는 자산과 같은 자산으로는 보낼 수 없어, 같으면 고르지 않은 것으로 봅니다.
    final toAsset = toAssetId.value == asset?.id
        ? null
        : book.assetById(toAssetId.value);
    final receivableAssets = [
      for (final other in book.assets)
        if (other.id != asset?.id) other,
    ];
    final editingCategory = editing?.category;
    final categories = [
      ...book.categoriesOf(type.value),
      // 고치는 거래의 카테고리가 지워졌어도 저장하면서 바뀌지 않게 계속 보여 줍니다.
      if (editingCategory != null &&
          editingCategory.type == type.value &&
          !book.categoriesOf(type.value).contains(editingCategory))
        editingCategory,
    ];
    // 이체에는 카테고리가 없습니다.
    final selectedCategory = categories.isEmpty
        ? null
        : categories.contains(category.value)
        ? category.value
        : categories.first;

    Future<void> addCategory() async {
      final added = await showAppSheet<LedgerCategory>(
        context,
        title: 'entry.category_add_title.${type.value.name}'.tr(),
        child: CategoryAddSheet(type: type.value),
      );
      if (added != null) {
        category.value = added;
      }
    }

    Future<void> deleteCategory(LedgerCategory item) async {
      final confirmed = await confirmDelete(
        context,
        message: 'entry.category_delete_confirm'.tr(args: [item.label]),
        confirmLabel: 'common.delete'.tr(),
        cancelLabel: 'common.cancel'.tr(),
      );
      if (confirmed) {
        await ref.read(ledgerProvider.notifier).deleteCategory(item.id);
      }
    }

    final today = ref.watch(todayProvider);
    // 날짜를 그대로 두고 고칠 때는 처음 반복을 건 날을 지킵니다.
    final recurringDay =
        editing != null &&
            DateUtils.isSameDay(editing.occurredAt, occurredAt.value)
        ? editing.recurringDay ?? occurredAt.value.day
        : occurredAt.value.day;
    // 보관한 프로젝트는 새로 붙일 수 없습니다. 이미 붙어 있던 거래를 고칠 때만 보여 줍니다.
    final taggableProjects = [
      for (final project in book.projects)
        if (!project.isArchived || project.id == projectId.value) project,
    ];

    void moveDay(int daysAgo) {
      final at = occurredAt.value;
      occurredAt.value = DateTime(
        today.year,
        today.month,
        today.day - daysAgo,
        at.hour,
        at.minute,
      );
    }

    Future<void> pickDateTime() async {
      final at = occurredAt.value;
      final date = await showDatePicker(
        context: context,
        initialDate: at,
        firstDate: DateTime(today.year - 10),
        lastDate: DateTime(today.year + 1, 12, 31),
      );
      if (date == null || !context.mounted) {
        return;
      }
      final time = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.fromDateTime(at),
      );
      occurredAt.value = DateTime(
        date.year,
        date.month,
        date.day,
        time?.hour ?? at.hour,
        time?.minute ?? at.minute,
      );
    }

    Future<void> save({required bool keepAdding}) async {
      if (saving.value) {
        return;
      }
      final found = validateEntry(
        type: type.value,
        amount: parseWon(amount.text),
        assetId: asset?.id,
        toAssetId: toAsset?.id,
      );
      errors.value = found;
      if (found.isNotEmpty) {
        return;
      }
      final name = title.text.trim();
      final draft = LedgerEntry(
        id: editing?.id ?? '${DateTime.now().microsecondsSinceEpoch}',
        type: type.value,
        amount: parseWon(amount.text),
        title: name.isNotEmpty
            ? name
            : isTransfer
            ? '${asset!.name} → ${toAsset!.name}'
            : selectedCategory?.label ?? '',
        occurredAt: occurredAt.value,
        assetId: asset!.id,
        toAssetId: isTransfer ? toAsset!.id : null,
        category: isTransfer ? null : selectedCategory,
        // 세부 분류는 이 화면에서 고치지 않으므로 카테고리가 그대로일 때만 남깁니다.
        detail:
            selectedCategory != null && selectedCategory == editing?.category
            ? editing?.detail
            : null,
        projectId: isTransfer ? null : projectId.value,
        memo: memo.text.trim().isEmpty ? null : memo.text.trim(),
        isRecurring: recurring.value,
        recurringDay: recurring.value ? recurringDay : null,
        recurrenceHandled:
            recurring.value && (editing?.recurrenceHandled ?? false),
      );
      saving.value = true;
      saveFailed.value = false;
      try {
        final controller = ref.read(ledgerProvider.notifier);
        await (editing == null
            ? controller.addEntry(draft)
            : controller.updateEntry(draft));
        if (!context.mounted) {
          return;
        }
        if (keepAdding) {
          amount.clear();
          title.clear();
          memo.clear();
        } else {
          Navigator.of(context).pop();
        }
      } on Object {
        if (context.mounted) {
          saveFailed.value = true;
        }
      } finally {
        if (context.mounted) {
          saving.value = false;
        }
      }
    }

    Future<void> delete() async {
      final confirmed = await confirmDelete(
        context,
        message: 'entry.delete_confirm'.tr(),
        confirmLabel: 'common.delete'.tr(),
        cancelLabel: 'common.cancel'.tr(),
      );
      if (!confirmed || saving.value) {
        return;
      }
      saving.value = true;
      saveFailed.value = false;
      try {
        await ref.read(ledgerProvider.notifier).deleteEntry(editing!);
        if (context.mounted) {
          Navigator.of(context).pop();
        }
      } on Object {
        if (context.mounted) {
          saving.value = false;
          saveFailed.value = true;
        }
      }
    }

    InputDecoration field(String hint) => InputDecoration(
      hintText: hint,
      filled: true,
      fillColor: colors.surfaceLow,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppRadius.md),
        borderSide: BorderSide.none,
      ),
    );

    return Scaffold(
      appBar: AppBar(
        leadingWidth: 72,
        leading: TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(
            'entry.cancel'.tr(),
            style: AppTypography.headlineSm.copyWith(color: colors.textPrimary),
          ),
        ),
        centerTitle: true,
        title: Text(
          editing == null ? 'entry.title'.tr() : 'entry.title_edit'.tr(),
          style: AppTypography.headlineSm.copyWith(color: colors.textPrimary),
        ),
      ),
      body: AppContentWidth(
        child: ListView(
          padding: const EdgeInsets.all(AppSpacing.gutter),
          children: [
            EntryTypeSegment(
              selected: type.value,
              onChanged: (value) {
                type.value = value;
                errors.value = const {};
              },
            ),
            const SizedBox(height: AppSpacing.md),
            AmountInputCard(
              controller: amount,
              label: 'entry.amount_label.${type.value.name}'.tr(),
              color: isTransfer ? colors.textPrimary : accent,
              errorText: errors.value.contains(EntryFormError.amount)
                  ? 'entry.error.amount'.tr()
                  : null,
            ),
            const SizedBox(height: AppSpacing.md),
            EntrySectionCard(
              icon: Icons.calendar_today_outlined,
              label: 'entry.date'.tr(),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  ActionChip(
                    label: Text('common.yesterday'.tr()),
                    onPressed: () => moveDay(1),
                  ),
                  const SizedBox(width: AppSpacing.xs),
                  ActionChip(
                    label: Text('common.today'.tr()),
                    onPressed: () => moveDay(0),
                  ),
                ],
              ),
              child: InkWell(
                onTap: pickDateTime,
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        '${dottedDateLabel(occurredAt.value)} '
                        '(${weekdayShortLabel(occurredAt.value)}) '
                        '${timeLabel(occurredAt.value)}',
                        style: AppTypography.bodyLg.copyWith(
                          color: colors.textPrimary,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    Icon(Icons.schedule, size: 20, color: colors.textSecondary),
                  ],
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.xs),
            AppTapRow(
              onTap: () => recurring.value = !recurring.value,
              borderRadius: BorderRadius.circular(AppRadius.md),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm),
                child: Row(
                  children: [
                    Checkbox(
                      value: recurring.value,
                      onChanged: (value) => recurring.value = value ?? false,
                    ),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'entry.recurring'.tr(),
                            style: AppTypography.bodyMd.copyWith(
                              color: colors.textPrimary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          if (recurring.value)
                            Text(
                              editing?.recurrenceHandled ?? false
                                  ? 'entry.recurring_handled'.tr()
                                  : 'entry.recurring_next'.tr(
                                      args: [
                                        dottedDateLabel(
                                          nextMonthlyDate(
                                            occurredAt.value,
                                            recurringDay,
                                          ),
                                        ),
                                      ],
                                    ),
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
            const SizedBox(height: AppSpacing.md),
            EntrySectionCard(
              icon: Icons.credit_card,
              label: 'entry.asset_label.${type.value.name}'.tr(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  AssetPickerTile(
                    assets: book.assets,
                    selected: asset,
                    onChanged: (value) => assetId.value = value.id,
                  ),
                  if (book.assets.isEmpty)
                    Text(
                      'entry.asset_empty'.tr(),
                      style: AppTypography.bodySm.copyWith(
                        color: colors.textSecondary,
                      ),
                    ),
                  if (errors.value.contains(EntryFormError.asset))
                    InlineErrorText('entry.error.asset'.tr()),
                  if (isTransfer) ...[
                    const Divider(height: AppSpacing.xl),
                    Text(
                      'entry.to_asset'.tr(),
                      style: AppTypography.labelMd.copyWith(
                        color: colors.textSecondary,
                      ),
                    ),
                    if (receivableAssets.isEmpty) ...[
                      const SizedBox(height: AppSpacing.sm),
                      Text(
                        'entry.transfer_need_asset'.tr(),
                        style: AppTypography.bodyMd.copyWith(
                          color: colors.textPrimary,
                        ),
                      ),
                      Align(
                        alignment: Alignment.centerLeft,
                        child: TextButton.icon(
                          onPressed: () => showAppSheet<void>(
                            context,
                            title: 'settings.asset_add'.tr(),
                            child: const AssetEditSheet(),
                          ),
                          icon: const Icon(Icons.add, size: 18),
                          label: Text('settings.asset_add'.tr()),
                        ),
                      ),
                    ] else
                      AssetPickerTile(
                        assets: receivableAssets,
                        selected: toAsset,
                        onChanged: (value) => toAssetId.value = value.id,
                      ),
                    if (errors.value.contains(EntryFormError.toAsset))
                      InlineErrorText('entry.error.to_asset'.tr())
                    else if (errors.value.contains(EntryFormError.sameAsset))
                      InlineErrorText('entry.error.same_asset'.tr()),
                    const SizedBox(height: AppSpacing.sm),
                    Text(
                      'entry.transfer_notice'.tr(),
                      style: AppTypography.bodySm.copyWith(
                        color: colors.textSecondary,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            if (!isTransfer) ...[
              const SizedBox(height: AppSpacing.md),
              EntrySectionCard(
                icon: Icons.category_outlined,
                label: 'entry.category_label.${type.value.name}'.tr(),
                child: GridView.count(
                  crossAxisCount: 3,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  mainAxisSpacing: AppSpacing.xs,
                  crossAxisSpacing: AppSpacing.xs,
                  childAspectRatio: 2.6,
                  children: [
                    for (final item in categories)
                      Semantics(
                        button: true,
                        selected: item == selectedCategory,
                        child: Material(
                          color: item == selectedCategory
                              ? (type.value == EntryType.income
                                    ? colors.incomeTint
                                    : colors.expenseTint)
                              : colors.surfaceContainer,
                          borderRadius: BorderRadius.circular(AppRadius.md),
                          child: InkWell(
                            onTap: () => category.value = item,
                            onLongPress: item.isCustom
                                ? () => deleteCategory(item)
                                : null,
                            borderRadius: BorderRadius.circular(AppRadius.md),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  item.icon,
                                  size: 18,
                                  color: item == selectedCategory
                                      ? accent
                                      : colors.textSecondary,
                                ),
                                const SizedBox(width: 6),
                                Flexible(
                                  child: Text(
                                    item.label,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: AppTypography.labelMd.copyWith(
                                      color: colors.textPrimary,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    Material(
                      color: colors.surface,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(AppRadius.md),
                        side: BorderSide(color: colors.divider),
                      ),
                      child: InkWell(
                        onTap: addCategory,
                        borderRadius: BorderRadius.circular(AppRadius.md),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.add, size: 18, color: colors.primary),
                            const SizedBox(width: AppSpacing.xs),
                            Text(
                              'entry.category_add'.tr(),
                              style: AppTypography.labelMd.copyWith(
                                color: colors.primary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              if (taggableProjects.isNotEmpty) ...[
                const SizedBox(height: AppSpacing.md),
                EntrySectionCard(
                  icon: Icons.folder_outlined,
                  label: 'entry.project'.tr(),
                  trailing: Text(
                    'entry.optional'.tr(),
                    style: AppTypography.labelSm.copyWith(
                      color: colors.primary,
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Wrap(
                        spacing: AppSpacing.sm,
                        runSpacing: AppSpacing.sm,
                        children: [
                          for (final project in taggableProjects)
                            AppFilterChip(
                              label: project.name,
                              icon: Icons.flight_takeoff,
                              selected: project.id == projectId.value,
                              onTap: () => projectId.value =
                                  project.id == projectId.value
                                  ? null
                                  : project.id,
                            ),
                        ],
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      Text(
                        'entry.project_hint'.tr(),
                        style: AppTypography.bodySm.copyWith(
                          color: colors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
            const SizedBox(height: AppSpacing.md),
            EntrySectionCard(
              icon: Icons.edit_note,
              label: 'entry.memo'.tr(),
              child: Column(
                children: [
                  TextField(
                    controller: title,
                    textInputAction: TextInputAction.next,
                    decoration: field('entry.title_hint'.tr()),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  TextField(
                    controller: memo,
                    decoration: field('entry.memo_hint'.tr()),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.gutter,
            AppSpacing.sm,
            AppSpacing.gutter,
            AppSpacing.md,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (saveFailed.value) ...[
                InlineErrorText('entry.error.save'.tr()),
                const SizedBox(height: AppSpacing.sm),
              ],
              Row(
                children: [
                  Expanded(
                    child: AppFillButton(
                      label: editing == null
                          ? 'entry.save_and_continue'.tr()
                          : 'common.delete'.tr(),
                      variant: AppFillVariant.tonal,
                      onPressed: saving.value
                          ? null
                          : editing == null
                          ? () => save(keepAdding: true)
                          : delete,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: AppFillButton(
                      label: 'entry.save'.tr(),
                      icon: Icons.check,
                      onPressed: saving.value
                          ? null
                          : () => save(keepAdding: false),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
