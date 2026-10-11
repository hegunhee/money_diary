// 프론트 전용 상태 묶음(`*State` 클래스 · record typedef)이 허가 없이 늘지 않게 막습니다.
//
// 컨트롤러 상태는 모델 그대로, 화면 전용 값은 훅으로 두는 것이 규칙입니다.
// 예외는 `state_allowlist.txt` 에 이유와 함께 올라간 것만 허용합니다.
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

const _guide =
    '컨트롤러 상태는 모델 그대로, 화면 전용 값은 훅(useState 등)으로 두세요. '
    '정말 필요하면 state_allowlist.txt 에 이유와 함께 추가하세요.';

final _classDeclaration = RegExp(
  r'^\s*(?:(?:abstract|base|final|sealed|interface|mixin)\s+)*class\s+(\w+)([^{]*)',
  multiLine: true,
);
final _recordTypedef = RegExp(
  r'^\s*typedef\s+(\w+)(?:<[^=]*>)?\s*=\s*\(',
  multiLine: true,
);
final _flutterStateBase = RegExp(r'\bextends\s+(?:Consumer)?State<');

/// `IapPurchaseState` → `iap_purchase_state`
String _snake(String name) => name
    .replaceAllMapped(RegExp('[A-Z]'), (m) => '_${m[0]!.toLowerCase()}')
    .substring(1);

void main() {
  // 이름 → 이유
  final allowlist = <String, String>{};
  for (final line in File('state_allowlist.txt').readAsLinesSync()) {
    final text = line.trim();
    if (text.isEmpty || text.startsWith('#')) {
      continue;
    }
    final split = text.indexOf('#');
    final name = (split < 0 ? text : text.substring(0, split)).trim();
    allowlist[name] = split < 0 ? '' : text.substring(split + 1).trim();
  }

  // 이름 → 파일 경로
  final stateClasses = <String, String>{};
  final recordTypedefs = <String, String>{};
  final flutterStates = <String>[];
  final files = Directory('lib')
      .listSync(recursive: true)
      .whereType<File>()
      .where((file) => file.path.endsWith('.dart'));
  for (final file in files) {
    final path = file.path.replaceAll(r'\', '/');
    final source = file.readAsStringSync();
    for (final match in _classDeclaration.allMatches(source)) {
      final name = match[1]!;
      if (_flutterStateBase.hasMatch(match[2]!)) {
        flutterStates.add('$name ($path)');
      } else if (name.endsWith('State')) {
        stateClasses[name] = path;
      }
    }
    for (final match in _recordTypedef.allMatches(source)) {
      recordTypedefs[match[1]!] = path;
    }
  }

  test('StatefulWidget 의 State 가 없다', () {
    expect(
      flutterStates,
      isEmpty,
      reason: 'StatefulWidget 대신 HookWidget · HookConsumerWidget 과 훅을 쓰세요.',
    );
  });

  test('*State 클래스는 allowlist 에 있다', () {
    final unlisted = [
      for (final entry in stateClasses.entries)
        if (!allowlist.containsKey(entry.key)) '${entry.key} (${entry.value})',
    ];
    expect(
      unlisted,
      isEmpty,
      reason: '허가되지 않은 *State 클래스입니다. $_guide',
    );
  });

  test('record typedef 로 상태를 묶지 않는다', () {
    final unlisted = [
      for (final entry in recordTypedefs.entries)
        if (!allowlist.containsKey(entry.key)) '${entry.key} (${entry.value})',
    ];
    expect(
      unlisted,
      isEmpty,
      reason: 'record typedef 로 값을 묶는 것은 *State 클래스 우회입니다. $_guide',
    );
  });

  test('허가된 *State 는 models/<이름>_state.dart 에 있다', () {
    final misplaced = [
      for (final entry in stateClasses.entries)
        if (allowlist.containsKey(entry.key) &&
            !entry.value.endsWith('/models/${_snake(entry.key)}.dart'))
          '${entry.key} (${entry.value})',
    ];
    expect(
      misplaced,
      isEmpty,
      reason: '허가된 *State 는 feature 의 models/ 폴더에 이름과 같은 파일로 두세요.',
    );
  });

  test('allowlist 항목은 이유가 있고 실제로 존재한다', () {
    final problems = [
      for (final entry in allowlist.entries)
        if (entry.value.isEmpty)
          '${entry.key}: 이유(# ...)가 없습니다'
        else if (!stateClasses.containsKey(entry.key) &&
            !recordTypedefs.containsKey(entry.key))
          '${entry.key}: lib 에 더 이상 없습니다',
    ];
    expect(
      problems,
      isEmpty,
      reason: 'state_allowlist.txt 를 정리하세요. 없어진 항목은 지웁니다.',
    );
  });
}
