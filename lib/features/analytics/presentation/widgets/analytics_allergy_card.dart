import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:vaidya/features/analytics/presentation/models/analytics_view_data.dart';
import 'package:vaidya/features/analytics/presentation/widgets/analytics_section_card.dart';
import 'package:vaidya/themes/colors.dart';

class AnalyticsAllergyCard extends StatelessWidget {
  final List<AnalyticsSeverityPointViewData> data;
  final bool hasData;

  const AnalyticsAllergyCard({
    super.key,
    required this.data,
    required this.hasData,
  });

  @override
  Widget build(BuildContext context) {
    return AnalyticsSectionCard(
      title: 'Allergy severity',
      subtitle: 'Distribution of recorded allergy severities.',
      child: !hasData
          ? const AnalyticsEmptyState(label: 'No allergy details logged yet.')
          : Column(
              children: [
                SizedBox(
                  height: 205,
                  child: PieChart(
                    PieChartData(
                      centerSpaceRadius: 55,
                      sectionsSpace: 3,
                      sections: _sections,
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Wrap(
                  alignment: WrapAlignment.center,
                  spacing: 12,
                  runSpacing: 8,
                  children: data
                      .map(
                        (item) => _LegendItem(
                          label: item.name,
                          color: _colorFor(item.name),
                        ),
                      )
                      .toList(growable: false),
                ),
              ],
            ),
    );
  }

  List<PieChartSectionData> get _sections {
    final used = data.where((item) => item.value > 0).toList(growable: false);
    if (used.isEmpty) {
      return [
        PieChartSectionData(
          value: 1,
          title: '',
          color: AppColors.borderStrong,
          radius: 32,
        ),
      ];
    }
    return used
        .map(
          (item) => PieChartSectionData(
            value: item.value.toDouble(),
            title: '',
            color: _colorFor(item.name),
            radius: 30,
          ),
        )
        .toList(growable: false);
  }
}

class _LegendItem extends StatelessWidget {
  final String label;
  final Color color;

  const _LegendItem({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 9,
          height: 9,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 6),
        Text(
          label,
          style: TextStyle(
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

Color _colorFor(String name) {
  switch (name.toLowerCase()) {
    case 'mild':
      return AppColors.primary;
    case 'moderate':
      return const Color(0xFF2F86EA);
    case 'severe':
      return const Color(0xFF1868C5);
    default:
      return const Color(0xFF94A3B8);
  }
}

