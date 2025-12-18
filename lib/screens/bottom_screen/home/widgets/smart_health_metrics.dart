import 'package:flutter/material.dart';
import 'package:vaidya/screens/bottom_screen/home/widgets/metrics_card.dart';
import 'package:vaidya/themes/colors.dart';

class SmartHealthMetrics extends StatelessWidget {
  const SmartHealthMetrics({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              "Smart Health Metrics",
              style: Theme.of(context).textTheme.titleLarge,
            ),
            Text(
              "View All",
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AppColors.textSecondary,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),

        // 2x2 Grid
        GridView.count(
          shrinkWrap: true,
          crossAxisCount: 2,
          mainAxisSpacing: 10,
          crossAxisSpacing: 10,
          childAspectRatio: 166 / 139,
          physics: NeverScrollableScrollPhysics(),
          children: [
            MetricsCard(
              iconPath: "assets/icons/heart_rate.svg",
              name: "Heart Rate",
              value: "89",
              unit: "bpm",
              updated: "Last update 1 day ago",
            ),
            MetricsCard(
              iconPath: "assets/icons/blood_pressure.svg",
              name: "Blood Pressure",
              value: "90",
              unit: "mmHg",
              updated: "Last update 9 day ago",
            ),
            MetricsCard(
              iconPath: "assets/icons/blood_sugar.svg",
              name: "Blood Sugar",
              value: "92",
              unit: "mg/dL",
              updated: "Last update 1 day ago",
            ),
            MetricsCard(
              iconPath: "assets/icons/bmi.svg",
              name: "BMI",
              value: "20",
              unit: "kg/m",
              updated: "Last update 1 day ago",
            ),
          ],
        ),
      ],
    );
  }
}
