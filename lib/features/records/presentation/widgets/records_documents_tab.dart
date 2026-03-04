import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:vaidya/features/records/domain/entities/medical_record_entity.dart';
import 'package:vaidya/features/records/presentation/widgets/record_menu_action.dart';
import 'package:vaidya/features/records/presentation/widgets/records_ui_helpers.dart';
import 'package:vaidya/themes/colors.dart';

const double _kDocIconSlotWidth = 44;

class RecordsDocumentsTab extends StatelessWidget {
  final List<MedicalRecordEntity> records;
  final String searchTerm;
  final ValueChanged<String> onSearchChanged;
  final int currentPage;
  final int pageSize;
  final ValueChanged<int> onPageChanged;
  final VoidCallback onAddMore;
  final void Function(MedicalRecordEntity record, RecordMenuAction action)
  onRecordAction;

  const RecordsDocumentsTab({
    super.key,
    required this.records,
    required this.searchTerm,
    required this.onSearchChanged,
    required this.currentPage,
    required this.pageSize,
    required this.onPageChanged,
    required this.onAddMore,
    required this.onRecordAction,
  });

  @override
  Widget build(BuildContext context) {
    final safePageSize = pageSize <= 0 ? 10 : pageSize;
    final totalCount = records.length;
    final totalPages = totalCount == 0
        ? 1
        : ((totalCount + safePageSize - 1) ~/ safePageSize);
    final normalizedPage = currentPage.clamp(1, totalPages);
    final start = totalCount == 0 ? 0 : (normalizedPage - 1) * safePageSize;
    final end = totalCount == 0
        ? 0
        : (start + safePageSize).clamp(0, totalCount);
    final pageRecords = records.sublist(start, end);

    final grouped = _groupByYear(pageRecords);
    final years = grouped.keys.toList()..sort((a, b) => b.compareTo(a));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                'Your documents',
                style: TextStyle(
                  fontFamily: 'Urbanist',
                  fontSize: 20,
                  fontWeight: FontWeight.w500,
                  color: AppColors.textPrimary,
                ),
              ),
            ),
            OutlinedButton.icon(
              onPressed: onAddMore,
              style: OutlinedButton.styleFrom(
                padding: EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(999),
                ),
              ),
              icon: Icon(Icons.add_rounded, size: 16),
              label: Text(
                'Add more',
                style: TextStyle(
                  fontFamily: 'Urbanist',
                  fontSize: 13.5,
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
        SizedBox(height: 10),
        Container(
          padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: AppColors.card,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.border),
          ),
          child: TextFormField(
            onChanged: onSearchChanged,
            initialValue: searchTerm,
            style: TextStyle(
              fontFamily: 'Urbanist',
              fontSize: 14.5,
              color: AppColors.textPrimary,
              fontWeight: FontWeight.w500,
            ),
            decoration: InputDecoration(
              isDense: true,
              hintText: 'Search records...',
              hintStyle: TextStyle(
                fontFamily: 'Urbanist',
                fontSize: 14,
                color: AppColors.textSecondary,
              ),
              prefixIcon: Icon(Icons.search_rounded, size: 18),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(999),
                borderSide: BorderSide(
                  color: AppColors.primary.withValues(alpha: 0.25),
                ),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(999),
                borderSide: BorderSide(
                  color: AppColors.primary.withValues(alpha: 0.25),
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(999),
                borderSide: BorderSide(color: AppColors.primary),
              ),
            ),
          ),
        ),
        SizedBox(height: 12),
        if (totalCount == 0)
          Container(
            width: double.infinity,
            padding: EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.card,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.border),
            ),
            child: Text(
              'No records available yet. Add your first record.',
              style: TextStyle(
                fontFamily: 'Urbanist',
                fontSize: 14.5,
                fontWeight: FontWeight.w500,
                color: AppColors.textSecondary,
              ),
            ),
          ),
        ...years.map((year) {
          final items = grouped[year] ?? <MedicalRecordEntity>[];
          return _YearSection(
            year: year,
            records: items,
            onRecordAction: onRecordAction,
          );
        }),
        if (totalCount > 0) ...[
          SizedBox(height: 16),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 4, vertical: 2),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    'Showing ${start + 1}-$end of $totalCount records',
                    style: TextStyle(
                      fontFamily: 'Urbanist',
                      fontSize: 13.5,
                      color: AppColors.textSecondary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                OutlinedButton(
                  onPressed: normalizedPage > 1
                      ? () => onPageChanged(normalizedPage - 1)
                      : null,
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                    textStyle: const TextStyle(
                      fontSize: 13.5,
                      fontWeight: FontWeight.w500,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(999),
                    ),
                  ),
                  child: const Text('Previous'),
                ),
                const SizedBox(width: 8),
                OutlinedButton(
                  onPressed: normalizedPage < totalPages
                      ? () => onPageChanged(normalizedPage + 1)
                      : null,
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                    textStyle: const TextStyle(
                      fontSize: 13.5,
                      fontWeight: FontWeight.w500,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(999),
                    ),
                  ),
                  child: const Text('Next'),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }

  Map<int, List<MedicalRecordEntity>> _groupByYear(
    List<MedicalRecordEntity> source,
  ) {
    final map = <int, List<MedicalRecordEntity>>{};
    final sorted = [...source]
      ..sort((a, b) {
        final aDate =
            tryParseDate(a.effectiveDate)?.millisecondsSinceEpoch ?? 0;
        final bDate =
            tryParseDate(b.effectiveDate)?.millisecondsSinceEpoch ?? 0;
        return bDate.compareTo(aDate);
      });

    for (final record in sorted) {
      final year = recordYear(record);
      map.putIfAbsent(year, () => <MedicalRecordEntity>[]).add(record);
    }
    return map;
  }
}

