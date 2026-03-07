import 'package:flutter/material.dart';
import 'package:vaidya/core/widgets/app_main_bottom_nav.dart';
import 'package:vaidya/features/analytics/presentation/pages/analytics_screen.dart';
import 'package:vaidya/features/dashboard/presentation/pages/home_screen.dart';
import 'package:vaidya/features/intelligence/presentation/pages/risk_analysis_screen.dart';
import 'package:vaidya/features/profile/presentation/pages/profile_screen.dart';
import 'package:vaidya/features/records/presentation/pages/records_screen.dart';

class DashboardScreen extends StatefulWidget {
  final int initialIndex;

  const DashboardScreen({super.key, this.initialIndex = 0});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  late int _selectedIndex;

  final List<Widget> _screens = const [
    HomeScreen(),
    RecordsScreen(),
    RiskAnalysisScreen(),
    AnalyticsScreen(),
    ProfileScreen(),
  ];

  @override
  void initState() {
    super.initState();
    _selectedIndex = widget.initialIndex.clamp(0, _screens.length - 1);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_selectedIndex],
      bottomNavigationBar: AppMainBottomNav(
        activeItem: _itemFromIndex(_selectedIndex),
        onTap: (item) {
          setState(() => _selectedIndex = _indexFromItem(item));
        },
      ),
    );
  }

  MainBottomNavItem _itemFromIndex(int index) {
    switch (index) {
      case 1:
        return MainBottomNavItem.records;
      case 2:
        return MainBottomNavItem.intelligence;
      case 3:
        return MainBottomNavItem.analytics;
      case 4:
        return MainBottomNavItem.profile;
      default:
        return MainBottomNavItem.home;
    }
  }

  int _indexFromItem(MainBottomNavItem item) {
    switch (item) {
      case MainBottomNavItem.home:
        return 0;
      case MainBottomNavItem.records:
        return 1;
      case MainBottomNavItem.intelligence:
        return 2;
      case MainBottomNavItem.analytics:
        return 3;
      case MainBottomNavItem.profile:
        return 4;
    }
  }
}
