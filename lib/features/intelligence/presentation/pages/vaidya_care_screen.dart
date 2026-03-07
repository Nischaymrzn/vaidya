import 'package:flutter/material.dart';
import 'package:vaidya/core/widgets/app_drawer_toggle_button.dart';
import 'package:vaidya/core/widgets/app_main_bottom_nav.dart';
import 'package:vaidya/core/widgets/app_side_drawer.dart';
import 'package:vaidya/features/dashboard/presentation/pages/dashboard.dart';
import 'package:vaidya/themes/colors.dart';

class VaidyaCareScreen extends StatelessWidget {
  const VaidyaCareScreen({super.key});

  @override
  Widget build(BuildContext context) {
    void openMainTab(MainBottomNavItem item) {
      final targetIndex = switch (item) {
        MainBottomNavItem.home => 0,
        MainBottomNavItem.records => 1,
        MainBottomNavItem.intelligence => 2,
        MainBottomNavItem.analytics => 3,
        MainBottomNavItem.profile => 4,
      };

      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(
          builder: (_) => DashboardScreen(initialIndex: targetIndex),
        ),
        (_) => false,
      );
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      drawer: const AppSideDrawer(
        currentDestination: AppDrawerDestination.vaidyaCare,
      ),
      bottomNavigationBar: AppMainBottomNav(
        activeItem: null,
        onTap: openMainTab,
      ),
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        centerTitle: true,
        leading: const AppDrawerToggleButton(color: AppColors.textPrimary),
        title: const Text(
          'Vaidya Care',
          style: TextStyle(
            color: AppColors.textPrimary,
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: const Center(
        child: Text(
          'Vaidya care module',
          style: TextStyle(fontSize: 16, color: AppColors.textSecondary),
        ),
      ),
    );
  }
}
