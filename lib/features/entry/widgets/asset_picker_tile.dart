import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:money_diary/core/themes/app_colors.dart';
import 'package:money_diary/core/themes/app_layout.dart';
import 'package:money_diary/core/themes/app_spacing.dart';
import 'package:money_diary/core/themes/app_typography.dart';
import 'package:money_diary/shared/models/asset_account.dart';
import 'package:money_diary/shared/util/ledger_labels.dart';
import 'package:money_diary/shared/widgets/app_tap_row.dart';

/// 자산 한 줄의 보조 설명 (종류 · 잔액 또는 결제 예정 금액)
String assetCaption(AssetAccount asset) => [
  asset.kind.label,
  if (asset.kind.countsTowardNetWorth)
    'entry.asset_balance'.tr(args: [wonLabel(asset.balance)])
  else
    'entry.asset_due'.tr(args: [wonLabel(asset.balance)]),
].join(' · ');

/// 고른 자산을 보여 주고, 누르면 자산 목록 시트를 여는 줄
class AssetPickerTile extends StatelessWidget {
  const AssetPickerTile({
    required this.assets,
    required this.selected,
    required this.onChanged,
    super.key,
  });

  final List<AssetAccount> assets;

  final AssetAccount? selected;

  final ValueChanged<AssetAccount> onChanged;

  Future<void> _pick(BuildContext context) async {
    final picked = await showModalBottomSheet<AssetAccount>(
      context: context,
      showDragHandle: true,
      backgroundColor: context.colors.surface,
      constraints: const BoxConstraints(maxWidth: AppLayout.sheetMaxWidth),
      builder: (context) => SafeArea(
        child: ListView(
          shrinkWrap: true,
          children: [
            for (final asset in assets)
              AppTapRow(
                onTap: () => Navigator.of(context).pop(asset),
                child: _AssetRow(asset: asset),
              ),
          ],
        ),
      ),
    );
    if (picked != null) {
      onChanged(picked);
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final asset = selected;
    return AppTapRow(
      onTap: () => _pick(context),
      borderRadius: BorderRadius.circular(AppRadius.md),
      child: Row(
        children: [
          Expanded(
            child: asset == null
                ? Padding(
                    padding: const EdgeInsets.symmetric(
                      vertical: AppSpacing.md,
                    ),
                    child: Text(
                      'entry.asset_placeholder'.tr(),
                      style: AppTypography.bodyLg.copyWith(
                        color: colors.textSecondary,
                      ),
                    ),
                  )
                : _AssetRow(asset: asset, dense: true),
          ),
          Text(
            'entry.asset_change'.tr(),
            style: AppTypography.labelMd.copyWith(color: colors.primary),
          ),
          Icon(Icons.chevron_right, size: 20, color: colors.primary),
        ],
      ),
    );
  }
}

class _AssetRow extends StatelessWidget {
  const _AssetRow({required this.asset, this.dense = false});

  final AssetAccount asset;

  /// 카드 안에 넣을 때 좌우 여백을 뺍니다.
  final bool dense;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: dense ? 0 : AppSpacing.lg,
        vertical: AppSpacing.sm,
      ),
      child: Row(
        children: [
          DecoratedBox(
            decoration: BoxDecoration(
              color: colors.surfaceContainer,
              borderRadius: BorderRadius.circular(AppRadius.md),
            ),
            child: SizedBox.square(
              dimension: 44,
              child: Icon(asset.kind.icon, size: 22, color: colors.primary),
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  asset.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTypography.headlineSm.copyWith(
                    color: colors.textPrimary,
                  ),
                ),
                Text(
                  assetCaption(asset),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTypography.bodySm.copyWith(
                    color: colors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
