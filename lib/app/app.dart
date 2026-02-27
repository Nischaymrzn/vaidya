import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vaidya/core/services/storage/light_sensor_theme_controller.dart';
import 'package:vaidya/core/services/storage/theme_mode_controller.dart';
import 'package:vaidya/core/widgets/global_fall_detection_listener.dart';
import 'package:vaidya/features/splash/presentation/pages/splash_screen.dart';
import 'package:vaidya/themes/colors.dart';

class App extends ConsumerWidget {
  const App({super.key});
  static final GlobalKey<NavigatorState> _rootNavigatorKey =
      GlobalKey<NavigatorState>();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedThemeMode = ref.watch(themeModeControllerProvider);
    final lightSensorTheme = ref.watch(lightSensorThemeControllerProvider);
    final appThemeMode = switch (selectedThemeMode) {
      AppThemeMode.light => ThemeMode.light,
      AppThemeMode.dark => ThemeMode.dark,
      AppThemeMode.system => ThemeMode.system,
      AppThemeMode.autoLux =>
        lightSensorTheme.sensorAvailable
            ? (lightSensorTheme.brightness == Brightness.dark
                  ? ThemeMode.dark
                  : ThemeMode.light)
            : ThemeMode.system,
    };

    const lightBackground = Color(0xFFF8FAFC);
    const lightCard = Color(0xFFFFFFFF);
    const lightTextPrimary = Color(0xFF0F172A);
    const lightTextSecondary = Color(0xFF64748B);
    const lightBorder = Color(0xFFE2E8F0);

    const darkBackground = Color(0xFF09090B);
    const darkCard = Color(0xFF18181B);
    const darkTextPrimary = Color(0xFFF8FAFC);
    const darkTextSecondary = Color(0xFF94A3B8);
    const darkBorder = Color(0xFF27272A);

    final urbanistTheme = ThemeData(
      brightness: Brightness.light,
      fontFamily: 'Urbanist',
    );
    final appTextTheme = urbanistTheme.textTheme.apply(
      bodyColor: lightTextPrimary,
      displayColor: lightTextPrimary,
    );

    final lightScheme = ColorScheme.fromSeed(
      seedColor: AppColors.primary,
      brightness: Brightness.light,
      primary: AppColors.primary,
      secondary: AppColors.primaryMuted,
      surface: lightCard,
      onSurface: lightTextPrimary,
      outline: lightBorder,
    );

    final darkScheme = ColorScheme.fromSeed(
      seedColor: AppColors.primary,
      brightness: Brightness.dark,
      primary: AppColors.primary,
      secondary: AppColors.primaryMuted,
      surface: darkCard,
      onSurface: darkTextPrimary,
      outline: darkBorder,
    );

    return MaterialApp(
      title: 'Vaidya.ai',
      debugShowCheckedModeBanner: false,
      navigatorKey: _rootNavigatorKey,
      themeMode: appThemeMode,
      theme: ThemeData(
        brightness: Brightness.light,
        fontFamily: 'Urbanist',
        colorScheme: lightScheme,
        textTheme: appTextTheme,
        primaryTextTheme: urbanistTheme.primaryTextTheme.apply(
          bodyColor: lightTextPrimary,
          displayColor: lightTextPrimary,
        ),
        scaffoldBackgroundColor: lightBackground,
        appBarTheme: AppBarTheme(
          backgroundColor: lightBackground,
          foregroundColor: lightTextPrimary,
          elevation: 0,
          scrolledUnderElevation: 0,
          systemOverlayStyle: SystemUiOverlayStyle.dark,
        ),
        cardTheme: CardThemeData(
          color: lightCard,
          elevation: 0,
          shape: RoundedRectangleBorder(
            side: BorderSide(color: lightBorder),
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        dividerColor: lightBorder,
        dialogTheme: DialogThemeData(
          backgroundColor: lightCard,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
            side: BorderSide(color: lightBorder),
          ),
        ),
        drawerTheme: DrawerThemeData(
          backgroundColor: lightBackground,
          surfaceTintColor: Colors.transparent,
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: lightCard,
          hintStyle: TextStyle(color: lightTextSecondary),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: lightBorder),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: lightBorder),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: AppColors.primary),
          ),
        ),
        bottomNavigationBarTheme: const BottomNavigationBarThemeData(
          selectedLabelStyle: TextStyle(fontWeight: FontWeight.w500),
          unselectedLabelStyle: TextStyle(fontWeight: FontWeight.w400),
        ),
      ),
      darkTheme: ThemeData(
        brightness: Brightness.dark,
        fontFamily: 'Urbanist',
        colorScheme: darkScheme,
        scaffoldBackgroundColor: darkBackground,
        appBarTheme: AppBarTheme(
          backgroundColor: darkBackground,
          foregroundColor: darkTextPrimary,
          elevation: 0,
          scrolledUnderElevation: 0,
          systemOverlayStyle: SystemUiOverlayStyle.light,
        ),
        cardTheme: CardThemeData(
          color: darkCard,
          elevation: 0,
          shape: RoundedRectangleBorder(
            side: BorderSide(color: darkBorder),
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        dialogTheme: DialogThemeData(
          backgroundColor: darkCard,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
            side: BorderSide(color: darkBorder),
          ),
        ),
        drawerTheme: DrawerThemeData(
          backgroundColor: darkBackground,
          surfaceTintColor: Colors.transparent,
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: darkCard,
          hintStyle: TextStyle(color: darkTextSecondary),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: darkBorder),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: darkBorder),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: AppColors.primary),
          ),
        ),
        cardColor: darkCard,
        dividerColor: darkBorder,
        textTheme:
            ThemeData(
              brightness: Brightness.dark,
              fontFamily: 'Urbanist',
            ).textTheme.apply(
              bodyColor: darkTextPrimary,
              displayColor: darkTextPrimary,
            ),
      ),
      builder: (context, child) {
        final brightness = Theme.of(context).brightness;
        AppColors.sync(brightness);
        final isDark = brightness == Brightness.dark;
        SystemChrome.setSystemUIOverlayStyle(
          SystemUiOverlayStyle(
            statusBarColor: Colors.transparent,
            statusBarIconBrightness: isDark
                ? Brightness.light
                : Brightness.dark,
            statusBarBrightness: isDark ? Brightness.dark : Brightness.light,
            systemNavigationBarColor: AppColors.background,
            systemNavigationBarIconBrightness: isDark
                ? Brightness.light
                : Brightness.dark,
          ),
        );
        return GlobalFallDetectionListener(
          navigatorKey: _rootNavigatorKey,
          child: child ?? const SizedBox.shrink(),
        );
      },
      home: SplashScreen(),
    );
  }
}
