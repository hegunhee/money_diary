import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:money_diary/core/themes/app_theme.dart';
import 'package:money_diary/shared/controllers/today_controller.dart';
import 'package:money_diary/shared/models/asset_account.dart';
import 'package:money_diary/shared/models/ledger_book.dart';
import 'package:money_diary/shared/models/ledger_entry.dart';
import 'package:money_diary/shared/models/project.dart';
import 'package:money_diary/shared/repositories/ledger_repository.dart';
import 'package:money_diary/shared/util/sample_ledger.dart';

/// 시안이 오늘로 그린 날짜
final designToday = DateTime(2026, 3, 18, 15, 30);

/// 로컬 DB 대신 메모리에 가계부를 들고 있는 저장소
class FakeLedgerRepository implements LedgerRepository {
  FakeLedgerRepository([LedgerBook? book])
    : book = book ?? buildSampleLedger(designToday);

  LedgerBook book;

  /// [saveEntry]로 저장된 거래
  final List<LedgerEntry> saved = [];

  @override
  Future<bool> isInitialized() async => true;

  @override
  Future<LedgerBook> load() async => book;

  @override
  Future<void> replace(LedgerBook book) async => this.book = book;

  @override
  Future<void> saveEntry(LedgerEntry entry, List<AssetAccount> assets) async {
    saved.add(entry);
  }

  @override
  Future<void> saveAsset(AssetAccount asset) async {}

  @override
  Future<void> deleteAsset(String id) async {}

  @override
  Future<void> saveProject(Project project) async {}

  @override
  Future<void> deleteProject(String id, List<LedgerEntry> untagged) async {}

  @override
  Future<void> saveMonthlyBudget(int budget) async {}
}

/// 시안의 예시 가계부와 날짜로 [home]을 띄웁니다.
Future<FakeLedgerRepository> pumpApp(
  WidgetTester tester,
  Widget home, {
  LedgerBook? book,
  ThemeData? theme,
}) async {
  final repository = FakeLedgerRepository(book);
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        ledgerRepositoryProvider.overrideWithValue(repository),
        todayProvider.overrideWithValue(designToday),
      ],
      child: MaterialApp(theme: theme ?? AppTheme.lightTheme, home: home),
    ),
  );
  await tester.pumpAndSettle();
  return repository;
}
