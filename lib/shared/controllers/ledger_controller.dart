import 'package:easy_localization/easy_localization.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:money_diary/shared/controllers/today_controller.dart';
import 'package:money_diary/shared/models/asset_account.dart';
import 'package:money_diary/shared/models/ledger_book.dart';
import 'package:money_diary/shared/models/ledger_category.dart';
import 'package:money_diary/shared/models/ledger_entry.dart';
import 'package:money_diary/shared/models/project.dart';
import 'package:money_diary/shared/repositories/ledger_repository.dart';
import 'package:money_diary/shared/util/ledger_calculator.dart';
import 'package:money_diary/shared/util/ledger_labels.dart';

/// 가계부 Provider
final ledgerProvider = AsyncNotifierProvider<LedgerController, LedgerBook>(
  LedgerController.new,
);

/// 로컬 DB의 가계부를 읽고 거래를 더하는 컨트롤러
class LedgerController extends AsyncNotifier<LedgerBook> {
  @override
  Future<LedgerBook> build() async {
    final repository = ref.read(ledgerRepositoryProvider);
    // 처음 실행하면 거래를 바로 적을 수 있게 잔액 0원인 현금 자산 하나만 둡니다.
    if (!await repository.isInitialized()) {
      await repository.replace(
        LedgerBook(
          assets: [
            AssetAccount(
              id: 'cash',
              name: 'asset.kind.cash'.tr(),
              kind: AssetKind.cash,
              balance: 0,
            ),
          ],
        ),
      );
    }
    return _withDueRecurring(await repository.load());
  }

  /// 매달 반복으로 지금까지 등록됐어야 할 거래를 만들어 저장합니다.
  Future<LedgerBook> _withDueRecurring(LedgerBook book) async {
    final changed = dueRecurringEntries(book.entries, ref.read(todayProvider));
    if (changed.isEmpty) {
      return book;
    }
    final existing = {for (final entry in book.entries) entry.id};
    var assets = book.assets;
    var entries = book.entries;
    for (final entry in changed) {
      // 새로 만든 거래만 잔액에 반영합니다. 원래 거래는 표시만 바뀝니다.
      if (!existing.contains(entry.id)) {
        assets = applyEntry(assets, entry);
      }
      entries = _upsert(entries, entry, (e) => e.id);
    }
    await ref.read(ledgerRepositoryProvider).saveEntries(changed, assets);
    return book.copyWith(entries: entries, assets: assets);
  }

  /// 앱으로 돌아왔을 때처럼 날짜가 바뀌었을 수 있을 때, 밀린 반복 거래를 등록합니다.
  Future<void> registerDueRecurring() async {
    final book = await future;
    state = AsyncData(await _withDueRecurring(book));
  }

  /// 거래를 더하고 자산 잔액에 반영합니다.
  Future<void> addEntry(LedgerEntry entry) async {
    final book = await future;
    final assets = applyEntry(book.assets, entry);
    await ref.read(ledgerRepositoryProvider).saveEntry(entry, assets);
    // 지난 날짜로 적은 반복 거래는 밀린 달을 바로 이어서 등록합니다.
    state = AsyncData(
      await _withDueRecurring(
        book.copyWith(entries: [...book.entries, entry], assets: assets),
      ),
    );
  }

  /// 거래를 고칩니다. 예전 값으로 반영했던 잔액을 되돌린 뒤 새 값으로 다시 반영합니다.
  Future<void> updateEntry(LedgerEntry entry) async {
    final book = await future;
    final old = book.entries.firstWhere((other) => other.id == entry.id);
    final assets = applyEntry(revertEntry(book.assets, old), entry);
    await ref.read(ledgerRepositoryProvider).saveEntry(entry, assets);
    state = AsyncData(
      await _withDueRecurring(
        book.copyWith(
          entries: _upsert(book.entries, entry, (e) => e.id),
          assets: assets,
        ),
      ),
    );
  }

  /// 거래를 지우고 잔액을 되돌립니다.
  Future<void> deleteEntry(LedgerEntry entry) async {
    final book = await future;
    final assets = revertEntry(book.assets, entry);
    await ref.read(ledgerRepositoryProvider).deleteEntry(entry.id, assets);
    state = AsyncData(
      book.copyWith(
        entries: [...book.entries.where((e) => e.id != entry.id)],
        assets: assets,
      ),
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

  /// 자산을 보여 주는 순서를 바꿉니다. [assets]는 같은 자산을 새 순서로 늘어놓은 목록입니다.
  Future<void> reorderAssets(List<AssetAccount> assets) async {
    final book = await future;
    // 끌어다 놓은 줄이 저장을 기다리는 동안 제자리로 튀지 않게 먼저 반영합니다.
    state = AsyncData(book.copyWith(assets: assets));
    try {
      await ref.read(ledgerRepositoryProvider).saveAssetOrder([
        for (final asset in assets) asset.id,
      ]);
    } on Object {
      state = AsyncData(book);
      rethrow;
    }
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

  /// 카테고리를 더합니다. 같은 종류에 같은 이름이 이미 있으면 더하지 않고 null을 돌려줍니다.
  Future<LedgerCategory?> addCategory(String name, EntryType type) async {
    final book = await future;
    final taken = book
        .categoriesOf(type)
        .any((category) => category.label == name);
    if (taken) {
      return null;
    }
    final category = LedgerCategory(
      id: 'custom-${DateTime.now().microsecondsSinceEpoch}',
      type: type,
      customName: name,
    );
    await ref.read(ledgerRepositoryProvider).saveCategory(category);
    state = AsyncData(
      book.copyWith(categories: [...book.categories, category]),
    );
    return category;
  }

  /// 사용자가 더한 카테고리를 지웁니다. 그 카테고리로 적은 거래는 그대로 남습니다.
  Future<void> deleteCategory(String id) async {
    final book = await future;
    await ref.read(ledgerRepositoryProvider).deleteCategory(id);
    state = AsyncData(
      book.copyWith(
        categories: [...book.categories.where((c) => c.id != id)],
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
