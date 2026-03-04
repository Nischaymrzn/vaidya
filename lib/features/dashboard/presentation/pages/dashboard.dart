import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:vaidya/features/analytics/presentation/pages/analytics_screen.dart';
import 'package:vaidya/themes/colors.dart';
import 'package:vaidya/features/dashboard/presentation/pages/home_screen.dart';
import 'package:vaidya/features/intelligence/presentation/pages/vaidya_ai_screen.dart';
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
    VaidyaAiScreen(),
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
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          border: Border(top: BorderSide(color: Colors.grey, width: 0.5)),
        ),
        child: BottomNavigationBar(
          type: BottomNavigationBarType.fixed,
          backgroundColor: AppColors.background,
          elevation: 0,
          currentIndex: _selectedIndex,
          selectedItemColor: AppColors.activeNav,
          unselectedItemColor: AppColors.isNotActiveNav,
          showSelectedLabels: false,
          showUnselectedLabels: false,
          onTap: (index) => setState(() => _selectedIndex = index),
          items: [
            BottomNavigationBarItem(
              icon: const Icon(LucideIcons.layoutDashboard, size: 22),
              activeIcon: const Icon(LucideIcons.layoutDashboard, size: 22),
              label: '',
            ),
            BottomNavigationBarItem(
              icon: const Icon(LucideIcons.folderHeart, size: 22),
              activeIcon: const Icon(LucideIcons.folderHeart, size: 22),
              label: '',
            ),
            BottomNavigationBarItem(
              icon: const Icon(LucideIcons.brain, size: 22),
              activeIcon: const Icon(LucideIcons.brain, size: 22),
              label: '',
            ),
            BottomNavigationBarItem(
              icon: const Icon(LucideIcons.chartColumnBig, size: 22),
              activeIcon: const Icon(LucideIcons.chartColumnBig, size: 22),
              label: '',
            ),
            BottomNavigationBarItem(
              icon: const Icon(LucideIcons.user, size: 22),
              activeIcon: const Icon(LucideIcons.user, size: 22),
              label: '',
            ),
          ],
        ),
      ),
    );
  }
}

