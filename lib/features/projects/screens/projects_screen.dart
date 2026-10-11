import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:money_diary/core/themes/app_colors.dart';
import 'package:money_diary/core/themes/app_spacing.dart';
import 'package:money_diary/core/themes/app_typography.dart';
import 'package:money_diary/features/projects/widgets/project_edit_sheet.dart';
import 'package:money_diary/shared/controllers/ledger_controller.dart';
import 'package:money_diary/shared/controllers/today_controller.dart';
import 'package:money_diary/shared/models/project.dart';
import 'package:money_diary/shared/util/ledger_calculator.dart';
import 'package:money_diary/shared/widgets/app_card.dart';
import 'package:money_diary/shared/widgets/app_content_width.dart';
import 'package:money_diary/shared/widgets/app_error_view.dart';
import 'package:money_diary/shared/widgets/app_sheet.dart';
import 'package:money_diary/shared/widgets/app_top_bar.dart';
import 'package:money_diary/shared/widgets/project_card.dart';

/// 프로젝트 — 여행·이사처럼 목적별 예산을 진행 중과 보관됨으로 나눠 관리합니다.
///
/// 보관은 사용자가 직접 합니다. 여행이 끝난 뒤에도 정산 같은 지출이 이어질 수 있어
/// 기간이 지났다고 자동으로 보관하지 않습니다.
class ProjectsScreen extends ConsumerWidget {
  const ProjectsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = context.colors;
    final ledger = ref.watch(ledgerProvider);
    final today = ref.watch(todayProvider);

    void edit([Project? project]) => showAppSheet<void>(
      context,
      title: project == null ? 'project.add'.tr() : 'project.edit'.tr(),
      child: ProjectEditSheet(project: project),
    );

    Future<void> delete(Project project) async {
      final confirmed = await confirmDelete(
        context,
        message: 'project.delete_confirm'.tr(args: [project.name]),
        confirmLabel: 'common.delete'.tr(),
        cancelLabel: 'common.cancel'.tr(),
      );
      if (!confirmed) {
        return;
      }
      try {
        await ref.read(ledgerProvider.notifier).deleteProject(project.id);
      } on Object {
        if (context.mounted) {
          await showNotice(
            context,
            message: 'common.delete_failed'.tr(),
            closeLabel: 'common.close'.tr(),
          );
        }
      }
    }

    return Scaffold(
      appBar: AppTopBar(section: 'nav.projects'.tr()),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: edit,
        backgroundColor: colors.primary,
        foregroundColor: colors.onPrimary,
        shape: const StadiumBorder(),
        icon: const Icon(Icons.add),
        label: Text('project.add'.tr(), style: AppTypography.headlineSm),
      ),
      body: ledger.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => AppErrorView(
          message: 'common.load_failed'.tr(),
          onRetry: () => ref.invalidate(ledgerProvider),
        ),
        data: (book) {
          final sections = [
            (
              'project.title_active'.tr(),
              book.projects.where((p) => !p.isArchived),
            ),
            (
              'project.title_archived'.tr(),
              book.projects.where((p) => p.isArchived),
            ),
          ];
          return AppContentWidth(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.gutter,
                AppSpacing.sm,
                AppSpacing.gutter,
                96,
              ),
              children: [
                if (book.projects.isEmpty)
                  AppCard(
                    child: Text(
                      'project.empty'.tr(),
                      textAlign: TextAlign.center,
                      style: AppTypography.bodyMd.copyWith(
                        color: colors.textSecondary,
                      ),
                    ),
                  ),
                for (final (title, projects) in sections)
                  if (projects.isNotEmpty) ...[
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        vertical: AppSpacing.sm,
                      ),
                      child: Text(
                        '$title ${projects.length}',
                        style: AppTypography.headlineSm.copyWith(
                          color: colors.textPrimary,
                        ),
                      ),
                    ),
                    for (final project in projects)
                      Padding(
                        padding: const EdgeInsets.only(bottom: AppSpacing.md),
                        child: ProjectCard(
                          project: project,
                          spent: projectSpent(book.entries, project.id),
                          today: today,
                          onTap: () => edit(project),
                          onLongPress: () => delete(project),
                        ),
                      ),
                  ],
              ],
            ),
          );
        },
      ),
    );
  }
}
