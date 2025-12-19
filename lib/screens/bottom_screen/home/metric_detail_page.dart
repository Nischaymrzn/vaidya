import 'package:flutter/material.dart';
import 'package:vaidya/themes/colors.dart';

class MetricDetailPage extends StatelessWidget {
  final String metricName;
  final String iconPath;
  final String value;
  final String unit;
  final String condition;

  const MetricDetailPage({
    super.key,
    required this.metricName,
    required this.iconPath,
    required this.value,
    required this.unit,
    required this.condition,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: AppColors.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          metricName,
          style: TextStyle(
            color: AppColors.textPrimary,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: false,
      ),
      body: Center(
        child: Text(
          'I am $metricName page',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
      ),
    );
  }
}
