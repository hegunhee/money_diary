import 'package:flutter/material.dart';
import 'package:money_diary/core/themes/app_colors.dart';
import 'package:money_diary/core/themes/app_spacing.dart';

/// 예산·비중을 보여 주는 가로 진행 바
class AppProgressBar extends StatelessWidget {
  const AppProgressBar({
    required this.value,
    this.color,
    this.height = 8,
    super.key,
  });

  /// 채운 비율. 0~1 밖의 값은 잘라 그립니다.
  final double value;

  /// 채운 부분의 색. null이면 `primary`
  final Color? color;

  final double height;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return ClipRRect(
      borderRadius: BorderRadius.circular(AppRadius.full),
      child: SizedBox(
        width: double.infinity,
        height: height,
        child: ColoredBox(
          color: colors.surfaceHigh,
          child: FractionallySizedBox(
            alignment: Alignment.centerLeft,
            widthFactor: value.clamp(0, 1).toDouble(),
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: color ?? colors.primary,
                borderRadius: BorderRadius.circular(AppRadius.full),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
