import 'dart:math' as math;

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:vaidya/features/family_health/presentation/models/family_health_view_data.dart';
import 'package:vaidya/themes/colors.dart';

class FamilyChartsSection extends StatelessWidget {
  final FamilySummaryViewData summary;

  const FamilyChartsSection({super.key, required this.summary});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final wide = constraints.maxWidth >= 960;
        final scoreChart = _VaidyaScoreChart(summary: summary);
        final heartChart = _HeartRateChart(summary: summary);

        if (wide) {
          return Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(child: scoreChart),
              const SizedBox(width: 12),
              Expanded(child: heartChart),
            ],
          );
        }
        return Column(
          children: [scoreChart, const SizedBox(height: 12), heartChart],
        );
      },
    );
  }
}

class MemberVitalsCharts extends StatelessWidget {
  final FamilySummaryViewData summary;
  final FamilyMemberViewData member;

  const MemberVitalsCharts({
    super.key,
    required this.summary,
    required this.member,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final wide = constraints.maxWidth >= 760;
        final snapshot = _VitalsSnapshotChart(member: member);
        final comparison = _ScoreComparisonChart(
          summary: summary,
          member: member,
        );

        if (wide) {
          return Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(child: snapshot),
              const SizedBox(width: 12),
              Expanded(child: comparison),
            ],
          );
        }
        return Column(
          children: [snapshot, const SizedBox(height: 12), comparison],
        );
      },
    );
  }
}

class _ChartCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final Widget chart;
  final Widget? footer;
  final double footerTopSpacing;

  const _ChartCard({
    required this.title,
    required this.subtitle,
    required this.chart,
    this.footer,
    this.footerTopSpacing = 10,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontFamily: 'Urbanist',
              fontSize: 17,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            subtitle,
            style: const TextStyle(
              fontFamily: 'Urbanist',
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(height: 200, child: chart),
          if (footer != null) ...[SizedBox(height: footerTopSpacing), footer!],
        ],
      ),
    );
  }
}

class _VaidyaScoreChart extends StatelessWidget {
  final FamilySummaryViewData summary;
  const _VaidyaScoreChart({required this.summary});

  @override
  Widget build(BuildContext context) {
    final values = summary.members
        .map((e) => (e.healthScore ?? 0).toDouble())
        .toList();
    final maxY = math
        .max(100, (values.isEmpty ? 100 : values.reduce(math.max)).toInt() + 10)
        .toDouble();

    return _ChartCard(
      title: 'Vaidya score',
      subtitle: 'Health score across all members from latest vitals.',
      chart: BarChart(
        BarChartData(
          maxY: maxY,
          gridData: const FlGridData(show: true, drawVerticalLine: false),
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
                interval: 1,
                reservedSize: 14,
                getTitlesWidget: (v, _) =>
                    _memberBottomTitle(summary, v, topPadding: 0),
              ),
            ),
          ),
          barGroups: List.generate(summary.members.length, (i) {
            return BarChartGroupData(
              x: i,
              barRods: [
                BarChartRodData(
                  toY: values[i],
                  width: 24,
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(6),
                ),
              ],
            );
          }),
        ),
      ),
      footer: _ScoreLegend(summary: summary),
      footerTopSpacing: 0,
    );
  }
}

class _ScoreLegend extends StatelessWidget {
  final FamilySummaryViewData summary;
  const _ScoreLegend({required this.summary});

