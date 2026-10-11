import 'package:flutter/material.dart';
import 'package:money_diary/core/themes/app_colors.dart';

/// 목록의 한 줄처럼 넓은 탭 대상에 쓰는 누름 표현입니다.
///
/// 누르는 동안 줄 전체가 옅게 어두워집니다. 물결이 퍼지는 표현은 쓰지 않습니다.
/// 물결은 배경이 칠해진 줄에서는 가려져 보이지 않아, 줄마다 반응이 있다가 없다가
/// 합니다. 카드·알약·아이콘처럼 줄이 아닌 모양에는 `AppPressScale`을 씁니다.
///
/// [child]에 불투명한 배경을 칠하면 어두워지는 표현이 가려지므로, 배경은 이 위젯
/// 바깥에 둡니다.
class AppTapRow extends StatelessWidget {
  const AppTapRow({
    required this.onTap,
    required this.child,
    this.onLongPress,
    this.borderRadius,
    super.key,
  });

  /// 탭 콜백. null이면 누름 표현도 하지 않습니다.
  final VoidCallback? onTap;

  /// 꾹 눌렀을 때의 동작 (선택)
  final VoidCallback? onLongPress;

  /// 줄의 내용
  final Widget child;

  /// 어두워지는 영역의 모서리
  final BorderRadius? borderRadius;

  @override
  Widget build(BuildContext context) => Material(
    type: MaterialType.transparency,
    child: InkWell(
      onTap: onTap,
      onLongPress: onLongPress,
      borderRadius: borderRadius,
      splashFactory: NoSplash.splashFactory,
      highlightColor: context.colors.surfaceHigh,
      child: child,
    ),
  );
}
