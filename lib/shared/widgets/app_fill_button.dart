import 'package:flutter/material.dart';
import 'package:money_diary/core/themes/app_colors.dart';
import 'package:money_diary/core/themes/app_spacing.dart';
import 'package:money_diary/core/themes/app_typography.dart';

/// [AppFillButton]의 색상 variant.
enum AppFillVariant {
  /// primary 색 채움 — 화면의 주 동작
  primary,

  /// 옅은 바탕 — 주 동작 옆의 보조 동작
  tonal,
}

/// 높이 52의 채움 버튼.
///
/// [onPressed]가 null이면 비활성으로 그립니다.
class AppFillButton extends StatelessWidget {
  const AppFillButton({
    required this.label,
    this.variant = AppFillVariant.primary,
    this.icon,
    this.onPressed,
    super.key,
  });

  /// 버튼에 표시할 텍스트
  final String label;

  /// 색상 variant
  final AppFillVariant variant;

  /// 라벨 앞 아이콘 (선택)
  final IconData? icon;

  /// 탭 콜백
  final VoidCallback? onPressed;

  static const _height = 52.0;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final enabled = onPressed != null;
    final background = !enabled
        ? colors.surfaceHighest
        : switch (variant) {
            AppFillVariant.primary => colors.primary,
            AppFillVariant.tonal => colors.surfaceHigh,
          };
    final foreground = !enabled
        ? colors.outline
        : switch (variant) {
            AppFillVariant.primary => colors.onPrimary,
            AppFillVariant.tonal => colors.textPrimary,
          };
    final radius = BorderRadius.circular(AppRadius.lg);

    return Material(
      color: background,
      borderRadius: radius,
      child: InkWell(
        onTap: onPressed,
        borderRadius: radius,
        child: SizedBox(
          height: _height,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (icon != null) ...[
                  Icon(icon, color: foreground, size: 20),
                  const SizedBox(width: AppSpacing.xs),
                ],
                Flexible(
                  child: Text(
                    label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTypography.headlineSm.copyWith(color: foreground),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
