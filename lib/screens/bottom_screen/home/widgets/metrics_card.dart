import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:vaidya/screens/bottom_screen/home/metric_detail_page.dart';
import 'package:vaidya/themes/colors.dart';

class MetricsCard extends StatelessWidget {
  final String iconPath;
  final String name;
  final String value;
  final String unit;
  final String condition;

  const MetricsCard({
    super.key,
    required this.iconPath,
    required this.name,
    required this.value,
    required this.unit,
    required this.condition,
  });

  Color _getConditionColor() {
    switch (condition.toLowerCase()) {
      case 'normal':
        return const Color(0xFFBBF7D0);
      case 'low':
        return const Color(0xFFFEF3C7);
      case 'high':
        return const Color(0xFFFECDD3);
      default:
        return const Color(0xFFBBF7D0);
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        // Navigate to detail page
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => MetricDetailPage(
              metricName: name,
              iconPath: iconPath,
              value: value,
              unit: unit,
              condition: condition,
            ),
          ),
        );
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.card,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Color(0xFFE2DCD5), width: 1.25),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: Color(0xFFE5E7EB),
                    shape: BoxShape.circle,
                  ),
                  child: SvgPicture.asset(iconPath, height: 20, width: 20),
                ),
                const SizedBox(width: 8),
                Text(
                  name,
                  style: TextStyle(
                    fontSize: 17,
                    color: AppColors.textSecondary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.only(left: 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  RichText(
                    text: TextSpan(
                      text: value,
                      style: TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 26,
                        fontWeight: FontWeight.w500,
                        fontFamily: "Urbanist",
                      ),
                      children: [
                        TextSpan(
                          text: ' $unit',
                          style: TextStyle(
                            color: AppColors.textSecondary.withAlpha(200),
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 8),
                  // Condition Badge
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: _getConditionColor(),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      condition,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
