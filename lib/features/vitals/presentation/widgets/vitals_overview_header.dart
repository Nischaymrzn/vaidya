import 'package:flutter/material.dart';
import 'package:vaidya/themes/colors.dart';

class VitalsOverviewHeader extends StatelessWidget {
  final VoidCallback onAddReading;

  const VitalsOverviewHeader({super.key, required this.onAddReading});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Vitals overview',
                style: TextStyle(
                  fontFamily: 'Urbanist',
                  fontSize: 30,
                  height: 1.1,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
              SizedBox(height: 6),
              Text(
                'Balance, strength, vitality, wellness. Review your core signals at a glance.',
                style: TextStyle(
                  fontFamily: 'Urbanist',
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 12),
        FilledButton(
          onPressed: onAddReading,
          style: FilledButton.styleFrom(
            backgroundColor: AppColors.primary,
            foregroundColor: Colors.white,
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(999),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 11),
            textStyle: const TextStyle(
              fontFamily: 'Urbanist',
              fontSize: 15,
              fontWeight: FontWeight.w500,
            ),
          ),
          child: const Text('Add reading'),
        ),
      ],
    );
  }
}
