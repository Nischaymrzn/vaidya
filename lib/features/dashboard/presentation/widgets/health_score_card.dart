import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:vaidya/features/dashboard/domain/entities/dashboard_summary_entity.dart';
import 'package:vaidya/themes/colors.dart';

class HealthScoreCard extends StatelessWidget {
  final String score;
  final String desc;
  final List<DashboardHealthScorePointEntity> trend;

  const HealthScoreCard({
    super.key,
    required this.desc,
    required this.score,
    required this.trend,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final parsedScore =
        int.tryParse(score) ?? (trend.isNotEmpty ? trend.last.score : null);
    final displayScore = parsedScore?.toString() ?? '--';
    final status = _statusLabel(parsedScore);
    final lineSpots = _buildLineSpots(parsedScore);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Health Score',
          style: TextStyle(
            fontSize: 20,
            color: AppColors.textPrimary,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.all(16),
          width: double.infinity,
          decoration: BoxDecoration(
            color: AppColors.card,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: AppColors.border, width: 1),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Stack(
                    alignment: Alignment.center,
                    children: [
                      Image.asset(
                        'assets/images/score_badge.png',
                        width: 64,
                        height: 64,
                        fit: BoxFit.contain,
                      ),
                      Text(
                        displayScore,
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.w500,
                          color: isDark ? Colors.black : AppColors.textPrimary,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'VAIDYA Score',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          desc,
                          softWrap: true,
                          style: Theme.of(context).textTheme.bodyMedium!
                              .copyWith(
                                fontSize: 14,
                                color: AppColors.textSecondary.withValues(
                                  alpha: 0.7,
                                ),
                                fontWeight: FontWeight.w600,
                                height: 1.2,
                              ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: AppColors.primarySoft,
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  status,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: AppColors.primary,
                  ),
                ),
              ),
              const SizedBox(height: 26),
              SizedBox(
                height: 26,
                child: LineChart(
                  LineChartData(
                    minY: 0,
                    maxY: 10,
                    gridData: const FlGridData(show: false),
                    titlesData: const FlTitlesData(show: false),
                    borderData: FlBorderData(show: false),
                    lineBarsData: [
                      LineChartBarData(
                        spots: lineSpots,
                        isCurved: true,
                        curveSmoothness: 0.35,
                        color: AppColors.primary,
                        barWidth: 2.2,
                        dotData: const FlDotData(show: false),
                        belowBarData: BarAreaData(show: false),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  String _statusLabel(int? score) {
    if (score == null) return 'No Data';
    if (score >= 80) return 'Great';
    if (score >= 65) return 'Good';
    if (score >= 45) return 'Watch';
    return 'Risk';
  }

  List<FlSpot> _buildLineSpots(int? parsedScore) {
    if (trend.isEmpty) {
      final endY = parsedScore != null && parsedScore >= 65 ? 7.0 : 6.0;
      return [
        const FlSpot(0, 2.0),
        const FlSpot(1, 2.0),
        const FlSpot(2, 2.0),
        const FlSpot(3, 2.0),
        FlSpot(4, endY),
        FlSpot(5, endY),
      ];
    }

    final recent = trend.length > 6 ? trend.sublist(trend.length - 6) : trend;
    final values = recent.map((e) => e.score.toDouble()).toList();
    final min = values.reduce((a, b) => a < b ? a : b);
    final max = values.reduce((a, b) => a > b ? a : b);

    if ((max - min).abs() < 0.001) {
      return [
        const FlSpot(0, 2.0),
        const FlSpot(1, 2.0),
        const FlSpot(2, 2.0),
        const FlSpot(3, 2.0),
        const FlSpot(4, 6.0),
        const FlSpot(5, 6.0),
      ];
    }

    return List<FlSpot>.generate(recent.length, (index) {
      final normalized = (recent[index].score - min) / (max - min);
      final y = 2.0 + normalized * 5.0;
      return FlSpot(index.toDouble(), y);
    });
  }
}
