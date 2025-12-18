import 'package:flutter/material.dart';
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
          alignment: Alignment.centerLeft,
          width: double.infinity,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: AppColors.border, width: 1),
          ),
          child: Row(
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
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(left: 12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Vaidya Score',
                        style: Theme.of(context).textTheme.titleLarge!.copyWith(
                          fontWeight: FontWeight.w500,
                          fontSize: 21,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        desc,
                        softWrap: true,
                        style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                          fontSize: 16,
                          color: AppColors.textSecondary,
                          fontWeight: FontWeight.w400,
                          height: 1.2,
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
