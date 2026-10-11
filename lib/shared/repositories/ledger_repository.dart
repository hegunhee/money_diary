import 'package:hive_ce/hive.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:money_diary/shared/models/asset_account.dart';
import 'package:money_diary/shared/models/ledger_book.dart';
import 'package:money_diary/shared/models/ledger_entry.dart';
import 'package:money_diary/shared/models/project.dart';

/// 가계부 저장소 Provider
final ledgerRepositoryProvider = Provider<LedgerRepository>(
  (ref) => LedgerRepository(),
);

/// 가계부를 기기의 로컬 DB(Hive)에 읽고 씁니다.
///
/// 거래·자산·프로젝트를 상자 하나씩에 id를 키로 저장합니다.
class LedgerRepository {
  static const _entries = 'ledger_entries';
  static const _assets = 'ledger_assets';
  static const _projects = 'ledger_projects';
  static const _settings = 'ledger_settings';
  static const _monthlyBudget = 'monthlyBudget';
  static const _initialized = 'initialized';

  Future<Box<Map<dynamic, dynamic>>> _box(String name) => Hive.openBox(name);

  /// 가계부가 한 번이라도 저장된 적이 있는지 여부
  Future<bool> isInitialized() async {
    final settings = await Hive.openBox<Object>(_settings);
    return settings.get(_initialized) == true;
  }

  /// 저장된 가계부 전체를 읽습니다.
  Future<LedgerBook> load() async {
    final settings = await Hive.openBox<Object>(_settings);
    List<Map<String, dynamic>> rows(Box<Map<dynamic, dynamic>> box) => [
      for (final row in box.values) Map<String, dynamic>.from(row),
    ];
    return LedgerBook(
      entries: rows(await _box(_entries)).map(LedgerEntry.fromJson).toList(),
      // 상자는 id 순으로 돌려주므로, 종류별로 모아 이름순으로 보여 줍니다.
      assets: rows(await _box(_assets)).map(AssetAccount.fromJson).toList()
        ..sort(
          (a, b) => a.kind == b.kind
              ? a.name.compareTo(b.name)
              : a.kind.index.compareTo(b.kind.index),
        ),
      projects: rows(await _box(_projects)).map(Project.fromJson).toList(),
      monthlyBudget: settings.get(_monthlyBudget) as int? ?? 0,
    );
  }

  /// 가계부 전체를 덮어씁니다.
  Future<void> replace(LedgerBook book) async {
    final entries = await _box(_entries);
    final assets = await _box(_assets);
    final projects = await _box(_projects);
    final settings = await Hive.openBox<Object>(_settings);
    await entries.clear();
    await assets.clear();
    await projects.clear();
    await entries.putAll({for (final e in book.entries) e.id: e.toJson()});
    await assets.putAll({for (final a in book.assets) a.id: a.toJson()});
    await projects.putAll({for (final p in book.projects) p.id: p.toJson()});
    await settings.putAll({
      _monthlyBudget: book.monthlyBudget,
      _initialized: true,
    });
  }

  /// 거래 한 건과, 그 거래로 잔액이 바뀐 자산을 함께 저장합니다.
  Future<void> saveEntry(LedgerEntry entry, List<AssetAccount> assets) async {
    await (await _box(_entries)).put(entry.id, entry.toJson());
    await (await _box(_assets)).putAll({
      for (final asset in assets) asset.id: asset.toJson(),
    });
  }

  /// 거래 한 건을 지우고, 잔액을 되돌린 자산을 함께 저장합니다.
  Future<void> deleteEntry(String id, List<AssetAccount> assets) async {
    await (await _box(_entries)).delete(id);
    await (await _box(_assets)).putAll({
      for (final asset in assets) asset.id: asset.toJson(),
    });
  }

  /// 자산 하나를 더하거나 고쳐 저장합니다.
  Future<void> saveAsset(AssetAccount asset) async {
    await (await _box(_assets)).put(asset.id, asset.toJson());
  }

  /// 자산 하나를 지웁니다.
  Future<void> deleteAsset(String id) async {
    await (await _box(_assets)).delete(id);
  }

  /// 프로젝트 하나를 더하거나 고쳐 저장합니다.
  Future<void> saveProject(Project project) async {
    await (await _box(_projects)).put(project.id, project.toJson());
  }

  /// 프로젝트 하나를 지우고, 태그를 뗀 거래들을 함께 저장합니다.
  Future<void> deleteProject(String id, List<LedgerEntry> untagged) async {
    await (await _box(_entries)).putAll({
      for (final entry in untagged) entry.id: entry.toJson(),
    });
    await (await _box(_projects)).delete(id);
  }

  /// 한 달 지출 예산을 저장합니다.
  Future<void> saveMonthlyBudget(int budget) async {
    await (await Hive.openBox<Object>(_settings)).put(_monthlyBudget, budget);
  }
}
