import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:vaidya/themes/colors.dart'; // your AppColors

class MetricsCard extends StatelessWidget {
  final String iconPath;
  final String name;
  final String value;
  final String unit;
  final String updated;

  const MetricsCard({
    super.key,
    required this.iconPath,
    required this.name,
    required this.value,
    required this.unit,
    required this.updated,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      // onTap: () {
      //   // Navigate to detail page
      //   Navigator.push(
      //     context,
      //     MaterialPageRoute(
      //       builder: (context) => HeartRateDetailPage(), // your detail page
      //     ),
      //   );
      // },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.card,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Color(0xFFE2DCD5), width: 1.25),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,

          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,

              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: Color(0xFFE5E7EB),
                    shape: BoxShape.circle,
                  ),
                  child: SvgPicture.asset(iconPath, height: 20, width: 20),
                ),
                const SizedBox(width: 6),
                Text(
                  name,
                  style: TextStyle(
                    fontSize: 16,
                    color: AppColors.textSecondary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 26),

            Padding(
              padding: const EdgeInsets.only(left: 12),
              child: RichText(
                text: TextSpan(
                  text: value,
                  style: TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 26,
                    fontWeight: FontWeight.w500,
                  ),
                  children: [
                    TextSpan(
                      text: ' $unit',
                      style: TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 8),

            Padding(
              padding: const EdgeInsets.only(left: 12),
              child: Text(
                updated,
                style: TextStyle(color: AppColors.textSecondary, fontSize: 14),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
