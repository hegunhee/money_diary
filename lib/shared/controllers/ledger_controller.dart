import 'package:flutter/foundation.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:money_diary/shared/controllers/today_controller.dart';
import 'package:money_diary/shared/models/asset_account.dart';
import 'package:money_diary/shared/models/ledger_book.dart';
import 'package:money_diary/shared/models/ledger_entry.dart';
import 'package:money_diary/shared/models/project.dart';
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
    // 개발 빌드에서는 처음 실행할 때 시안의 예시 가계부를 채워 화면을 바로 확인합니다.
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
      book.copyWith(entries: [...book.entries, entry], assets: assets),
    );
  }

  /// 자산을 더하거나 고칩니다.
  Future<void> saveAsset(AssetAccount asset) async {
    final book = await future;
    await ref.read(ledgerRepositoryProvider).saveAsset(asset);
    state = AsyncData(
      book.copyWith(assets: _upsert(book.assets, asset, (a) => a.id)),
    );
  }

  /// 자산을 지웁니다. 그 자산을 쓴 거래가 있으면 지우지 않고 false를 돌려줍니다.
  Future<bool> deleteAsset(String id) async {
    final book = await future;
    final inUse = book.entries.any(
      (entry) => entry.assetId == id || entry.toAssetId == id,
    );
    if (inUse) {
      return false;
    }
    await ref.read(ledgerRepositoryProvider).deleteAsset(id);
    state = AsyncData(
      book.copyWith(assets: [...book.assets.where((a) => a.id != id)]),
    );
    return true;
  }

  /// 프로젝트를 더하거나 고칩니다.
  Future<void> saveProject(Project project) async {
    final book = await future;
    await ref.read(ledgerRepositoryProvider).saveProject(project);
    state = AsyncData(
      book.copyWith(projects: _upsert(book.projects, project, (p) => p.id)),
    );
  }

  /// 프로젝트를 지웁니다. 묶여 있던 거래는 남기고 태그만 뗍니다.
  Future<void> deleteProject(String id) async {
    final book = await future;
    final untagged = [
      for (final entry in book.entries)
        if (entry.projectId == id) entry.withoutProject(),
    ];
    await ref.read(ledgerRepositoryProvider).deleteProject(id, untagged);
    state = AsyncData(
      book.copyWith(
        entries: [
          for (final entry in book.entries)
            entry.projectId == id ? entry.withoutProject() : entry,
        ],
        projects: [...book.projects.where((p) => p.id != id)],
      ),
    );
  }

  /// 한 달 지출 예산을 바꿉니다.
  Future<void> saveMonthlyBudget(int budget) async {
    final book = await future;
    await ref.read(ledgerRepositoryProvider).saveMonthlyBudget(budget);
    state = AsyncData(book.copyWith(monthlyBudget: budget));
  }

  /// 같은 id가 있으면 그 자리에서 바꾸고, 없으면 끝에 더합니다.
  static List<T> _upsert<T>(List<T> items, T item, String Function(T) idOf) {
    final exists = items.any((other) => idOf(other) == idOf(item));
    return [
      for (final other in items) idOf(other) == idOf(item) ? item : other,
      if (!exists) item,
    ];
  }
}
