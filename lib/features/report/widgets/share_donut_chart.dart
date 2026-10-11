import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:money_diary/core/themes/app_colors.dart';

/// 몫을 구분하는 차트 색. 큰 몫부터 차례로 씁니다.
List<Color> shareColors(AppColors colors) => [
  colors.primary,
  colors.income,
  colors.expense,
  colors.transfer,
  colors.outline,
  colors.divider,
];

/// 몫의 순서에 맞는 차트 색
Color shareColorAt(AppColors colors, int index) {
  final palette = shareColors(colors);
  return palette[index % palette.length];
}

/// 비율을 고리로 그리는 도넛 차트. 가운데에 [child]를 놓습니다.
class ShareDonutChart extends StatelessWidget {
  const ShareDonutChart({required this.ratios, required this.child, super.key});

  /// 큰 순서로 정렬된 비율 (합이 1)
  final List<double> ratios;

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return SizedBox.square(
      dimension: 180,
      child: CustomPaint(
        painter: _DonutPainter(
          ratios: ratios,
          colors: [
            for (var i = 0; i < ratios.length; i++) shareColorAt(colors, i),
          ],
          track: colors.surfaceHigh,
        ),
        child: Center(child: child),
      ),
    );
  }
}

class _DonutPainter extends CustomPainter {
  const _DonutPainter({
    required this.ratios,
    required this.colors,
    required this.track,
  });

  final List<double> ratios;
  final List<Color> colors;
  final Color track;

  static const _stroke = 22.0;

  @override
  void paint(Canvas canvas, Size size) {
    final rect = (Offset.zero & size).deflate(_stroke / 2);
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = _stroke
      ..color = track;
    canvas.drawArc(rect, 0, math.pi * 2, false, paint);
    var start = -math.pi / 2;
    for (final (index, ratio) in ratios.indexed) {
      final sweep = math.pi * 2 * ratio;
      canvas.drawArc(rect, start, sweep, false, paint..color = colors[index]);
      start += sweep;
    }
  }

  @override
  bool shouldRepaint(_DonutPainter old) =>
      old.ratios != ratios || old.colors != colors || old.track != track;
}
