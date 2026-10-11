import 'package:money_diary/shared/models/asset_account.dart';
import 'package:money_diary/shared/models/ledger_category.dart';
import 'package:money_diary/shared/models/ledger_entry.dart';
import 'package:money_diary/shared/models/project.dart';

/// 로컬 DB에 저장된 가계부 전체
class LedgerBook {
  const LedgerBook({
    this.entries = const [],
    this.assets = const [],
    this.projects = const [],
    this.categories = const [],
    this.monthlyBudget = 0,
  });

  final List<LedgerEntry> entries;

  final List<AssetAccount> assets;

  final List<Project> projects;

  /// 사용자가 더한 카테고리. 기본 카테고리는 들어 있지 않습니다.
  final List<LedgerCategory> categories;

  /// 한 달 지출 예산(원). 정하지 않았으면 0입니다.
  final int monthlyBudget;

  LedgerBook copyWith({
    List<LedgerEntry>? entries,
    List<AssetAccount>? assets,
    List<Project>? projects,
    List<LedgerCategory>? categories,
    int? monthlyBudget,
  }) => LedgerBook(
    entries: entries ?? this.entries,
    assets: assets ?? this.assets,
    projects: projects ?? this.projects,
    categories: categories ?? this.categories,
    monthlyBudget: monthlyBudget ?? this.monthlyBudget,
  );

  /// [type]의 거래에서 고를 수 있는 카테고리. 기본 카테고리 뒤에 사용자가 더한 것이 옵니다.
  List<LedgerCategory> categoriesOf(EntryType type) => [
    for (final category in [...LedgerCategory.builtIns, ...categories])
      if (category.type == type) category,
  ];

  AssetAccount? assetById(String? id) {
    for (final asset in assets) {
      if (asset.id == id) {
        return asset;
      }
    }
    return null;
  }

  Project? projectById(String? id) {
    for (final project in projects) {
      if (project.id == id) {
        return project;
      }
    }
    return null;
  }
}
