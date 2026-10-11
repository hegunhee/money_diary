import 'package:flutter/foundation.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:money_diary/shared/controllers/today_controller.dart';
import 'package:money_diary/shared/models/ledger_book.dart';
import 'package:money_diary/shared/models/ledger_entry.dart';
import 'package:money_diary/shared/repositories/ledger_repository.dart';
import 'package:money_diary/shared/util/ledger_calculator.dart';
import 'package:money_diary/shared/util/sample_ledger.dart';

/// 가계부 Provider
final ledgerProvider = AsyncNotifierProvider<LedgerController, LedgerBook>(
  LedgerController.new,
);

/// 로컬 DB의 가계부를 읽고 거래를 더하는 컨트롤러
class LedgerController extends AsyncNotifier<LedgerBook> {
  @override
  Future<LedgerBook> build() async {
    final repository = ref.read(ledgerRepositoryProvider);
    // 자산·프로젝트·예산을 관리하는 화면이 아직 없어, 개발 빌드에서는 처음 실행할 때
    // 시안의 예시 가계부를 채워 화면을 확인할 수 있게 합니다.
    if (kDebugMode && !await repository.isInitialized()) {
      await repository.replace(buildSampleLedger(ref.read(todayProvider)));
    }
    return repository.load();
  }

  /// 거래를 더하고 자산 잔액에 반영합니다.
  Future<void> addEntry(LedgerEntry entry) async {
    final book = await future;
    final assets = applyEntry(book.assets, entry);
    await ref.read(ledgerRepositoryProvider).saveEntry(entry, assets);
    state = AsyncData(
      LedgerBook(
        entries: [...book.entries, entry],
        assets: assets,
        projects: book.projects,
        monthlyBudget: book.monthlyBudget,
      ),
    );
  }
}
