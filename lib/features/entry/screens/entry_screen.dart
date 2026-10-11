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
import 'package:money_diary/features/entry/widgets/entry_section_card.dart';
import 'package:money_diary/features/entry/widgets/entry_type_segment.dart';
import 'package:money_diary/shared/controllers/ledger_controller.dart';
import 'package:money_diary/shared/controllers/today_controller.dart';
import 'package:money_diary/shared/models/ledger_entry.dart';
import 'package:money_diary/shared/util/ledger_labels.dart';
import 'package:money_diary/shared/widgets/app_content_width.dart';
import 'package:money_diary/shared/widgets/app_fill_button.dart';
import 'package:money_diary/shared/widgets/app_filter_chip.dart';
import 'package:money_diary/shared/widgets/inline_error_text.dart';

/// 거래 입력 — 지출·수입·이체 한 건을 적어 저장합니다.
class EntryScreen extends HookConsumerWidget {
  const EntryScreen({this.initialType = EntryType.expense, super.key});

  /// 처음 골라져 있는 거래 종류
  final EntryType initialType;

  /// 아래에서 올라오는 전체 화면으로 여는 route
  static Route<void> route([EntryType type = EntryType.expense]) =>
      MaterialPageRoute(
        fullscreenDialog: true,
        builder: (_) => EntryScreen(initialType: type),
      );

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = context.colors;
    final type = useState(initialType);
    final amount = useTextEditingController();
    final title = useTextEditingController();
    final memo = useTextEditingController();
    final occurredAt = useState(ref.read(todayProvider));
    final assetId = useState<String?>(null);
    final toAssetId = useState<String?>(null);
    final category = useState(LedgerCategory.food);
    final projectId = useState<String?>(null);
    final recurring = useState(false);
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
    final toAsset = book.assetById(toAssetId.value);
    final categories = type.value == EntryType.income
        ? LedgerCategory.incomeValues
        : LedgerCategory.expenseValues;
    final selectedCategory = categories.contains(category.value)
        ? category.value
        : categories.first;
    final today = ref.watch(todayProvider);

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
      final entry = LedgerEntry(
        id: '${DateTime.now().microsecondsSinceEpoch}',
        type: type.value,
        amount: parseWon(amount.text),
        title: name.isNotEmpty
            ? name
            : isTransfer
            ? '${asset!.name} → ${toAsset!.name}'
            : selectedCategory.label,
        occurredAt: occurredAt.value,
        assetId: asset!.id,
        toAssetId: isTransfer ? toAsset!.id : null,
        category: isTransfer ? null : selectedCategory,
        projectId: isTransfer ? null : projectId.value,
        memo: memo.text.trim().isEmpty ? null : memo.text.trim(),
        isRecurring: recurring.value,
      );
      saving.value = true;
      saveFailed.value = false;
      try {
        await ref.read(ledgerProvider.notifier).addEntry(entry);
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
          'entry.title'.tr(),
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
                    AssetPickerTile(
                      assets: book.assets,
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
                  ],
                ),
              ),
              if (book.projects.isNotEmpty) ...[
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
                          for (final project in book.projects)
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
            const SizedBox(height: AppSpacing.md),
            EntrySectionCard(
              icon: Icons.event_repeat,
              label: 'entry.recurring'.tr(),
              trailing: Switch(
                value: recurring.value,
                onChanged: (value) => recurring.value = value,
              ),
              child: Text(
                recurring.value
                    ? 'entry.recurring_on'.tr()
                    : 'entry.recurring_off'.tr(),
                style: AppTypography.bodySm.copyWith(
                  color: colors.textSecondary,
                ),
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
                      label: 'entry.save_and_continue'.tr(),
                      variant: AppFillVariant.tonal,
                      onPressed: saving.value
                          ? null
                          : () => save(keepAdding: true),
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
