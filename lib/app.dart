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
        fontFamily: 'Outfit',
        scaffoldBackgroundColor: AppColors.background,
      ),
      home: SplashScreen(),
    );
  }
}
