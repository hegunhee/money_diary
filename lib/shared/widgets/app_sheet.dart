import 'package:flutter/material.dart';
import 'package:money_diary/core/themes/app_colors.dart';
import 'package:money_diary/core/themes/app_layout.dart';
import 'package:money_diary/core/themes/app_spacing.dart';
import 'package:money_diary/core/themes/app_typography.dart';

/// 입력 폼을 담는 바텀 시트를 엽니다. 키보드가 올라오면 내용이 그 위로 밀립니다.
Future<T?> showAppSheet<T>(
  BuildContext context, {
  required String title,
  required Widget child,
}) => showModalBottomSheet<T>(
  context: context,
  isScrollControlled: true,
  showDragHandle: true,
  backgroundColor: context.colors.surface,
  constraints: const BoxConstraints(maxWidth: AppLayout.sheetMaxWidth),
  builder: (context) => Padding(
    padding: EdgeInsets.only(bottom: MediaQuery.viewInsetsOf(context).bottom),
    child: SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.gutter,
          0,
          AppSpacing.gutter,
          AppSpacing.lg,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              title,
              style: AppTypography.headlineMd.copyWith(
                color: context.colors.textPrimary,
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            child,
          ],
        ),
      ),
    ),
  ),
);

/// 시트·화면의 입력칸에 쓰는 채움 장식
InputDecoration appInputDecoration(
  BuildContext context, {
  String? label,
  String? hint,
  String? prefix,
}) => InputDecoration(
  labelText: label,
  hintText: hint,
  prefixText: prefix,
  filled: true,
  fillColor: context.colors.surfaceLow,
  border: OutlineInputBorder(
    borderRadius: BorderRadius.circular(AppRadius.md),
    borderSide: BorderSide.none,
  ),
);

/// 확인만 받으면 되는 안내를 띄웁니다. 꾹 눌러 지우다 실패했을 때처럼 알릴 자리가 없을 때 씁니다.
Future<void> showNotice(
  BuildContext context, {
  required String message,
  required String closeLabel,
}) => showDialog<void>(
  context: context,
  builder: (context) => AlertDialog(
    content: Text(message),
    actions: [
      TextButton(
        onPressed: () => Navigator.of(context).pop(),
        child: Text(closeLabel),
      ),
    ],
  ),
);

/// 되돌릴 수 없는 삭제 전에 한 번 더 묻습니다. 지우기로 하면 true입니다.
Future<bool> confirmDelete(
  BuildContext context, {
  required String message,
  required String confirmLabel,
  required String cancelLabel,
}) async {
  final confirmed = await showDialog<bool>(
    context: context,
    builder: (context) => AlertDialog(
      content: Text(message),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(false),
          child: Text(cancelLabel),
        ),
        TextButton(
          onPressed: () => Navigator.of(context).pop(true),
          child: Text(
            confirmLabel,
            style: TextStyle(color: context.colors.error),
          ),
        ),
      ],
    ),
  );
  return confirmed ?? false;
}
