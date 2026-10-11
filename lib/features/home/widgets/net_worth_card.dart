import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:money_diary/core/themes/app_colors.dart';
import 'package:money_diary/core/themes/app_spacing.dart';
import 'package:money_diary/core/themes/app_typography.dart';
import 'package:money_diary/shared/models/asset_account.dart';
import 'package:money_diary/shared/util/ledger_calculator.dart';
import 'package:money_diary/shared/util/ledger_labels.dart';
import 'package:money_diary/shared/util/won_format.dart';
import 'package:money_diary/shared/widgets/app_badge.dart';
import 'package:money_diary/shared/widgets/app_card.dart';

/// 총 순자산과 자산군별 합계를 보여 주는 카드
class NetWorthCard extends HookWidget {
  const NetWorthCard({required this.assets, this.monthlyChange, super.key});

  final List<AssetAccount> assets;

  /// 이번 달에 늘어난 금액(수입 − 지출). 이번 달을 보고 있지 않으면 null입니다.
  final int? monthlyChange;

  static const _hidden = '••••••';

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final hidden = useState(false);
    final total = netWorth(assets);
    final change = monthlyChange;
    final previous = change == null ? 0 : total - change;
    final groups = [
      (AssetKind.bank, colors.primary),
      (AssetKind.investment, colors.income),
      (AssetKind.cash, colors.outline),
    ];

    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                'home.net_worth'.tr(),
                style: AppTypography.labelMd.copyWith(
                  color: colors.textSecondary,
                ),
              ),
              IconButton(
                tooltip: hidden.value
                    ? 'home.show_amount'.tr()
                    : 'home.hide_amount'.tr(),
                visualDensity: VisualDensity.compact,
                iconSize: 18,
                onPressed: () => hidden.value = !hidden.value,
                icon: Icon(
                  hidden.value
                      ? Icons.visibility_off_outlined
                      : Icons.visibility_outlined,
                  color: colors.textSecondary,
                ),
              ),
              const Spacer(),
              if (change != null && previous > 0 && !hidden.value)
                Flexible(
                  flex: 4,
                  child: AppBadge(
                    'home.vs_last_month'.tr(
                      namedArgs: {
                        'amount':
                            '${change >= 0 ? '+' : '-'}${wonLabel(change.abs())}',
                        'percent':
                            '${change >= 0 ? '+' : '-'}${percentLabel(change.abs() / previous)}',
                      },
                    ),
                    icon: change >= 0 ? Icons.trending_up : Icons.trending_down,
                    background: colors.surfaceHigh,
                    foreground: colors.primary,
                  ),
                ),
            ],
          ),
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(
                '₩',
                style: AppTypography.headlineMd.copyWith(
                  color: colors.textPrimary,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(width: 6),
              Text(
                hidden.value ? _hidden : formatWon(total),
                style: AppTypography.displayCurrencyMobile.copyWith(
                  color: colors.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: [
              for (final (kind, dot) in groups)
                DecoratedBox(
                  decoration: BoxDecoration(
                    color: colors.surfaceLow,
                    borderRadius: BorderRadius.circular(AppRadius.md),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: AppSpacing.xs,
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        DecoratedBox(
                          decoration: BoxDecoration(
                            color: dot,
                            shape: BoxShape.circle,
                          ),
                          child: const SizedBox.square(dimension: 6),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          kind.label,
                          style: AppTypography.labelMd.copyWith(
                            color: colors.textSecondary,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          hidden.value
                              ? _hidden
                              : formatWon(
                                  assetTotal(
                                    assets.where((a) => a.kind == kind),
                                  ),
                                ),
                          style: AppTypography.amountMd.copyWith(
                            color: colors.textPrimary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}
