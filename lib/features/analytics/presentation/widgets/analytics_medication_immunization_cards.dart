import 'package:flutter/material.dart';
import 'package:vaidya/features/analytics/presentation/models/analytics_view_data.dart';
import 'package:vaidya/features/analytics/presentation/widgets/analytics_section_card.dart';
import 'package:vaidya/themes/colors.dart';

class AnalyticsMedicationHistoryCard extends StatelessWidget {
  final List<AnalyticsMedicationHistoryPointViewData> data;
  final bool hasData;

  const AnalyticsMedicationHistoryCard({
    super.key,
    required this.data,
    required this.hasData,
  });

  @override
  Widget build(BuildContext context) {
    return AnalyticsSectionCard(
      title: 'Medication history',
      subtitle: 'Active, new, and discontinued medications by month.',
      child: !hasData
          ? const AnalyticsEmptyState(
              label: 'Add medications to track activity.',
            )
          : Column(
              children: [
                _StackedHistoryChart<AnalyticsMedicationHistoryPointViewData>(
                  items: data,
                  xLabelOf: (item) => item.month,
                  firstValue: (item) => item.active,
                  secondValue: (item) => item.newCount,
                  thirdValue: (item) => item.stopped,
                  firstColor: AppColors.primary.withValues(alpha: .9),
                  secondColor: AppColors.primary.withValues(alpha: .65),
                  thirdColor: const Color(0xFF94A3B8).withValues(alpha: .6),
                ),
                const SizedBox(height: 10),
                const _LegendRow(
                  firstLabel: 'Active',
                  secondLabel: 'New',
                  thirdLabel: 'Stopped',
                  firstColor: Color(0xFF1F7AE0),
                  secondColor: Color(0xA61F7AE0),
                  thirdColor: Color(0x9994A3B8),
                ),
              ],
            ),
    );
  }
}

class AnalyticsImmunizationHistoryCard extends StatelessWidget {
  final List<AnalyticsImmunizationHistoryPointViewData> data;
  final bool hasData;

  const AnalyticsImmunizationHistoryCard({
    super.key,
    required this.data,
    required this.hasData,
  });

  @override
  Widget build(BuildContext context) {
    return AnalyticsSectionCard(
      title: 'Immunization history',
      subtitle: 'Monthly vaccination activity by type.',
      child: !hasData
          ? const AnalyticsEmptyState(
              label: 'No immunization data available yet.',
            )
          : Column(
              children: [
                _StackedHistoryChart<AnalyticsImmunizationHistoryPointViewData>(
                  items: data,
                  xLabelOf: (item) => item.month,
                  firstValue: (item) => item.routine,
                  secondValue: (item) => item.booster,
                  thirdValue: (item) => item.travel,
                  firstColor: AppColors.primary.withValues(alpha: .9),
                  secondColor: AppColors.primary.withValues(alpha: .62),
                  thirdColor: AppColors.primary.withValues(alpha: .42),
                ),
                const SizedBox(height: 10),
                const _LegendRow(
                  firstLabel: 'Routine',
                  secondLabel: 'Booster',
                  thirdLabel: 'Travel',
                  firstColor: Color(0xFF1F7AE0),
                  secondColor: Color(0xA61F7AE0),
                  thirdColor: Color(0x701F7AE0),
                ),
              ],
            ),
    );
  }
}

class _StackedHistoryChart<T> extends StatelessWidget {
  final List<T> items;
  final String Function(T item) xLabelOf;
  final int Function(T item) firstValue;
  final int Function(T item) secondValue;
  final int Function(T item) thirdValue;
  final Color firstColor;
  final Color secondColor;
  final Color thirdColor;

  const _StackedHistoryChart({
    required this.items,
    required this.xLabelOf,
    required this.firstValue,
    required this.secondValue,
    required this.thirdValue,
    required this.firstColor,
    required this.secondColor,
    required this.thirdColor,
  });

  @override
  Widget build(BuildContext context) {
    final maxTotal = items.fold<int>(1, (max, item) {
      final total = firstValue(item) + secondValue(item) + thirdValue(item);
      return total > max ? total : max;
    });

    return SizedBox(
      height: 220,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: items
            .map((item) {
              final first = firstValue(item);
              final second = secondValue(item);
              final third = thirdValue(item);
              final total = first + second + third;
              final ratio = ratioFromCount(total, maxTotal);

              final firstRatio = total == 0 ? 0.0 : first / total;
              final secondRatio = total == 0 ? 0.0 : second / total;
              final thirdRatio = total == 0 ? 0.0 : third / total;

              return Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Expanded(
                        child: Stack(
                          children: [
                            Positioned.fill(
                              child: Column(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceEvenly,
                                children: List.generate(
                                  5,
                                  (_) => Container(
                                    width: double.infinity,
                                    height: 1,
                                    color: const Color(0xFFE1E8F3),
                                  ),
                                ),
                              ),
                            ),
                            Align(
                              alignment: Alignment.bottomCenter,
                              child: Container(
                                width: double.infinity,
                                height: 142 * ratio,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(8),
                                  color: const Color(0xFFEAF1FA),
                                ),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: [
                                    if (third > 0)
                                      Flexible(
                                        flex: (thirdRatio * 1000).round().clamp(
                                          1,
                                          1000,
                                        ),
                                        child: Container(color: thirdColor),
                                      ),
                                    if (second > 0)
                                      Flexible(
                                        flex: (secondRatio * 1000)
                                            .round()
                                            .clamp(1, 1000),
                                        child: Container(color: secondColor),
                                      ),
                                    if (first > 0)
                                      Flexible(
                                        flex: (firstRatio * 1000).round().clamp(
                                          1,
                                          1000,
                                        ),
                                        child: Container(
                                          decoration: BoxDecoration(
                                            color: firstColor,
                                            borderRadius:
                                                total == first && total > 0
                                                ? BorderRadius.circular(8)
                                                : const BorderRadius.vertical(
                                                    top: Radius.circular(8),
                                                  ),
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
                      const SizedBox(height: 8),
                      Text(
                        xLabelOf(item),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontFamily: 'Urbanist',
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            })
            .toList(growable: false),
      ),
    );
  }
}

class _LegendRow extends StatelessWidget {
  final String firstLabel;
  final String secondLabel;
  final String thirdLabel;
  final Color firstColor;
  final Color secondColor;
  final Color thirdColor;

  const _LegendRow({
    required this.firstLabel,
    required this.secondLabel,
    required this.thirdLabel,
    required this.firstColor,
    required this.secondColor,
    required this.thirdColor,
  });

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 14,
      runSpacing: 6,
      children: [
        _LegendDot(label: firstLabel, color: firstColor),
        _LegendDot(label: secondLabel, color: secondColor),
        _LegendDot(label: thirdLabel, color: thirdColor),
      ],
    );
  }
}

class _LegendDot extends StatelessWidget {
  final String label;
  final Color color;

  const _LegendDot({required this.label, required this.color});

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
          style: const TextStyle(
            fontFamily: 'Urbanist',
            fontSize: 13,
            fontWeight: FontWeight.w500,
            color: AppColors.textPrimary,
          ),
        ),
      ],
    );
  }
}
