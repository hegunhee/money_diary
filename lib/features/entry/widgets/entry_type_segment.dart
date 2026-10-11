import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:money_diary/core/themes/app_colors.dart';
import 'package:money_diary/core/themes/app_layout.dart';
import 'package:money_diary/core/themes/app_palette.dart';
import 'package:money_diary/core/themes/app_spacing.dart';
import 'package:money_diary/core/themes/app_typography.dart';
import 'package:money_diary/shared/models/ledger_entry.dart';

/// 거래 종류의 강조색
Color entryTypeColor(AppColors colors, EntryType type) => switch (type) {
  EntryType.expense => colors.expense,
  EntryType.income => colors.income,
  EntryType.transfer => colors.transfer,
};

/// 지출 · 수입 · 이체를 고르는 3분할 세그먼트
class EntryTypeSegment extends StatelessWidget {
  const EntryTypeSegment({
    required this.selected,
    required this.onChanged,
    super.key,
  });

  final EntryType selected;

  final ValueChanged<EntryType> onChanged;

  static IconData _icon(EntryType type) => switch (type) {
    EntryType.expense => Icons.trending_down,
    EntryType.income => Icons.trending_up,
    EntryType.transfer => Icons.sync_alt,
  };

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return DecoratedBox(
      decoration: BoxDecoration(
        color: colors.surfaceContainer,
        borderRadius: BorderRadius.circular(AppRadius.lg),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xs),
        child: Row(
          children: [
            for (final type in EntryType.values)
              Expanded(
                child: Semantics(
                  button: true,
                  selected: type == selected,
                  child: GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: () => onChanged(type),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 150),
                      height: AppLayout.minTouchTarget,
                      decoration: BoxDecoration(
                        color: type == selected ? colors.surface : null,
                        borderRadius: BorderRadius.circular(AppRadius.md),
                        boxShadow: [
                          if (type == selected)
                            const BoxShadow(
                              color: AppPalette.shadow,
                              blurRadius: 3,
                              offset: Offset(0, 1),
                            ),
                        ],
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            _icon(type),
                            size: 18,
                            color: type == selected
                                ? entryTypeColor(colors, type)
                                : colors.textSecondary,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            'entry.type.${type.name}'.tr(),
                            style: AppTypography.headlineSm.copyWith(
                              color: type == selected
                                  ? entryTypeColor(colors, type)
                                  : colors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
