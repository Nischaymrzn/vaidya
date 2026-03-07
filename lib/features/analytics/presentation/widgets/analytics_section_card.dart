import 'package:flutter/material.dart';
import 'package:vaidya/themes/colors.dart';

class AnalyticsSectionCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final Widget child;
  final EdgeInsetsGeometry padding;
  final double borderRadius;

  const AnalyticsSectionCard({
    super.key,
    required this.title,
    required this.subtitle,
    required this.child,
    this.padding = const EdgeInsets.fromLTRB(16, 14, 16, 14),
    this.borderRadius = 20,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(borderRadius),
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
        padding: padding,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontFamily: 'Urbanist',
                fontSize: 33 / 2,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              subtitle,
              style: const TextStyle(
                fontFamily: 'Urbanist',
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 14),
            child,
          ],
        ),
      ),
    );
  }
}

class AnalyticsEmptyState extends StatelessWidget {
  final String label;

  const AnalyticsEmptyState({super.key, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 30),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        border: Border.all(color: AppColors.border),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Text(
        label,
        textAlign: TextAlign.center,
        style: const TextStyle(
          fontFamily: 'Urbanist',
          fontSize: 14,
          fontWeight: FontWeight.w500,
          color: AppColors.textSecondary,
        ),
      ),
    );
  }
}
