import 'package:flutter/material.dart';
import 'package:money_diary/core/themes/app_colors.dart';
import 'package:money_diary/core/themes/app_palette.dart';
import 'package:money_diary/core/themes/app_spacing.dart';

/// 화면 바탕 위에 놓이는 흰 카드
class AppCard extends StatelessWidget {
  const AppCard({
    required this.child,
    this.padding = const EdgeInsets.all(AppSpacing.xl),
    this.color,
    super.key,
  });

  final Widget child;

  final EdgeInsetsGeometry padding;

  /// 바탕색. null이면 `surface`
  final Color? color;

  @override
  Widget build(BuildContext context) => DecoratedBox(
    decoration: BoxDecoration(
      color: color ?? context.colors.surface,
      borderRadius: BorderRadius.circular(AppRadius.lg),
      boxShadow: const [
        BoxShadow(
          color: AppPalette.shadow,
          blurRadius: 4,
          offset: Offset(0, 1),
        ),
      ],
    ),
    child: ClipRRect(
      borderRadius: BorderRadius.circular(AppRadius.lg),
      child: Padding(padding: padding, child: child),
    ),
  );
}
