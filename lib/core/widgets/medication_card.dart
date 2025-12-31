import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:vaidya/themes/colors.dart';

class MedicationCard extends StatelessWidget {
  final String iconPath;
  final String title;
  final String date;
  final String hospital;
  final VoidCallback? onView;
  final VoidCallback? onPdf;
  final VoidCallback? onMore;

  const MedicationCard({
    super.key,
    required this.iconPath,
    required this.title,
    required this.date,
    required this.hospital,
    this.onView,
    this.onPdf,
    this.onMore,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.only(left: 16, right: 16),
      margin: const EdgeInsets.only(bottom: 16, top: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: const Color(0xFFE5E7EB),
              shape: BoxShape.circle,
            ),
            child: SvgPicture.asset(iconPath, height: 28, width: 28),
          ),
          const SizedBox(width: 12),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 19,
                    fontWeight: FontWeight.w500,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Text(
                      date,
                      style: const TextStyle(
                        fontSize: 15,
                        color: AppColors.textSecondary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Text(
                      hospital,
                      style: const TextStyle(
                        fontSize: 15,
                        color: AppColors.textSecondary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // More button
          GestureDetector(
            onTap: onMore,
            child: const Icon(Icons.more_horiz, color: AppColors.textSecondary),
          ),
        ],
      ),
    );
  }
}
