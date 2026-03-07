import 'package:flutter/material.dart';
import 'package:vaidya/features/splash/presentation/pages/splash_screen.dart';
import 'package:vaidya/themes/colors.dart';

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    final urbanistTheme = ThemeData(
      brightness: Brightness.light,
      fontFamily: 'Urbanist',
    );
    final appTextTheme = urbanistTheme.textTheme.apply(
      bodyColor: AppColors.textPrimary,
      displayColor: AppColors.textPrimary,
    );

    return MaterialApp(
      title: 'Vaidya.ai',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.light,
        fontFamily: 'Urbanist',
        textTheme: appTextTheme,
        primaryTextTheme: urbanistTheme.primaryTextTheme.apply(
          bodyColor: AppColors.textPrimary,
          displayColor: AppColors.textPrimary,
        ),
        scaffoldBackgroundColor: AppColors.background,
        bottomNavigationBarTheme: const BottomNavigationBarThemeData(
          selectedLabelStyle: TextStyle(
            fontWeight: FontWeight.w500,
          ),
          unselectedLabelStyle: TextStyle(
            fontWeight: FontWeight.w400,
          ),
        ),
      ),
      home: SplashScreen(),
    );
  }
}
