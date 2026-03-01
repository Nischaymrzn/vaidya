import 'package:flutter/material.dart';
import 'package:vaidya/core/widgets/medication_card.dart';
import 'package:vaidya/features/dashboard/domain/entities/dashboard_summary_entity.dart';
import 'package:vaidya/themes/colors.dart';

class RecentMedications extends StatelessWidget {
  final List<DashboardMedicationItemEntity> medications;
  final List<DashboardTimelineItemEntity> recentRecords;

  const RecentMedications({
    super.key,
    required this.medications,
    required this.recentRecords,
  });

  @override
  Widget build(BuildContext context) {
    final items = _buildItems();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Recent Medications',
              style: TextStyle(
                fontSize: 20,
                color: AppColors.textPrimary,
                fontWeight: FontWeight.w500,
              ),
            ),
            Text(
              'View all',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AppColors.primary.withValues(alpha: 0.85),
                fontWeight: FontWeight.w600,
                fontSize: 14,
              ),
            ),
          ],
        ),
        SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: AppColors.card,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.border, width: 1),
          ),
          child: items.isEmpty
              ? Padding(
                  padding: EdgeInsets.all(16),
                  child: Text(
                    'No recent medication or health records available.',
                    style: TextStyle(
                      fontSize: 14,
                      color: AppColors.textSecondary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                )
              : ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: items.length,
                  separatorBuilder: (context, index) => Divider(
                    color: AppColors.border,
                    thickness: 1.2,
                    height: 2,
                  ),
                  itemBuilder: (context, index) {
                    final item = items[index];
                    return MedicationCard(
                      iconPath: item.iconPath,
                      title: item.title,
                      date: item.date,
                      hospital: item.hospital,
                    );
                  },
                ),
        ),
      ],
    );
  }

  List<_RecentMedicationItem> _buildItems() {
    final records = recentRecords.take(2).toList(growable: false);
    if (records.isNotEmpty) {
      return List<_RecentMedicationItem>.generate(records.length, (index) {
        final record = records[index];
        return _RecentMedicationItem(
          iconPath: index.isEven
              ? 'assets/icons/file_2.svg'
              : 'assets/icons/file_1.svg',
          title: record.title.isEmpty ? 'Health Record' : record.title,
          date: record.date,
          hospital: record.meta,
        );
      });
    }

    return medications
        .take(2)
        .map((medication) {
          return _RecentMedicationItem(
            iconPath: 'assets/icons/file_2.svg',
            title: '${medication.name} (${medication.dose})',
            date: 'Recently updated',
            hospital: medication.meta ?? 'Medication on file',
          );
        })
        .toList(growable: false);
  }
}

class _RecentMedicationItem {
  final String iconPath;
  final String title;
  final String date;
  final String hospital;

  const _RecentMedicationItem({
    required this.iconPath,
    required this.title,
    required this.date,
    required this.hospital,
  });
}
