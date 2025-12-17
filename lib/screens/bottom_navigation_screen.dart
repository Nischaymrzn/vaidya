import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:vaidya/screens/bottom_screen/assistant.dart';
import 'package:vaidya/screens/bottom_screen/insights.dart';
import 'package:vaidya/screens/bottom_screen/profile.dart';
import 'package:vaidya/screens/bottom_screen/records_screen.dart';
import 'package:vaidya/screens/home_screen.dart';
import 'package:vaidya/themes/colors.dart';

class BottomNavigationScreen extends StatefulWidget {
  const BottomNavigationScreen({super.key});

  @override
  State<BottomNavigationScreen> createState() => _BottomNavigationScreenState();
}

class _BottomNavigationScreenState extends State<BottomNavigationScreen> {
  int _selectedIndex = 0;

  final List<Widget> _screens = const [
    HomeScreen(),
    RecordsScreen(),
    AssistantScreen(),
    InsightsScreen(),
    ProfileScreen(),
  ];

  /// Custom widget to render SVG icons
  Widget _navIcon(String path, Color color, {double size = 28}) {
    return SvgPicture.asset(
      path,
      width: size,
      height: size,
      colorFilter: ColorFilter.mode(color, BlendMode.srcIn),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_selectedIndex],
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          border: Border(
            top: BorderSide(color: AppColors.border, width: 0.5), // top border
          ),
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
              icon: Icon(Icons.home, size: 30, color: AppColors.isNotActiveNav),
              activeIcon: Icon(
                Icons.home,
                size: 28,
                color: AppColors.activeNav,
              ),
              label: 'Home',
            ),
            BottomNavigationBarItem(
              icon: _navIcon(
                'assets/icons/health.svg',
                AppColors.isNotActiveNav,
                size: 28,
              ),
              activeIcon: _navIcon(
                'assets/icons/health.svg',
                AppColors.activeNav,
                size: 28,
              ),
              label: 'Records',
            ),
            BottomNavigationBarItem(
              icon: Icon(
                Icons.smart_toy_outlined,
                size: 28,
                color: AppColors.isNotActiveNav,
              ),
              activeIcon: Icon(
                Icons.smart_toy_outlined,
                size: 28,
                color: AppColors.activeNav,
              ),
              label: 'Assistant',
            ),
            BottomNavigationBarItem(
              icon: _navIcon(
                'assets/icons/insights.svg',
                AppColors.isNotActiveNav,
                size: 30,
              ),
              activeIcon: _navIcon(
                'assets/icons/insights.svg',
                AppColors.activeNav,
                size: 30,
              ),
              label: 'Insights',
            ),
            BottomNavigationBarItem(
              icon: _navIcon(
                'assets/icons/profile_2.svg',
                AppColors.isNotActiveNav,
                size: 30,
              ),
              activeIcon: _navIcon(
                'assets/icons/profile_2.svg',
                AppColors.activeNav,
                size: 30,
              ),
              label: 'Profile',
            ),
          ],
        ),
      ),
    );
  }
}
