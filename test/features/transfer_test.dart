import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:money_diary/features/entry/screens/entry_screen.dart';
import 'package:money_diary/shared/controllers/ledger_controller.dart';
import 'package:money_diary/shared/models/asset_account.dart';
import 'package:money_diary/shared/models/ledger_book.dart';
import 'package:money_diary/shared/models/ledger_entry.dart';
import 'package:money_diary/shared/util/ledger_calculator.dart';

import '../helpers/pump_app.dart';

void main() {
  testWidgets('이체하면 돈만 옮겨지고 수입·지출에는 잡히지 않는다', (tester) async {
    tester.view.physicalSize = const Size(430, 2400);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    late WidgetRef ref;
    final repository = await pumpApp(
      tester,
      Consumer(
        builder: (context, r, _) {
          ref = r;
          return const EntryScreen(initialType: EntryType.transfer);
        },
      ),
      book: const LedgerBook(
        assets: [
          AssetAccount(
            id: 'a',
            name: '월급 통장',
            kind: AssetKind.bank,
            balance: 100000,
          ),
          AssetAccount(
            id: 'b',
            name: '생활비 통장',
            kind: AssetKind.bank,
            balance: 0,
          ),
        ],
      ),
    );

    await tester.enterText(find.byType(TextField).first, '30000');
    await tester.pump();
    await tester.tap(find.text('자산 변경').last);
    await tester.pumpAndSettle();
    await tester.tap(find.text('생활비 통장').last);
    await tester.pumpAndSettle();
    await tester.tap(find.text('저장 후 계속 추가'));
    await tester.pumpAndSettle();

    final book = ref.read(ledgerProvider).requireValue;
    expect(repository.saved.single.type, EntryType.transfer);
    expect(book.assetById('a')!.balance, 70000);
    expect(book.assetById('b')!.balance, 30000);
    expect(netWorth(book.assets), 100000);
    expect(totalsOf(book.entries).income, 0);
    expect(totalsOf(book.entries).expense, 0);
  });

  testWidgets('자산이 하나뿐이면 이체 화면에서 바로 자산을 더해 받는 자산으로 고를 수 있다', (tester) async {
    tester.view.physicalSize = const Size(430, 2400);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    await pumpApp(
      tester,
      const EntryScreen(),
      book: const LedgerBook(
        assets: [
          AssetAccount(
            id: 'cash',
            name: '현금',
            kind: AssetKind.cash,
            balance: 0,
          ),
        ],
      ),
    );

    // 지출에서 이체로 바꿔도 화면이 죽지 않아야 합니다.
    await tester.tap(find.text('이체'));
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
    expect(find.textContaining('받는 자산이 하나 더 필요해요'), findsOneWidget);

    await tester.tap(find.text('자산 추가'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField).at(3), '카카오뱅크');
    await tester.tap(find.text('저장'));
    await tester.pumpAndSettle();

    expect(find.textContaining('받는 자산이 하나 더 필요해요'), findsNothing);
    await tester.tap(find.text('자산 변경').last);
    await tester.pumpAndSettle();
    expect(find.text('카카오뱅크'), findsOneWidget);
  });
}
