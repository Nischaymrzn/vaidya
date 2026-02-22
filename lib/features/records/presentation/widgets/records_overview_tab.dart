import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:vaidya/features/records/domain/entities/medical_record_entity.dart';
import 'package:vaidya/features/records/presentation/widgets/record_menu_action.dart';
import 'package:vaidya/features/records/presentation/widgets/records_ui_helpers.dart';
import 'package:vaidya/themes/colors.dart';

class RecordsOverviewTab extends StatelessWidget {
  final List<MedicalRecordEntity> allRecords;
  final int aiProcessedCount;
  final VoidCallback onScanTap;
  final void Function(MedicalRecordEntity record, RecordMenuAction action)
  onRecordAction;

  const RecordsOverviewTab({
    super.key,
    required this.allRecords,
    required this.aiProcessedCount,
    required this.onScanTap,
    required this.onRecordAction,
  });

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final fourteenDaysAgo = now.subtract(const Duration(days: 14));
    final newUploads = allRecords.where((record) {
      final date = tryParseDate(record.effectiveDate);
      if (date == null) return false;
      return date.isAfter(fourteenDaysAgo);
    }).length;
    final providerCount = allRecords
        .map((record) => (record.provider ?? '').trim())
        .where((provider) => provider.isNotEmpty)
        .toSet()
        .length;
    final recentRecords = [...allRecords]
      ..sort((a, b) {
        final aDate =
            tryParseDate(a.effectiveDate)?.millisecondsSinceEpoch ?? 0;
        final bDate =
            tryParseDate(b.effectiveDate)?.millisecondsSinceEpoch ?? 0;
        return bDate.compareTo(aDate);
      });
    final recent = recentRecords.take(3).toList(growable: false);
    final insights = _buildInsights(allRecords);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        LayoutBuilder(
          builder: (context, constraints) {
            final width = constraints.maxWidth;
            final cardAspectRatio = width < 360
                ? 1.55
                : width < 430
                ? 1.7
                : 1.9;

            return GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              padding: EdgeInsets.zero,
              crossAxisCount: 2,
              mainAxisSpacing: 10,
              crossAxisSpacing: 10,
              childAspectRatio: cardAspectRatio,
              children: [
                _OverviewStatItem(
                  data: _OverviewStatData(
                    label: 'Total records',
                    value: '${allRecords.length}',
                    detail: 'All time',
                  ),
                ),
                _OverviewStatItem(
                  data: _OverviewStatData(
                    label: 'New uploads',
                    value: '$newUploads',
                    detail: 'Last 14 days',
                  ),
                ),
                _OverviewStatItem(
                  data: _OverviewStatData(
                    label: 'AI processed',
                    value: '$aiProcessedCount',
                    detail: 'Ready to review',
                  ),
                ),
                _OverviewStatItem(
                  data: _OverviewStatData(
                    label: 'Providers',
                    value: '$providerCount',
                    detail: 'Connected sources',
                  ),
                ),
              ],
            );
          },
        ),
        const SizedBox(height: 12),
        LayoutBuilder(
          builder: (context, constraints) {
            final isWide = constraints.maxWidth >= 980;
            if (!isWide) {
              return Column(
                children: [
                  _recentRecordsCard(recent, count: recent.length),
                  const SizedBox(height: 20),
                  _aiScanCard(),
                  const SizedBox(height: 12),
                  _aiInsightsCard(insights),
                ],
              );
            }

            return Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  flex: 7,
                  child: _recentRecordsCard(recent, count: recent.length),
                ),
                const SizedBox(width: 20),
                Expanded(
                  flex: 3,
                  child: Column(
                    children: [
                      _aiScanCard(),
                      const SizedBox(height: 12),
                      _aiInsightsCard(insights),
                    ],
                  ),
                ),
              ],
            );
          },
        ),
      ],
    );
  }

  Widget _recentRecordsCard(
    List<MedicalRecordEntity> recent, {
    required int count,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 12, 14, 8),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    'Recent Medications',
                    style: TextStyle(
                      fontFamily: 'Urbanist',
                      fontSize: 18,
                      color: AppColors.textPrimary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                Text(
                  '$count records',
                  style: TextStyle(
                    fontFamily: 'Urbanist',
                    fontSize: 13,
                    color: AppColors.textSecondary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          if (recent.isNotEmpty)
            Divider(height: 1, color: AppColors.border.withValues(alpha: 0.9)),
          if (recent.isEmpty)
            const Padding(
              padding: EdgeInsets.all(10),
              child: Text(
                'No recent medications available.',
                style: TextStyle(
                  fontFamily: 'Urbanist',
                  fontSize: 14,
                  color: AppColors.textSecondary,
                  fontWeight: FontWeight.w500,
                ),
              ),
            )
          else
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              padding: const EdgeInsets.only(bottom: 12),
              itemCount: recent.length,
              separatorBuilder: (context, index) => Divider(
                color: AppColors.border.withValues(alpha: 0.9),
                thickness: 1,
                height: 1,
              ),
              itemBuilder: (context, index) {
                final record = recent[index];
                return Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 10,
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 34,
                        height: 34,
                        padding: const EdgeInsets.all(5),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF5EDEE),
                          shape: BoxShape.circle,
                          border: Border.all(color: AppColors.border),
                        ),
                        child: SvgPicture.asset(
                          index.isEven
                              ? 'assets/icons/file_2.svg'
                              : 'assets/icons/file_1.svg',
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              record.title,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontFamily: 'Urbanist',
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: AppColors.textPrimary,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Row(
                              children: [
                                Text(
                                  formatDateLabel(record.effectiveDate),
                                  style: TextStyle(
                                    fontFamily: 'Urbanist',
                                    fontSize: 13.5,
                                    fontWeight: FontWeight.w500,
                                    color: AppColors.textSecondary,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Text(
                                    (record.provider?.trim().isNotEmpty ??
                                            false)
                                        ? record.provider!.trim()
                                        : 'Unspecified',
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                      fontFamily: 'Urbanist',
                                      fontSize: 13.5,
                                      fontWeight: FontWeight.w500,
                                      color: AppColors.textSecondary,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      _RecordActionsMenu(
                        onSelected: (action) => onRecordAction(record, action),
                      ),
                    ],
                  ),
                );
              },
            ),
        ],
      ),
    );
  }

  Widget _aiScanCard() {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 8, 12, 6),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'AI scan intake',
                  style: TextStyle(
                    fontFamily: 'Urbanist',
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Upload a file to generate a draft record.',
                  style: TextStyle(
                    fontFamily: 'Urbanist',
                    fontSize: 14,
                    color: AppColors.textSecondary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          Padding(
            padding: const EdgeInsets.all(10),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: AppColors.primary.withValues(alpha: 0.2),
                ),
                color: AppColors.primary.withValues(alpha: 0.05),
              ),
              child: Column(
                children: [
                  const Icon(
                    Icons.cloud_upload_outlined,
                    color: AppColors.primary,
                    size: 28,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Drop files here or click to upload',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontFamily: 'Urbanist',
                      fontSize: 14.5,
                      color: AppColors.textPrimary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'JPG, PNG, WEBP up to 5 MB.',
                    style: TextStyle(
                      fontFamily: 'Urbanist',
                      fontSize: 13,
                      color: AppColors.textSecondary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 6),
                  ElevatedButton(
                    onPressed: onScanTap,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(999),
                      ),
                    ),
                    child: const Text('Select files'),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _aiInsightsCard(List<_InsightItem> insights) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 8, 12, 6),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'AI insights',
                        style: TextStyle(
                          fontFamily: 'Urbanist',
                          fontSize: 20,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Suggestions based on uploaded records only.',
                        style: TextStyle(
                          fontFamily: 'Urbanist',
                          fontSize: 14,
                          color: AppColors.textSecondary,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
                TextButton(
                  onPressed: () {},
                  style: TextButton.styleFrom(
                    foregroundColor: AppColors.primary,
                    textStyle: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                  child: const Text('Refresh'),
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          Padding(
            padding: const EdgeInsets.all(10),
            child: Column(
              children: insights
                  .map(
                    (item) => Container(
                      width: double.infinity,
                      margin: const EdgeInsets.only(bottom: 6),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(14),
                        color: item.bgColor,
                        border: Border.all(color: item.borderColor),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  item.title,
                                  style: TextStyle(
                                    fontFamily: 'Urbanist',
                                    fontSize: 15.5,
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.textPrimary,
                                  ),
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 3,
                                ),
                                decoration: BoxDecoration(
                                  color: item.badgeBg,
                                  borderRadius: BorderRadius.circular(999),
                                ),
                                child: Text(
                                  item.level,
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: item.badgeText,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 6),
                          Text(
                            item.body,
                            style: TextStyle(
                              fontFamily: 'Urbanist',
                              fontSize: 14,
                              color: AppColors.textSecondary,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                  .toList(growable: false),
            ),
          ),
        ],
      ),
    );
  }

  List<_InsightItem> _buildInsights(List<MedicalRecordEntity> records) {
    if (records.isEmpty) {
      return const [
        _InsightItem(
          title: 'Add initial records',
          body:
              'Upload two records to start provider and date consistency insights.',
          level: 'INFO',
          bgColor: Color(0xFFF3F8FF),
          borderColor: Color(0xFFD5E7FF),
          badgeBg: Color(0xFFE7F1FF),
          badgeText: AppColors.primary,
        ),
        _InsightItem(
          title: 'No AI processed records',
          body:
              'Use AI scan inbox to extract metadata from files automatically.',
          level: 'INFO',
          bgColor: Color(0xFFF3F8FF),
          borderColor: Color(0xFFD5E7FF),
          badgeBg: Color(0xFFE7F1FF),
          badgeText: AppColors.primary,
        ),
      ];
    }

    final missingProvider = records
        .where((record) => (record.provider ?? '').trim().isEmpty)
        .length;
    final missingDate = records
        .where((record) => tryParseDate(record.effectiveDate) == null)
        .length;

    return [
      _InsightItem(
        title: missingProvider > 0
            ? 'Missing provider details'
            : 'Provider data looks complete',
        body: missingProvider > 0
            ? '$missingProvider records are missing provider information.'
            : 'Most records have provider information.',
        level: missingProvider > 0 ? 'MEDIUM' : 'GOOD',
        bgColor: missingProvider > 0
            ? const Color(0xFFFFF8E8)
            : const Color(0xFFEFFAF2),
        borderColor: missingProvider > 0
            ? const Color(0xFFF7D69A)
            : const Color(0xFFB8E4C3),
        badgeBg: missingProvider > 0
            ? const Color(0xFFFFF1CC)
            : const Color(0xFFD8F3DF),
        badgeText: missingProvider > 0
            ? const Color(0xFF9A6700)
            : const Color(0xFF1B7D38),
      ),
      _InsightItem(
        title: missingDate > 0
            ? 'Missing record dates'
            : 'Date timeline is stable',
        body: missingDate > 0
            ? '$missingDate records are missing date fields.'
            : 'Records have valid dates for timeline sorting.',
        level: missingDate > 0 ? 'MEDIUM' : 'GOOD',
        bgColor: missingDate > 0
            ? const Color(0xFFFFF8E8)
            : const Color(0xFFEFFAF2),
        borderColor: missingDate > 0
            ? const Color(0xFFF7D69A)
            : const Color(0xFFB8E4C3),
        badgeBg: missingDate > 0
            ? const Color(0xFFFFF1CC)
            : const Color(0xFFD8F3DF),
        badgeText: missingDate > 0
            ? const Color(0xFF9A6700)
            : const Color(0xFF1B7D38),
      ),
    ];
  }
}

class _OverviewStatItem extends StatelessWidget {
  final _OverviewStatData data;

  const _OverviewStatItem({required this.data});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      padding: const EdgeInsets.all(8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            data.label.toUpperCase(),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontFamily: 'Urbanist',
              fontSize: 11.5,
              letterSpacing: 0.4,
              color: AppColors.textSecondary,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 1),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(
              data.value,
              style: TextStyle(
                fontFamily: 'Urbanist',
                fontSize: 27,
                color: AppColors.textPrimary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          const SizedBox(height: 1),
          Text(
            data.detail,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontFamily: 'Urbanist',
              fontSize: 13,
              color: AppColors.textSecondary,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

class _RecordActionsMenu extends StatelessWidget {
  final ValueChanged<RecordMenuAction> onSelected;

  const _RecordActionsMenu({required this.onSelected});

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<RecordMenuAction>(
      icon: const Icon(Icons.more_horiz, size: 20),
      color: Colors.white,
      padding: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
        side: const BorderSide(color: AppColors.border),
      ),
      onSelected: onSelected,
      itemBuilder: (context) => const [
        PopupMenuItem(
          value: RecordMenuAction.viewRecord,
          child: _MenuLabel(
            icon: Icons.visibility_outlined,
            label: 'View record',
          ),
        ),
        PopupMenuItem(
          value: RecordMenuAction.viewPdf,
          child: _MenuLabel(
            icon: Icons.insert_drive_file_outlined,
            label: 'View as PDF',
          ),
        ),
        PopupMenuItem(
          value: RecordMenuAction.viewImage,
          child: _MenuLabel(icon: Icons.image_outlined, label: 'View as image'),
        ),
        PopupMenuItem(
          value: RecordMenuAction.download,
          child: _MenuLabel(icon: Icons.download_rounded, label: 'Download'),
        ),
        PopupMenuItem(
          value: RecordMenuAction.edit,
          child: _MenuLabel(icon: Icons.edit_outlined, label: 'Edit'),
        ),
        PopupMenuItem(
          value: RecordMenuAction.delete,
          child: _MenuLabel(
            icon: Icons.delete_outline_rounded,
            label: 'Delete',
            isDelete: true,
          ),
        ),
      ],
    );
  }
}

class _MenuLabel extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isDelete;

  const _MenuLabel({
    required this.icon,
    required this.label,
    this.isDelete = false,
  });

  @override
  Widget build(BuildContext context) {
    final color = isDelete ? const Color(0xFFE53935) : AppColors.textPrimary;
    return Row(
      children: [
        Icon(icon, size: 18, color: color),
        const SizedBox(width: 10),
        Text(
          label,
          style: TextStyle(
            fontFamily: 'Urbanist',
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: color,
          ),
        ),
      ],
    );
  }
}

class _OverviewStatData {
  final String label;
  final String value;
  final String detail;

  const _OverviewStatData({
    required this.label,
    required this.value,
    required this.detail,
  });
}

class _InsightItem {
  final String title;
  final String body;
  final String level;
  final Color bgColor;
  final Color borderColor;
  final Color badgeBg;
  final Color badgeText;

  const _InsightItem({
    required this.title,
    required this.body,
    required this.level,
    required this.bgColor,
    required this.borderColor,
    required this.badgeBg,
    required this.badgeText,
  });
}