  @override
  Widget build(BuildContext context) {
    if (summary.members.isEmpty) return const SizedBox.shrink();
    final crossAxisCount = summary.members.length >= 3
        ? 3
        : summary.members.length;
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: summary.members.length,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        mainAxisSpacing: 8,
        crossAxisSpacing: 8,
        childAspectRatio: 1.35,
      ),
      itemBuilder: (context, index) {
        final m = summary.members[index];
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: BoxDecoration(
            color: const Color(0xFFF8FAFC),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: AppColors.border.withValues(alpha: 0.6)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                m
                    .relationLabel(currentUserId: summary.currentUserId)
                    .toUpperCase(),
                style: const TextStyle(
                  fontFamily: 'Urbanist',
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textSecondary,
                  letterSpacing: 0.3,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              Text(
                '${m.healthScore ?? '--'}',
                style: const TextStyle(
                  fontFamily: 'Urbanist',
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
              const Text(
                'Health score',
                style: TextStyle(
                  fontFamily: 'Urbanist',
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _HeartRateChart extends StatelessWidget {
  final FamilySummaryViewData summary;
  const _HeartRateChart({required this.summary});

  @override
  Widget build(BuildContext context) {
    final count = summary.members.length;
    final spots = summary.members.asMap().entries.map((e) {
      return FlSpot(
        e.key.toDouble(),
        (e.value.latestVitals?.heartRate ?? 0).toDouble(),
      );
    }).toList();

    final maxY = math
        .max(
          120.0,
          (spots.isEmpty ? 0 : spots.map((e) => e.y).reduce(math.max)) + 10,
        )
        .toDouble();

    return _ChartCard(
      title: 'Heart rate snapshot',
      subtitle: 'Latest heart rate recorded per member.',
      chart: LineChart(
        LineChartData(
          minY: -8,
          maxY: maxY,
          gridData: const FlGridData(show: true, drawVerticalLine: false),
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
                interval: 1,
                reservedSize: 30,
                getTitlesWidget: (v, _) {
                  final rounded = v.round();
                  if ((v - rounded).abs() > 0.001) {
                    return const SizedBox.shrink();
                  }
                  if (rounded < 0 || rounded >= count) {
                    return const SizedBox.shrink();
                  }
                  final horizontalShift = rounded == 0
                      ? 8.0
                      : (rounded == count - 1 ? -8.0 : 0.0);
                  return _memberBottomTitle(
                    summary,
                    v,
                    topPadding: 2,
                    horizontalShift: horizontalShift,
                  );
                },
              ),
            ),
          ),
          lineBarsData: [
            LineChartBarData(
              spots: spots,
              isCurved: true,
              color: const Color(0xFF4DA3FF),
              barWidth: 2.5,
              dotData: const FlDotData(show: true),
              belowBarData: BarAreaData(
                show: true,
                color: const Color(0xFF4DA3FF).withValues(alpha: 0.08),
              ),
            ),
          ],
        ),
      ),
      footer: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: const Color(0xFFF8FAFC),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: AppColors.border.withValues(alpha: 0.6)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'AVERAGE HEART RATE',
              style: TextStyle(
                fontFamily: 'Urbanist',
                fontSize: 10,
                fontWeight: FontWeight.w600,
                color: AppColors.textSecondary,
                letterSpacing: 0.3,
              ),
            ),
            Text(
              summary.averageHeartRate > 0
                  ? '${summary.averageHeartRate} bpm'
                  : '-- bpm',
              style: const TextStyle(
                fontFamily: 'Urbanist',
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
            const Text(
              'Based on latest vitals entries.',
              style: TextStyle(
                fontFamily: 'Urbanist',
                fontSize: 11,
                fontWeight: FontWeight.w500,
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _VitalsSnapshotChart extends StatelessWidget {
  final FamilyMemberViewData member;
  const _VitalsSnapshotChart({required this.member});

  @override
  Widget build(BuildContext context) {
    final pts = [
      _DataPoint('Systolic', (member.latestVitals?.systolicBp ?? 0).toDouble()),
      _DataPoint(
        'Diastolic',
        (member.latestVitals?.diastolicBp ?? 0).toDouble(),
      ),
      _DataPoint('Heart', (member.latestVitals?.heartRate ?? 0).toDouble()),
      _DataPoint(
        'Glucose',
        (member.latestVitals?.glucoseLevel ?? 0).toDouble(),
      ),
    ];
    final maxY = pts.map((e) => e.value).fold<double>(120, math.max) + 10;

    return _ChartCard(
      title: 'Vitals snapshot',
      subtitle: 'Latest key vitals for this member.',
      chart: BarChart(
        BarChartData(
          maxY: maxY,
          gridData: const FlGridData(show: true, drawVerticalLine: false),
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
                getTitlesWidget: (v, _) => Padding(
                  padding: const EdgeInsets.only(top: 6),
                  child: Text(
                    pts[v.toInt()].label,
                    style: const TextStyle(
                      fontFamily: 'Urbanist',
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ),
              ),
            ),
          ),
          barGroups: List.generate(pts.length, (i) {
            return BarChartGroupData(
              x: i,
              barRods: [
                BarChartRodData(
                  toY: pts[i].value,
                  width: 24,
                  color: const Color(0xFF4DA3FF),
                  borderRadius: BorderRadius.circular(6),
                ),
              ],
            );
          }),
        ),
      ),
    );
  }
}

class _ScoreComparisonChart extends StatelessWidget {
  final FamilySummaryViewData summary;
  final FamilyMemberViewData member;

  const _ScoreComparisonChart({required this.summary, required this.member});

  @override
  Widget build(BuildContext context) {
    final memberScore = (member.healthScore ?? 0).toDouble();
    final avg = summary.averageHealthScore.toDouble();
    final maxY = math.max(100.0, math.max(memberScore, avg) + 10);

    return _ChartCard(
      title: 'Score comparison',
      subtitle: 'Member score vs family average.',
      chart: LineChart(
        LineChartData(
          minX: 0,
          maxX: 1,
          minY: 0,
          maxY: maxY,
          gridData: const FlGridData(show: true, drawVerticalLine: false),
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
                interval: 1,
                reservedSize: 28,
                getTitlesWidget: (v, _) {
                  if ((v - 0).abs() < 0.001) {
                    return Transform.translate(
                      offset: const Offset(10, 0),
                      child: const Padding(
                        padding: EdgeInsets.only(top: 6),
                        child: Text(
                          'Member',
                          style: TextStyle(
                            fontFamily: 'Urbanist',
                            fontSize: 11,
                            fontWeight: FontWeight.w500,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ),
                    );
                  }
                  if ((v - 1).abs() < 0.001) {
                    return Transform.translate(
                      offset: const Offset(-10, 0),
                      child: const Padding(
                        padding: EdgeInsets.only(top: 6),
                        child: Text(
                          'Family Avg',
                          style: TextStyle(
                            fontFamily: 'Urbanist',
                            fontSize: 11,
                            fontWeight: FontWeight.w500,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ),
                    );
                  }
                  return const SizedBox.shrink();
                },
              ),
            ),
          ),
          lineBarsData: [
            LineChartBarData(
              spots: [FlSpot(0, memberScore), FlSpot(1, avg)],
              isCurved: false,
              color: AppColors.primary,
              barWidth: 2.5,
              dotData: const FlDotData(show: true),
            ),
          ],
        ),
      ),
      footer: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: const Color(0xFFF8FAFC),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: AppColors.border.withValues(alpha: 0.6)),
        ),
        child: Text(
          'Family average score: ${summary.averageHealthScore > 0 ? summary.averageHealthScore : '--'}',
          style: const TextStyle(
            fontFamily: 'Urbanist',
            fontSize: 13,
            fontWeight: FontWeight.w500,
            color: AppColors.textSecondary,
          ),
        ),
      ),
    );
  }
}

String _firstName(FamilySummaryViewData s, int i) {
  if (i < 0 || i >= s.members.length) return '';
  final n = s.members[i].displayName.trim().split(' ');
  return n.isEmpty ? '' : n.first;
}

Widget _memberBottomTitle(
  FamilySummaryViewData summary,
  double value, {
  double topPadding = 6,
  double horizontalShift = 0,
}) {
  final rounded = value.round();
  if ((value - rounded).abs() > 0.001) return const SizedBox.shrink();
  if (rounded < 0 || rounded >= summary.members.length) {
    return const SizedBox.shrink();
  }
  return Transform.translate(
    offset: Offset(horizontalShift, 0),
    child: Padding(
      padding: EdgeInsets.only(top: topPadding),
      child: SizedBox(
        width: 56,
        child: Text(
          _firstName(summary, rounded),
          textAlign: TextAlign.center,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            fontFamily: 'Urbanist',
            fontSize: 11,
            fontWeight: FontWeight.w500,
            color: AppColors.textSecondary,
          ),
        ),
      ),
    ),
  );
}

class _DataPoint {
  final String label;
  final double value;
  const _DataPoint(this.label, this.value);
}
