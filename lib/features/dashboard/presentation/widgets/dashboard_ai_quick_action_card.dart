import 'package:flutter/material.dart';
import 'package:vaidya/themes/colors.dart';

class DashboardAiQuickActionCard extends StatelessWidget {
  final VoidCallback onTap;

  const DashboardAiQuickActionCard({super.key, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'VAIDYA.AI',
            style: TextStyle(
              fontSize: 12,
              letterSpacing: 0.8,
              color: Colors.white70,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Your personal AI doctor for symptoms, medications, and care plans',
            style: TextStyle(
              fontSize: 16,
              height: 1.25,
              color: Colors.white,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 14),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: onTap,
              style: ElevatedButton.styleFrom(
                elevation: 0,
                backgroundColor: isDark ? AppColors.card : Colors.white,
                foregroundColor: isDark
                    ? AppColors.textPrimary
                    : AppColors.primary,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(999),
                ),
              ),
              child: const Text(
                'Open Vaidya.ai',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
