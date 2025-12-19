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
              "View all",
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AppColors.textSecondary.withOpacity(0.8),
                fontWeight: FontWeight.w500,
                fontSize: 14,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),

        LayoutBuilder(
          builder: (context, constraints) {
            // If width less than 600: 2 columns, else 4 columns
            int crossAxisCount = constraints.maxWidth < 600 ? 2 : 4;

            return GridView.count(
              shrinkWrap: true,
              crossAxisCount: crossAxisCount,
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
                  condition: "Normal",
                ),
                MetricsCard(
                  iconPath: "assets/icons/blood_pressure.svg",
                  name: "Blood Pressure",
                  value: "90",
                  unit: "mmHg",
                  condition: "High",
                ),
                MetricsCard(
                  iconPath: "assets/icons/blood_sugar.svg",
                  name: "Blood Sugar",
                  value: "92",
                  unit: "mg/dL",
                  condition: "Low",
                ),
                MetricsCard(
                  iconPath: "assets/icons/bmi.svg",
                  name: "BMI",
                  value: "20",
                  unit: "kg/m",
                  condition: "Normal",
                ),
              ],
            );
          },
        ),
      ],
    );
  }
}
