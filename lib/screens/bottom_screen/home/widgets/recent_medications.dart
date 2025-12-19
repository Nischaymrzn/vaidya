import 'package:flutter/material.dart';
import 'package:vaidya/widgets/medication_card.dart';
import 'package:vaidya/themes/colors.dart';

final List<Map<String, dynamic>> medications = [
  {
    "iconPath": "assets/icons/file_2.svg",
    "title": "Complete Blood Count (CBC)",
    "date": "Oct 20, 2025",
    "hospital": "Bir Hospital",
  },
  {
    "iconPath": "assets/icons/file_1.svg",
    "title": "Discharge Summary",
    "date": "Sep 12, 2025",
    "hospital": "Bir Hospital",
  },
];

class RecentMedications extends StatelessWidget {
  const RecentMedications({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              "Recent Medications",
              style: Theme.of(context).textTheme.titleLarge,
            ),
            Text(
              "View all",
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AppColors.textSecondary.withAlpha(203),
                fontWeight: FontWeight.w500,
                fontSize: 14,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: AppColors.card,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Color(0xFFE2DCD5), width: 1),
          ),
          child: ListView.separated(
            shrinkWrap: true,
            physics: NeverScrollableScrollPhysics(),
            itemCount: medications.length,
            separatorBuilder: (context, index) => Divider(
              color: Colors.grey.shade300,
              thickness: 1.5,
              height: 24,
            ),
            itemBuilder: (context, index) {
              final med = medications[index];
              return MedicationCard(
                iconPath: med['iconPath'],
                title: med['title'],
                date: med['date'],
                hospital: med['hospital'],
              );
            },
          ),
        ),
      ],
    );
  }
}
