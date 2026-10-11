import 'package:flutter/services.dart';
import 'package:money_diary/shared/util/won_format.dart';

/// 쉼표가 섞인 입력값에서 금액을 읽습니다. 숫자가 없으면 0입니다.
int parseWon(String text) =>
    int.tryParse(text.replaceAll(RegExp('[^0-9]'), '')) ?? 0;

/// 숫자만 받아 세 자리마다 쉼표를 넣는 입력 포매터
class WonInputFormatter extends TextInputFormatter {
  /// 입력을 막는 자릿수 (억 단위까지)
  static const _maxDigits = 12;

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final digits = newValue.text.replaceAll(RegExp('[^0-9]'), '');
    if (digits.length > _maxDigits) {
      return oldValue;
    }
    final amount = parseWon(digits);
    final text = amount == 0 ? '' : formatWon(amount);
    return TextEditingValue(
      text: text,
      selection: TextSelection.collapsed(offset: text.length),
    );
  }
}
