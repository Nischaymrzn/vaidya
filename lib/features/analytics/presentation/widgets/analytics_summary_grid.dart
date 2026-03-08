import 'package:flutter/material.dart';
import 'package:vaidya/features/analytics/presentation/models/analytics_view_data.dart';
import 'package:vaidya/themes/colors.dart';

class AnalyticsSummaryGrid extends StatelessWidget {
  final List<AnalyticsSummaryCardViewData> items;

  const AnalyticsSummaryGrid({super.key, required this.items});

  @override
  Widget build(BuildContext context) {
    final cards = _normalizedCards(items);

    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        final isTablet = width >= 700;
        final gridDelegate = isTablet
            ? const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
                mainAxisExtent: 150,
              )
            : const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
                childAspectRatio: 1.55,
              );

        return GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          padding: const EdgeInsets.all(10),
          itemCount: 4,
          gridDelegate: gridDelegate,
          itemBuilder: (context, index) {
            return _SummaryTile(data: cards[index]);
          },
        );
      },
    );
  }
}

List<AnalyticsSummaryCardViewData> _normalizedCards(
  List<AnalyticsSummaryCardViewData> source,
) {
  const defaults = <AnalyticsSummaryCardViewData>[
    AnalyticsSummaryCardViewData(
      label: 'ACTIVE CONDITIONS',
      value: 0,
      detail: 'No new conditions in last 90 days',
    ),
    AnalyticsSummaryCardViewData(
      label: 'ACTIVE MEDICATIONS',
      value: 0,
      detail: 'No recent medication changes',
    ),
    AnalyticsSummaryCardViewData(
      label: 'ENCOUNTERS',
      value: 0,
      detail: 'No telehealth visits logged',
    ),
    AnalyticsSummaryCardViewData(
      label: 'IMMUNIZATIONS',
      value: 0,
      detail: 'No boosters due soon',
    ),
  ];

  final cards = List<AnalyticsSummaryCardViewData>.from(defaults);
  final limit = source.length < 4 ? source.length : 4;
  for (var i = 0; i < limit; i++) {
    cards[i] = source[i];
  }
  return cards;
}

class _SummaryTile extends StatelessWidget {
  final AnalyticsSummaryCardViewData data;

  const _SummaryTile({required this.data});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.zero,
      elevation: 0,
      clipBehavior: Clip.antiAlias,
      color: AppColors.card,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: BorderSide(color: AppColors.border),
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(14, 12, 12, 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Text(
              data.label,
              style: TextStyle(
                fontFamily: 'Urbanist',
                fontSize: 12,
                letterSpacing: 0.7,
                fontWeight: FontWeight.w500,
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              '${data.value}',
              style: TextStyle(
                fontFamily: 'Urbanist',
                fontSize: 37 / 1.5,
                height: 1.0,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 5),
            Text(
              data.detail,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontFamily: 'Urbanist',
                fontSize: 13.5,
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
