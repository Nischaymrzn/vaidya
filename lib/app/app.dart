import 'package:flutter/material.dart';
import 'package:vaidya/features/splash/presentation/pages/splash_screen.dart';
import 'package:vaidya/themes/colors.dart';

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    final baseTheme = ThemeData.light();

    return MaterialApp(
      title: 'Vaidya.ai',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        fontFamily: 'Urbanist',
        scaffoldBackgroundColor: AppColors.background,
        textTheme: baseTheme.textTheme.apply(
          fontFamily: 'Urbanist',
          bodyColor: AppColors.textPrimary,
          displayColor: AppColors.textPrimary,
        ),
        primaryTextTheme: baseTheme.primaryTextTheme.apply(
          fontFamily: 'Urbanist',
        ),
        bottomNavigationBarTheme: const BottomNavigationBarThemeData(
          selectedLabelStyle: TextStyle(
            fontFamily: 'Urbanist',
            fontWeight: FontWeight.w500,
          ),
          unselectedLabelStyle: TextStyle(
            fontFamily: 'Urbanist',
            fontWeight: FontWeight.w400,
          ),
        ),
      ),
      home: SplashScreen(),
    );
  }
}
