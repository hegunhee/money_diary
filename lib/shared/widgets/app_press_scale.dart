import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

/// 누르는 동안 살짝 줄어드는 탭 대상입니다.
///
/// 카드·아이콘처럼 잉크 물결을 얹기 어려운 모양에 눌림 표현을 줍니다. 손을 떼면
/// 제 크기로 돌아옵니다. OS의 동작 줄이기가 켜져 있으면 크기를 바꾸지 않습니다.
class AppPressScale extends HookWidget {
  const AppPressScale({
    required this.onTap,
    required this.child,
    this.onLongPress,
    this.behavior,
    super.key,
  });

  /// 탭 콜백. null이면 눌림 표현도 하지 않습니다.
  final VoidCallback? onTap;

  /// 꾹 눌렀을 때의 동작 (선택)
  final VoidCallback? onLongPress;

  /// 눌리는 대상
  final Widget child;

  /// 탭을 받는 범위. 빈 영역까지 받으려면 [HitTestBehavior.opaque]를 줍니다.
  final HitTestBehavior? behavior;

  static const _pressedScale = 0.97;
  static const _duration = Duration(milliseconds: 100);

  @override
  Widget build(BuildContext context) {
    final pressed = useState(false);
    final enabled = onTap != null && !MediaQuery.disableAnimationsOf(context);
    return GestureDetector(
      behavior: behavior,
      onTap: onTap,
      onLongPress: onLongPress,
      onTapDown: enabled ? (_) => pressed.value = true : null,
      onTapUp: enabled ? (_) => pressed.value = false : null,
      onTapCancel: enabled ? () => pressed.value = false : null,
      child: AnimatedScale(
        scale: pressed.value ? _pressedScale : 1,
        duration: _duration,
        curve: Curves.easeOut,
        child: child,
      ),
    );
  }
}
