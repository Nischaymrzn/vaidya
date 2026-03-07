import 'dart:math' as math;

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:vaidya/features/vitals/presentation/models/vitals_view_data.dart';
import 'package:vaidya/themes/colors.dart';

class VitalsTrendOverviewCard extends StatelessWidget {
  final List<VitalsTrendPointViewData> trend;
  final List<VitalsSummaryCardViewData> stats;

  const VitalsTrendOverviewCard({
    super.key,
    required this.trend,
    required this.stats,
  });

  @override
  Widget build(BuildContext context) {
    final heartSpots = _spots((point) => point.heartRate);
    final systolicSpots = _spots((point) => point.systolic);
    final glucoseSpots = _spots((point) => point.glucose);

    final allValues = [
      ...heartSpots.map((spot) => spot.y),
      ...systolicSpots.map((spot) => spot.y),
      ...glucoseSpots.map((spot) => spot.y),
    ];

    final maxY = allValues.isEmpty
        ? 140.0
        : (allValues.reduce(math.max) + 18).clamp(40, 240).toDouble();
    final minY = allValues.isEmpty
        ? 0.0
        : (allValues.reduce(math.min) - 18).clamp(0, maxY - 20).toDouble();

    return Container(
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.border),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0A1F2937),
            blurRadius: 8,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 14, 16, 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            LayoutBuilder(
              builder: (context, constraints) {
                final wide = constraints.maxWidth >= 640;

                if (wide) {
                  return const Row(
                    children: [
                      Expanded(
                        child: Text(
                          'Trend Overview',
                          style: TextStyle(
                            fontFamily: 'Urbanist',
                            fontSize: 20,
                            height: 1.0,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ),
                      SizedBox(width: 8),
                      Flexible(
                        child: Text(
                          'Heart rate, blood pressure & glucose from oldest to latest readings.',
                          textAlign: TextAlign.right,
                          style: TextStyle(
                            fontFamily: 'Urbanist',
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ),
                    ],
                  );
                }

                return const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Trend Overview',
                      style: TextStyle(
                        fontFamily: 'Urbanist',
                        fontSize: 20,
                        height: 1.0,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    SizedBox(height: 5),
                    Text(
                      'Heart rate, blood pressure & glucose from oldest to latest readings.',
                      style: TextStyle(
                        fontFamily: 'Urbanist',
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                );
              },
            ),
            const SizedBox(height: 10),
            SizedBox(
              height: 210,
              child: trend.isEmpty
                  ? const Center(
                      child: Text(
                        'No trend data yet.',
                        style: TextStyle(
                          fontFamily: 'Urbanist',
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    )
                  : LineChart(
                      LineChartData(
                        minX: 0,
                        maxX: math.max(0, trend.length - 1).toDouble(),
                        minY: minY,
                        maxY: maxY,
                        gridData: FlGridData(
                          show: true,
                          drawVerticalLine: false,
                          horizontalInterval: ((maxY - minY) / 4).clamp(10, 40),
                          getDrawingHorizontalLine: (value) {
                            return const FlLine(
                              color: Color(0xFFDDE6F2),
                              strokeWidth: 1,
                              dashArray: [4, 4],
                            );
                          },
                        ),
                        borderData: FlBorderData(show: false),
                        titlesData: FlTitlesData(
                          leftTitles: const AxisTitles(
                            sideTitles: SideTitles(showTitles: false),
                          ),
                          rightTitles: const AxisTitles(
                            sideTitles: SideTitles(showTitles: false),
                          ),
                          topTitles: const AxisTitles(
                            sideTitles: SideTitles(showTitles: false),
                          ),
                          bottomTitles: AxisTitles(
                            sideTitles: SideTitles(
                              showTitles: true,
                              reservedSize: 26,
                              getTitlesWidget: (value, meta) {
                                final index = value.round();
                                if (index < 0 || index >= trend.length) {
                                  return const SizedBox.shrink();
                                }
                                final label = trend[index].label.trim();
                                if (label.isEmpty) {
                                  return const SizedBox.shrink();
                                }

                                return Padding(
                                  padding: const EdgeInsets.only(top: 8),
                                  child: Text(
                                    label,
                                    style: const TextStyle(
                                      fontFamily: 'Urbanist',
                                      fontSize: 12,
                                      fontWeight: FontWeight.w500,
                                      color: AppColors.textSecondary,
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                        ),
                        lineTouchData: LineTouchData(
                          handleBuiltInTouches: true,
                          touchTooltipData: LineTouchTooltipData(
                            fitInsideHorizontally: true,
                            fitInsideVertically: true,
                            getTooltipColor: (_) => Colors.white,
                            tooltipPadding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 6,
                            ),
                            getTooltipItems: (spots) {
                              return spots
                                  .map((spot) {
                                    return LineTooltipItem(
                                      spot.y.toStringAsFixed(0),
                                      const TextStyle(
                                        fontFamily: 'Urbanist',
                                        fontSize: 12,
                                        fontWeight: FontWeight.w600,
                                        color: AppColors.textPrimary,
                                      ),
                                    );
                                  })
                                  .toList(growable: false);
                            },
                          ),
                        ),
                        lineBarsData: [
                          _line(
                            spots: heartSpots,
                            opacity: 1,
                            fillOpacity: 0.16,
                            width: 2.2,
                          ),
                          _line(
                            spots: systolicSpots,
                            opacity: 0.62,
                            fillOpacity: 0.08,
                            width: 1.8,
                          ),
                          _line(
                            spots: glucoseSpots,
                            opacity: 0.45,
                            fillOpacity: 0,
                            width: 1.6,
                            dashArray: [4, 3],
                          ),
                        ],
                      ),
                    ),
            ),
            const SizedBox(height: 6),
            const _LegendRow(),
            const SizedBox(height: 10),
            LayoutBuilder(
              builder: (context, constraints) {
                final visibleStats = stats.take(3).toList(growable: false);
                final crossAxisCount = constraints.maxWidth >= 520 ? 3 : 2;

                return GridView.builder(
                  itemCount: visibleStats.length,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: crossAxisCount,
                    crossAxisSpacing: 10,
                    mainAxisSpacing: 10,
                    mainAxisExtent: 102,
                  ),
                  itemBuilder: (context, index) {
                    return _TrendStatTile(card: visibleStats[index]);
                  },
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  List<FlSpot> _spots(double? Function(VitalsTrendPointViewData point) getter) {
    return trend
        .asMap()
        .entries
        .where((entry) => getter(entry.value) != null)
        .map((entry) => FlSpot(entry.key.toDouble(), getter(entry.value)!))
        .toList(growable: false);
  }

  LineChartBarData _line({
    required List<FlSpot> spots,
    required double opacity,
    required double fillOpacity,
    required double width,
    List<int>? dashArray,
  }) {
    return LineChartBarData(
      spots: spots,
      isCurved: true,
      color: AppColors.primary.withValues(alpha: opacity),
      barWidth: width,
      dashArray: dashArray,
      isStrokeCapRound: true,
      dotData: const FlDotData(show: false),
      belowBarData: BarAreaData(
        show: fillOpacity > 0,
        color: AppColors.primary.withValues(alpha: fillOpacity),
      ),
      preventCurveOverShooting: true,
      preventCurveOvershootingThreshold: 8,
      curveSmoothness: 0.24,
    );
  }
}

class _LegendRow extends StatelessWidget {
  const _LegendRow();

  @override
  Widget build(BuildContext context) {
    return const Wrap(
      spacing: 14,
      runSpacing: 6,
      children: [
        _LegendDot(label: 'Heart Rate', opacity: 1),
        _LegendDot(label: 'Blood Pressure', opacity: 0.62),
        _LegendDot(label: 'Glucose', opacity: 0.45),
      ],
    );
  }
}

class _LegendDot extends StatelessWidget {
  final String label;
  final double opacity;

  const _LegendDot({required this.label, required this.opacity});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 9,
          height: 9,
          decoration: BoxDecoration(
            color: AppColors.primary.withValues(alpha: opacity),
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 6),
        Text(
          label,
          style: const TextStyle(
            fontFamily: 'Urbanist',
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: AppColors.textPrimary,
          ),
        ),
      ],
    );
  }
}

class _TrendStatTile extends StatelessWidget {
  final VitalsSummaryCardViewData card;

  const _TrendStatTile({required this.card});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            card.label.toUpperCase(),
            style: const TextStyle(
              fontFamily: 'Urbanist',
              fontSize: 11,
              letterSpacing: 0.8,
              fontWeight: FontWeight.w500,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 5),
          Text(
            card.displayValue,
            style: const TextStyle(
              fontFamily: 'Urbanist',
              fontSize: 20,
              height: 1,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 3),
          Text(
            card.delta,
            style: const TextStyle(
              fontFamily: 'Urbanist',
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: AppColors.primary,
            ),
          ),
        ],
      ),
    );
  }
}
