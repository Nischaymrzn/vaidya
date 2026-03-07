import 'dart:math' as math;

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:vaidya/features/analytics/presentation/models/analytics_view_data.dart';
import 'package:vaidya/features/analytics/presentation/widgets/analytics_section_card.dart';
import 'package:vaidya/themes/colors.dart';

class AnalyticsEncountersCard extends StatelessWidget {
  final List<AnalyticsEncounterPointViewData> history;
  final AnalyticsEncounterTotalsViewData totals;
  final bool hasData;

  const AnalyticsEncountersCard({
    super.key,
    required this.history,
    required this.totals,
    required this.hasData,
  });

  @override
  Widget build(BuildContext context) {
    return AnalyticsSectionCard(
      title: 'Encounter volume by month',
      subtitle:
          'Outpatient, telehealth, and inpatient activity across the selected period.',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _TotalChip(label: 'Outpatient', count: totals.outpatient),
              _TotalChip(label: 'Telehealth', count: totals.telehealth),
              _TotalChip(label: 'Inpatient', count: totals.inpatient),
            ],
          ),
          const SizedBox(height: 12),
          if (!hasData)
            const AnalyticsEmptyState(
              label: 'Log medical records to see encounter trends.',
            )
          else
            _EncounterChart(history: history),
        ],
      ),
    );
  }
}

class _EncounterChart extends StatelessWidget {
  final List<AnalyticsEncounterPointViewData> history;

  const _EncounterChart({required this.history});

  @override
  Widget build(BuildContext context) {
    final outpatientSpots = _spots((point) => point.outpatient.toDouble());
    final telehealthSpots = _spots((point) => point.telehealth.toDouble());
    final inpatientSpots = _spots((point) => point.inpatient.toDouble());

    final all = <double>[
      ...outpatientSpots.map((spot) => spot.y),
      ...telehealthSpots.map((spot) => spot.y),
      ...inpatientSpots.map((spot) => spot.y),
    ];

    final maxY = all.isEmpty
        ? 4.0
        : math.max(all.reduce(math.max) + 1, 4).toDouble();

    return Column(
      children: [
        SizedBox(
          height: 240,
          child: LineChart(
            LineChartData(
              minX: 0,
              maxX: math.max(history.length - 1, 0).toDouble(),
              minY: 0,
              maxY: maxY,
              borderData: FlBorderData(show: false),
              gridData: FlGridData(
                drawVerticalLine: false,
                horizontalInterval: (maxY / 4).clamp(1, 4),
                getDrawingHorizontalLine: (_) =>
                    const FlLine(color: Color(0xFFDDE6F2), strokeWidth: 1),
              ),
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
                    reservedSize: 28,
                    getTitlesWidget: (value, _) {
                      final index = value.toInt();
                      if (index < 0 || index >= history.length) {
                        return const SizedBox.shrink();
                      }
                      final step = history.length > 7
                          ? (history.length / 6).ceil()
                          : 1;
                      final show =
                          index == 0 ||
                          index == history.length - 1 ||
                          index % step == 0;
                      if (!show) return const SizedBox.shrink();
                      return Padding(
                        padding: const EdgeInsets.only(top: 8),
                        child: Text(
                          history[index].month,
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
              lineBarsData: [
                _line(
                  spots: outpatientSpots,
                  opacity: 1,
                  fillOpacity: 0.12,
                  width: 2,
                ),
                _line(
                  spots: telehealthSpots,
                  opacity: 0.7,
                  fillOpacity: 0.08,
                  width: 2,
                ),
                _line(
                  spots: inpatientSpots,
                  opacity: 0.45,
                  fillOpacity: 0,
                  width: 1.8,
                  dashArray: [5, 4],
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 8),
        const Wrap(
          spacing: 14,
          runSpacing: 6,
          children: [
            _LegendDot(label: 'Outpatient', opacity: 1),
            _LegendDot(label: 'Telehealth', opacity: 0.7),
            _LegendDot(label: 'Inpatient', opacity: 0.45),
          ],
        ),
      ],
    );
  }

  List<FlSpot> _spots(
    double Function(AnalyticsEncounterPointViewData point) get,
  ) {
    return history
        .asMap()
        .entries
        .map((entry) => FlSpot(entry.key.toDouble(), get(entry.value)))
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
      dotData: const FlDotData(show: false),
      isStrokeCapRound: true,
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

class _TotalChip extends StatelessWidget {
  final String label;
  final int count;

  const _TotalChip({required this.label, required this.count});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.primarySoft,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        '$label $count',
        style: const TextStyle(
          fontFamily: 'Urbanist',
          fontSize: 13,
          fontWeight: FontWeight.w500,
          color: AppColors.primary,
        ),
      ),
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
            borderRadius: BorderRadius.circular(2),
            color: AppColors.primary.withValues(alpha: opacity),
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
