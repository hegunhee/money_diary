import 'package:money_diary/shared/models/ledger_entry.dart';

/// 거래 입력에서 저장을 막는 사유
enum EntryFormError {
  /// 금액이 0 이하
  amount,

  /// 자산을 고르지 않음
  asset,

  /// 이체에서 받는 자산을 고르지 않음
  toAsset,

  /// 이체에서 보내는 자산과 받는 자산이 같음
  sameAsset,
}

/// 입력값에서 저장을 막는 사유를 모두 찾습니다. 비어 있으면 저장할 수 있습니다.
Set<EntryFormError> validateEntry({
  required EntryType type,
  required int amount,
  required String? assetId,
  required String? toAssetId,
}) => {
  if (amount <= 0) EntryFormError.amount,
  if (assetId == null) EntryFormError.asset,
  if (type == EntryType.transfer && toAssetId == null) EntryFormError.toAsset,
  if (type == EntryType.transfer && assetId != null && assetId == toAssetId)
    EntryFormError.sameAsset,
};
