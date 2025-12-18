import 'package:flutter/material.dart';
import 'package:vaidya/screens/splash_screen.dart';
import 'package:vaidya/themes/colors.dart';

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Vaidya.ai',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        fontFamily: 'Urbanist',
        scaffoldBackgroundColor: AppColors.background,

        textTheme: const TextTheme(
          titleLarge: TextStyle(
            color: AppColors.textPrimary,
            fontSize: 22,
            fontWeight: FontWeight.w500,
            fontFamily: 'Urbanist',
          ),
        ),
      ),
      home: SplashScreen(),
    );
  }
}