class _YearSection extends StatelessWidget {
  final int year;
  final List<MedicalRecordEntity> records;
  final void Function(MedicalRecordEntity record, RecordMenuAction action)
  onRecordAction;

  const _YearSection({
    required this.year,
    required this.records,
    required this.onRecordAction,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.only(left: 2, bottom: 6),
            child: Text(
              '$year',
              style: TextStyle(
                fontFamily: 'Urbanist',
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: AppColors.textSecondary,
                letterSpacing: 0.3,
              ),
            ),
          ),
          Container(
            decoration: BoxDecoration(
              color: AppColors.card,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.border),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.04),
                  blurRadius: 8,
                  offset: Offset(0, 1),
                ),
              ],
            ),
            child: Column(
              children: [
                _DocumentsHeaderRow(),
                Divider(
                  color: AppColors.border.withValues(alpha: 0.9),
                  height: 1,
                ),
                ListView.separated(
                  shrinkWrap: true,
                  physics: NeverScrollableScrollPhysics(),
                  padding: EdgeInsets.zero,
                  itemCount: records.length,
                  separatorBuilder: (_, __) => Divider(
                    color: AppColors.border.withValues(alpha: 0.9),
                    height: 1,
                  ),
                  itemBuilder: (context, index) {
                    final record = records[index];
                    return _DocumentTile(
                      isFirst: index == 0,
                      record: record,
                      iconPath: index.isEven
                          ? 'assets/icons/file_2.svg'
                          : 'assets/icons/file_1.svg',
                      onRecordAction: onRecordAction,
                    );
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _DocumentTile extends StatelessWidget {
  final bool isFirst;
  final MedicalRecordEntity record;
  final String iconPath;
  final void Function(MedicalRecordEntity record, RecordMenuAction action)
  onRecordAction;

  const _DocumentTile({
    this.isFirst = false,
    required this.record,
    required this.iconPath,
    required this.onRecordAction,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(14, isFirst ? 14 : 14, 14, 14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SizedBox(
            width: _kDocIconSlotWidth,
            child: Align(
              alignment: Alignment.centerLeft,
              child: Container(
                width: 34,
                height: 34,
                padding: EdgeInsets.all(5),
                decoration: BoxDecoration(
                  color: AppColors.surfaceSoft,
                  shape: BoxShape.circle,
                  border: Border.all(color: AppColors.border),
                ),
                child: SvgPicture.asset(iconPath),
              ),
            ),
          ),
          Expanded(
            child: Row(
              children: [
                Expanded(
                  flex: 2,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        record.title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontFamily: 'Urbanist',
                          fontSize: 15.5,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        formatDateLabel(record.effectiveDate),
                        style: TextStyle(
                          fontFamily: 'Urbanist',
                          fontSize: 13.5,
                          fontWeight: FontWeight.w500,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  flex: 2,
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      (record.provider?.trim().isNotEmpty ?? false)
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
                ),
                Expanded(
                  flex: 1,
                  child: Align(
                    alignment: Alignment.centerRight,
                    child: PopupMenuButton<RecordMenuAction>(
                      color: AppColors.card,
                      padding: EdgeInsets.zero,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                        side: BorderSide(color: AppColors.border),
                      ),
                      onSelected: (action) => onRecordAction(record, action),
                      itemBuilder: (context) => [
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
                            icon: Icons.picture_as_pdf_outlined,
                            label: 'View as PDF',
                          ),
                        ),
                        PopupMenuItem(
                          value: RecordMenuAction.viewImage,
                          child: _MenuLabel(
                            icon: Icons.image_outlined,
                            label: 'View as image',
                          ),
                        ),
                        PopupMenuItem(
                          value: RecordMenuAction.download,
                          child: _MenuLabel(
                            icon: Icons.download_rounded,
                            label: 'Download',
                          ),
                        ),
                        PopupMenuItem(
                          value: RecordMenuAction.edit,
                          child: _MenuLabel(
                            icon: Icons.edit_outlined,
                            label: 'Edit',
                          ),
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
                      child: const SizedBox(
                        width: 24,
                        height: 24,
                        child: Icon(Icons.more_horiz, size: 20),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _DocumentsHeaderRow extends StatelessWidget {
  const _DocumentsHeaderRow();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(14, 8, 14, 2),
      child: Row(
        children: [
          SizedBox(width: _kDocIconSlotWidth),
          Expanded(
            child: Row(
              children: [
                Expanded(
                  flex: 2,
                  child: Text(
                    'TITLE',
                    style: TextStyle(
                      fontFamily: 'Urbanist',
                      fontSize: 11.5,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textSecondary,
                      letterSpacing: 0.3,
                    ),
                  ),
                ),
                Expanded(
                  flex: 2,
                  child: Text(
                    'HOSPITAL',
                    style: TextStyle(
                      fontFamily: 'Urbanist',
                      fontSize: 11.5,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textSecondary,
                      letterSpacing: 0.3,
                    ),
                  ),
                ),
                Expanded(
                  flex: 1,
                  child: Align(
                    alignment: Alignment.centerRight,
                    child: Text(
                      'ACTION',
                      textAlign: TextAlign.right,
                      style: TextStyle(
                        fontFamily: 'Urbanist',
                        fontSize: 11.5,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textSecondary,
                        letterSpacing: 0.3,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
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
    final color = isDelete ? Color(0xFFE53935) : AppColors.textPrimary;
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
