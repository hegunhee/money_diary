import 'package:intl/intl.dart';

final _grouped = NumberFormat('#,###');

/// 금액을 세 자리마다 쉼표로 끊어 적습니다. (예: 18,450,200)
String formatWon(int amount) => _grouped.format(amount);
