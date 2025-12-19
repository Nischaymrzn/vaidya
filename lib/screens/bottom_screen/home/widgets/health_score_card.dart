import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:vaidya/themes/colors.dart';

class HealthScoreCard extends StatelessWidget {
  final String score;
  final String desc;

  const HealthScoreCard({super.key, required this.desc, required this.score});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("Health Score", style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.all(16),
          width: double.infinity,
          decoration: BoxDecoration(
            color: Colors.white,
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
                    alignment: Alignment.bottomCenter,
                    children: [
                      Image.asset(
                        'assets/images/score_badge.png',
                        width: 70,
                        height: 72,
                        fit: BoxFit.contain,
                      ),
                      Text(
                        score,
                        style: Theme.of(
                          context,
                        ).textTheme.bodyLarge!.copyWith(fontSize: 24),
                      ),
                    ],
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Vaidya Score',
                          style: Theme.of(context).textTheme.titleLarge!
                              .copyWith(
                                fontWeight: FontWeight.w500,
                                fontSize: 21,
                              ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          desc,
                          softWrap: true,
                          style: Theme.of(context).textTheme.bodyMedium!
                              .copyWith(
                                fontSize: 16,
                                color: AppColors.textSecondary.withOpacity(0.7),
                                fontWeight: FontWeight.w500,
                                height: 1.2,
                              ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              SizedBox(
                height: 60,
                child: LineChart(
                  LineChartData(
                    gridData: FlGridData(show: false),
                    titlesData: FlTitlesData(show: false),
                    borderData: FlBorderData(show: false),
                    minY: 0,
                    maxY: 100,
                    lineBarsData: [
                      LineChartBarData(
                        spots: const [
                          FlSpot(0, 72),
                          FlSpot(1, 64),
                          FlSpot(2, 89),
                          FlSpot(3, 65),
                          FlSpot(4, 82),
                          FlSpot(5, 55),
                          FlSpot(6, 79),
                          FlSpot(7, 82),
                          FlSpot(8, 72),
                          FlSpot(9, 88),
                        ],
                        isCurved: true,
                        curveSmoothness: 0.35,
                        color: const Color(0xFF7FE5D8),
                        barWidth: 2.5,
                        dotData: FlDotData(show: false),
                        belowBarData: BarAreaData(
                          show: true,
                          gradient: LinearGradient(
                            colors: [
                              const Color(0xFF7FE5D8).withOpacity(0.3),
                              const Color(0xFF7FE5D8).withOpacity(0.05),
                            ],
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                          ),
                        ),
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
}
