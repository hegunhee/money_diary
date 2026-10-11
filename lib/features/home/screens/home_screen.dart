import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:money_diary/core/themes/app_colors.dart';
import 'package:money_diary/core/themes/app_spacing.dart';
import 'package:money_diary/core/themes/app_typography.dart';
import 'package:money_diary/shared/widgets/app_content_width.dart';

/// 홈 화면
///
/// 아직 기록 기능이 없어 빈 상태 안내만 보여 줍니다.
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'common.app_name'.tr(),
          style: AppTypography.headlineSm.copyWith(color: colors.textPrimary),
        ),
      ),
      body: SafeArea(
        child: AppContentWidth(
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.xl),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'home.empty_title'.tr(),
                  textAlign: TextAlign.center,
                  style: AppTypography.headlineLg.copyWith(
                    color: colors.textPrimary,
                  ),
                ),
                const SizedBox(height: AppSpacing.sm),
                Text(
                  'home.empty_description'.tr(),
                  textAlign: TextAlign.center,
                  style: AppTypography.bodyLg.copyWith(
                    color: colors.textSecondary,
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
