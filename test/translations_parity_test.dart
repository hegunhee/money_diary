// ko·en 번역 파일의 키 정합성을 지킵니다.
//
// easy_localization 은 키가 없으면 번역문 대신 키 문자열을 그대로 화면에 출력합니다.
// 사람이 눈으로 잡기 어려운 종류의 결함이라 테스트로 막습니다.
import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

/// 중첩 JSON 을 `a.b.c` 형태의 평탄한 키 집합으로 바꿉니다.
Map<String, String> _flatten(Map<String, dynamic> src, [String prefix = '']) {
  final out = <String, String>{};
  src.forEach((key, value) {
    final path = prefix.isEmpty ? key : '$prefix.$key';
    if (value is Map<String, dynamic>) {
      out.addAll(_flatten(value, path));
    } else {
      out[path] = '$value';
    }
  });
  return out;
}

Map<String, String> _load(String locale) => _flatten(
  jsonDecode(File('assets/translations/$locale.json').readAsStringSync())
      as Map<String, dynamic>,
);

void main() {
  late Map<String, String> ko;
  late Map<String, String> en;

  setUpAll(() {
    ko = _load('ko');
    en = _load('en');
  });

  test('ko 와 en 의 키가 같다', () {
    expect(
      ko.keys.toSet().difference(en.keys.toSet()),
      isEmpty,
      reason: 'en.json 에 없는 키입니다. 비워두면 화면에 키 문자열이 그대로 나옵니다.',
    );
    expect(
      en.keys.toSet().difference(ko.keys.toSet()),
      isEmpty,
      reason: 'ko.json 에 없는 키입니다.',
    );
  });

  test('번역 값이 비어 있지 않다', () {
    for (final entry in {'ko': ko, 'en': en}.entries) {
      final blank = entry.value.entries
          .where((e) => e.value.trim().isEmpty)
          .map((e) => e.key)
          .toList();
      expect(blank, isEmpty, reason: '${entry.key}.json 의 값이 비어 있습니다.');
    }
  });

  test('치환 자리표시자 개수가 로케일 간 일치한다', () {
    // '{}' 위치 인자와 '{name}' 이름 인자의 개수가 다르면 런타임에 어긋납니다.
    final placeholder = RegExp(r'\{[a-zA-Z0-9_]*\}');
    final mismatched = [
      for (final key in ko.keys)
        if (en[key] != null &&
            placeholder.allMatches(en[key]!).length !=
                placeholder.allMatches(ko[key]!).length)
          key,
    ];
    expect(mismatched, isEmpty, reason: '자리표시자 개수가 로케일마다 다릅니다.');
  });
}
