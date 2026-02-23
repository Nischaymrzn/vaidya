import 'package:flutter/material.dart';
import 'package:vaidya/features/analytics/presentation/models/analytics_view_data.dart';
import 'package:vaidya/features/analytics/presentation/widgets/analytics_section_card.dart';
import 'package:vaidya/themes/colors.dart';

class AnalyticsConditionsCard extends StatelessWidget {
  final List<AnalyticsCategoryCountViewData> data;
  final bool hasData;

  const AnalyticsConditionsCard({
    super.key,
    required this.data,
    required this.hasData,
  });

  @override
  Widget build(BuildContext context) {
    final top = data.take(5).toList(growable: false);
    final maxCount = top.fold<int>(1, (max, item) {
      return item.count > max ? item.count : max;
    });

    return AnalyticsSectionCard(
      title: 'Most frequent conditions',
      subtitle: 'Top diagnoses across the record.',
      child: !hasData
          ? const AnalyticsEmptyState(
              label: 'Record diagnoses to see condition trends.',
            )
          : Column(
              children: top
                  .map(
                    (item) => Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: _BarRow(
                        label: item.name,
                        value: item.count,
                        ratio: ratioFromCount(item.count, maxCount),
                        opacity: item == top.last ? 0.6 : 0.9,
                      ),
                    ),
                  )
                  .toList(growable: false),
            ),
    );
  }
}

class AnalyticsProceduresCard extends StatelessWidget {
  final List<AnalyticsCategoryCountViewData> data;
  final bool hasData;

  const AnalyticsProceduresCard({
    super.key,
    required this.data,
    required this.hasData,
  });

  @override
  Widget build(BuildContext context) {
    final top = data.take(4).toList(growable: false);
    final maxCount = top.fold<int>(1, (max, item) {
      return item.count > max ? item.count : max;
    });

    return AnalyticsSectionCard(
      title: 'Procedures overview',
      subtitle: 'Procedure volume grouped by category.',
      child: !hasData
          ? const AnalyticsEmptyState(
              label: 'Upload lab results and records to see procedures.',
            )
          : SizedBox(
              height: 220,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: top
                    .map((item) {
                      final ratio = ratioFromCount(item.count, maxCount);
                      return Expanded(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8),
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
                                        height: 140 * ratio,
                                        decoration: BoxDecoration(
                                          color: AppColors.primary.withValues(
                                            alpha: 0.86,
                                          ),
                                          borderRadius:
                                              const BorderRadius.vertical(
                                                top: Radius.circular(8),
                                              ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                item.name,
                                textAlign: TextAlign.center,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  fontFamily: 'Urbanist',
                                  fontSize: 13,
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
            ),
    );
  }
}

class _BarRow extends StatelessWidget {
  final String label;
  final int value;
  final double ratio;
  final double opacity;

  const _BarRow({
    required this.label,
    required this.value,
    required this.ratio,
    required this.opacity,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        SizedBox(
          width: 102,
          child: Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontFamily: 'Urbanist',
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: AppColors.textSecondary,
            ),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Container(
            height: 26,
            decoration: BoxDecoration(
              color: const Color(0xFFEAF1FA),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Align(
              alignment: Alignment.centerLeft,
              child: FractionallySizedBox(
                widthFactor: ratio,
                child: Container(
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: opacity),
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ),
          ),
        ),
        const SizedBox(width: 8),
        SizedBox(
          width: 26,
          child: Text(
            '$value',
            textAlign: TextAlign.right,
            style: const TextStyle(
              fontFamily: 'Urbanist',
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
        ),
      ],
    );
  }
}
