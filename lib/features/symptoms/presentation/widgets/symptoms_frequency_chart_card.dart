import 'package:flutter/material.dart';
import 'package:vaidya/features/symptoms/presentation/models/symptom_view_data.dart';
import 'package:vaidya/themes/colors.dart';

class SymptomsFrequencyChartCard extends StatelessWidget {
  final List<SymptomFrequencyViewData> data;

  const SymptomsFrequencyChartCard({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    final maxCount = data.fold<int>(1, (max, item) {
      return item.count > max ? item.count : max;
    });

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(14, 14, 14, 14),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Most frequent symptoms',
            style: TextStyle(
              fontFamily: 'Urbanist',
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 2),
          const Text(
            'Top 5 symptom types from your logs',
            style: TextStyle(
              fontFamily: 'Urbanist',
              fontSize: 15,
              fontWeight: FontWeight.w500,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 14),
          if (data.isEmpty)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 30),
              alignment: Alignment.center,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                color: const Color(0xFFF8FAFC),
                border: Border.all(
                  color: AppColors.border.withValues(alpha: .75),
                ),
              ),
              child: const Text(
                'No symptom trends yet',
                style: TextStyle(
                  fontFamily: 'Urbanist',
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: AppColors.textSecondary,
                ),
              ),
            )
          else
            SizedBox(
              height: 190,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: data
                    .map((item) {
                      final ratio = (item.count / maxCount).clamp(0.1, 1.0);
                      return Expanded(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 6),
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
                                            color: const Color(0xFFE8EEF5),
                                          ),
                                        ),
                                      ),
                                    ),
                                    Align(
                                      alignment: Alignment.bottomCenter,
                                      child: Container(
                                        width: 48,
                                        height: 130 * ratio,
                                        decoration: BoxDecoration(
                                          borderRadius: BorderRadius.circular(
                                            10,
                                          ),
                                          color: AppColors.primary,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                item.name,
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
        ],
      ),
    );
  }
}
