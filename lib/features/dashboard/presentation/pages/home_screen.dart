import 'package:flutter/material.dart';
import 'package:vaidya/app/theme/colors.dart';
import 'package:vaidya/features/dashboard/presentation/widgets/health_score_card.dart';
import 'package:vaidya/features/dashboard/presentation/widgets/health_suggestion.dart';
import 'package:vaidya/features/dashboard/presentation/widgets/home_appbar.dart';
import 'package:vaidya/features/dashboard/presentation/widgets/recent_medications.dart';
import 'package:vaidya/features/dashboard/presentation/widgets/smart_health_metrics.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: HomeAppbar(),
      body: Padding(
        padding: EdgeInsetsGeometry.only(
          bottom: 20,
          top: 20,
          left: 18,
          right: 18,
        ),
        child: SingleChildScrollView(
          child: Column(
            children: [
              HealthScoreCard(
                desc:
                    'Based on your data, we think your health status is above average',
                score: '88',
              ),
              const SizedBox(height: 24),
              SmartHealthMetrics(),
              const SizedBox(height: 24),
              RecentMedications(),
              const SizedBox(height: 24),
              HealthSuggestion(
                title: "Low Blood Pressure",
                desc: "Drink water. Eat small, frequent meals",
              ),
            ],
          ),
        ),
      ),
    );
  }
}
