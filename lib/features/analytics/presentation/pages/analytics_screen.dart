import 'package:flutter/material.dart';
import 'package:vaidya/core/widgets/app_drawer_toggle_button.dart';
import 'package:vaidya/core/widgets/app_side_drawer.dart';
import 'package:vaidya/themes/colors.dart';

class AnalyticsScreen extends StatelessWidget {
  const AnalyticsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      drawer: const AppSideDrawer(
        currentDestination: AppDrawerDestination.analytics,
      ),
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        centerTitle: true,
        leading: const AppDrawerToggleButton(color: AppColors.textPrimary),
        title: const Text(
          'Analytics',
          style: TextStyle(
            color: AppColors.textPrimary,
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: const Center(
        child: Text(
          'This is Analytics Page',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
        ),
      ),
    );
  }
}
