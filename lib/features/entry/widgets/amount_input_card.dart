import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:money_diary/core/themes/app_colors.dart';
import 'package:money_diary/core/themes/app_spacing.dart';
import 'package:money_diary/core/themes/app_typography.dart';
import 'package:money_diary/shared/util/won_format.dart';
import 'package:money_diary/shared/util/won_input.dart';
import 'package:money_diary/shared/widgets/app_card.dart';
import 'package:money_diary/shared/widgets/inline_error_text.dart';

/// 큰 글씨로 금액을 적고, 버튼으로 금액을 더하는 카드
class AmountInputCard extends StatelessWidget {
  const AmountInputCard({
    required this.controller,
    required this.label,
    required this.color,
    this.errorText,
    super.key,
  });

  final TextEditingController controller;

  /// 금액 위에 적는 이름 (번역된 문자열)
  final String label;

  /// 금액 글자색. 거래 종류에 따라 달라집니다.
  final Color color;

  /// 금액 아래에 보여 줄 오류 문구
  final String? errorText;

  static const _steps = [1000, 5000, 10000, 50000];

  void _set(int amount) {
    final text = amount <= 0 ? '' : formatWon(amount);
    controller.value = TextEditingValue(
      text: text,
      selection: TextSelection.collapsed(offset: text.length),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final error = errorText;
    return AppCard(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        children: [
          Text(
            label,
            style: AppTypography.labelMd.copyWith(color: colors.textSecondary),
          ),
          TextField(
            controller: controller,
            keyboardType: TextInputType.number,
            inputFormatters: [WonInputFormatter()],
            textAlign: TextAlign.center,
            style: AppTypography.displayCurrencyMobile.copyWith(color: color),
            cursorColor: color,
            decoration: InputDecoration(
              border: InputBorder.none,
              hintText: '0',
              hintStyle: AppTypography.displayCurrencyMobile.copyWith(
                color: colors.divider,
              ),
              prefixIcon: Padding(
                padding: const EdgeInsets.only(left: AppSpacing.lg),
                child: Text(
                  '₩',
                  style: AppTypography.headlineLg.copyWith(color: color),
                ),
              ),
              prefixIconConstraints: const BoxConstraints(),
              suffixIcon: IconButton(
                tooltip: 'entry.amount_delete'.tr(),
                onPressed: () => _set(parseWon(controller.text) ~/ 10),
                icon: Icon(
                  Icons.backspace_outlined,
                  size: 20,
                  color: colors.textSecondary,
                ),
              ),
            ),
          ),
          if (error != null) ...[
            InlineErrorText(error),
            const SizedBox(height: AppSpacing.sm),
          ],
          Wrap(
            alignment: WrapAlignment.center,
            spacing: AppSpacing.sm,
            runSpacing: AppSpacing.sm,
            children: [
              for (final step in _steps)
                ActionChip(
                  label: Text('entry.amount_step.$step'.tr()),
                  onPressed: () => _set(parseWon(controller.text) + step),
                ),
              ActionChip(
                label: Text('entry.amount_reset'.tr()),
                onPressed: () => _set(0),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
