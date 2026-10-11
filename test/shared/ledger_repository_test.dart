import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:hive_ce/hive.dart';
import 'package:money_diary/shared/models/ledger_entry.dart';
import 'package:money_diary/shared/repositories/ledger_repository.dart';
import 'package:money_diary/shared/util/ledger_calculator.dart';
import 'package:money_diary/shared/util/sample_ledger.dart';

void main() {
  late Directory directory;

  setUp(() {
    directory = Directory.systemTemp.createTempSync('ledger_repository_test');
    Hive.init(directory.path);
  });

  tearDown(() async {
    await Hive.close();
    directory.deleteSync(recursive: true);
  });

  test('저장한 가계부와 새 거래가 다시 열어도 그대로 읽힌다', () async {
    final repository = LedgerRepository();
    final sample = buildSampleLedger(DateTime(2026, 3, 18));
    expect(await repository.isInitialized(), isFalse);

    await repository.replace(sample);
    final added = LedgerEntry(
      id: 'new',
      type: EntryType.expense,
      amount: 35000,
      title: '점심',
      occurredAt: DateTime(2026, 3, 18, 15, 30),
      assetId: 'kakao-bank',
      category: LedgerCategory.food,
      projectId: 'japan-trip',
      memo: '친구들과 점심 식사',
    );
    await repository.saveEntry(added, applyEntry(sample.assets, added));
    await Hive.close();
    Hive.init(directory.path);

    final book = await LedgerRepository().load();
    final saved = book.entries.singleWhere((entry) => entry.id == 'new');
    expect(await LedgerRepository().isInitialized(), isTrue);
    expect(book.entries, hasLength(sample.entries.length + 1));
    expect(saved.toJson(), added.toJson());
    expect(book.assetById('kakao-bank')!.balance, 1500000 - 35000);
    expect(book.projects.single.budget, 1500000);
    expect(book.monthlyBudget, 4000000);
  });
}
