import 'package:flutter/material.dart';
import 'package:vaidya/features/dashboard/domain/entities/dashboard_summary_entity.dart';
import 'package:vaidya/themes/colors.dart';

class DashboardHealthRecordsCard extends StatelessWidget {
  final List<DashboardClinicalItemEntity> items;

  const DashboardHealthRecordsCard({super.key, required this.items});

  @override
  Widget build(BuildContext context) {
    final visibleItems = items.take(3).toList(growable: false);

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Health Records',
                      style: TextStyle(
                        fontSize: 17,
                        color: AppColors.textPrimary,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      'Recent records and diagnoses',
                      style: TextStyle(
                        fontSize: 13,
                        color: AppColors.textSecondary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              OutlinedButton(
                onPressed: () {},
                style: OutlinedButton.styleFrom(
                  side: BorderSide(color: AppColors.border),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(999),
                  ),
                  padding: EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 4,
                  ),
                  minimumSize: Size.zero,
                ),
                child: Text(
                  'View Records',
                  style: TextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 14),
          if (visibleItems.isEmpty)
            Text(
              'No health records found.',
              style: TextStyle(
                fontSize: 13,
                color: AppColors.textSecondary,
                fontWeight: FontWeight.w500,
              ),
            )
          else
            ...visibleItems.map(
              (item) => Container(
                width: double.infinity,
                margin: EdgeInsets.only(bottom: 10),
                padding: EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.surfaceSoft,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.border),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.label.toUpperCase(),
                      style: TextStyle(
                        fontSize: 11,
                        letterSpacing: 0.4,
                        color: AppColors.textSecondary,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    SizedBox(height: 6),
                    Text(
                      item.value,
                      style: TextStyle(
                        fontSize: 15,
                        color: AppColors.textPrimary,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      item.meta,
                      style: TextStyle(
                        fontSize: 12,
                        color: AppColors.textSecondary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}
