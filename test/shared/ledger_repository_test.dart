import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:hive_ce/hive.dart';
import 'package:money_diary/shared/models/ledger_category.dart';
import 'package:money_diary/shared/models/ledger_entry.dart';
import 'package:money_diary/shared/repositories/ledger_repository.dart';
import 'package:money_diary/shared/util/ledger_calculator.dart';

import '../helpers/sample_ledger.dart';

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
      // 사용자가 더한 카테고리. 목록에서 지워져도 거래에는 이름이 남아야 합니다.
      category: const LedgerCategory(
        id: 'custom-pet',
        type: EntryType.expense,
        customName: '반려동물',
      ),
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
    expect(saved.category?.customName, '반려동물');
    expect(book.categories, isEmpty);
    expect(book.assetById('kakao-bank')!.balance, 1500000 - 35000);
    expect(book.projects.single.budget, 1500000);
    expect(book.monthlyBudget, 4000000);
  });

  test('정한 자산 순서는 다시 열어도 남고 순서를 정하지 않은 자산은 뒤에 온다', () async {
    final repository = LedgerRepository();
    await repository.replace(buildSampleLedger(DateTime(2026, 3, 18)));
    await repository.saveAssetOrder(['cash', 'kakao-bank']);
    await Hive.close();
    Hive.init(directory.path);

    final assets = (await LedgerRepository().load()).assets;

    expect(
      [for (final asset in assets.take(3)) asset.id],
      [
        'cash',
        'kakao-bank',
        'shinhan-bank',
      ],
    );
  });

  test('자산별 예산이 없던 때 저장한 자산은 예산 0으로 읽히고, 정한 예산은 다시 열어도 남는다', () async {
    final repository = LedgerRepository();
    await repository.replace(buildSampleLedger(DateTime(2026, 3, 18)));
    final assets = await Hive.openBox<Map<dynamic, dynamic>>('ledger_assets');
    await assets.put('old', {
      'id': 'old',
      'name': '예전 통장',
      'kind': 'bank',
      'balance': 1000,
    });
    final cash = (await repository.load()).assetById('cash')!;
    await repository.saveBudgets(2000000, [cash.withMonthlyBudget(300000)]);
    await Hive.close();
    Hive.init(directory.path);

    final book = await LedgerRepository().load();
    expect(book.assetById('old')!.monthlyBudget, 0);
    expect(book.assetById('cash')!.monthlyBudget, 300000);
    expect(book.assetById('cash')!.balance, cash.balance);
    expect(book.monthlyBudget, 2000000);
  });
}
