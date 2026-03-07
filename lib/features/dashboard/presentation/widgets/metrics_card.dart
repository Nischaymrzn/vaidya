import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:vaidya/features/vitals/presentation/pages/metric_detail_page.dart';
import 'package:vaidya/themes/colors.dart';

class MetricsCard extends StatelessWidget {
  final String iconPath;
  final String name;
  final String value;
  final String unit;
  final String condition;
  final int scorePercent;
  final List<double> historyPoints;

  const MetricsCard({
    super.key,
    required this.iconPath,
    required this.name,
    required this.value,
    required this.unit,
    required this.condition,
    required this.scorePercent,
    required this.historyPoints,
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
              scorePercent: scorePercent,
              historyPoints: historyPoints,
            ),
          ),
        );
      },
      child: Container(
        padding: const EdgeInsets.fromLTRB(14, 8, 0, 0),
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
                  padding: const EdgeInsets.all(8),
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: Color(0xFFE5E7EB),
                    shape: BoxShape.circle,
                  ),
                  child: SvgPicture.asset(iconPath, height: 16, width: 16),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 15,
                      color: AppColors.textSecondary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 22),
            Padding(
              padding: const EdgeInsets.only(left: 2),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    width: double.infinity,
                    child: FittedBox(
                      alignment: Alignment.centerLeft,
                      fit: BoxFit.scaleDown,
                      child: RichText(
                        text: TextSpan(
                          text: value,
                          style: const TextStyle(
                            color: AppColors.textPrimary,
                            fontSize: 20,
                            height: 1.0,
                            fontWeight: FontWeight.w600,
                            fontFamily: 'Urbanist',
                          ),
                          children: [
                            TextSpan(
                              text: '  $unit',
                              style: TextStyle(
                                color: AppColors.textSecondary.withValues(
                                  alpha: 0.78,
                                ),
                                fontSize: 12,
                                height: 1.0,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 3),
                  // Condition Badge
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: _getConditionColor(),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      condition,
                      style: const TextStyle(
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
