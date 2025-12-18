import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:vaidya/screens/bottom_screen/assistant.dart';
import 'package:vaidya/screens/bottom_screen/insights.dart';
import 'package:vaidya/screens/bottom_screen/profile.dart';
import 'package:vaidya/screens/bottom_screen/records_screen.dart';
import 'package:vaidya/screens/bottom_screen/home/home_screen.dart';
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
