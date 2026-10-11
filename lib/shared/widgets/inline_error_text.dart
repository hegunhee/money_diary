import 'package:flutter/material.dart';
import 'package:money_diary/core/themes/app_colors.dart';
import 'package:money_diary/core/themes/app_typography.dart';

/// 작업 영역에 남아 있으며 스크린 리더에도 변경을 알리는 오류 안내입니다.
class InlineErrorText extends StatelessWidget {
  /// 번역된 사용자 안내 문구를 표시합니다.
  const InlineErrorText(this.message, {super.key});

  /// 현재 화면 언어로 번역된 문구입니다.
  final String message;

  @override
  Widget build(BuildContext context) => Semantics(
    liveRegion: true,
    child: Text(
      message,
      style: AppTypography.bodySm.copyWith(color: context.colors.error),
    ),
  );
}
