import 'package:money_diary/shared/models/asset_account.dart';
import 'package:money_diary/shared/models/ledger_entry.dart';
import 'package:money_diary/shared/models/project.dart';

/// 로컬 DB에 저장된 가계부 전체
class LedgerBook {
  const LedgerBook({
    this.entries = const [],
    this.assets = const [],
    this.projects = const [],
    this.monthlyBudget = 0,
  });

  final List<LedgerEntry> entries;

  final List<AssetAccount> assets;

  final List<Project> projects;

  /// 한 달 지출 예산(원). 정하지 않았으면 0입니다.
  final int monthlyBudget;

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
