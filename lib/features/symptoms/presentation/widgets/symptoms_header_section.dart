import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:vaidya/themes/colors.dart';

class SymptomsHeaderSection extends StatelessWidget {
  final VoidCallback onLogSymptom;

  const SymptomsHeaderSection({super.key, required this.onLogSymptom});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final compact = constraints.maxWidth < 620;
        final heading = Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Symptom Tracker',
              style: TextStyle(
                fontFamily: 'Urbanist',
                fontSize: 30,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
                letterSpacing: -0.2,
              ),
            ),
            SizedBox(height: 4),
            Text(
              'Log symptoms, spot patterns, and keep your care timeline current.',
              style: TextStyle(
                fontFamily: 'Urbanist',
                fontSize: 15,
                fontWeight: FontWeight.w500,
                color: AppColors.textSecondary,
              ),
            ),
          ],
        );
        final button = FilledButton.icon(
          onPressed: onLogSymptom,
          style: FilledButton.styleFrom(
            backgroundColor: AppColors.primary,
            foregroundColor: Colors.white,
            elevation: 0,
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(999),
            ),
          ),
          icon: const Icon(LucideIcons.plus, size: 16),
          label: const Text(
            'Log symptom',
            style: TextStyle(
              fontFamily: 'Urbanist',
              fontSize: 15,
              fontWeight: FontWeight.w600,
            ),
          ),
        );

        if (compact) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [heading, const SizedBox(height: 12), button],
          );
        }

        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(child: heading),
            const SizedBox(width: 10),
            button,
          ],
        );
      },
    );
  }
}
