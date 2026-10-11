import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:money_diary/core/themes/app_colors.dart';
import 'package:money_diary/core/themes/app_spacing.dart';
import 'package:money_diary/core/themes/app_typography.dart';

/// 화면 조회 실패 시 가운데에 띄우는 안내 문구 + 다시 시도 버튼.
///
/// 조회 실패를 빈 목록으로 감추지 않고, 같은 자리에서 다시 시도하게 합니다.
/// 어두운 배경 위에서는 [color]로 글자색을 바꿉니다(기본 `textPrimary`).
class AppErrorView extends StatelessWidget {
  const AppErrorView({
    required this.message,
    required this.onRetry,
    this.color,
    super.key,
  });

  /// 안내 문구 (번역된 문자열)
  final String message;

  /// 다시 시도 콜백
  final VoidCallback onRetry;

  /// 안내 문구 색. null이면 `textPrimary`
  final Color? color;

  @override
  Widget build(BuildContext context) => Center(
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Semantics(
          liveRegion: true,
          child: Text(
            message,
            textAlign: TextAlign.center,
            style: AppTypography.bodyLg.copyWith(
              color: color ?? context.colors.textPrimary,
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        ElevatedButton(onPressed: onRetry, child: Text('common.retry'.tr())),
      ],
    ),
  );
}
