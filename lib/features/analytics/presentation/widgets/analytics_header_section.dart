import 'package:flutter/material.dart';
import 'package:vaidya/themes/colors.dart';

class AnalyticsHeaderSection extends StatelessWidget {
  const AnalyticsHeaderSection({super.key});

  @override
  Widget build(BuildContext context) {
    return const Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Clinical overview',
          style: TextStyle(
            fontFamily: 'Urbanist',
            fontSize: 39 / 1.5,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        SizedBox(height: 3),
        Text(
          'Track encounters, conditions, medications, and care network activity to understand patient momentum at a glance.',
          style: TextStyle(
            fontFamily: 'Urbanist',
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: AppColors.textSecondary,
          ),
        ),
      ],
    );
  }
}
