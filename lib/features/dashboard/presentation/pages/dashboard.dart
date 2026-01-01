import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:vaidya/app/theme/colors.dart';
import 'package:vaidya/features/dashboard/presentation/pages/assistant.dart';
import 'package:vaidya/features/dashboard/presentation/pages/home_screen.dart';
import 'package:vaidya/features/dashboard/presentation/pages/insights.dart';
import 'package:vaidya/features/dashboard/presentation/pages/profile.dart';
import 'package:vaidya/features/dashboard/presentation/pages/records_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int _selectedIndex = 0;

  final List<Widget> _screens = const [
    HomeScreen(),
    RecordsScreen(),
    AssistantScreen(),
    InsightsScreen(),
    ProfileScreen(),
  ];

  Widget _navIcon(String path, Color color) {
    return SvgPicture.asset(
      path,
      colorFilter: ColorFilter.mode(color, BlendMode.srcIn),
    );
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
          selectedLabelStyle: const TextStyle(fontWeight: FontWeight.w600),
          unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.w500),
          onTap: (index) => setState(() => _selectedIndex = index),
          items: [
            BottomNavigationBarItem(
              icon: _navIcon('assets/icons/home.svg', AppColors.isNotActiveNav),
              activeIcon: _navIcon(
                'assets/icons/home.svg',
                AppColors.activeNav,
              ),
              label: 'Home',
            ),
            BottomNavigationBarItem(
              icon: _navIcon(
                'assets/icons/record.svg',
                AppColors.isNotActiveNav,
              ),
              activeIcon: _navIcon(
                'assets/icons/record.svg',
                AppColors.activeNav,
              ),
              label: 'Records',
            ),
            BottomNavigationBarItem(
              icon: _navIcon(
                'assets/icons/assistant.svg',
                AppColors.isNotActiveNav,
              ),
              activeIcon: _navIcon(
                'assets/icons/assistant.svg',
                AppColors.activeNav,
              ),
              label: 'Assistant',
            ),
            BottomNavigationBarItem(
              icon: _navIcon(
                'assets/icons/insights.svg',
                AppColors.isNotActiveNav,
              ),
              activeIcon: _navIcon(
                'assets/icons/insights.svg',
                AppColors.activeNav,
              ),
              label: 'Insights',
            ),
            BottomNavigationBarItem(
              icon: _navIcon('assets/icons/user.svg', AppColors.isNotActiveNav),
              activeIcon: _navIcon(
                'assets/icons/user.svg',
                AppColors.activeNav,
              ),
              label: 'Profile',
            ),
          ],
        ),
      ),
    );
  }
}
