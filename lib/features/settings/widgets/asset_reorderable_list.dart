import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:money_diary/core/themes/app_colors.dart';
import 'package:money_diary/core/themes/app_layout.dart';
import 'package:money_diary/core/themes/app_palette.dart';
import 'package:money_diary/core/themes/app_spacing.dart';
import 'package:money_diary/core/themes/app_typography.dart';
import 'package:money_diary/shared/models/asset_account.dart';
import 'package:money_diary/shared/util/ledger_labels.dart';
import 'package:money_diary/shared/widgets/app_tap_row.dart';

/// 손잡이를 끌어 순서를 바꾸고 왼쪽으로 밀어 지우는 자산 목록 카드 (sliver)
///
/// 끄는 동안 화면 끝에서 바깥 스크롤이 따라 움직이도록, 스크롤 안에 sliver로 넣습니다.
class AssetReorderableList extends StatelessWidget {
  const AssetReorderableList({
    required this.assets,
    required this.onTap,
    required this.onDelete,
    required this.onReorder,
    super.key,
  });

  final List<AssetAccount> assets;

  final ValueChanged<AssetAccount> onTap;

  /// 줄을 왼쪽으로 밀었을 때 불립니다. 지울지 묻는 것은 받는 쪽이 합니다.
  final ValueChanged<AssetAccount> onDelete;

  /// 줄을 옮겼을 때 불립니다. 원래 자리와 옮긴 뒤의 자리를 받습니다.
  final void Function(int from, int to) onReorder;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return DecoratedSliver(
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        boxShadow: const [
          BoxShadow(
            color: AppPalette.shadow,
            blurRadius: 4,
            offset: Offset(0, 1),
          ),
        ],
      ),
      sliver: SliverReorderableList(
        itemCount: assets.length,
        // 아래로 옮길 때는 빠진 자리만큼 한 칸 큰 값이 옵니다.
        onReorder: (from, to) => onReorder(from, to > from ? to - 1 : to),
        proxyDecorator: (child, _, _) => Material(
          color: colors.surface,
          elevation: 4,
          borderRadius: BorderRadius.circular(AppRadius.md),
          clipBehavior: Clip.antiAlias,
          child: child,
        ),
        itemBuilder: (context, index) {
          final asset = assets[index];
          return Column(
            key: ValueKey(asset.id),
            mainAxisSize: MainAxisSize.min,
            children: [
              if (index > 0)
                Divider(
                  height: 1,
                  color: colors.divider.withValues(alpha: 0.3),
                ),
              ClipRRect(
                borderRadius: BorderRadius.vertical(
                  top: index == 0
                      ? const Radius.circular(AppRadius.lg)
                      : Radius.zero,
                  bottom: index == assets.length - 1
                      ? const Radius.circular(AppRadius.lg)
                      : Radius.zero,
                ),
                child: Dismissible(
                  key: ValueKey('swipe-${asset.id}'),
                  direction: DismissDirection.endToStart,
                  // 지울지는 확인 창에서 정하므로 줄은 언제나 제자리로 돌려놓습니다.
                  confirmDismiss: (_) async {
                    onDelete(asset);
                    return false;
                  },
                  background: ColoredBox(
                    color: colors.error,
                    child: Align(
                      alignment: Alignment.centerRight,
                      child: Padding(
                        padding: const EdgeInsets.only(right: AppSpacing.lg),
                        child: Icon(
                          Icons.delete_outline,
                          color: colors.onPrimary,
                        ),
                      ),
                    ),
                  ),
                  child: ColoredBox(
                    color: colors.surface,
                    child: AppTapRow(
                      onTap: () => onTap(asset),
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(
                          AppSpacing.lg,
                          AppSpacing.md,
                          AppSpacing.xs,
                          AppSpacing.md,
                        ),
                        child: Row(
                          children: [
                            DecoratedBox(
                              decoration: BoxDecoration(
                                color: colors.surfaceContainer,
                                borderRadius: BorderRadius.circular(
                                  AppRadius.md,
                                ),
                              ),
                              child: SizedBox.square(
                                dimension: 40,
                                child: Icon(
                                  asset.kind.icon,
                                  size: 20,
                                  color: colors.primary,
                                ),
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
                                    style: AppTypography.bodyLg.copyWith(
                                      color: colors.textPrimary,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  Text(
                                    asset.kind.countsTowardNetWorth
                                        ? asset.kind.label
                                        : 'settings.asset_due_caption'.tr(
                                            args: [asset.kind.label],
                                          ),
                                    style: AppTypography.bodySm.copyWith(
                                      color: colors.textSecondary,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Text(
                              wonLabel(asset.balance),
                              style: AppTypography.amountMd.copyWith(
                                color: colors.textPrimary,
                              ),
                            ),
                            ReorderableDragStartListener(
                              index: index,
                              child: Semantics(
                                label: 'settings.asset_reorder'.tr(),
                                child: SizedBox.square(
                                  dimension: AppLayout.minTouchTarget,
                                  child: Icon(
                                    Icons.drag_handle,
                                    size: 20,
                                    color: colors.textSecondary,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
