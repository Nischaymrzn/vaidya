import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:vaidya/themes/colors.dart';

class HealthSuggestion extends StatelessWidget {
  final dynamic title;

  final dynamic desc;

  const HealthSuggestion({super.key, required this.title, required this.desc});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Color(0xFFE5F0FF),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.border,
          width: 1, // thin border
        ),
      ),
      child: Column(
        children: [
          Row(
            children: [
              SvgPicture.asset("assets/icons/suggestion.svg", width: 18),
              const SizedBox(width: 8),
              const Text(
                "Health Suggestion",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w500,
                  color: Color(0xFF1E3A8A),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: Color(0xFFF2F8FF),
                  shape: BoxShape.circle,
                  border: Border.all(color: Color(0XFFE5E7EB), width: 2),
                ),
                child: SvgPicture.asset(
                  "assets/icons/blood_pressure.svg",
                  height: 20,
                  width: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w500,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    Text(
                      desc,
                      softWrap: true,
                      style: TextStyle(
                        fontSize: 15,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
